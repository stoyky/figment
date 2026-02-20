packer {
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

variable "hostonly_ip" {
  type = string
}

variable "default_gateway" {
  type = string
}

variable "dns_ip" {
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

variable "ethernet0_pcislotnumber" {
  type = string
}

variable "ethernet1_pcislotnumber" {
  type = string
}

variable "export_vagrant" {
  type        = bool
  default     = false
}

## VMWARE 
source "vmware-iso" "flarevm" {
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
  output_directory     = "temp/flarevm-vmware"

  disk_size         = var.disk_size
  disk_adapter_type = "nvme"
  disk_type_id      = 0

  floppy_files = [
    "packer/flarevm/autounattend/autounattend.xml",
    "packer/flarevm/scripts/enable-ssh.ps1"
  ]

  shutdown_command = "shutdown /s /t 10 /f"
  shutdown_timeout = "4h"
  headless         = false

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

source "virtualbox-iso" "flarevm" {
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
  keep_registered           = true
  disk_size                 = var.disk_size

  floppy_files = [
    "packer/flarevm/autounattend/autounattend.xml",
    "packer/flarevm/scripts/enable-ssh.ps1"
  ]

  guest_additions_mode = "upload"
  guest_additions_path = "vmtools.iso"

  shutdown_command = "shutdown /s /t 10 /f"
  shutdown_timeout = "4h"
  headless         = false
  vboxmanage = [
    ["modifyvm", "${var.vm_name}", "--nic1", "nat"],
    ["modifyvm", "${var.vm_name}", "--nic2", "hostonly"],
    ["modifyvm", "${var.vm_name}", "--hostonlyadapter2", "vboxnet0"],
    ["modifyvm", "${var.vm_name}", "--macaddress1", "${var.mac_nat_virtualbox}"],
    ["modifyvm", "${var.vm_name}", "--macaddress2", "${var.mac_hostonly_virtualbox}"]
  ]

  output_directory = "temp/flarevm-virtualbox"
}



build {
  sources = [
    "source.vmware-iso.flarevm",
    "source.virtualbox-iso.flarevm"
  ]

  provisioner "ansible" {
    playbook_file = "ansible/playbooks/flarevm.yml"
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
      "-e", "hostonly_ip=${var.hostonly_ip}",
      "-e", "default_gateway=${var.default_gateway}",
      "-e", "dns_ip=${var.dns_ip}",
      "-e", "mac_nat=${source.type == "vmware-iso" ? var.mac_nat_vmware : var.mac_nat_virtualbox}",
      "-e", "mac_hostonly=${source.type == "vmware-iso" ? var.mac_hostonly_vmware : var.mac_hostonly_virtualbox}",
      "-e", "user=${var.user}",
      "-e", "source_type=${source.type}",
      "--forks=20"
    ]
  }

  post-processor "vagrant" {
    output               = source.type == "vmware-iso" ? "boxes/flarevm-vmware.box" : "boxes/flarevm-virtualbox.box"
    keep_input_artifact  = true
    provider_override    = source.type == "vmware-iso" ? "vmware" : "virtualbox"
    vagrantfile_template = "vagrant/flarevm/Vagrantfile"
    only                 = var.export_vagrant ? ["vmware-iso.flarevm", "virtualbox-iso.flarevm"] : []
  }
}