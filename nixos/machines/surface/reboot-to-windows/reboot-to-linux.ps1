# Check if the script is running with administrative privileges
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Relaunch the script with administrative privileges if not already elevated
if (-not (Test-Admin)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Run the bcdedit command to get all boot entries and capture the output
$bcdeditOutput = bcdedit /enum FIRMWARE | Out-String

# Extract the relevant section by splitting on double newlines
$entries = $bcdeditOutput -split "\r?\n\r?\n"

### GETTING PRELOADER GUID ###
# Initialize variable
$preloaderGuid = $null

# Loop through each entry
foreach ($entry in $entries) {
    # Check if the entry contains "description             PreLoader"
    if ($entry -match "description\s+PreLoader") {
        # Extract the GUID from the identifier line
        if ($entry -match "identifier\s+({[0-9a-fA-F-]+})") {
            $preloaderGuid = $matches[1]
            break
        }
    }
}

# Output the found GUID
if ($preloaderGuid) {
    Write-Output "The GUID of the firmware application with description 'PreLoader' is: $preloaderGuid"
} else {
    Write-Output "No firmware application with description 'PreLoader' found."
}

### GETTING Linux Boot Manager GUID ###
# Initialize variable
$linuxBootManagerGuid = $null

# Loop through each entry
foreach ($entry in $entries) {
    # Check if the entry contains "description             Linux Boot Manager"
    if ($entry -match "description\s+Linux Boot Manager") {
        # Extract the GUID from the identifier line
        if ($entry -match "identifier\s+({[0-9a-fA-F-]+})") {
            $linuxBootManagerGuid = $matches[1]
            break
        }
    }
}

# Output the found GUID
if ($linuxBootManagerGuid) {
    Write-Output "The GUID of the firmware application with description 'Linux Boot Manager' is: $linuxBootManagerGuid"
} else {
    Write-Output "No firmware application with description 'Linux Boot Manager' found."
}

# If Preloader & Linux Boot Manager is found, set boot loader order accordingly
if ($preloaderGuid -and $linuxBootManagerGuid) {
    # Set the Preloader as the first boot option
    bcdedit /set "{fwbootmgr}" displayorder "$preloaderGuid" "{bootmgr}" "$linuxBootManagerGuid"

    # Confirm the change
    Write-Host "Linux boot order set as the first boot option."
} else {
    Write-Host "WARNING - Unable to find the correct Linux Boot Order entries, please check"
}

Read-Host "Press Enter to exit..."

# # Reboot the system
# Restart-Computer