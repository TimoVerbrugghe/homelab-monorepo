# Check if the script is running with administrative privileges
# if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
#     $arguments = "& '" + $myinvocation.mycommand.definition + "'"
#     Start-Process powershell -Verb runAs -ArgumentList $arguments
#     exit
# }

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


# If Preloader & Linux Boot Manager is found, set boot loader order accordingly
if ($preloaderGuid -and $linuxBootManagerGuid) {
    # Set the Preloader as the first boot option
    bcdedit /set "{fwbootmgr}" displayorder "$preloaderGuid" "{bootmgr}" "$linuxBootManagerGuid"
} else {
    Write-Host "WARNING - Unable to find the correct Linux Boot Order entries, please check your setup. Not rebooting to NixOS."
    exit 1
}

# Reboot the system
Restart-Computer