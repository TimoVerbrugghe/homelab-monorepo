# Create a WinPE image with virtio-win drivers for use with netbootxyz
# CI/CD version - no network share operations, outputs ISO to C:\WinPE_amd64\WinPE_amd64.iso
#
# Prerequisites:
#   - Windows ADK with Deployment Tools (OptionId.DeploymentTools)
#   - Windows ADK WinPE addon (OptionId.WindowsPreinstallationEnvironment)
#
# Install from: https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$winpefolder = "C:\WinPE_amd64"
$mountfolder = "C:\WinPE_amd64\mount"
$bootimage = "C:\WinPE_amd64\media\sources\boot.wim"
$adk_winpe = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64"
$virtio_drivers_url = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
$virtio_iso_path = "C:\virtio-win.iso"
$isofile = "$winpefolder\WinPE_amd64.iso"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function CopyPE {
    param (
        [string]$architecture,
        [string]$destination
    )
    $dandIEnv = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
    cmd.exe /c """$dandIEnv"" && copype $architecture $destination"
}

function MakeWinPEMedia {
    param (
        [string]$source,
        [string]$outputIso
    )
    $dandIEnv = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
    cmd.exe /c """$dandIEnv"" && MakeWinPEMedia /ISO $source $outputIso"
}

# Clean up any existing mount state
Write-Output "Checking for existing mounted images..."
if (Test-Path "$mountfolder\Users") {
    Write-Output "Found mounted image, dismounting..."
    Dismount-WindowsImage -Path $mountfolder -Discard
    Clear-WindowsCorruptMountPoint
}

# Remove existing WinPE folder if present
if (Test-Path $winpefolder) {
    Write-Output "Removing existing WinPE folder..."
    Remove-Item -Recurse -Force $winpefolder
}

# Create working copy of Windows PE files
Write-Output "Creating WinPE working directory..."
CopyPE -architecture "amd64" -destination $winpefolder

# Mount boot image
Write-Output "Mounting boot image..."
Mount-WindowsImage -Path $mountfolder -ImagePath $bootimage -Index 1

# Add WinPE packages required for Windows 11 installation
Write-Output "Adding WinPE-WMI and WinPE-SecureStartup packages..."
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-WMI.cab" -Path $mountfolder
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-WMI_en-us.cab" -Path $mountfolder -IgnoreCheck
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\WinPE-SecureStartup.cab" -Path $mountfolder
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-SecureStartup_en-us.cab" -Path $mountfolder -IgnoreCheck

# Add HSP-Driver for AMD Ryzen / ARM processors with Pluton (optional, may not exist in all ADK versions)
$hspDriverPath = "$adk_winpe\WinPE_OCs\WinPE-HSP-Driver.cab"
if (Test-Path $hspDriverPath) {
    Write-Output "Adding WinPE-HSP-Driver package..."
    Add-WindowsPackage -PackagePath $hspDriverPath -Path $mountfolder
} else {
    Write-Warning "WinPE-HSP-Driver.cab not found in this ADK version, skipping."
}

# Add PowerShell support packages
Write-Output "Adding PowerShell support packages..."
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

# Download the latest stable virtio-win ISO
Write-Output "Downloading latest virtio-win ISO..."
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $virtio_drivers_url -OutFile $virtio_iso_path -UseBasicParsing
$ProgressPreference = 'Continue'
Write-Output "virtio-win ISO downloaded."

# Mount virtio-win ISO and inject drivers
Write-Output "Mounting virtio-win ISO..."
$mountResult = Mount-DiskImage -ImagePath $virtio_iso_path -PassThru
$driveLetter = ($mountResult | Get-Volume).DriveLetter
$isoMountPath = "$($driveLetter):\"

Write-Output "Adding virtio-win drivers to boot image..."
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\NetKVM\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\pvpanic\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\qemupciserial\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\qemufwcfg\w11\amd64" -Recurse
# SMBus driver skipped - known installation issues
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\sriov\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viofs\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viogpudo\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\vioinput\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viomem\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viorng\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\vioscsi\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\vioserial\w11\amd64" -Recurse
Add-WindowsDriver -Path $mountfolder -Driver "$isoMountPath\viostor\w11\amd64" -Recurse

# Dismount virtio-win ISO
Dismount-DiskImage -ImagePath $virtio_iso_path

# Apply startnet.cmd from the windows/ directory to the boot image
Write-Output "Applying startnet.cmd..."
Copy-Item -Path "$scriptDir\startnet.cmd" -Destination "$mountfolder\Windows\System32\startnet.cmd" -Force

# Commit boot image changes
Write-Output "Committing changes and dismounting boot image..."
Dismount-WindowsImage -Path $mountfolder -Save -Verbose

# Build the final WinPE ISO
Write-Output "Creating WinPE ISO..."
MakeWinPEMedia -source $winpefolder -outputIso $isofile

Write-Output "WinPE ISO created at: $isofile"
