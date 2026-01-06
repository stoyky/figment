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

source "null" "remnux" {
  communicator = "none"
}

build {
    sources = ["source.null.remnux"]

    provisioner "shell-local" {
        inline = [
            "ovftool ../isos/remnux-focal-amd64.ova remnux/output-packer/remnux-focal-amd64.vmx"
        ]
    }

    post-processors {
        post-processor "artifice" {
            files = [
                "remnux/output-packer/remnux-focal-amd64.vmx",
                "remnux/output-packer/remnux-focal-amd64-disk1.vmdk"
            ]
        }

        post-processor "vagrant" {
            keep_input_artifact = true
            provider_override   = "vmware"
            output = "remnux/output-vagrant/remnux.box"

            include = [
                "remnux/output-packer/remnux-focal-amd64/remnux-focal-amd64.vmx",
                "remnux/output-packer/remnux-focal-amd64/remnux-focal-amd64-disk1.vmdk"
            ]
        }
    }

}
