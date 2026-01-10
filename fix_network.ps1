Set-ExecutionPolicy Unrestricted -Force
New-NetIPAddress -InterfaceAlias 'Ethernet0 2' -IPAddress 192.168.56.35 -PrefixLength 24
Set-NetIPAddress -InterfaceAlias 'Ethernet0 2' -IPAddress 192.168.56.35 -PrefixLength 24