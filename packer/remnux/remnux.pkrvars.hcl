source_path_vmware_raw  = "assets/remnux-noble-amd64.ova"
source_path_qemu        = "assets/remnux-noble-amd64-proxmox.qcow2"
source_path_vmware      = "temp/remnux/remnux.vmx"
source_path_virtualbox  = "assets/remnux/remnux-noble-amd64-virtualbox.ova"
vm_name                 = "remnux"
display_name            = "remnux"
ssh_username            = "remnux"
ssh_password            = "malware"
ssh_timeout             = "20m"
boot_wait               = "30s"

# Network Configuration
hostonly_ip             = "192.168.55.10"

eth0_pcislot_vmware     = "33"
eth1_pcislot_vmware     = "36"

eth0_pcislot_virtualbox = "3"
eth1_pcislot_virtualbox = "8"

eth0_pcislot_qemu = "2"
eth1_pcislot_qemu = "3"

# VMWare valid MAC
mac_nat_vmware      = "00:0c:29:00:00:01"
mac_hostonly_vmware = "00:0c:29:00:00:02"

# Virtualbox valid MAC
mac_nat_virtualbox      = "080027000001"
mac_hostonly_virtualbox = "080027000002"

# QEMU valid MAC
mac_nat_qemu      = "52:54:00:07:66:ea"
mac_hostonly_qemu = "52:54:00:07:66:eb"

export_vagrant          = true

