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

variable "server_nat_ip" {
  type = string
}

variable "server_nat_default_gateway" {
  type = string
}

variable "guest_hostonly_default_gateway" {
  type = string
}

variable "guest_hostonly_range_start" {
  type = string
}

variable "guest_hostonly_range_end" {
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

variable "cape_commit" {
  type    = string
  default = false
}

variable "cape_nested_virt" {
  type    = bool
  default = false
}

variable "cape_guests" {
  type = list(object({
    name         = string
    platform     = string
    arch         = string
    ip_nat       = string
    ip_hostonly  = string
    mac_nat      = string
    mac_hostonly = string
  }))
}

variable "cape_machinery" {
  type    = string
  default = "kvm"
}

locals {
  cape_machines_line = join(", ", [
    for m in var.cape_guests : m.name
  ])

  cape_machine_blocks = join("\n\n", [
    for m in var.cape_guests : <<-EOT
      [${m.name}]
      label = ${m.name}
      platform = ${m.platform}
      ip = ${m.ip_hostonly}
      arch = ${m.arch}
    EOT
  ])
}

source "vmware-iso" "cape-server" {
  cd_files             = ["packer/cape-server/cloud-init/user-data", "packer/cape-server/cloud-init/meta-data"]
  cd_label             = "cidata"
  output_directory     = "temp/cape-server"
  iso_url              = var.source_path_vmware_raw
  iso_checksum         = "SHA256:3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e"
  vm_name              = var.vm_name
  display_name         = var.display_name
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_timeout          = var.ssh_timeout
  network_adapter_type = "e1000"
  disk_size            = 102400
  memory = 8192
  cpus   = 4
  # keep_registered = true

  vhv_enabled       = true
  shutdown_timeout = "30m"
  shutdown_command = "sudo shutdown -h now"
  boot_wait        = "5s"
  boot_command = [
    "<wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net;s=file:///cdrom/",
    "<f10>"
  ]

  vmx_remove_ethernet_interfaces = false
  skip_compaction                = true
  headless                       = false

  vmx_data = {
    "ide1:0.present"        = "TRUE"
    "ide1:0.startConnected" = "TRUE"

    # "ethernet1.present"        = "TRUE"
    # "ethernet1.connectionType" = "hostonly"
    # "ethernet1.pcislotnumber"  = var.eth1_pcislot_vmware
    # "ethernet1.virtualDev"     = "e1000"
  }

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
    "source.vmware-iso.cape-server",
    # "source.virtualbox-ovf.remnux"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install git vim -y",
      "sudo reboot"
    ]
    expect_disconnect = true
    only              = ["vmware-iso.cape-server"]
  }

  provisioner "shell" {
    pause_before = "10s"
    inline = [
      "echo 'Cloning CAPE and running KVM-QEMU installer'",
      "git clone https://github.com/kevoreilly/CAPEv2.git",
      "cd CAPEv2 && git checkout ${var.cape_commit} && cd installer",
      "sed -i 's/<WOOT>/ACPI/g' kvm-qemu.sh",
      "sudo ./kvm-qemu.sh all ${var.ssh_username} | tee kvm-qemu.log",
      "sudo reboot",
    ]
    expect_disconnect = true
    only              = ["vmware-iso.cape-server"]
  }

  provisioner "shell" {
    pause_before = "10s"
    inline = [
      "echo 'Running CAPE installer'",
      "cd CAPEv2/installer",
      "sudo ./cape2.sh all cape | tee cape.log",
      "sudo reboot",
    ]
    expect_disconnect = true
    only              = ["vmware-iso.cape-server"]
  }

  provisioner "shell" {
    pause_before = "10s"
    inline = [
      "echo 'Performing poetry installation'",
      "cd /opt/CAPEv2/",
      "echo $PATH",
      "sudo -u cape /etc/poetry/bin/poetry install",
    ]
    only = ["vmware-iso.cape-server"]
  }

  # provisioner "file" {
  #   source      = "packer/cape-server/cape-repo/conf/default"
  #   destination = "/tmp/cape-conf"
  # }

  # provisioner "shell" {
  #   inline = [
  #     "for f in /tmp/cape-conf/*.conf.default; do sudo cp \"$f\" \"/opt/CAPEv2/conf/$(basename \"$f\" .default)\"; done"
  #   ]
  # }

  provisioner "shell" {
    inline = var.cape_nested_virt ? [
      "echo 'Installing Vagrant and libvirt dependencies'",
      "wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt update && sudo apt install -y vagrant"
    ] : [
      "echo 'Skipping install of nested-virt guest VMs'"
    ]
  }

  provisioner "shell" {
    inline = var.cape_nested_virt ? [
      "echo 'Creating libvirt hostonly network'",
      "cat > /tmp/hostonly.xml <<'EOF'",
      "<network>",
      "  <name>hostonly</name>",
      "  <bridge name='virbr1' stp='on' delay='0'/>",
      "  <domain name='hostonly'/>",
      "  <ip address='${var.guest_hostonly_default_gateway}' netmask='255.255.255.0'>",
      "    <dhcp>",
      "      <range start='${var.guest_hostonly_range_start}' end='${var.guest_hostonly_range_end}'/>",
      "    </dhcp>",
      "  </ip>",
      "</network>",
      "EOF",
      "virsh -c qemu:///system net-destroy hostonly >/dev/null 2>&1 || true",
      "virsh -c qemu:///system net-undefine hostonly >/dev/null 2>&1 || true",
      "virsh -c qemu:///system net-define /tmp/hostonly.xml",
      "virsh -c qemu:///system net-autostart hostonly",
      "virsh -c qemu:///system net-start hostonly",
      "virsh -c qemu:///system net-list --all"
    ] : [
      "echo 'Skipping libvirt hostonly network creation'"
    ]
    only = ["vmware-iso.cape-server"]
  }

  provisioner "shell" {
    inline = var.cape_nested_virt ? concat(
      ["echo 'Installing nested-virt guest VMs'"],
      flatten([
        for m in var.cape_guests : [
          "vagrant box add figment/${m.name}",

          "virsh -c qemu:///system net-update default add-last ip-dhcp-host \"<host mac='${m.mac_nat}' name='${m.name}-nat' ip='${m.ip_nat}' />\" --live --config --parent-index 0",
          "virsh -c qemu:///system net-update hostonly add-last ip-dhcp-host \"<host mac='${m.mac_hostonly}' name='${m.name}-hostonly' ip='${m.ip_hostonly}' />\" --live --config --parent-index 0",

          "virt-install --connect qemu:///system --noautoconsole --name ${m.name} --import --disk path=\"$HOME/.vagrant.d/boxes/figment-VAGRANTSLASH-${m.name}/0.0.1/amd64/libvirt/box_0.img\" --network network=default,model=e1000,mac=${m.mac_nat} --network network=hostonly,model=e1000,mac=${m.mac_hostonly} --os-variant win10",

          "virsh -c qemu:///system snapshot-create-as --domain ${m.name} --name snapshot-$(date +%F-%H%M%S) --diskspec sda,snapshot=internal --atomic",
          "virsh -c qemu:///system shutdown ${m.name}"
        ]
      ])
    ) : [
      "echo 'Skipping install of nested-virt guest VMs'"
    ]
  }

  provisioner "shell" {
    inline = var.cape_nested_virt ? [
      "echo 'Configuring machinery for nested-virt guest VMs'",
      "sudo crudini --set /opt/CAPEv2/conf/${var.cape_machinery}.conf kvm machines \"${local.cape_machines_line}\"",
      "sudo crudini --merge /opt/CAPEv2/conf/${var.cape_machinery}.conf <<BLOCK\n${local.cape_machine_blocks}\nBLOCK"
    ] : [
      "echo 'Skipping install of nested-virt guest VMs'"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Setting CAPE resultserver IP address in cuckoo.conf'",
      "sudo crudini --set /opt/CAPEv2/conf/cuckoo.conf resultserver ip \"$(ip -j r s default | jq -r '.[0].prefsrc')\""
    ]
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
  #   only = ["vmware-iso.cape-server"]
  #   expect_disconnect = true
  # }


  # provisioner "shell" {
  #   inline = [
  #     "sudo tee /etc/netplan/50-cloud-init.yaml >/dev/null <<'EOF'",
  #     "network:",
  #     "  version: 2",
  #     "  renderer: networkd",
  #     "  ethernets:",
  #     "    enp0s${var.eth0_pcislot_virtualbox}:",
  #     "      dhcp4: true",
  #     "    enp0s${var.eth1_pcislot_virtualbox}:",
  #     "      addresses: [${var.host_hostonly_ip}/24]",
  #     "EOF",
  #     "sudo chmod 600 /etc/netplan/50-cloud-init.yaml",
  #     "sudo netplan generate && sudo netplan apply"
  #   ]
  #   only = ["virtualbox-ovf.cape-server"]
  # }

  post-processor "vagrant" {
    output               = source.type == "vmware-iso" ? "boxes/cape-server-vmware.box" : "boxes/cape-server-virtualbox.box"
    keep_input_artifact  = true
    provider_override    = source.type == "vmware-iso" ? "vmware" : "virtualbox"
    vagrantfile_template = "vagrant/cape-server/Vagrantfile"
    only                 = var.export_vagrant ? ["vmware-iso.cape-server", "virtualbox-ovf.cape-server"] : []
  }
}