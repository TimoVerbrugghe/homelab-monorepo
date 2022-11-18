# Set up winrm configuration
#
#
#    "winrm_username": "Administrator",
#    "winrm_password": "SuperS3cr3t!!!",
#    "winrm_insecure": true,
#    "winrm_use_ssl": true

Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore

# Don't set this before Set-ExecutionPolicy as it throws an error
# $ErrorActionPreference = "stop"

# Making sure network connection is set to private
Set-NetConnectionProfile -NetworkCategory Private

# Remove HTTP & HTTPS listener (if any exist) - for this the winrm service has to be started
Start-Service WinRM
Remove-WSManInstance -ResourceURI WinRM/Config/Listener -selectorset @{Address="*";Transport="https"}
Remove-WSManInstance -ResourceURI WinRM/Config/Listener -selectorset @{Address="*";Transport="http"}

# Create a self-signed certificate to let ssl work (certificate works for IP or for hostname)
# Wi-Fi ip address - for testing purposes
# $IP = (Get-NetIPAddress -InterfaceAlias "Wi-Fi*" -AddressFamily IPv4).IPAddress

$IP = (Get-NetIPAddress -InterfaceAlias "Ethernet*" -AddressFamily IPv4).IPAddress
$Certificate = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME,$IP -CertStoreLocation Cert:\LocalMachine\My

# Create new HTTPS listener with the self-signed certificate
New-WSManInstance WinRM/Config/Listener -SelectorSet @{Address="*"; Transport="HTTPS"} -ValueSet @{Hostname=$env:COMPUTERNAME;CertificateThumbprint=$Certificate.Thumbprint;Port="5986"}

# Configure WinRM to be able to sign in with CredSSP, and provide the
# self-signed cert to the WinRM listener.
Set-WSManInstance -ResourceURI WinRM/Config/Service/Auth -ValueSet @{Basic = "true"} 
Set-WSManInstance -ResourceURI WinRM/Config/Service/Auth -ValueSet @{CredSSP = "true"} 

# Enable connections from any host
Set-WSManInstance -ResourceURI WinRM/Config/Client -ValueSet @{TrustedHosts="*"}

# Create firewall rule to allow Winrm over the standard https port (5986)
$rule = @{
    Name = "WINRM-HTTPS-In-TCP"
    DisplayName = "Windows Remote Management (HTTPS-In)"
    Description = "Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]"
    Enabled = "true"
    Direction = "Inbound"
    Profile = "Any"
    Action = "Allow"
    Protocol = "TCP"
    LocalPort = "5986"
  }
 New-NetFirewallRule @rule

# Restart WinRM, and set it so that it auto-launches on startup
Stop-Service WinRM
Set-Service WinRM -StartupType Automatic
Start-Service WinRM
