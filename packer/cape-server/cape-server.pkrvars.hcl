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
cape_machines = [
  {
    name = "cape-guest-win10"
    platform = "windows"
    ip   = "192.168.122.121"
    arch = "x64"
  }
]

# Network Configuration
hostonly_ip         = "192.168.122.101"
eth0_pcislot_vmware = "33"
eth1_pcislot_vmware = "36"

eth0_pcislot_virtualbox = "3"
eth1_pcislot_virtualbox = "8"

mac_nat      = "080027000001"
mac_hostonly = "080027000002"

export_vagrant = true

