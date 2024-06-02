packer {
  required_plugins {
    googlecompute = {
      version = " >= 1.0.0 "
      source  = "github.com/hashicorp/googlecompute"
    }
    ansible = {
      version = ">= 1.0.0"
      source = "github.com/hashicorp/ansible"
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

variable "enable_node_exporter" {
  type        = bool
  description = "Enable Node Exporter installation"
  default     = false
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
  image_family        = "aya-base-image"
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
    ]
    execute_command = "/usr/bin/cloud-init status --wait && sudo -E -S sh '{{ .Path }}'" # This is added to mitigate potential race conditions with cloud-init
  }

  # Run Ansible Playbook for AYA Node
  provisioner "ansible" {
    playbook_file = "../ansible/aya-node-playbook.yml"
    extra_arguments = [ "--scp-extra-args", "'-O'" ]
  }

  # Conditionally run the playbook to install Node Exporter
  provisioner "ansible" {
    playbook_file = "../ansible/node_exporter-playbook.yml"
    extra_arguments = [ "--extra-vars", "enable_node_exporter=${var.enable_node_exporter}","--scp-extra-args", "'-O'" ]
  }

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "echo 'version: 1' > /home/aya/iso_image_version.yaml",
      "echo 'timestamp: ${local.timestamp_qualifier}' >> /home/aya/iso_image_version.yaml",
    ]
  }

}
# run: packer build -var 'gcp_project_id=YOUR_GCP_PROJECT_ID' -var 'gcp_zone=YOUR_GCP_ZONE' aya-base-image.pkr.hcl
