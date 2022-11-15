# Set up winrm configuration
#
#
#    "winrm_username": "Administrator",
#    "winrm_password": "SuperS3cr3t!!!",
#    "winrm_insecure": true,
#    "winrm_use_ssl": true


Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore

# Don't set this before Set-ExecutionPolicy as it throws an error
$ErrorActionPreference = "stop"

# Remove HTTP listener
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse

# Create a self-signed certificate to let ssl work
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "packer"
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

# Configure WinRM to be able to sign in with CredSSP, and provide the
# self-signed cert to the WinRM listener.
winrm quickconfig -quiet
winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
winrm set "winrm/config/listener?Address=*+Transport=HTTPS" "@{Port=`"5986`";Hostname=`"packer`";CertificateThumbprint=`"$($Cert.Thumbprint)`"}"

# Make sure appropriate firewall port openings exist
netsh advfirewall firewall set rule group="Remote Administration using WinRM (packer & ansible)" new enable=yes
netsh firewall add portopening TCP 5986 "Port 5986"

# Restart WinRM, and set it so that it auto-launches on startup
net stop winrm
sc config winrm start= auto
net start winrm