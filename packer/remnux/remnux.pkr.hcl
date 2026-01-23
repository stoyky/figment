packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "source_path" {
  type        = string
}

variable "display_name" {
  type        = string
}

variable "ssh_username" {
  type    = string
}

variable "ssh_password" {
  type        = string
  sensitive   = true
}

variable "ssh_timeout" {
  type    = string
}

variable "boot_wait" {
  type    = string
}

variable "hostonly_ip" {
  type    = string
}

variable "ethernet0_pcislotnumber" {
  type    = number
}

variable "ethernet1_pcislotnumber" {
  type    = number
}


source "vmware-vmx" "remnux" {
  source_path  = var.source_path
  display_name = var.display_name
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout

  shutdown_command = "sudo shutdown -h now"
  boot_wait        = var.boot_wait
  boot_command = [
    "sudo systemctl enable ssh --now<enter>"
  ]

  vmx_remove_ethernet_interfaces = false
  skip_compaction                = "true"
  headless                       = false

  vmx_data_post = {
    "ethernet0.present"        = "TRUE"
    "ethernet0.connectionType" = "nat"
    "ethernet0.pcislotnumber"  = var.ethernet0_pcislotnumber # ens160 (Vagrant default)
    "ethernet0.virtualDev"     = "e1000"

    "ethernet1.present"        = "TRUE"
    "ethernet1.connectionType" = "hostonly"
    "ethernet1.pcislotnumber"  = var.ethernet1_pcislotnumber # ens192 (Vagrant adapter 1 default)
    "ethernet1.virtualDev"     = "e1000"
  }

}

build {
  sources = ["source.vmware-vmx.remnux"]

  provisioner "shell" {
    inline = [
      "sudo tee /etc/netplan/99-remnux.yaml >/dev/null <<'EOF'",
      "network:",
      "  version: 2",
      "  renderer: networkd",
      "  ethernets:",
      "    ens${var.ethernet0_pcislotnumber}:",
      "      dhcp4: true",
      "    ens${var.ethernet1_pcislotnumber}:",
      "      addresses: [${var.hostonly_ip}/24]",
      "EOF",
      "sudo netplan generate && sudo netplan apply"
    ]
  }
}