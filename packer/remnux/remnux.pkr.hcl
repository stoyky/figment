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

variable "source_path_vmware_raw" {
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

source "null" "remnux" {
  communicator = "none"
}

## VMWare
source "vmware-vmx" "remnux" {
  source_path     = var.source_path_vmware
  vm_name         = var.vm_name
  display_name    = var.display_name
  ssh_username    = var.ssh_username
  ssh_password    = var.ssh_password
  ssh_timeout     = var.ssh_timeout
  keep_registered = true

  shutdown_command = "sudo shutdown -h now"
  boot_wait        = var.boot_wait

  vmx_remove_ethernet_interfaces = false
  skip_compaction                = true
  headless                       = false

  vmx_data = {
    "ethernet1.present"        = "TRUE"
    "ethernet1.connectionType" = "hostonly"
    "ethernet1.pcislotnumber"  = var.eth1_pcislot_vmware
    "ethernet1.virtualDev"     = "e1000"
  }

}

## Virtualbox
source "virtualbox-ovf" "remnux" {
  source_path = var.source_path_virtualbox

  vm_name          = var.vm_name
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = var.ssh_timeout
  skip_export      = false
  keep_registered  = true
  shutdown_command = "sudo shutdown -h now"

  headless = false

  vboxmanage_post = [
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
  
  boot_wait = "30s"
  boot_command = [
    "<esc><esc><esc><wait>",
    "<wait5>",
    " sudo ssh-keygen -A<enter>",
    "<wait5>",
    "sudo systemctl start ssh<enter>",
    "<wait5>",
    "sudo sed -i 's/ens18/enp0s${var.eth0_pcislot_qemu}/g' /etc/netplan/50-cloud-init.yaml<enter>",
    "<wait5>",
    "sudo chmod 600 /etc/netplan/50-cloud-init.yaml<enter>",
    "<wait5>",
    "sudo netplan generate && sudo netplan apply<enter>",
    "<wait5>"
  ]

  qemuargs = [
    ["-cpu", "host"],

    ["-netdev", "user,id=user.0,hostfwd=tcp::{{ .SSHHostPort }}-:22"],
    ["-device", "e1000,netdev=user.0,mac=${var.mac_nat_qemu}"],

    ["-netdev", "bridge,id=hn1,br=virbr1"],
    ["-device", "e1000,netdev=hn1,mac=${var.mac_hostonly_qemu}"]
  ]
  
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "4h"
  vm_name      = var.vm_name
  net_device   = "e1000"
  disk_interface = "ide"
}

build {
  sources = [
    "source.null.remnux",
    "source.vmware-vmx.remnux",
    "source.virtualbox-ovf.remnux",
    "source.qemu.remnux"
  ]

  provisioner "shell-local" {
    inline = [
      "ovftool -n=${var.vm_name} ${var.source_path_vmware_raw} temp/"
    ]
    only = ["null.remnux"]
  }

  provisioner "shell" {
    inline = [
      "sudo remnux install --mode=cloud"
    ]
    only = ["vmware-vmx.remnux", "virtualbox-ovf.remnux", "source.qemu.remnux"]
  }

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
    only = ["virtualbox-ovf.remnux", "source.qemu.remnux"]
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
    only = ["virtualbox-ovf.remnux", "source.qemu.remnux"]
  }

  post-processor "vagrant" {
    keep_input_artifact  = true
    output               = source.type == "vmware-iso" ? "boxes/remnux-vmware.box" : source.type == "virtualbox-iso" ? "boxes/remnux-virtualbox.box" : "boxes/remnux-qemu.box"
    provider_override    = source.type == "vmware-iso" ? "vmware" : source.type == "virtualbox-iso" ? "virtualbox" : "libvirt"
    vagrantfile_template = "vagrant/remnux/Vagrantfile"
    only                 = var.export_vagrant ? ["vmware-iso.remnux", "virtualbox-iso.remnux", "qemu.remnux"] : []
  }
}