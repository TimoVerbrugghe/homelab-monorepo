## Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0

## Allow Remote Desktop through Firewall
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"