# VM Configuration
iso_sha256              = "SHA256:a6f470ca6d331eb353b815c043e327a347f594f37ff525f17764738fe812852e"
iso_url                 = "assets/flarevm/win10.iso"
user                    = "admin"
password                = "password"
cpus                    = 2
memory                  = 2048
vm_name                 = "FlareVM"
disk_size               = 70000
enable_vagrant          = false

# Network Configuration
hostonly_ip             = "192.168.56.222"
default_gateway         = "192.168.56.111"
dns_ip                  = "192.168.56.111"
ethernet0_pcislotnumber = "33"
ethernet1_pcislotnumber = "36"

# VMWare valid MAC
# mac_nat                 = "00:0c:29:00:00:01"
# mac_hostonly            = "00:0c:29:00:00:02"

# Virtualbox valid MAC
mac_nat                 = "080027000001"
mac_hostonly            = "080027000002"

# FlareVM Installer Configuration 
install_args            = "-password password -noWait -noChecks -noGui -noReboots -customConfig .\\custom-config.xml"
