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
  iso_url      = "../isos/Win10_22H2_English_x64v1.iso"
  iso_checksum = "SHA256:a6f470ca6d331eb353b815c043e327a347f594f37ff525f17764738fe812852e"

  communicator              = "winrm"
  winrm_username              = "admin"
  winrm_password              = "password"
  winrm_timeout               = "4h"
  winrm_use_ssl              = false
  winrm_insecure             = true

  vm_name          = "flarevm"
  guest_os_type    = "windows9-64"
  cpus             = 2
  memory           = 2048
  network          = "nat"
  output_directory = "flarevm/output-packer"

  disk_size         = 70000
  disk_adapter_type = "nvme"
  disk_type_id      = 0

  floppy_files = [
    "flarevm/answer-files/autounattend.xml",
    "flarevm/scripts/enable-winrm.ps1",
    "flarevm/scripts/enable-winrm.bat"
  ]

  shutdown_command = "shutdown /s /t 10 /f"
  shutdown_timeout = "4h"
}



build {
  sources = ["source.vmware-iso.flarevm"]

  provisioner "ansible" {
    playbook_file = "../ansible/flarevm/install-flarevm.yml"
    user          = "admin"
    use_proxy     = false
    timeout       = "4h"

    # extra_arguments = [
    #   "-e", "ansible_connection=winrm",
    #   "-e", "ansible_shell_type=powershell",
    #   "-e", "ansible_winrm_args='-o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=ssh-rsa -o UserKnownHostsFile=/dev/null'",
    #   "-e", "ansible_winrm_user=admin",
    #   "-e", "ansible_winrm_pass=password",
    #   "-e", "ansible_become_pass=password",
    #   "-e", "ansible_host_key_checking=false",
    #   "-vvv"
    # ]
  }

  # post-processor "vagrant" {
  #   keep_input_artifact = true
  #   output              = "vagrant/flarevm.box"
  # }

}


