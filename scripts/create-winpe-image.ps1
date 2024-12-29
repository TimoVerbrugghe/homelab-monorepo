# Create a Windows PE image to use with netbootxyz so I can netboot Windows 11 installation
# You need to the Windows ADK & the Windows ADK WinPe addon installed to run this script
# Install the Windows ADK from https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install
# Install the Windows ADK WinPE addon from https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-create-usb-bootable-drive

$winpefolder="C:\WinPE_amd64"
$mountfolder="C:\WinPE_amd64\mount"
$bootimage="C:\WinPE_amd64\media\sources\boot.wim"
$adk_winpe="C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64"
$virtio_drivers_url="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
$virtio_iso_path="C:\virtio-win.iso"

# Check if WinPE folder exists and if yes, delete it
if (Test-Path $winpefolder) {    
    Write-Output "WinPE folder exists, deleting..."
    Remove-Item -Recurse -Force $winpefolder
}

# Use copype in order to create working copy of Windows PE files
Write-Output "Creating working copy of Windows PE files..."
cmd /c "copype amd64 $winpefolder"

# Mount Boot image to make modifications to it
Write-Output "Modifying boot image..."
Mount-WindowsImage -Path $mountfolder -ImagePath $bootimage -Index 1 -Verbose

# Add WinPE-WMI and WinPE-SecureStartup packages since this is needed for Windows 11 installation
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-WMI_en-us.cab" -Path $mountfolder -Verbose
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-SecureStartup_en-us.cab" -Path $mountfolder -Verbose

# Download virtio drivers from url and extract iso to temp folder
Write-Output "Downloading virtio drivers..."
Invoke-WebRequest -Uri $virtio_drivers_url -OutFile $virtio_iso_path
$mountResult = Mount-DiskImage -ImagePath $virtio_iso_path -PassThru

# Get the drive letter of the mounted ISO
$driveLetter = ($mountResult | Get-Volume).DriveLetter
$isoMountPath = "$($driveLetter):\"

# Add Virtio drivers
Write-Output "Adding virtio drivers to boot image..."
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viostor\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\vioscsi\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viorng\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\vioserial\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viomem\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\vioinput\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viogpudo\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viofs\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\sriov\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\smbus\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\NetKVM\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viogpudo\w11\amd64" -Recurse -Verbose
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\Balloon\w11\amd64" -Recurse -Verbose

# Dismount the ISO
Dismount-DiskImage -ImagePath $virtio_iso_path

# Delete the ISO
Remove-Item -Path $virtio_iso_path

