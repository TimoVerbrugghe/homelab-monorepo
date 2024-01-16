$mountfolder="C:\WinPE_amd64\mount"
$bootimage="C:\WinPE_amd64\media\sources\boot.wim"
$adk_winpe="C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64"

# Mount Boot image to make modifications to it
Mount-WindowsImage -Path $mountfolder -ImagePath $bootimage -Index 1 -Verbose

# Add WinPE-WMI and WinPE-SecureStartup packages since this is needed for Windows 11 installation
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-WMI_en-us.cab" -Path $mountfolder -Verbose
Add-WindowsPackage -PackagePath "$adk_winpe\WinPE_OCs\en-us\WinPE-SecureStartup_en-us.cab" -Path $mountfolder -Verbose

# Add Virtio drivers
Add-WindowsDriver -Path $mountfolder -Driver "<Driver_INF_source_path>\<driver>.inf"

# Apply latest cumulative update
Add-WindowsPackage -PackagePath "<Path_to_CU_MSU_update>\<CU>.cab" -Path $mountfolder -Verbose

## Copy boot files from the mounted image where we applied the update
# Backup bootmgr file & update it from the mounted image
Copy-Item "$adk_winpe\Media\bootmgr.efi" "$adk_winpe\Media\bootmgr.bak.efi"
Copy-Item "$mountfolder\Windows\Boot\EFI\bootmgr.efi" "$adk_winpe\Media\bootmgr.efi"

# Backup boot firmware & update it from the mounted image
Copy-Item "$adk_winpe\Media\EFI\Boot\bootx64.efi" "$adk_winpe\Media\EFI\Boot\bootx64.bak.efi"

Copy-Item "$mountfolder\Windows\Boot\EFI\bootmgfw.efi" "$adk_winpe\Media\EFI\Boot\bootx64.efi"

