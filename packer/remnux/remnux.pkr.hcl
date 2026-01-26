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

variable "source_path_vmware" {
  type = string
}

variable "source_path_virtualbox" {
  type = string
}

variable "ssh_username" {
  type = string
}

variable "ssh_password" {
  type      = string
  sensitive = true
}

variable "ssh_timeout" {
  type = string
}

variable "boot_wait" {
  type = string
}

variable "hostonly_ip" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "mac_nat" {
  type = string
}

variable "mac_hostonly" {
  type = string
}


variable "eth0_pcislot_vmware" {
  type = number
}

variable "eth1_pcislot_vmware" {
  type = number
}

variable "eth0_pcislot_virtualbox" {
  type = number
}

variable "eth1_pcislot_virtualbox" {
  type = number
}


## VMWare
source "vmware-vmx" "remnux" {
  source_path  = var.source_path_vmware
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

## Virtualbox

source "virtualbox-ovf" "remnux" {
  source_path      = var.source_path_virtualbox

  vm_name          = var.vm_name
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = var.ssh_timeout
  skip_export      = true
  keep_registered  = true
  shutdown_command = "sudo shutdown -h now"

  headless = false

  vboxmanage_post = [
    ["modifyvm", "${var.vm_name}", "--nic1", "none"],
    ["modifyvm", "${var.vm_name}", "--nic2", "hostonly"],
    ["modifyvm", "${var.vm_name}", "--hostonlyadapter2", "vboxnet0"],
    ["modifyvm", "${var.vm_name}", "--macaddress2", "${var.mac_hostonly}"]
  ]
}


build {
  sources = [
    "source.vmware-vmx.remnux",
    "source.virtualbox-ovf.remnux"
  ]

  provisioner "shell" {
    inline = [
      "sudo tee /etc/netplan/99-remnux.yaml >/dev/null <<'EOF'",
      "network:",
      "  version: 2",
      "  renderer: networkd",
      "  ethernets:",
      "    ens${var.eth0_pcislot_vmware}:",
      "      dhcp4: true",
      "    ens${var.eth1_pcislot_vmware}:",
      "      addresses: [${var.hostonly_ip}/24]",
      "EOF",
      "sudo chmod 600 /etc/netplan/99-remnux.yaml",
      "sudo netplan generate && sudo netplan apply"
    ]
    only = ["vmware-vmx.remnux"]
  }

  provisioner "shell" {
    inline = [
      "sudo tee /etc/netplan/99-remnux.yaml >/dev/null <<'EOF'",
      "network:",
      "  version: 2",
      "  renderer: networkd",
      "  ethernets:",
      "    enp0s${var.eth0_pcislot_virtualbox}:",
      "      dhcp4: true",
      "    enp0s${var.eth1_pcislot_virtualbox}:",
      "      addresses: [${var.hostonly_ip}/24]",
      "EOF",
      "sudo chmod 600 /etc/netplan/99-remnux.yaml",
      "sudo netplan generate && sudo netplan apply"
    ]
    only = ["virtualbox-ovf.remnux"]
  }
}