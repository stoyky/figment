# VM Configuration
iso_sha256     = "SHA256:b56b911bf18a2ceaeb3904d87e7c770bdf92d3099599d61ac2497b91bf190b11"
iso_url        = "assets/flarevm/Win11_24H2_English_x64.iso"
user           = "admin"
password       = "password"
cpus           = 2
memory         = 4096
vm_name        = "flarevm"
disk_size      = 60000

# Network Configuration
hostonly_ip             = "192.168.56.20"
default_gateway         = "192.168.56.10"
dns_ip                  = "192.168.56.10"
ethernet0_pcislotnumber = "33"
ethernet1_pcislotnumber = "36"

# VMWare valid MAC
mac_nat_vmware      = "00:0c:29:00:00:01"
mac_hostonly_vmware = "00:0c:29:00:00:02"

# Virtualbox valid MAC
mac_nat_virtualbox      = "080027000001"
mac_hostonly_virtualbox = "080027000002"

# FlareVM Installer Configuration 
install_args = "-password password -noWait -noChecks -noGui -noReboots -customConfig .\\custom-config.xml"

export_vagrant = true
