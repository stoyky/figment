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

source "vmware-iso" "flarevm" {
  iso_url      = "../../assets/flarevm/win10.iso"
  iso_checksum = "SHA256:a6f470ca6d331eb353b815c043e327a347f594f37ff525f17764738fe812852e"

  communicator              = "ssh"
  ssh_username              = "admin"
  ssh_password              = "password"
  ssh_timeout               = "4h"
  ssh_clear_authorized_keys = true

  vm_name          = "flarevm"
  guest_os_type    = "windows9-64"
  cpus             = 2
  memory           = 2048
  network          = "nat"
  output_directory = "temp-output"

  disk_size         = 70000
  disk_adapter_type = "nvme"
  disk_type_id      = 0

  floppy_files = [
    "autounattend/autounattend.xml",
    "scripts/enable-ssh.ps1"
  ]

  shutdown_command = "shutdown /s /t 10 /f"
  shutdown_timeout = "4h"
}



build {
  sources = ["source.vmware-iso.flarevm"]

  provisioner "ansible" {
    playbook_file = "../../ansible/playbooks/flarevm.yml"
    user          = "admin"
    use_proxy     = false
    timeout       = "4h"

    ansible_env_vars = ["ANSIBLE_PIPELINING=true", "ANSIBLE_SSH_PIPELINING=true"]

    extra_arguments = [
      "-e", "ansible_connection=ssh",
      "-e", "ansible_shell_type=powershell",
      "-e", "ansible_ssh_args='-o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=ssh-rsa -o UserKnownHostsFile=/dev/null -o ControlMaster=auto -o ControlPersist=30m'",
      "-e", "ansible_ssh_user=admin",
      "-e", "ansible_ssh_pass=password",
      "-e", "ansible_become_pass=password",
      "-e", "ansible_host_key_checking=false",
      "-e", "pipelining=true",
      "--forks=20"
    ]
  }

  post-processor "vagrant" {
    output = "../../boxes/flarevm.box" 
    keep_input_artifact = false
  }

}