packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
    vagrant = {
      version = "~> 1"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variable "source_path_vmware" {
  type = string
}

variable "source_path_qemu" {
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

variable "display_name" {
  type = string
}

variable "mac_nat_vmware" {
  type = string
}

variable "mac_hostonly_vmware" {
  type = string
}

variable "mac_nat_virtualbox" {
  type = string
}

variable "mac_hostonly_virtualbox" {
  type = string
}

variable "mac_nat_virtualbox_norm" {
  type = string
}

variable "mac_hostonly_virtualbox_norm" {
  type = string
}

variable "mac_nat_qemu" {
  type = string
}

variable "mac_hostonly_qemu" {
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

variable "eth0_pcislot_qemu" {
  type = number
}

variable "eth1_pcislot_qemu" {
  type = number
}

variable "export_vagrant" {
  type    = bool
  default = false
}

## VMWare
source "vmware-vmx" "remnux" {
  source_path                    = var.source_path_vmware
  vm_name                        = var.vm_name
  display_name                   = var.display_name
  ssh_username                   = var.ssh_username
  ssh_password                   = var.ssh_password
  ssh_timeout                    = var.ssh_timeout
  guest_os_type                  = "ubuntu-64"
  shutdown_command               = "sudo shutdown -h now"
  vmx_remove_ethernet_interfaces = false
  headless                       = false
  output_directory               = "temp/remnux-vmware"

  boot_wait = var.boot_wait
  boot_command = [
    "<esc><esc><esc><wait>",
    "<wait5>",
    " sudo ssh-keygen -A<enter>",
    "<wait5>",
    "sudo systemctl enable --now ssh<enter>",
    "<wait5>",
    "sudo sed -i 's/ens18/enp0s${var.eth0_pcislot_vmware}/g' /etc/netplan/50-cloud-init.yaml<enter>",
    "<wait5>",
    "sudo netplan apply<enter>"
  ]

  vmx_data = {
      "ethernet1.present"        = "TRUE",
      "ethernet1.addressType"    = "static",
      "ethernet1.connectionType" = "hostonly",
      "ethernet1.virtualDev"     = "e1000",
      "ethernet1.connect"        = "connected",
      "ethernet1.startConnected" = "TRUE",
      "ethernet1.address"        = var.mac_hostonly_vmware,
  }

}

## Virtualbox
source "virtualbox-ovf" "remnux" {
  source_path      = var.source_path_virtualbox
  vm_name          = var.vm_name
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = var.ssh_timeout
  skip_export      = false
  shutdown_command = "sudo shutdown -h now"
  headless         = false
  output_directory = "temp/remnux-virtualbox"

  boot_wait = var.boot_wait
  boot_command = [
    "<esc><esc><esc><wait>",
    "<wait5>",
    " sudo ssh-keygen -A<enter>",
    "<wait5>",
    "sudo systemctl enable --now ssh<enter>",
    "<wait5>",
    "sudo sed -i 's/ens18/enp0s${var.eth0_pcislot_virtualbox}/g' /etc/netplan/50-cloud-init.yaml<enter>",
    "<wait5>",
    "sudo netplan apply<enter>"
  ]

  vboxmanage = [
    ["modifyvm", "${var.vm_name}", "--nic2", "hostonly"],
    ["modifyvm", "${var.vm_name}", "--hostonlyadapter2", "vboxnet0"],
    ["modifyvm", "${var.vm_name}", "--macaddress2", "${var.mac_hostonly_virtualbox}"]
  ]
}

source "qemu" "remnux" {
  iso_url          = var.source_path_qemu
  iso_checksum     = "SHA256:95adcfd293b29aee77c0c95b2d0a9a7f8f2f7829c49f20b3def16b5b28638e93"
  disk_image       = true
  shutdown_command = "sudo shutdown -h now"
  format           = "qcow2"
  accelerator      = "kvm"
  machine_type     = "q35"
  output_directory = "temp/remnux-qemu"
  skip_resize_disk = true
  memory           = 2048
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = "4h"
  vm_name          = var.vm_name
  net_device       = "e1000"
  disk_interface   = "ide"

  boot_wait = "30s"
  boot_command = [
    "<esc><esc><esc><wait>",
    "<wait5>",
    " sudo ssh-keygen -A<enter>",
    "<wait5>",
    "sudo systemctl enable --now ssh<enter>",
    "<wait5>",
    "sudo sed -i 's/ens18/enp0s${var.eth0_pcislot_qemu}/g' /etc/netplan/50-cloud-init.yaml<enter>",
    "<wait5>",
    "sudo netplan apply<enter>"
  ]

  qemuargs = [
    ["-cpu", "host"],
    
    ["-netdev", "user,id=user.0,hostfwd=tcp::{{ .SSHHostPort }}-:22"],
    ["-device", "e1000,netdev=user.0,mac=${var.mac_nat_qemu}"],

    ["-netdev", "bridge,id=hn1,br=virbr1"],
    ["-device", "e1000,netdev=hn1,mac=${var.mac_hostonly_qemu}"]
  ]
}

build {
  sources = [
    "vmware-vmx.remnux",
    "virtualbox-ovf.remnux",
    "qemu.remnux"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo remnux install --mode=cloud"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo tee /etc/netplan/99-figment.yaml >/dev/null <<EOF",
      "network:",
      "  version: 2",
      "  renderer: NetworkManager",
      "  ethernets:",
      "    nat:",
      "      match:",
      "        macaddress: ${var.mac_nat_vmware}",
      "      dhcp4: true",
      "    hostonly:",
      "      match:",
      "        macaddress: ${var.mac_hostonly_vmware}",
      "      addresses: [${var.hostonly_ip}]",
      "EOF",
    ]
    only = ["vmware-vmx.remnux"]
  }

    provisioner "shell" {
    inline = [
      "sudo tee /etc/netplan/99-figment.yaml >/dev/null <<EOF",
      "network:",
      "  version: 2",
      "  renderer: NetworkManager",
      "  ethernets:",
      "    nat:",
      "      match:",
      "        macaddress: ${var.mac_nat_virtualbox_norm}",
      "      dhcp4: true",
      "    hostonly:",
      "      match:",
      "        macaddress: ${var.mac_hostonly_virtualbox_norm}",
      "      addresses: [${var.hostonly_ip}]",
      "EOF",
    ]
    only = ["virtualbox-ovf.remnux"]
  }

  provisioner "shell" {
    inline = [
      "sudo tee /etc/netplan/99-figment.yaml >/dev/null <<EOF",
      "network:",
      "  version: 2",
      "  renderer: NetworkManager",
      "  ethernets:",
      "    nat:",
      "      match:",
      "        macaddress: ${var.mac_nat_qemu}",
      "      dhcp4: true",
      "    hostonly:",
      "      match:",
      "        macaddress: ${var.mac_hostonly_qemu}",
      "      addresses: [${var.hostonly_ip}]",
      "EOF",
    ]
    only = ["qemu.remnux"]
  }

  provisioner "shell" {
    inline = [
      "sudo chmod 600 /etc/netplan/99-figment.yaml",
      "sudo netplan generate && sudo netplan apply"
    ]
  }

  post-processor "vagrant" {
    keep_input_artifact  = true
    output               = source.type == "vmware-vmx" ? "boxes/remnux-vmware.box" : source.type == "virtualbox-ovf" ? "boxes/remnux-virtualbox.box" : "boxes/remnux-qemu.box"
    provider_override    = source.type == "vmware-vmx" ? "vmware" : source.type == "virtualbox-ovf" ? "virtualbox" : "libvirt"
    vagrantfile_template = "vagrant/remnux/Vagrantfile"
    only                 = var.export_vagrant ? ["vmware-vmx.remnux", "virtualbox-ovf.remnux", "qemu.remnux"] : []
  }
}