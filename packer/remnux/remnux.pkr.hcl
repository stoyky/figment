// Description : Creating a virtual machine template under Ubuntu Server 24.04 LTS from ISO file with Packer using VMware Workstation
// Author : Yoann LAMY <https://github.com/ynlamy/packer-ubuntuserver24_04>
// Licence : GPLv3

// Packer : https://www.packer.io/

packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

source "vagrant" "remnux" {
  communicator = "ssh"
  source_path = ""
  provider = "vmware_desktop"
  add_force = true
  box_name = "remnux"
  output_dir = "remnux/output-vagrant"
}

build {
  sources = ["source.vagrant.remnux"]
}