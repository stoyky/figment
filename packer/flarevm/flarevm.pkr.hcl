packer {
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

variable "iso_url" {
  type = string
}

variable "iso_sha256" {
  type = string
}

variable "user" {
  type    = string
}

variable "password" {
  type    = string
  sensitive = true
}

variable "vm_name" {
  type = string
}

variable "cpus" {
  type    = number
}

variable "memory" {
  type    = number
}

variable "disk_size" {
  type    = number
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

variable "enable_vagrant" {
  type = bool
}


source "vmware-iso" "flarevm" {
  iso_url      = var.iso_url
  iso_checksum = var.iso_sha256

  communicator              = "ssh"
  ssh_username              = var.user
  ssh_password              = var.password
  ssh_timeout               = "4h"
  ssh_clear_authorized_keys = true

  vm_name          = var.vm_name
  guest_os_type    = "windows9-64"
  cpus             = var.cpus
  memory           = var.memory
  network          = "nat"
  output_directory = "temp/flarevm"

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

  vmx_data = {
    "ethernet0.present"        = "TRUE"
    "ethernet0.connectiontype" = "nat"
    "ethernet0.virtualdev"     = "e1000"
    "ethernet0.connect"        = "connected"
    "ethernet0.startconnected" = "TRUE"
    "ethernet0.displayname"    = "nat"
    "ethernet0.networkname"    = "nat"

    "ethernet1.present"        = "TRUE"
    "ethernet1.connectiontype" = "hostonly"
    "ethernet1.virtualdev"     = "e1000"
    "ethernet1.connect"        = "connected"
    "ethernet1.startconnected" = "TRUE"
    "ethernet1.displayname"    = "hostonly"
    "ethernet1.networkname"    = "hostonly"
  }
}

build {
  sources = ["source.vmware-iso.flarevm"]

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
      "--forks=20"
    ]
  }

  post-processor "vagrant" {
    output               = "boxes/flarevm.box"
    keep_input_artifact  = true
    provider_override    = "vmware"
    vagrantfile_template = "packer/flarevm/Vagrantfile"
    only = var.enable_vagrant ? ["vmware-iso.flarevm"] : []
  }

}