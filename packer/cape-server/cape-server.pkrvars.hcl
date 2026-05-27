source_path_vmware_raw = "assets/ubuntu-24.04.4-desktop-amd64.iso"
source_path_vmware     = "temp/cape-server/cape-server.vmx"
source_path_virtualbox = "assets/noble-server-cloudimg-amd64.ova"
vm_name                = "cape-server"
display_name           = "cape-server"
ssh_username           = "ubuntu"
ssh_password           = "password"
ssh_timeout            = "20m"
boot_wait              = "30s"

# CAPE configuration
# This is the commit hash of the CAPE repository that will be cloned during the provisioning process.
cape_commit      = "3eaf9b"
cape_nested_virt = true
cape_machinery   = "kvm"
cape_guests = [
  {
    name         = "cape-guest-win10"
    platform     = "windows"
    arch         = "x64"
    ip_nat       = "192.168.122.50"
    ip_hostonly  = "192.168.55.101"
    mac_nat      = "52:54:00:07:66:ea"
    mac_hostonly = "52:54:00:07:66:eb"
  }
]

# Network Configuration
# Assign this a NAT ip in your VMWare network NAT range.
server_nat_ip              = "192.168.227.10"
server_nat_default_gateway = "192.168.227.2"

# Assign this an ip in your VMWare network hostonly range.
guest_hostonly_default_gateway = "192.168.55.1"
guest_hostonly_range_start     = "192.168.55.2"
guest_hostonly_range_end       = "192.168.55.254"

eth0_pcislot_vmware = "33"
eth1_pcislot_vmware = "36"

eth0_pcislot_virtualbox = "3"
eth1_pcislot_virtualbox = "8"

mac_nat      = "080027000001"
mac_hostonly = "080027000002"

export_vagrant = true

