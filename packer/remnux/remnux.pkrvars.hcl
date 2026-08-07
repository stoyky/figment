source_path_vmware = "assets/remnux-noble-amd64.ova"
source_path_virtualbox = "assets/remnux-noble-amd64-virtualbox.ova"
source_path_qemu = "assets/remnux-noble-amd64-proxmox.qcow2"

vm_name      = "remnux"
display_name = "remnux"
ssh_username = "remnux"
ssh_password = "malware"
ssh_timeout  = "20m"

# Boot wait and command to enable SSH
boot_wait = "30s"

# Network Configuration
hostonly_ip = "192.168.55.10/24"

eth0_pcislot_vmware = "33"
eth1_pcislot_vmware = "36"

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

export_vagrant = true

