# Source Image Paths
source_path_vmware = "assets/ubuntu-24.04.4-desktop-amd64.iso"
temp_path_vmware     = "temp/cape-server/cape-server.vmx"
checksum_vmware = "SHA256:3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e"

source_path_virtualbox = "assets/ubuntu-24.04.4-desktop-amd64.iso"
checksum_virtualbox = "SHA256:3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e"

source_path_qemu = "assets/ubuntu-24.04.4-desktop-amd64.iso"
checksum_qemu = "SHA256:3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e"

# VM Identity
vm_name      = "cape-server"
display_name = "cape-server"

# SSH / Boot Settings
ssh_username = "ubuntu"
ssh_password = "password"
ssh_timeout  = "20m"
boot_wait    = "30s"

# CAPE Settings
cape_commit              = "e451de454137e0d44ab1ce1f72eae2e2bccfa78a"
cape_nested_virt         = true
cape_machinery           = "kvm"
cape_machinery_interface = "virbr1"

cape_guests = [
  {
    name              = "cape-guest-win10"
    platform          = "windows"
    arch              = "x64"
    replicas          = 1
    hostonly_offset   = 101
    mac_base_hostonly = "52:54:00:10:20"
    mac_base_nat      = "52:54:00:20:10"
  },
  {
    name              = "cape-guest-win11"
    platform          = "windows"
    arch              = "x64"
    replicas          = 0
    hostonly_offset   = 151
    mac_base_hostonly = "52:54:00:20:30"
    mac_base_nat      = "52:54:00:30:20"
  },
  {
    name              = "cape-guest-ubuntu"
    platform          = "linux"
    arch              = "x64"
    replicas          = 1
    hostonly_offset   = 201
    mac_base_hostonly = "52:54:00:30:40"
    mac_base_nat      = "52:54:00:40:30"
  }
]

# Guest Host-Only Network
guest_hostonly_subnet          = "192.168.55.10/24"

# VMware PCI Slots
eth0_pcislot_vmware = "33"
eth1_pcislot_vmware = "36"

# VirtualBox PCI Slots
eth0_pcislot_virtualbox = "3"
eth1_pcislot_virtualbox = "8"

eth0_pcislot_qemu = "2"
eth1_pcislot_qemu = "3"

# VMWare valid MAC
mac_nat_vmware      = "00:0c:29:00:00:03"
mac_hostonly_vmware = "00:0c:29:00:00:04"

# Virtualbox valid MAC
mac_nat_virtualbox      = "080027000003"
mac_hostonly_virtualbox = "080027000004"

mac_nat_virtualbox_norm      = "08:00:27:00:00:03"
mac_hostonly_virtualbox_norm = "08:00:27:00:00:04"

# QEMU valid MAC
mac_nat_qemu      = "52:54:00:00:00:03"
mac_hostonly_qemu = "52:54:00:00:00:04"

# Export Settings
export_vagrant = true