locals {
  arch           = "amd64"
  image_filename = "nkp-${local.arch}.qcow2"
}

resource "terraform_data" "build_image" {
  triggers_replace = [
    fileexists("${path.module}/packer/images/${local.image_filename}"),
    filesha256("${path.module}/packer/nkp.pkr.hcl")
  ]

  provisioner "local-exec" {
    command = <<EOT
      set -e
      cd ${path.module}/packer
      if [ ! -f images/${local.image_filename} ]; then
        mkdir -p bin
        if [ -n "${var.nkp_cli_path != null ? var.nkp_cli_path : ""}" ]; then
          echo "Using pre-existing NKP binary from ${var.nkp_cli_path != null ? var.nkp_cli_path : ""}..."
          cp "${var.nkp_cli_path != null ? var.nkp_cli_path : ""}" bin/nkp
        else
          BUNDLE_PATH=$(eval echo ${abspath(var.nkp_bundle_path)})
          echo "Extracting NKP binary from $BUNDLE_PATH..."
          rm -rf bin
          mkdir -p bin
          tar -xzf "$BUNDLE_PATH" -C bin --strip-components=2 nkp-v${var.nkp_version}/cli/nkp
        fi
        
        echo "Building image with Packer..."
        packer init .
        packer build \
          -force \
          -var "nkp_version=${var.nkp_version}" \
          -var "nkp_bundle_path=${var.nkp_bundle_path}" \
          .
      fi
    EOT
  }
}

resource "nutanix_image" "nkp" {
  name        = local.image_filename
  source_path = "${path.module}/packer/images/${local.image_filename}"
  description = "NKP Bastion Image"

  depends_on = [terraform_data.build_image]
}
