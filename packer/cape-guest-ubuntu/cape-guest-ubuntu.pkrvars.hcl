# Source Image Paths
iso_url                 = "assets/ubuntu-24.04.4-desktop-amd64.iso"
source_path_vmware      = "temp/cape-guest-ubuntu/cape-guest-ubuntu.vmx"
source_path_virtualbox  = "assets/noble-server-cloudimg-amd64.ova"
iso_sha256              = "SHA256:3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e"
# 

cpus        = 2
memory      = 4096
disk_size   = 60000

# VM Identity
vm_name             = "cape-guest-ubuntu"
display_name        = "cape-guest-ubuntu"
cape_commit         = "e451de454137e0d44ab1ce1f72eae2e2bccfa78a"
cape_tracee_version = "0.24.1"

# SSH / Boot Settings
ssh_username = "ubuntu"
ssh_password = "password"
ssh_timeout  = "20m"
boot_wait    = "30s"

# Guest Host-Only Network
hostonly_ip = "192.168.55.101"

mac_nat_qemu      = "52:54:00:07:66:ea"
mac_hostonly_qemu = "52:54:00:07:66:eb"

# VMware PCI Slots
eth0_pcislot_vmware = "33"
eth1_pcislot_vmware = "36"

# VirtualBox PCI Slots
eth0_pcislot_virtualbox = "3"
eth1_pcislot_virtualbox = "8"

# QEmu PCI Slots
eth0_pcislot_qemu = "2"
eth1_pcislot_qemu = "3"

# Export Settings
export_vagrant = true