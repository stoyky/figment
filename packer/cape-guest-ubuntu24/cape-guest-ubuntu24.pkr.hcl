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

variable "mac_hostonly_qemu" {
  type = string
}

variable "mac_nat_qemu" {
  type = string
}


variable "cpus" {
  type = number
}

variable "memory" {
  type = number
}

variable "disk_size" {
  type = number
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

variable "vm_name" {
  type = string
}

variable "display_name" {
  type = string
}

variable "cape_commit" {
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

variable "hostonly_ip" {
  type = string
}


source "qemu" "cape-guest-ubuntu24" {
  iso_url          = var.source_path_vmware_raw
  iso_checksum     = "SHA256:3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e"
  shutdown_command = "sudo shutdown -h now"
  disk_size        = var.disk_size
  memory           = var.memory
  format           = "qcow2"
  accelerator      = "kvm"
  machine_type     = "q35"
  cpus             = var.cpus
  output_directory = "temp/cape-guest-ubuntu24-qemu"
  boot_command = [
    "<wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net;s=file:///cdrom/",
    "<f10>"
  ]

  cd_files = [
    "packer/cape-guest-ubuntu24/cloud-init/user-data",
    "packer/cape-guest-ubuntu24/cloud-init/meta-data"
  ]
  cd_label = "cidata"

  qemuargs = [
    ["-cpu", "host"],

    ["-netdev", "user,id=user.0,hostfwd=tcp::{{ .SSHHostPort }}-:22"],
    ["-device", "e1000,netdev=user.0,mac=${var.mac_nat_qemu}"],

    # ["-netdev", "user,id=user.1"],
    # ["-device", "e1000,netdev=user.1,mac=${var.mac_hostonly_qemu}"]

    ["-netdev", "bridge,id=hn1,br=virbr1"],
    ["-device", "e1000,netdev=hn1,mac=${var.mac_hostonly_qemu}"]
  ]

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "4h"
  vm_name      = var.vm_name
  net_device   = "e1000"
  # net_bridge = "virbr0"
  disk_interface = "ide"
}

# source "vmware-iso" "cape-guest-ubuntu24" {
#   cd_files             = ["packer/cape-guest-ubuntu24/cloud-init/user-data", "packer/cape-guest-ubuntu24/cloud-init/meta-data"]
#   cd_label             = "cidata"
#   output_directory     = "temp/cape-guest-ubuntu24"
#   iso_url              = var.source_path_vmware_raw
#   iso_checksum         = "SHA256:3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e"
#   vm_name              = var.vm_name
#   display_name         = var.display_name
#   ssh_username         = var.ssh_username
#   ssh_password         = var.ssh_password
#   ssh_timeout          = var.ssh_timeout
#   network_adapter_type = "e1000"
#   disk_size            = 60000
#   memory               = 4096
#   cpus                 = 2
#   # keep_registered = true

#   vhv_enabled      = true
#   shutdown_timeout = "30m"
#   shutdown_command = "sudo shutdown -h now"
#   boot_wait        = "5s"
#   boot_command = [
#     "<wait>",
#     "e<wait>",
#     "<down><down><down><end>",
#     " autoinstall ds=nocloud-net;s=file:///cdrom/",
#     "<f10>"
#   ]

#   vmx_remove_ethernet_interfaces = false
#   skip_compaction                = true
#   headless                       = false

#   vmx_data = {
#     "ide1:0.present"        = "TRUE"
#     "ide1:0.startConnected" = "TRUE"

#     # "ethernet1.present"        = "TRUE"
#     # "ethernet1.connectionType" = "hostonly"
#     # "ethernet1.pcislotnumber"  = var.eth1_pcislot_vmware
#     # "ethernet1.virtualDev"     = "e1000"
#   }

# }

# source "vmware-iso" "cape-guest-ubuntu24" {
#   format        = "ova"
#   guest_os_type = "ubuntu-64"
#   cd_files      = ["packer/cape-guest-ubuntu24/cloud-init/user-data", "packer/cape-guest-ubuntu24/cloud-init/meta-data"]
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
    "source.qemu.cape-guest-ubuntu24",
    # "source.virtualbox-ovf.remnux"
  ]


  provisioner "shell" {
    inline = [
      "echo 'Updating and upgrading system packages'",
      "sudo apt update",
      # "sudo apt upgrade -y",
      # "sudo apt install git vim -y",
      # "sudo apt-get remove -y --autoremove gnome-initial-setup",
      # "sudo reboot"
    ]
    expect_disconnect = true
    only              = ["qemu.cape-guest-ubuntu24"]
  }

  provisioner "shell" {
    pause_before = "10s"
    inline = [
      "echo 'Cloning CAPE and running KVM-QEMU installer'",
      "sudo apt install -y git",
      "git clone https://github.com/kevoreilly/CAPEv2.git",
      "cd CAPEv2 && git checkout ${var.cape_commit} && cd installer",
    ]
    expect_disconnect = true
    only              = ["qemu.cape-guest-ubuntu24"]
  }

  provisioner "shell" {
    inline = [
      "echo 'Installing recommended dependencies'",
      "sudo dpkg --add-architecture i386",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip python3-setuptools python3-wheel curl systemtap-runtime",
      "sudo python3 -m pip install --break-system-packages pyinotify Pillow pyscreenshot pyautogui"
    ]
    expect_disconnect = true
    only              = ["qemu.cape-guest-ubuntu24"]
  }


  provisioner "shell" {
    inline = [
      "echo 'Installing CAPE agent systemd service'",
      "sudo tee /etc/systemd/system/cape-agent.service >/dev/null <<'EOF'",
      "[Unit]",
      "Description=CAPE Agent",
      "After=network-online.target",
      "Wants=network-online.target",
      "",
      "[Service]",
      "Type=simple",
      "User=${var.ssh_username}",
      "Group=${var.ssh_username}",
      "WorkingDirectory=/home/${var.ssh_username}/CAPEv2",
      "ExecStart=/usr/bin/python3 -u /home/${var.ssh_username}/CAPEv2/agent/agent.py",
      "Restart=on-failure",
      "RestartSec=5",
      "",
      "[Install]",
      "WantedBy=multi-user.target",
      "EOF",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable cape-agent.service",
      "sudo systemctl start cape-agent.service"
    ]
    only = ["qemu.cape-guest-ubuntu24"]
  }


  # provisioner "shell" {
  #   inline = [
  #     "echo 'Hardcoding static IP configuration for host VM with Netplan'",
  #     "sudo chmod 600 /etc/netplan/*.yaml",
  #     "sudo tee /etc/netplan/50-cloud-init.yaml >/dev/null <<'EOF'",
  #     "network:",
  #     "  version: 2",
  #     "  renderer: NetworkManager",
  #     "  ethernets:",
  #     "    ens${var.eth0_pcislot_vmware}:",
  #     "      dhcp4: false",
  #     "      addresses:",
  #     "        - ${var.server_nat_ip}/24",
  #     "      routes:",
  #     "        - to: default",
  #     "          via: ${var.server_nat_default_gateway}",
  #     "      nameservers:",
  #     "        addresses:",
  #     "          - ${var.server_nat_default_gateway}",
  #     "          - 1.1.1.1",
  #     "EOF",
  #     "sudo netplan generate && sudo netplan apply",
  #     "sudo shutdown -h now"
  #   ]
  #   only = ["vmware-iso.cape-guest-ubuntu24"]
  #   expect_disconnect = true
  # }

  provisioner "shell" {
    inline = [
      "echo 'Hardcoding static IP configuration for host VM with Netplan'",
      "sudo chmod 600 /etc/netplan/*.yaml",
      "sudo tee /etc/netplan/50-cloud-init.yaml >/dev/null <<'EOF'",
      "network:",
      "  version: 2",
      "  renderer: NetworkManager",
      "  ethernets:",
      "    enp0s${var.eth0_pcislot_virtualbox}:",
      "      dhcp4: true",
      "    enp0s${var.eth1_pcislot_virtualbox}:",
      "      addresses: [${var.hostonly_ip}/24]",
      "EOF",
      "sudo netplan generate && sudo netplan try"
    ]
    expect_disconnect = true
    only              = ["qemu.cape-guest-ubuntu24"]
  }

  post-processor "vagrant" {
    keep_input_artifact  = true
    output               = source.type == "vmware-iso" ? "boxes/cape-guest-ubuntu24-vmware.box" : source.type == "virtualbox-iso" ? "boxes/cape-guest-ubuntu24-virtualbox.box" : "boxes/cape-guest-ubuntu24-qemu.box"
    provider_override    = source.type == "vmware-iso" ? "vmware" : source.type == "virtualbox-iso" ? "virtualbox" : "libvirt"
    vagrantfile_template = "vagrant/cape-guest-ubuntu24/Vagrantfile"
    only                 = var.export_vagrant ? ["vmware-iso.cape-guest-ubuntu24", "virtualbox-iso.cape-guest-ubuntu24", "qemu.cape-guest-ubuntu24"] : []
  }
}