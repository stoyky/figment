packer {
  required_version = ">= 1.7.0"
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

source "vagrant" "remnux" {
  communicator = "ssh"
  source_path = "bento/ubuntu-20.04"
  provider = "vmware_desktop"
  add_force = true
  box_name = "remnux"
  output_dir = "remnux/output-vagrant"
}

build {
  sources = ["source.vagrant.remnux"]

  provisioner "ansible" {
    playbook_file = "../ansible/remnux/install-remnux.yml"
    user          = "vagrant"
    use_proxy     = false
    timeout       = "4h"

    extra_arguments = [
      "-e", "ansible_connection=ssh",
      "-e", "ansible_ssh_args='-o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=ssh-rsa -o UserKnownHostsFile=/dev/null'",
      "-e", "ansible_ssh_user=vagrant",
      "-e", "ansible_ssh_pass=vagrant",
      "-e", "ansible_become_pass=vagrant",
      "-e", "ansible_host_key_checking=false",
    ]
  }
}