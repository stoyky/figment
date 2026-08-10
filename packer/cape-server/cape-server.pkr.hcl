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

variable "source_path_virtualbox" {
  type = string
}

variable "source_path_qemu" {
  type = string
}

variable "temp_path_vmware" {
  type = string
}

variable "checksum_vmware" {
  type = string
}

variable "checksum_virtualbox" {
  type = string
}

variable "checksum_qemu" {
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

variable "export_vagrant" {
  type    = bool
  default = false
}

variable "guest_hostonly_subnet" {
  type = string
}

variable "cape_commit" {
  type = string
}

variable "cape_nested_virt" {
  type    = bool
  default = false
}

variable "cape_guests" {
  type = list(object({
    name              = string
    platform          = string
    arch              = string
    hostonly_offset   = number # e.g. 10
    mac_base_hostonly = string # e.g. 52:54:00:10:20
    mac_base_nat      = string # e.g. 52:54:00:20:10

    replicas          = number
  }))
}

variable "cape_machinery" {
  type    = string
  default = "kvm"
}

variable "cape_machinery_interface" {
  type    = string
  default = "virbr0"
}

locals {
  guest_hostonly_default_gateway = cidrhost(var.guest_hostonly_subnet, 1)
  guest_hostonly_range_start     = cidrhost(var.guest_hostonly_subnet, 2)
  guest_hostonly_range_end       = cidrhost(var.guest_hostonly_subnet, -2)
  guest_hostonly_netmask         = cidrnetmask(var.guest_hostonly_subnet)

  enabled_cape_guests = [
    for g in var.cape_guests : g
    if g.replicas > 0
  ]

  cape_guest_box_names = distinct([
    for g in local.enabled_cape_guests : g.name
  ])

  cape_guest_instances = flatten([
    for g in local.enabled_cape_guests : [
      for replica in range(1, g.replicas + 1) : {
        base_name = g.name
        name      = "${g.name}-${g.arch}-${replica}"
        label     = "${g.name}-${g.arch}-${replica}"
        platform  = g.platform
        arch      = g.arch
        replica   = replica

        ip_hostonly  = cidrhost(var.guest_hostonly_subnet, g.hostonly_offset + replica - 1)
        mac_hostonly = format("%s:%02x", g.mac_base_hostonly, replica)
        mac_nat      = format("%s:%02x", g.mac_base_nat, replica)
      }
    ]
  ])

  cape_machines_line = join(", ", [
    for m in local.cape_guest_instances : m.name
  ])

  cape_machine_blocks = join("\n\n", [
    for m in local.cape_guest_instances : <<-EOT
      [${m.name}]
      label = ${m.label}
      platform = ${m.platform}
      ip = ${m.ip_hostonly}
      arch = ${m.arch}
    EOT
  ])
}

source "vmware-iso" "cape-server" {
  cd_files             = ["packer/cape-server/cloud-init/user-data", "packer/cape-server/cloud-init/meta-data"]
  cd_label             = "cidata"
  output_directory     = "temp/cape-server-vmware"
  iso_url              = var.source_path_vmware
  iso_checksum         = var.checksum_vmware
  vm_name              = var.vm_name
  display_name         = var.display_name
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_timeout          = var.ssh_timeout
  network_adapter_type = "e1000"
  disk_size            = 102400
  memory               = 16384
  cpus                 = 4

  vhv_enabled      = true
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
  }

}

## Virtualbox
source "virtualbox-iso" "cape-server" {
  cd_files         = ["packer/cape-server/cloud-init/user-data", "packer/cape-server/cloud-init/meta-data"]
  cd_label         = "cidata"
  iso_url          = var.source_path_virtualbox
  iso_checksum     = var.checksum_virtualbox
  vm_name          = "cape-server"
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = var.ssh_timeout
  output_directory = "temp/cape-server-virtualbox"
  disk_size        = 102400
  memory           = 8192
  skip_export      = false
  shutdown_command = "sudo shutdown -h now"
  headless         = false

  guest_os_type = "Ubuntu24_LTS_64"
  hard_drive_interface = "sata"

  boot_wait        = "5s"
  boot_command = [
  "<wait>",
  "e<wait>",
  "<down><down><down><end>",
  " autoinstall ds=nocloud-net;s=file:///cdrom/ nomodeset acpi=off",
  "<f10>",
  "<wait5s>"
]

  vboxmanage_post = [
    ["modifyvm", "${var.vm_name}", "--nic2", "hostonly"],
    ["modifyvm", "${var.vm_name}", "--hostonlyadapter2", "vboxnet0"],
    ["modifyvm", "${var.vm_name}", "--macaddress2", "${var.mac_hostonly_virtualbox}"]
  ]
}

source "qemu" "cape-server" {
  cd_files         = ["packer/cape-server/cloud-init/user-data", "packer/cape-server/cloud-init/meta-data"]
  cd_label         = "cidata"
  iso_url          = var.source_path_qemu
  iso_checksum     = var.checksum_qemu
  shutdown_command = "sudo shutdown -h now"
  accelerator      = "kvm"
  machine_type     = "q35"
  output_directory = "temp/cape-server-qemu"
  disk_size        = 102400
  memory           = 8192
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = "4h"
  vm_name          = var.vm_name
  net_device       = "e1000"
  disk_interface   = "ide"

  boot_wait        = "5s"
  boot_command = [
    "<wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net;s=file:///cdrom/",
    "<f10>"
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
    "vmware-iso.cape-server",
    "virtualbox-iso.cape-server",
    "qemu.cape-server"
  ]

  provisioner "shell" {
    inline = [
      "echo guest_hostonly_default_gateway=${local.guest_hostonly_default_gateway}",
      "echo guest_hostonly_range_start=${local.guest_hostonly_range_start}",
      "echo guest_hostonly_range_end=${local.guest_hostonly_range_end}",
      "echo guest_hostonly_netmask=${local.guest_hostonly_netmask}"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Updating and upgrading system packages'",
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install git vim -y",
      "sudo apt-get remove -y --autoremove gnome-initial-setup",
      "sudo reboot"
    ]
    expect_disconnect = true
  }

  provisioner "shell" {
    pause_before = "10s"
    inline = [
      "echo 'Cloning CAPEv2...'",
      "git clone https://github.com/kevoreilly/CAPEv2.git",
      "cd CAPEv2 && git checkout ${var.cape_commit} && cd installer",
    ]
  }


  provisioner "shell" {
    pause_before = "10s"
    inline = var.cape_nested_virt ? [
      "echo 'Running KVM-QEMU installer'",
      "cd CAPEv2/installer",
      "sed -i 's/<WOOT>/ACPI/g' kvm-qemu.sh",
      "sudo ./kvm-qemu.sh all ${var.ssh_username} | tee kvm-qemu.log",
      "sudo reboot",
    ] : [
      "echo 'Skipping install of nested-virt guest VMs'"
    ]
  }

  provisioner "shell" {
    pause_before = "10s"
    inline = [
      "echo 'Running CAPE installer'",
      "cd CAPEv2/installer",
      "sudo ./cape2.sh all cape | tee cape.log",
      "sudo reboot",
    ]
  }

  provisioner "shell" {
    pause_before = "10s"
    inline = [
      "echo 'Performing poetry installation'",
      "cd /opt/CAPEv2/",
      "echo $PATH",
      "sudo -u cape /etc/poetry/bin/poetry install",
    ]
  }

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
      "echo 'Creating libvirt host-only network'",
      "cat > /tmp/hostonly.xml <<'EOF'",
      "<network>",
      "  <name>hostonly</name>",
      "  <bridge name='virbr1' stp='on' delay='0'/>",
      "  <domain name='hostonly'/>",
      "  <ip address='${local.guest_hostonly_default_gateway}' netmask='${local.guest_hostonly_netmask}'>",
      "    <dhcp>",
      "      <range start='${local.guest_hostonly_range_start}' end='${local.guest_hostonly_range_end}'/>",
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
      "echo 'Skipping libvirt host-only network creation'"
    ]
  }

  provisioner "shell" {
    inline = var.cape_nested_virt ? concat(
      [
        "echo 'Installing nested-virt guest VMs'"
      ],

      [
        for box_name in local.cape_guest_box_names :
        "vagrant box list | grep -q '^figment/${box_name} ' || vagrant box add figment/${box_name}"
      ],

      flatten([
        for m in local.cape_guest_instances : [
          "virsh -c qemu:///system net-update hostonly add-last ip-dhcp-host \"<host mac='${m.mac_hostonly}' name='${m.name}-hostonly' ip='${m.ip_hostonly}' />\" --live --config --parent-index 0",

          "[ -f \"/var/lib/libvirt/images/${m.name}.qcow2\" ] || sudo qemu-img create -f qcow2 -F qcow2 -b \"$HOME/.vagrant.d/boxes/figment-VAGRANTSLASH-${m.base_name}/0.0.1/amd64/libvirt/box_0.img\" \"/var/lib/libvirt/images/${m.name}.qcow2\"",

          "virt-install --connect qemu:///system --noautoconsole --name ${m.name} --import --disk path=/var/lib/libvirt/images/${m.name}.qcow2,format=qcow2 --network network=default,model=e1000,mac=${m.mac_nat} --network network=hostonly,model=e1000,mac=${m.mac_hostonly} --os-variant win10",

          "virsh -c qemu:///system domif-setlink ${m.name} ${m.mac_nat} down",
          "virsh -c qemu:///system domif-setlink ${m.name} ${m.mac_nat} down --config",

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
      "sudo crudini --set /opt/CAPEv2/conf/${var.cape_machinery}.conf ${var.cape_machinery} machines \"${local.cape_machines_line}\"",
      "sudo crudini --set /opt/CAPEv2/conf/${var.cape_machinery}.conf ${var.cape_machinery} interface \"${var.cape_machinery_interface}\"",
      "sudo crudini --merge /opt/CAPEv2/conf/${var.cape_machinery}.conf <<BLOCK\n${local.cape_machine_blocks}\nBLOCK"
      ] : [
      "echo 'Skipping install of nested-virt guest VMs'"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Setting CAPE resultserver IP address in cuckoo.conf'",
      "sudo crudini --set /opt/CAPEv2/conf/cuckoo.conf resultserver ip \"$(ip -j addr show dev ${var.cape_machinery_interface} | jq -r '.[0].addr_info[0].local')\""
    ]
  }

 provisioner "shell" {
    inline = [
      "echo 'Create custom configuration directory for conf overrides'",
      "sudo mkdir -p /opt/CAPEv2/custom/conf",
      "sudo chown $USER:$USER /opt/CAPEv2/custom/conf"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/custom/conf/"
    destination = "/opt/CAPEv2/custom/conf/"
  }

  provisioner "shell" {
    inline = [
      "install -d -m 0755 /home/${var.ssh_username}/Downloads",
      "cd /home/${var.ssh_username}/Downloads",
      "echo 'Downloading sample malware to $(pwd)'",
      "curl -fL -O https://github.com/a0rtega/pafish/releases/download/v0.6/pafish.exe",
      "curl -fL -O https://github.com/a0rtega/pafish/releases/download/v0.6/pafish64.exe",
      "curl -fL -O https://github.com/citronneur/pamspy/releases/download/v0.3/pamspy"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Applying commit-specific fixes'",
      "sudo crudini --set --existing /usr/lib/systemd/system/mongodb.service Service 'Environment' 'GLIBC_TUNABLES=glibc.pthread.rseq=1'",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart mongodb || sudo systemctl restart mongod"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Restarting CAPE services'",
      "sudo systemctl restart cape*"
    ]
  }

  post-processor "vagrant" {
    keep_input_artifact  = true
    output               = source.type == "vmware-iso" ? "boxes/cape-server-vmware.box" : source.type == "virtualbox-iso" ? "boxes/cape-server-virtualbox.box" : "boxes/cape-server-qemu.box"
    provider_override    = source.type == "vmware-iso" ? "vmware" : source.type == "virtualbox-iso" ? "virtualbox" : "libvirt"
    vagrantfile_template = "vagrant/cape-server/Vagrantfile"
    only                 = var.export_vagrant ? ["vmware-iso.cape-server", "virtualbox-iso.cape-server", "qemu.cape-server"] : []
  }
}