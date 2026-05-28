#cloud-config

# set the hostname
fqdn: ${hostname}

ssh_pwauth: true
chpasswd:
  expire: false
  users:
  - name: ${bastion_vm_username}
    password: ${bastion_vm_password} # Recommended to change the password or update the script to use SSH keys
    type: text
packages:
- python3-pip
bootcmd:
- mkdir -p /etc/docker
write_files:
- content: |
    {
      "registry-mirrors": ["${registry_mirror_full}"],
      "insecure-registries": ["${registry_host}"]
    }
  path: /etc/docker/daemon.json
runcmd:
- systemctl daemon-reload
- systemctl restart docker
