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

source "vmware-vmx" "remnux" {
  source_path    = "temp/remnux/remnux.vmx"  # From shell-local ovftool output
  display_name   = "remnux"
  ssh_username   = "remnux"
  ssh_password   = "malware"
  ssh_timeout    = "20m"
  shutdown_command = "sudo shutdown -h now"
  boot_wait      = "20s"              # Adjust for login screen
  boot_command   = [
    "sudo sed -i 's/mode: dedicated/mode: cloud/' /etc/remnux-config<enter>",
    "sudo systemctl enable ssh --now<enter>"
  ]
}

build {
  sources = ["source.vmware-vmx.remnux"]  

  post-processor "vagrant" {
      keep_input_artifact = false
      provider_override   = "vmware"
      output = "boxes/remnux.box"
      vagrantfile_template = "packer/remnux/Vagrantfile"
  }
}