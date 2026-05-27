locals {
  arch           = "amd64"
  image_filename = "nkp-registry-${local.arch}.qcow2"
}

resource "terraform_data" "build_registry_image" {
  triggers_replace = [
    fileexists("${path.module}/packer/images/${local.image_filename}"),
    filesha256("${path.module}/packer/registry.pkr.hcl")
  ]

  provisioner "local-exec" {
    command = <<EOT
      set -e
      cd ${path.module}/packer
      if [ ! -f images/${local.image_filename} ]; then
        BUNDLE_PATH=$(eval echo ${abspath(var.nkp_bundle_path)})
        echo "Extracting NKP binary from $BUNDLE_PATH..."
        rm -rf bin
        mkdir -p bin
        tar -xzf "$BUNDLE_PATH" -C bin --strip-components=2 nkp-v${var.nkp_version}/cli/nkp

        packer init registry.pkr.hcl
        packer build \
          -force \
          -var "nkp_version=${var.nkp_version}" \
          -var "nkp_bundle_path=$BUNDLE_PATH" \
          -var "arch=${local.arch}" \
          registry.pkr.hcl
      fi
    EOT
  }
}

resource "nutanix_image" "nkp_registry" {
  name        = local.image_filename
  source_path = "${path.module}/packer/images/${local.image_filename}"
  description = "NKP Registry Image"

  depends_on = [terraform_data.build_registry_image]
}
