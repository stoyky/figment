# Source Image Paths
source_path_vmware_raw = "assets/ubuntu-24.04.4-desktop-amd64.iso"
source_path_vmware     = "temp/cape-guest-ubuntu24/cape-guest-ubuntu24.vmx"
source_path_virtualbox = "assets/noble-server-cloudimg-amd64.ova"

# 

cpus = 2
memory = 4096
disk_size = 60000

# VM Identity
vm_name      = "cape-guest-ubuntu24"
display_name = "cape-guest-ubuntu24"
cape_commit              = "3eaf9b"

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