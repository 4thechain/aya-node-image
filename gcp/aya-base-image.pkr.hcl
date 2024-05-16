packer {
  required_plugins {
    googlecompute = {
      version = " >= 1.0.0 "
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

variable "gcp_project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "gcp_zone" {
  type        = string
  description = "Google Cloud Zone"
  default     = "europe-west1-b"
}

locals {
  timestamp_qualifier = formatdate("YYYYMMDD-hhmm", timestamp())
}

source "googlecompute" "aya-base-image" {
  project_id          = var.gcp_project_id
  source_image        = "ubuntu-2204-jammy-v20240515"
  ssh_username        = "aya"
  zone                = var.gcp_zone
  image_name          = "aya-base-image-${local.timestamp_qualifier}"
  image_labels = {
    "os" : "ubuntu"
    "application" : "aya"
  }
  use_internal_ip     = false
  metadata = {
    enable-oslogin = false
  }
}

build {
  sources = [
    "source.googlecompute.aya-base-image"
  ]

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt install -y git clang curl libssl-dev llvm libudev-dev make protobuf-compiler pkg-config build-essential jq unzip",
      "echo 'aya ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/aya",
    ]
    execute_command = "/usr/bin/cloud-init status --wait && sudo -E -S sh '{{ .Path }}'" # This is added to mitigate potential race conditions with cloud-init
  }

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "echo 'version: 1' > /home/aya/iso_image_version.yaml",
      "echo 'timestamp: ${local.timestamp_qualifier}' >> /home/aya/iso_image_version.yaml",
      "mkdir -p /home/aya/utils/session_key_tools"
    ]
  }

  provisioner "shell" {
    script = "../common/get_aya_software.sh"
  }

  provisioner "file" {
    source      = "../common/split_session_key.sh"
    destination = "/home/aya/utils/session_key_tools/split_session_key.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x utils/session_key_tools/split_session_key.sh",
      "sudo bash -c \"echo 'export AYA_HOME=/home/aya/aya-node' >> /etc/bash.bashrc\"",
    ]
  }

  provisioner "file" {
    source      = "../common/start_aya_validator.sh"
    destination = "/home/aya/aya-node/start_aya_validator.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /home/aya/aya-node/start_aya_validator.sh",
    ]
  }

  provisioner "file" {
    source      = "../common/aya-node.service"
    destination = "/home/aya/aya-node.service"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /home/aya/aya-node.service /etc/systemd/system/aya-node.service",
      "sudo systemctl enable aya-node.service",
    ]
  }

}
# run: packer build -var 'gcp_project_id=YOUR_GCP_PROJECT_ID' -var 'gcp_zone=YOUR_GCP_ZONE' aya-base-image.pkr.hcl