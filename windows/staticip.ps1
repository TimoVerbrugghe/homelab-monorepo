# Set static IP address
New-NetIPAddress -IPAddress 10.10.10.15 -DefaultGateway 10.10.10.1 -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex
# Set Network Profile to Private
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private