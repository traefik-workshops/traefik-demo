import sys
import os
import re
import argparse
import urllib3
import logging
import time

# Import Nutanix SDKs
import ntnx_vmm_py_client
import ntnx_volumes_py_client
from ntnx_vmm_py_client import ApiClient as VmmApiClient
from ntnx_vmm_py_client import Configuration as VmmConfiguration
from ntnx_volumes_py_client import ApiClient as VolumesApiClient
from ntnx_volumes_py_client import Configuration as VolumesConfiguration

# Suppress warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Setup basic logging
logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger()

def get_env_var(name):
    value = os.getenv(name)
    if not value:
        logger.error(f"Error: Environment variable {name} is not set.")
        sys.exit(1)
    return value

# Configuration
PC_IP = get_env_var("NUTANIX_ENDPOINT")
PC_PORT = os.getenv("NUTANIX_PORT", "9440")
PC_USERNAME = get_env_var("NUTANIX_USERNAME")
PC_PASSWORD = get_env_var("NUTANIX_PASSWORD")

def get_vmm_client():
    config = VmmConfiguration()
    config.host = PC_IP
    config.port = PC_PORT
    config.username = PC_USERNAME
    config.password = PC_PASSWORD
    config.verify_ssl = False
    return VmmApiClient(configuration=config)

def get_volumes_client():
    config = VolumesConfiguration()
    config.host = PC_IP
    config.port = PC_PORT
    config.username = PC_USERNAME
    config.password = PC_PASSWORD
    config.verify_ssl = False
    return VolumesApiClient(configuration=config)

def get_storage_container_id_by_name(client, name):
    api = ntnx_vmm_py_client.StorageContainerApi(api_client=client)
    try:
        response = api.list_storage_containers()
        containers = response.data if response and response.data else []
        for container in containers:
            if container.name == name:
                return container.ext_id
    except Exception as e:
        logger.error(f"Failed to list storage containers: {e}")
        sys.exit(1)
    logger.error(f"Storage container '{name}' not found.")
    sys.exit(1)

def cleanup_volume_groups(dry_run, storage_container_id):
    logger.info("\\n--- Phase 1: Cleaning up Volume Groups ---")
    logger.info(f"Filtering by storage container ID: {storage_container_id}")
    client = get_volumes_client()
    api = ntnx_volumes_py_client.VolumeGroupsApi(api_client=client)

    try:
        # Paginate through ALL VGs - max limit is 100
        vgs = []
        page = 0
        page_size = 100
        while True:
            response = api.list_volume_groups(_limit=page_size, _page=page)
            batch = response.data if response and response.data else []
            vgs.extend(batch)
            if len(batch) < page_size:
                break
            page += 1
        logger.info(f"Fetched {len(vgs)} total Volume Groups")
    except Exception as e:
        logger.error(f"Failed to list volume groups: {e}")
        sys.exit(1)

    # Filter VGs ONLY by storage container - check each VG's disks
    matching_vgs = []
    logger.info("Checking each VG's storage container...")
    for vg in vgs:
        try:
            disks_resp = api.list_volume_disks_by_volume_group_id(vg.ext_id)
            disks = disks_resp.data if disks_resp and disks_resp.data else []
            
            # Include VG if ANY disk is in the target container
            for disk in disks:
                if hasattr(disk, 'storage_container_id') and disk.storage_container_id == storage_container_id:
                    matching_vgs.append(vg)
                    break
        except Exception as disk_err:
            logger.warning(f"Could not check disks for {vg.name}: {disk_err}")
    
    logger.info(f"Found {len(matching_vgs)} matching Volume Groups in nkp-storage container.")

    for vg in matching_vgs:
        logger.info(f"Processing Volume Group: {vg.name} ({vg.ext_id})")
        if dry_run:
            logger.info(f"[DRY RUN] Would detach and delete Volume Group: {vg.name}")
            continue

        try:
            # First, detach from all VMs
            try:
                attachments_resp = api.list_vm_attachments_by_volume_group_id(vg.ext_id)
                attachments = attachments_resp.data if attachments_resp and attachments_resp.data else []
                
                for attachment in attachments:
                    vm_ext_id = attachment.vm_ext_id if hasattr(attachment, 'vm_ext_id') else None
                    if not vm_ext_id and hasattr(attachment, 'ext_id'):
                        vm_ext_id = attachment.ext_id
                    
                    if vm_ext_id:
                        logger.info(f"  Detaching VG from VM {vm_ext_id}...")
                        detach_body = ntnx_volumes_py_client.VmAttachment()
                        detach_body.ext_id = vm_ext_id
                        api.detach_vm(vg.ext_id, detach_body)
                        logger.info(f"  Detached successfully")
            except Exception as detach_err:
                logger.warning(f"  Could not list/detach attachments: {detach_err}")
            
            # Now delete VG
            api.delete_volume_group_by_id(vg.ext_id)
            logger.info(f"Successfully initiated deletion for {vg.name}")
        except Exception as e:
            logger.error(f"Failed to delete Volume Group {vg.name}: {e}")
            sys.exit(1)

def cleanup_vms(dry_run, pattern):
    logger.info("\n--- Phase 2: Cleaning up VMs ---")
    client = get_vmm_client()
    api = ntnx_vmm_py_client.VmApi(api_client=client)
    vm_regex = re.compile(pattern)

    try:
        response = api.list_vms()
        vms = response.data if response and response.data else []
    except Exception as e:
        logger.error(f"Failed to list VMs: {e}")
        sys.exit(1)

    matching_vms = [vm for vm in vms if vm_regex.match(vm.name)]
    logger.info(f"Found {len(matching_vms)} matching VMs.")

    for vm in matching_vms:
        logger.info(f"Processing VM: {vm.name} ({vm.ext_id})")
        if dry_run:
            logger.info(f"[DRY RUN] Would power off and delete VM: {vm.name}")
            continue

        max_retries = 5
        for attempt in range(max_retries):
            try:
                # Fetch VM to get fresh ETag and current state
                single_vm_resp = api.get_vm_by_id(vm.ext_id)
                vm_data = single_vm_resp.data
                etag = None
                if hasattr(vm_data, '_reserved') and vm_data._reserved:
                    etag = vm_data._reserved.get('ETag')
                
                # Force power off first if VM is ON
                power_state = vm_data.power_state if hasattr(vm_data, 'power_state') else None
                if power_state and str(power_state).upper() != 'OFF':
                    logger.info(f"  Powering off VM (current state: {power_state})...")
                    try:
                        if etag:
                            client.add_default_header('If-Match', etag)
                        api.power_off_vm(vm.ext_id)
                        logger.info(f"  Power off initiated, waiting 10s...")
                        time.sleep(10)
                        # Refresh ETag after power off
                        single_vm_resp = api.get_vm_by_id(vm.ext_id)
                        vm_data = single_vm_resp.data
                        if hasattr(vm_data, '_reserved') and vm_data._reserved:
                            etag = vm_data._reserved.get('ETag')
                    except Exception as power_err:
                        logger.warning(f"  Power off failed: {power_err}")
                
                if etag:
                    client.add_default_header('If-Match', etag)
                
                api.delete_vm_by_id(vm.ext_id)
                logger.info(f"Successfully initiated deletion for {vm.name}")
                
                # Remove header for next iteration
                if hasattr(client, '_ApiClient__default_headers') and 'If-Match' in client._ApiClient__default_headers:
                    del client._ApiClient__default_headers['If-Match']
                
                # Success - break retry loop
                break

            except Exception as e:
                # Cleanup headers
                if hasattr(client, '_ApiClient__default_headers') and 'If-Match' in client._ApiClient__default_headers:
                    del client._ApiClient__default_headers['If-Match']

                if attempt < max_retries - 1:
                    wait_time = (attempt + 1) * 5
                    logger.warning(f"Failed to delete VM {vm.name} (Attempt {attempt+1}/{max_retries}): {e}. Retrying in {wait_time}s...")
                    time.sleep(wait_time)
                else:
                    logger.error(f"Failed to delete VM {vm.name} after {max_retries} attempts: {e}")
                    sys.exit(1)

def get_storage_container_id(container_name):
    """Look up storage container ID by name using v2 API"""
    import requests
    url = f"https://{PC_IP}:{PC_PORT}/PrismGateway/services/rest/v2.0/storage_containers"
    try:
        response = requests.get(url, auth=(PC_USERNAME, PC_PASSWORD), verify=False)
        response.raise_for_status()
        data = response.json()
        for container in data.get('entities', []):
            if container.get('name') == container_name:
                return container.get('storage_container_uuid')
    except Exception as e:
        logger.error(f"Failed to lookup storage container '{container_name}': {e}")
        sys.exit(1)
    
    logger.error(f"Storage container '{container_name}' not found.")
    sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Cleanup Nutanix NKP Resources using SDK")
    parser.add_argument("--dry-run", action="store_true", help="Simulate deletion")
    parser.add_argument("--vm-pattern", default=".*(nkp|nai|transit)-cluster.*", help="Regex for VMs")
    parser.add_argument("--vg-pattern", default=".*pvc-.*", help="Regex for Volume Groups")
    parser.add_argument("--storage-container", default="nkp-storage", help="Storage container name to filter VGs")

    args = parser.parse_args()

    print(f"Connecting to {PC_IP}...")
    
    # Look up storage container ID by name
    storage_container_id = get_storage_container_id(args.storage_container)
    logger.info(f"Using storage container '{args.storage_container}' (ID: {storage_container_id})")
    
    # Order: VGs FIRST, then VMs.
    cleanup_volume_groups(args.dry_run, storage_container_id)
    cleanup_vms(args.dry_run, args.vm_pattern)
    
    logger.info("\nCleanup sequence completed successfully.")

if __name__ == "__main__":
    main()
