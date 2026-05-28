packer {
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "arch" {
  type    = string
  default = "amd64"
}

variable "nkp_version" {
  type    = string
  default = "2.17.1"
}

variable "nkp_bundle_path" {
  type = string
}

locals {
  qemu_binary = {
    "arm64" = "qemu-system-aarch64"
    "amd64" = "qemu-system-x86_64"
  }
  machine_type = {
    "arm64" = "virt"
    "amd64" = "q35"
  }
  cpu_model = {
    "arm64" = "host"
    "amd64" = "qemu64"
  }
  accelerator = {
    "arm64" = "hvf"
    "amd64" = "tcg"
  }
  iso_url = {
    "arm64" = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64.img"
    "amd64" = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
  }
}

source "qemu" "registry" {
  qemu_binary       = local.qemu_binary[var.arch]
  machine_type      = local.machine_type[var.arch]
  cpu_model         = local.cpu_model[var.arch]
  accelerator       = local.accelerator[var.arch]
  headless          = true

  iso_url           = local.iso_url[var.arch]
  iso_checksum      = "file:https://cloud-images.ubuntu.com/releases/24.04/release/SHA256SUMS"
  output_directory  = "images"
  shutdown_command  = "sudo shutdown -P now"
  disk_size         = "100G"
  format            = "qcow2"
  ssh_username      = "traefiker"
  ssh_password      = "topsecretpassword"
  ssh_timeout       = "15m"
  vm_name           = "nkp-registry-${var.arch}.qcow2"
  memory            = 8192
  cpus              = 4
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  disk_image        = true
  use_backing_file  = false

  # Cloud-Init via NoCloud (CD-ROM)
  cd_files = ["scripts/user-data", "scripts/meta-data"]
  cd_label = "cidata"

  boot_wait = "5s"
  boot_command = [
    "<enter><wait>"
  ]
}

build {
  sources = ["source.qemu.registry"]

  # 1. Wait for cloud-init
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
    ]
  }
  
  # Disk expansion for large bundles
  provisioner "shell" {
    inline = [
      "sudo growpart /dev/sda 1 || true",
      "sudo resize2fs /dev/sda1 || true"
    ]
  }

  # 2. Setup Script Upload
  provisioner "shell" {
    inline = ["mkdir -p /tmp/scripts"]
  }

  provisioner "file" {
    source      = "scripts/setup_registry_runtime.sh"
    destination = "/tmp/scripts/setup_registry_runtime.sh"
  }

  # 3. Install Dependencies
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
      # Docker Installation
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
      "sudo usermod -aG docker traefiker",

      # Pre-pull registry:2 so the image is self-sufficient at runtime (no Docker Hub access needed)
      "sudo docker pull registry:2",

      # Kubectl Installation
      "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"",
      "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",
      "rm kubectl"
    ]
  }

  # 4. Upload Bundle (Last step to avoid time waste on failure)
  provisioner "shell" {
    inline = ["sudo mkdir -p /opt/nkp", "sudo chown traefiker:traefiker /opt/nkp"]
  }

  provisioner "file" {
    source      = var.nkp_bundle_path
    destination = "/opt/nkp/nkp-bundle.tar.gz"
  }
}
