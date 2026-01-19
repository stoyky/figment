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
  source_path    = "temp/remnux/remnux.vmx" 
  display_name   = "remnux"
  ssh_username   = "remnux"
  ssh_password   = "malware"
  ssh_timeout    = "20m"

  shutdown_command = "sudo shutdown -h now"
  boot_wait      = "20s"              
  boot_command   = [
    "sudo systemctl enable ssh --now<enter>"
  ]

  vmx_remove_ethernet_interfaces = false
  skip_compaction = "true"
  headless = false

  vmx_data_post = {
    "ethernet0.present"        = "TRUE"
    "ethernet0.connectionType" = "nat"
    "ethernet0.pcislotnumber"  = "33"  # ens160 (Vagrant default)
    "ethernet0.virtualDev"     = "e1000"

    "ethernet1.present"        = "TRUE"
    "ethernet1.connectionType" = "hostonly"
    "ethernet1.pcislotnumber"  = "36"  # ens192 (Vagrant adapter 1 default)
    "ethernet1.virtualDev"     = "e1000"
  }

}

build {
  sources = ["source.vmware-vmx.remnux"]  

  provisioner "shell" {
    inline = [
      "sudo tee /etc/netplan/99-remnux.yaml >/dev/null <<'EOF'",
      "network:",
      "  version: 2",
      "  renderer: networkd",
      "  ethernets:",
      "    ens33:",
      "      dhcp4: true",
      "    ens36:",
      "      addresses: [172.16.53.100/24]",
      "EOF",
      "sudo netplan generate && sudo netplan apply"
    ]
  }



  # post-processor "vagrant" {
  #     keep_input_artifact = true
  #     provider_override   = "vmware"
  #     output = "boxes/remnux.box"
  #     vagrantfile_template = "packer/remnux/Vagrantfile"
  # }
}