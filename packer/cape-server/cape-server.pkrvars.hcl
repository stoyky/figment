source_path_vmware_raw  = "assets/noble-server-cloudimg-amd64.ova"
source_path_vmware      = "temp/cape-server/cape-server.vmx"
source_path_virtualbox  = "assets/noble-server-cloudimg-amd64.ova"
vm_name                 = "cape-server"
display_name            = "cape-server"
ssh_username            = "ubuntu"
ssh_password            = "ubuntu"
ssh_timeout             = "20m"
boot_wait               = "30s"

# Network Configuration
hostonly_ip             = "192.168.56.10"
eth0_pcislot_vmware     = "33"
eth1_pcislot_vmware     = "36"

eth0_pcislot_virtualbox = "3"
eth1_pcislot_virtualbox = "8"

mac_nat                 = "080027000001"
mac_hostonly            = "080027000002"

export_vagrant          = true

