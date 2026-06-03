# Source Image Paths
source_path_vmware_raw = "assets/ubuntu-24.04.4-desktop-amd64.iso"
source_path_vmware     = "temp/cape-server/cape-server.vmx"
source_path_virtualbox = "assets/noble-server-cloudimg-amd64.ova"

# VM Identity
vm_name      = "cape-server"
display_name = "cape-server"

# SSH / Boot Settings
ssh_username = "ubuntu"
ssh_password = "password"
ssh_timeout  = "20m"
boot_wait    = "30s"

# CAPE Settings
cape_commit              = "3eaf9b"
cape_nested_virt         = true
cape_machinery           = "kvm"
cape_machinery_interface = "virbr1"

cape_guests = [
  {
    name              = "cape-guest-win10"
    platform          = "windows"
    arch              = "x64"
    replicas          = 2
    hostonly_offset   = 101
    mac_base_hostonly = "52:54:00:10:20"
    mac_base_nat      = "52:54:00:20:10"
  },
  {
    name              = "cape-guest-win11"
    platform          = "windows"
    arch              = "x64"
    replicas          = 2
    hostonly_offset   = 201
    mac_base_hostonly = "52:54:00:20:30"
    mac_base_nat      = "52:54:00:30:20"
  }
]

# Guest Host-Only Network
guest_hostonly_subnet          = "192.168.55.0/24"

# VMware PCI Slots
eth0_pcislot_vmware = "33"
eth1_pcislot_vmware = "36"

# VirtualBox PCI Slots
eth0_pcislot_virtualbox = "3"
eth1_pcislot_virtualbox = "8"

# Export Settings
export_vagrant = true