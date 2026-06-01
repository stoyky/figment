# VM Configuration
iso_sha256     = "SHA256:768984706b909479417b2368438909440f2967ff05c6a9195ed2667254e465e3"
iso_url        = "assets/Win11_25H2_English_x64_v2.iso"
user           = "admin"
password       = "password"
cpus           = 4
cores          = 4
memory         = 8192
vm_name        = "cape-guest-win11"
disk_size      = 60000

# Network Configuration
hostonly_subnet   = "192.168.55.0"
hostonly_netmask  = "255.255.255.0"
hostonly_gateway  = "192.168.55.1"

ethernet0_pcislotnumber = "33"
ethernet1_pcislotnumber = "36"

# VMWare valid MAC
mac_nat_vmware      = "00:0c:29:00:00:01"
mac_hostonly_vmware = "00:0c:29:00:00:02"

# Virtualbox valid MAC
mac_nat_virtualbox      = "080027000001"
mac_hostonly_virtualbox = "080027000002"

# QEMU valid MAC
mac_nat_qemu      = "52:54:00:07:66:ea"
mac_hostonly_qemu = "52:54:00:07:66:eb"

export_vagrant = true
