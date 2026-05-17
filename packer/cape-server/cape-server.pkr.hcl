packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = "~> 2"
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

variable "export_vagrant" {
  type    = bool
  default = false
}

# source "null" "cape-server" {
#   communicator = "none"
# }


source "vmware-iso" "cape-server" {
  format        = "ova"
  guest_os_type = "ubuntu-64"
  cd_files      = ["packer/cape-server/cloud-init/user-data", "packer/cape-server/cloud-init/meta-data"]
  cd_label      = "cidata"

  iso_url       = var.source_path_vmware_raw
  iso_checksum  = "SHA256:3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e"
  vm_name       = var.vm_name
  display_name  = var.display_name
  ssh_username  = var.ssh_username
  ssh_password  = var.ssh_password
  ssh_timeout   = var.ssh_timeout
  network_adapter_type = "e1000"

  # keep_registered = true

  shutdown_command = "sudo shutdown -h now"
  boot_wait        = "5s"
  boot_command = [
    "<wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net;s=file:///cdrom/",
    "<f10>"
  ]

  # vmx_remove_ethernet_interfaces = false
  # skip_compaction                = true
  # headless                       = false

  vmx_data = {
    "memsize"              = "8192"
    "numvcpus"             = "4"

    "ide1:0.present"        = "TRUE"
    "ide1:0.startConnected" = "TRUE"
    "vhv.enable"            = "TRUE"
  }

  # vmx_data = {
  #   "ethernet1.present"        = "TRUE"
  #   "ethernet1.connectionType" = "hostonly"
  #   "ethernet1.pcislotnumber"  = var.eth1_pcislot_vmware
  #   "ethernet1.virtualDev"     = "e1000"
  # }

}

# source "vmware-iso" "cape-server" {
#   format        = "ova"
#   guest_os_type = "ubuntu-64"
#   cd_files      = ["packer/cape-server/cloud-init/user-data", "packer/cape-server/cloud-init/meta-data"]
#   cd_label      = "cidata"
#   source_path   = var.source_path_vmware_raw
#   vm_name       = var.vm_name
#   display_name  = var.display_name
#   ssh_username  = var.ssh_username
#   ssh_password  = var.ssh_password
#   ssh_timeout   = var.ssh_timeout
#   disk_additional_size = [10240]

#   # keep_registered = true

#   shutdown_command = "sudo shutdown -h now"
#   boot_wait        = var.boot_wait

#   # vmx_remove_ethernet_interfaces = false
#   # skip_compaction                = true
#   # headless                       = false

#   vmx_data = {
#     "memsize"              = "8192"
#     "numvcpus"             = "4"

#     "ide1:0.present"        = "TRUE"
#     "ide1:0.startConnected" = "TRUE"
#     "vhv.enable"            = "TRUE"
#   }

#   # vmx_data = {
#   #   "ethernet1.present"        = "TRUE"
#   #   "ethernet1.connectionType" = "hostonly"
#   #   "ethernet1.pcislotnumber"  = var.eth1_pcislot_vmware
#   #   "ethernet1.virtualDev"     = "e1000"
#   # }

# }


## Virtualbox
# source "virtualbox-ovf" "remnux" {
#   source_path = var.source_path_virtualbox

#   vm_name          = var.vm_name
#   ssh_username     = var.ssh_username
#   ssh_password     = var.ssh_password
#   ssh_timeout      = var.ssh_timeout
#   skip_export      = false
#   keep_registered  = true
#   shutdown_command = "sudo shutdown -h now"

#   headless = false

#   vboxmanage_post = [
#     ["modifyvm", "${var.vm_name}", "--nic2", "hostonly"],
#     ["modifyvm", "${var.vm_name}", "--hostonlyadapter2", "vboxnet0"],
#     ["modifyvm", "${var.vm_name}", "--macaddress2", "${var.mac_hostonly}"]
#   ]
# }

build {
  sources = [
    # "source.null.cape-server",
    "source.vmware-iso.cape-server",
    # "source.virtualbox-ovf.remnux"
  ]

  # provisioner "shell" {
  #   inline = [
  #     "echo 'Waiting for cloud-init to finish...'",
  #     "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done",
  #     "echo 'Cloud-init finished!'"
  #   ]
  #   only = ["vmware-iso.cape-server"]
  # }
  
  provisioner "shell" {
    inline = [
      "echo 'Starting TO DO STUFF'",
      "sudo apt update",
      "sudo apt upgrade -y",
      # "sudo apt install ubuntu-desktop -y",
      "sudo reboot"
    ]
    expect_disconnect = true
    only = ["vmware-iso.cape-server"]
  }

  # provisioner "shell" {
  #   pause_before = "10s"
  #   inline = [
  #     "echo 'Cloning CAPE'",
  #     "git clone https://github.com/kevoreilly/CAPEv2",
  #     "cd CAPEv2/installer",
  #     "sed -i 's/<WOOT>/ACPI/g' kvm-qemu.sh",
  #     "sudo ./kvm-qemu.sh all ${var.ssh_username} | tee kvm-qemu.log",
  #     "sudo reboot",
  #   ]
  #   expect_disconnect = true
  #   only = ["vmware-iso.cape-server"]
  # }

  # provisioner "shell" {
  #   pause_before = "10s"
  #   inline = [
  #     "cd CAPEv2/installer",
  #     "sudo ./cape2.sh all ${var.ssh_username} | tee cape.log",
  #     "sudo reboot",
  #   ]
  #   expect_disconnect = true
  #   only = ["vmware-iso.cape-server"]
  # }

  # provisioner "shell" {
  #   pause_before = "10s"
  #   inline = [
  #     "cd /opt/CAPEv2/",
  #     "poetry install",
  #     "sudo reboot"
  #   ]
  #   expect_disconnect = true
  #   only = ["vmware-iso.cape-server"]
  # }

  # provisioner "shell" {
  #   pause_before = "10s"
  #   inline = [
  #     "sudo apt install ubuntu-desktop -y",
  #     "sudo reboot"
  #   ]
  #   expect_disconnect = true
  #   only = ["vmware-iso.cape-server"]
  # }

  # provisioner "shell-local" {
  #   inline = [
  #     "ovftool -n=${var.vm_name} ${var.source_path_vmware_raw} temp/"
  #   ]
  #   only = ["null.cape-server"]
  # }

  # provisioner "shell" {
  #   inline = [
  #     "sudo remnux install --mode=cloud"
  #   ]
  #   only = ["vmware-iso.remnux", "virtualbox-ovf.remnux"]
  # }

  # provisioner "shell" {
  #   inline = [
  #     "sudo tee /etc/netplan/99-remnux.yaml >/dev/null <<'EOF'",
  #     "network:",
  #     "  version: 2",
  #     "  renderer: networkd",
  #     "  ethernets:",
  #     "    ens${var.eth0_pcislot_vmware}:",
  #     "      dhcp4: true",
  #     "    ens${var.eth1_pcislot_vmware}:",
  #     "      addresses: [${var.hostonly_ip}/24]",
  #     "EOF",
  #     "sudo chmod 600 /etc/netplan/99-remnux.yaml",
  #     "sudo netplan generate && sudo netplan apply"
  #   ]
  #   only = ["vmware-iso.remnux"]
  # }

  # provisioner "shell" {
  #   inline = [
  #     "sudo tee /etc/netplan/99-remnux.yaml >/dev/null <<'EOF'",
  #     "network:",
  #     "  version: 2",
  #     "  renderer: networkd",
  #     "  ethernets:",
  #     "    enp0s${var.eth0_pcislot_virtualbox}:",
  #     "      dhcp4: true",
  #     "    enp0s${var.eth1_pcislot_virtualbox}:",
  #     "      addresses: [${var.hostonly_ip}/24]",
  #     "EOF",
  #     "sudo chmod 600 /etc/netplan/99-remnux.yaml",
  #     "sudo netplan generate && sudo netplan apply"
  #   ]
  #   only = ["virtualbox-ovf.remnux"]
  # }

  # post-processor "vagrant" {
  #   output               = source.type == "vmware-iso" ? "boxes/remnux-vmware.box" : "boxes/remnux-virtualbox.box"
  #   keep_input_artifact  = true
  #   provider_override    = source.type == "vmware-iso" ? "vmware" : "virtualbox"
  #   vagrantfile_template = "vagrant/remnux/Vagrantfile"
  #   only                 = var.export_vagrant ? ["vmware-iso.remnux", "virtualbox-ovf.remnux"] : []
  # }
}