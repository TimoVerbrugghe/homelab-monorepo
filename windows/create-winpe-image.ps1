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
$isofile="$winpefolder\WinPE_amd64.iso"

# Function to copy Windows PE files & make media - needs to be in a separate function to take over the environment that DISM normally sets up
function CopyPE {
    param (
        [string]$architecture,
        [string]$winpefolder
    )
    $env = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" 
    cmd.exe /c """$env"" && copype $architecture $winpefolder"
}

function MakeWinPEMedia {
    param (
        [string]$winpefolder,
        [string]$isofile
    )
    $env = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" 
    cmd.exe /c """$env"" && MakeWinPEMedia /ISO $winpefolder $isofile"
}

# Dismount the boot image and commit changes
Write-Output "Dismounting boot image (if mounted) and committing changes..."
if (Test-Path "$mountfolder\Users") {
    Write-Output "Found mounted image, dismounting..."
    Dismount-WindowsImage -Path $mountfolder -Discard
    Clear-WindowsCorruptMountPoint
} else {
    Write-Output "No mounted image found."
}

# Check if WinPE folder exists and if yes, delete it
if (Test-Path $winpefolder) {    
    Write-Output "WinPE folder exists, deleting..."
    Remove-Item -Recurse -Force $winpefolder
}

# Use copype in order to create working copy of Windows PE files
Write-Output "Creating working copy of Windows PE files..."
CopyPE -architecture "amd64" -winpefolder $winpefolder

# Mount Boot image to make modifications to it
Write-Output "Modifying boot image..."
Mount-WindowsImage -Path $mountfolder -ImagePath $bootimage -Index 1

# Add WinPE-WMI and WinPE-SecureStartup packages since this is needed for Windows 11 installation
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-WMI.cab" -Path $mountfolder
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-WMI_en-us.cab" -Path $mountfolder -IgnoreCheck
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-SecureStartup.cab" -Path $mountfolder
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-SecureStartup_en-us.cab" -Path $mountfolder -IgnoreCheck

# Add WinPE-HSP-Driver to support Pluton Processor (Ryzen & ARM processors)
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-HSP-Driver.cab" -Path $mountfolder

# Enable PowerShell Support
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-NetFx.cab" -Path $mountfolder
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-NetFx_en-us.cab" -Path $mountfolder -IgnoreCheck
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-Scripting.cab" -Path $mountfolder
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab" -Path $mountfolder -IgnoreCheck
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-PowerShell.cab" -Path $mountfolder
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab" -Path $mountfolder -IgnoreCheck
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-DismCmdlets.cab" -Path $mountfolder
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab" -Path $mountfolder -IgnoreCheck
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-StorageWMI.cab" -Path $mountfolder
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab" -Path $mountfolder -IgnoreCheck
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-EnhancedStorage.cab" -Path $mountfolder
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-EnhancedStorage_en-us.cab" -Path $mountfolder -IgnoreCheck
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-SecureBootCmdlets.cab" -Path $mountfolder

# Download virtio drivers from url and extract iso to temp folder
Write-Output "Downloading virtio drivers..."
if (-Not (Test-Path $virtio_iso_path)) {
    Write-Output "Virtio ISO not found, downloading..."
    # ProgressPreference is set to SilentlyContinue which significantly speeds up the download process
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $virtio_drivers_url -OutFile $virtio_iso_path -UseBasicParsing
    $ProgressPreference = 'Continue'
} else {
    Write-Output "Virtio ISO already exists, skipping download..."
}
$mountResult = Mount-DiskImage -ImagePath $virtio_iso_path -PassThru

# Get the drive letter of the mounted ISO
$driveLetter = ($mountResult | Get-Volume).DriveLetter
$isoMountPath = "$($driveLetter):\"

# Add Virtio drivers
Write-Output "Adding virtio drivers to boot image..."
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viostor\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\vioscsi\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viorng\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\vioserial\w11\amd64" -Recurse 
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viomem\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\vioinput\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viogpudo\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viofs\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\sriov\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\smbus\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\NetKVM\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viogpudo\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\Balloon\w11\amd64" -Recurse

# Dismount the ISO
Dismount-DiskImage -ImagePath $virtio_iso_path

# Copy Unattend.xml & startnet.cmd to root of boot image
Write-Output "Appplying unattend.xml & startnet.cmd to the boot image..."
Copy-Item -Path "./unattend-winpe.xml" -Destination "$mountfolder"
Copy-Item -Path "./startnet.cmd" -Destination "$mountfolder\Windows\System32\startnet.cmd" -Force

# Dismount the boot image and commit changes
Write-Output "Committing changes and dismounting boot image..."
Dismount-WindowsImage -Path $mountfolder -Save -Verbose

# Create ISO Image using MakeWinPEMedia
Write-Output "Creating ISO image..."
MakeWinPEMedia -winpefolder $winpefolder -isofile $isofile

# Mount the ISO file
Write-Output "Mounting the ISO file..."
$isoMountResult = Mount-DiskImage -ImagePath $isofile -PassThru

# Get the drive letter of the mounted ISO
$isoDriveLetter = ($isoMountResult | Get-Volume).DriveLetter
$isoMountPath = "$($isoDriveLetter):\"

# Transfer all files to the network share
Write-Output "Mounting network share..."
$networkPath = "\\10.10.10.2\windowsinstall\"
$credential = New-Object System.Management.Automation.PSCredential("windowsinstall", (ConvertTo-SecureString "windowsinstall" -AsPlainText -Force))
New-PSDrive -Name "Z" -PSProvider "FileSystem" -Root $networkPath -Credential $credential -Persist -Scope Global

# Delete everything inside the networkPath folder
Write-Output "Deleting existing files in the network share WinPE folder..."
Remove-Item -Path "Z:\WinPE\*" -Recurse -Force

Write-Output "Transferring files to the network share WinPE folder..."
Copy-Item -Path "$isoMountPath*" -Destination "Z:\WinPE\" -Recurse -Force

# Copy all XML files from the same folder to the network share
Write-Output "Copying all XML files to the network share Windows 11 folder..."
Copy-Item -Path "./*.xml" -Destination "Z:\Windows11\" -Recurse -Force

# Copy unattend-general.xml to unattend.xml on the network share
Write-Output "Copying unattend-general.xml to unattend.xml on the network share..."
Copy-Item -Path "./unattend-general.xml" -Destination "Z:\Windows11\unattend.xml" -Force

# Unmount the network share
Write-Output "Unmounting network share..."
Remove-PSDrive -Name "Z"

# Dismount the ISO
Write-Output "Dismounting the ISO file..."
Dismount-DiskImage -ImagePath $isofile

# Message to user on migrating files to netbootxyz folder
Write-Output "Please copy the files from the network share to the netbootxyz folder (assets/WinPE/x64) on the server to be able to boot WinPE using netbootxyz."
