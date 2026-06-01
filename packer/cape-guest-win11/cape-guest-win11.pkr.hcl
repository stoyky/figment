packer {
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

variable "iso_url" {
  type = string
}

variable "iso_sha256" {
  type = string
}

variable "user" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "vm_name" {
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

# variable "hostonly_ip" {
#   type = string
# }

variable "hostonly_subnet" {
  type = string
}

variable "hostonly_netmask" {
  type = string
}

variable "hostonly_gateway" {
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

variable "ethernet0_pcislotnumber" {
  type = string
}

variable "ethernet1_pcislotnumber" {
  type = string
}

variable "export_vagrant" {
  type    = bool
  default = false
}

## VMWARE 
source "vmware-iso" "cape-guest-win11" {
  iso_url      = var.iso_url
  iso_checksum = var.iso_sha256

  communicator              = "ssh"
  ssh_username              = var.user
  ssh_password              = var.password
  ssh_timeout               = "4h"
  ssh_clear_authorized_keys = true

  vm_name              = var.vm_name
  guest_os_type        = "windows9-64"
  cpus                 = var.cpus
  memory               = var.memory
  network              = "nat"
  network_adapter_type = "e1000"
  output_directory     = "temp/cape-guest-win11-vmware"

  disk_size         = var.disk_size
  disk_adapter_type = "nvme"
  disk_type_id      = 0

  floppy_files = [
    "packer/cape-guest-win11/autounattend/autounattend.xml",
    "packer/cape-guest-win11/scripts/enable-ssh.ps1"
  ]

  shutdown_command = "shutdown /s /t 10 /f"
  shutdown_timeout = "4h"
  headless         = false

  tools_mode          = "upload"
  tools_upload_flavor = "windows"
  tools_upload_path   = "vmtools.iso"

  vmx_data = {
    "ethernet0.present"        = "TRUE"
    "ethernet0.connectionType" = "nat"
    "ethernet0.virtualDev"     = "e1000"
    "ethernet0.connect"        = "connected"
    "ethernet0.startConnected" = "TRUE"
    "ethernet0.displayName"    = "nat"
    "ethernet0.addressType"    = "static"
    "ethernet0.address"        = "${var.mac_nat_vmware}"

    "ethernet1.present"        = "TRUE"
    "ethernet1.connectionType" = "hostonly"
    "ethernet1.virtualDev"     = "e1000"
    "ethernet1.connect"        = "connected"
    "ethernet1.startConnected" = "TRUE"
    "ethernet1.displayName"    = "hostonly"
    "ethernet1.addressType"    = "static"
    "ethernet1.address"        = "${var.mac_hostonly_vmware}"
  }
}

## VIRTUALBOX
source "virtualbox-iso" "cape-guest-win11" {
  iso_url                   = var.iso_url
  iso_checksum              = var.iso_sha256
  communicator              = "ssh"
  ssh_username              = var.user
  ssh_password              = var.password
  ssh_timeout               = "4h"
  ssh_clear_authorized_keys = true
  vm_name                   = var.vm_name
  guest_os_type             = "Windows10_64"
  cpus                      = var.cpus
  memory                    = var.memory
  skip_export               = false
  format                    = "ova"
  keep_registered           = true
  disk_size                 = var.disk_size

  floppy_files = [
    "packer/cape-guest-win11/autounattend/autounattend.xml",
    "packer/cape-guest-win11/scripts/enable-ssh.ps1"
  ]

  guest_additions_mode = "upload"
  guest_additions_path = "vmtools.iso"

  shutdown_command = "shutdown /r /t 0"
  shutdown_timeout = "4h"
  headless         = false
  vboxmanage = [
    ["modifyvm", "${var.vm_name}", "--nic1", "nat"],
    ["modifyvm", "${var.vm_name}", "--nic2", "hostonly"],
    ["modifyvm", "${var.vm_name}", "--hostonlyadapter2", "vboxnet0"],
    ["modifyvm", "${var.vm_name}", "--macaddress1", "${var.mac_nat_virtualbox}"],
    ["modifyvm", "${var.vm_name}", "--macaddress2", "${var.mac_hostonly_virtualbox}"]
  ]

  output_directory = "temp/cape-guest-win11-virtualbox"
}

source "qemu" "cape-guest-win11" {
  iso_url          = var.iso_url
  iso_checksum     = var.iso_sha256
  shutdown_command = "shutdown /s /t 10 /f"
  disk_size        = var.disk_size
  memory           = var.memory
  format           = "qcow2"
  accelerator      = "kvm"
  machine_type     = "q35"
  cpus             = var.cpus
  cpu_model      = "host"
  # vga = "qxl"
  output_directory = "temp/cape-guest-win11-qemu"
  # skip_nat_mapping = true

  floppy_files = [
    "packer/cape-guest-win11/autounattend/autounattend.xml",
    "packer/cape-guest-win11/scripts/enable-ssh.ps1"
  ]

  cd_files = [
    "packer/cape-guest-win11/drivers/*"
  ]

  qemuargs = [
    # ["-drive", "if=none,id=drive0,file=temp/cape-guest-win11-qemu/cape-guest-win11,format=qcow2,cache=writeback,discard=unmap"],
    # ["-drive", "media=cdrom,file=${var.iso_url}"],
    # ["-drive", "media=cdrom,file=packer/cape-guest-win11/drivers/virtio-win-0.1.285.iso"],

    ["-netdev", "user,id=user.0,hostfwd=tcp::{{ .SSHHostPort }}-:22"],
    ["-device", "virtio-net,netdev=user.0,mac=${var.mac_nat_qemu}"],

    # ["-netdev", "user,id=user.1"],
    # ["-device", "e1000,netdev=user.1,mac=${var.mac_hostonly_qemu}"]

    ["-netdev", "bridge,id=hn1,br=virbr1"],
    ["-device", "virtio-net,netdev=hn1,mac=${var.mac_hostonly_qemu}"]
  ]

  ssh_username = var.user
  ssh_password = var.password
  ssh_timeout  = "4h"
  vm_name      = var.vm_name
  # net_device     = "virtio-net"
  disk_interface = "virtio"
  disk_discard = "unmap"
  efi_boot = true
  vtpm = true
  tpm_device_type = "tpm-crb"
  # efi_boot = true
  # use_pflash = true
  # efi_firmware_code = "/usr/share/OVMF/OVMF_CODE_4M.fd"
  # efi_firmware_vars = "/usr/share/OVMF/OVMF_VARS_4M.fd"
  # cdrom_interface = "ide"
}

build {
  sources = [
    "source.vmware-iso.cape-guest-win11",
    "source.virtualbox-iso.cape-guest-win11",
    "source.qemu.cape-guest-win11"
  ]

  provisioner "ansible" {
    playbook_file = "ansible/playbooks/cape-guest-win11.yml"
    user          = var.user
    use_proxy     = false
    timeout       = "4h"

    ansible_env_vars = ["ANSIBLE_PIPELINING=true", "ANSIBLE_SSH_PIPELINING=true"]

    extra_arguments = [
      "-e", "ansible_connection=ssh",
      "-e", "ansible_shell_type=powershell",
      "-e", "ansible_ssh_args='-o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=ssh-rsa -o UserKnownHostsFile=/dev/null -o ControlMaster=auto -o ControlPersist=30m'",
      "-e", "ansible_ssh_user=${var.user}",
      "-e", "ansible_ssh_pass=${var.password}",
      "-e", "ansible_become_pass=${var.password}",
      "-e", "ansible_host_key_checking=false",
      "-e", "pipelining=true",
      "-e", "hostonly_gateway=${var.hostonly_gateway}",
      "-e", "hostonly_subnet=${var.hostonly_subnet}",
      "-e", "hostonly_netmask=${var.hostonly_netmask}",
      "-e", "mac_nat=${
        source.type == "vmware-iso" ? var.mac_nat_vmware :
        source.type == "virtualbox-iso" ? var.mac_nat_virtualbox :
        var.mac_nat_qemu
      }",
      "-e", "mac_hostonly=${
        source.type == "vmware-iso" ? var.mac_hostonly_vmware :
        source.type == "virtualbox-iso" ? var.mac_hostonly_virtualbox :
        var.mac_hostonly_qemu
      }",
      "-e", "user=${var.user}",
      "-e", "password=${var.password}",
      "-e", "source_type=${source.type}",
      "--forks=20"
    ]
  }

  post-processors {
    post-processor "artifice" {
      files = ["temp/cape-guest-win11-virtualbox/cape-guest-win11.ova"]
      only  = ["virtualbox-iso.cape-guest-win11"]
    }

    post-processor "vagrant" {
      keep_input_artifact  = true
      output               = source.type == "vmware-iso" ? "boxes/cape-guest-win11-vmware.box" : source.type == "virtualbox-iso" ? "boxes/cape-guest-win11-virtualbox.box" : "boxes/cape-guest-win11-qemu.box"
      provider_override    = source.type == "vmware-iso" ? "vmware" : source.type == "virtualbox-iso" ? "virtualbox" : "libvirt"
      vagrantfile_template = "vagrant/cape-guest-win11/Vagrantfile"
      only                 = var.export_vagrant ? ["vmware-iso.cape-guest-win11", "virtualbox-iso.cape-guest-win11", "qemu.cape-guest-win11"] : []
    }
  }
}