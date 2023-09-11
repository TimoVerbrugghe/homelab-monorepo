# Start iSCSI service and enable on boot
Start-Service -Name MSiSCSI
Set-Service -Name MSiSCSI -StartupType Automatic

# Connect to Truenas & mount scsi drive
New-IscsiTargetPortal -TargetPortalAddress "10.10.10.2"
Connect-IscsiTarget -NodeAddress "iscsi.local.timo.be:windowsvm"