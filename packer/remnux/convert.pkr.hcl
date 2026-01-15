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

source "null" "remnux" {
  communicator = "none"
}

build {
  sources = ["source.null.remnux"]

  provisioner "shell-local" {
    inline = [
      "ovftool assets/remnux/remnux-focal-amd64.ova temp/remnux.vmx"
    ]
  }
}