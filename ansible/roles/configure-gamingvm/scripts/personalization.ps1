## Some personalization things for desktop, taskbar, UAC, etc...

function Test-RegistryValue {

    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]$Path,
    
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]$Setting
    )
    
    try {
        Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Setting -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
    
}
    
function Set-Registry-Setting {
    param (
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $Setting,
        [Parameter(Mandatory)] [int] $Value
    )

    # Check if the Path in the Registry exists
    if (Test-Path $Path) {

        if (Test-RegistryValue $Path $Setting) {
            # If the setting exists, set its value
            Set-ItemProperty -Path $Path -Name $Setting -Value $Value -Force
        }
        Else {
            # If the setting doesn't exist, create it
            New-ItemProperty -Path $Path -Name $Setting -Value $Value -Force
        }
    }
    Else {
        # If the Path doesn't exist, then the setting also doesn't exist, so create both (using Force to create any subpaths as well) 
        New-Item -Path $Path -Force
        New-ItemProperty -Path $Path -Name $Setting -Value $Value -Force
    }

}

function Remove-Desktop-Links {
    $public_desktop_location = "C:\Users\Public\Desktop"
    $public_desktop_links = Get-ChildItem -Path $public_desktop_location -file -filter *.lnk -Recurse | ForEach-Object { $_.FullName }
    foreach ($link in $public_desktop_links) {
        Remove-Item $link
    }

    # Remove links on user desktop (might have been created due to winget/chocolatey installation)
    $private_desktop_location = "$env:HOMEPATH\Desktop"
    $private_desktop_links = Get-ChildItem -Path $private_desktop_location -file -filter *.lnk -Recurse | ForEach-Object { $_.FullName }
    foreach ($link in $private_desktop_links) {
        Remove-Item $link
    }
}

function Disable-Desktop-Icons() {
    # Don't show ANY desktop icons
    $Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $Setting = "NoDesktop"
    $Value = 1

    Set-Registry-Setting $Path $Setting $Value
}

function Remove-Chat-Icon() {
    # Remove Chat Icon from the taskbar
    $Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $Setting = "TaskbarMn"
    $Value = 0

    Set-Registry-Setting $Path $Setting $Value
}

function Disable-Search() {
    # Remove Searchbar from the taskbar
    $Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    $Setting = "SearchboxTaskbarMode"
    $Value = 0

    Set-Registry-Setting $Path $Setting $Value

    $Setting = "BingSearchEnabled"

    Set-Registry-Setting $Path $Setting $Value

    $Setting = "CortanaConsent"
    Set-Registry-Setting $Path $Setting $Value
}

function Remove-Widgets() {
    # Remove Widget icon from the taskbar
    $Path = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
    $Setting = "AllowNewsAndInterests"
    $Value = 0

    Set-Registry-Setting $Path $Setting $Value
}

function Set-Dark-Mode() {
    # System Dark Mode
    $Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $Setting = "SystemUsesLightTheme"
    $Value = 0

    Set-Registry-Setting $Path $Setting $Value

    # App dark mode
    $Setting = "AppsUseLightTheme"
    $Value = 0
    Set-Registry-Setting $Path $Setting $Value
}

function Remove-Quick-Access-Pins() {
    # Remove all Quick Access Pins EXCEPT for Desktop & Downloads)
    $QuickAccess = New-Object -ComObject shell.application 
    $okItems = @("Desktop", "Downloads")

    # See if there are any quick access items that needs to be removed (aka not part of okItems)
    $QuickAccessItemsToRemove = $QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | Where-Object { $_.name -notin $okItems }
    if ($QuickAccessItemsToRemove) {
        $QuickAccessItemsToRemove.InvokeVerb("unpinfromhome")
    }  
    
}

function Set-UAC-Notifications() {
    $Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    $Setting = "ConsentPromptBehaviorAdmin"
    $Value = 0

    Set-Registry-Setting $Path $Setting $Value
}

function Disable-Sleep() {
    powercfg.exe -x -monitor-timeout-ac 0
    powercfg.exe -x -monitor-timeout-dc 0
    powercfg.exe -x -disk-timeout-ac 0
    powercfg.exe -x -disk-timeout-dc 0
    powercfg.exe -x -standby-timeout-ac 0
    powercfg.exe -x -standby-timeout-dc 0
    powercfg.exe -x -hibernate-timeout-ac 0
    powercfg.exe -x -hibernate-timeout-dc 0
    powercfg.exe -h off
}

function Enable-GameMode() {
    $Path = "HKCU:\SOFTWARE\Microsoft\GameBar"
    $Setting = "AllowAutoGameMode"
    $Value = 1

    Set-Registry-Setting $Path $Setting $Value 
    
    $Setting = "AutoGameModeEnabled"
    $Value = 1
    Set-Registry-Setting $Path $Setting $Value 
}

function Enable-HWAcceleratedGPUScheduling() {
    $Path = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    $Setting = "HwSchMode"
    $Value = 2

    Set-Registry-Setting $Path $Setting $Value 
}

function Disable-Ndu() {
    # Network Data Usage Monitoring 
    $Path = "HKLM:\SYSTEM\ControlSet001\Services\Ndu"
    $Setting = "Start"
    $Value = 4

    Set-Registry-Setting $Path $Setting $Value 
}

function Enable-WindowsStoreAutoUpdate() {
    $Path = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    $Setting = "AutoDownload"
    # 4 is enabled, 2 is disabled
    $Value = 4

    Set-Registry-Setting $Path $Setting $Value
    
}

function Enable-UltimatePowerPlan() {
    $HighPerformancePowerPlanGuid="8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    $UltimatePowerPlanGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    $DestinationGuid = "06bdb311-c4dd-4fc5-a665-32f3c2291067"

    # Set power plan to High Performance
    powercfg -SetActive $HighPerformancePowerPlanGuid

    # Make sure that destinationGuid doesn't exist yet as Power plan (redirect errors if it doesn't exist)
    powercfg -Delete $DestinationGuid >$null 2>$null

    # Duplicate ultimatepowerplan & set it as active
    powercfg -DuplicateScheme $UltimatePowerPlanGuid $DestinationGuid
    powercfg -SetActive $DestinationGuid
}

function Set-AnimationSpeed() {
    # Sets animation speed to 100ms
    $Path = "HKCU:\Control Panel\Desktop"
    $Setting = "MenuShowDelay"
    $Value = 100

    Set-Registry-Setting $Path $Setting $Value
}

function Disable-FileExplorerAds() {
    $Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $Setting = "ShowSyncProviderNotifications"
    $Value = 0

    Set-Registry-Setting $Path $Setting $Value
}

function Enable-WindowsAutoUpdate() {
    $Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $Setting = "AUOptions"
    # Automatic download and scheduled installation.
    $Value = 4 

    Set-Registry-Setting $Path $Setting $Value

    $Setting = "AutoInstallMinorUpdates"
    $Value = 1

    Set-Registry-Setting $Path $Setting $Value

    $Setting = "NoAutoRebootWithLoggedOnUsers"
    $Value = 1

    Set-Registry-Setting $Path $Setting $Value

    $Setting = "NoAutoUpdate"
    $Value = 0

    Set-Registry-Setting $Path $Setting $Value

    $Setting = "ScheduledInstallDay"
    # 0 = every day, 1 through 7 = days of the week
    $Value = 0

    Set-Registry-Setting $Path $Setting $Value

    $Setting = "ScheduledInstallTime"
    # Hour in 24 hour format, 0-23
    $Value = 6

    Set-Registry-Setting $Path $Setting $Value  
    
    $Setting = "IncludeRecommendedUpdates"
    $Value = 1

    Set-Registry-Setting $Path $Setting $Value
}

function Disable-Notifications() {
    $Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications"
    $Setting="ToastEnabled"
    $Value=0

    Set-Registry-Setting $Path $Setting $Value
}

function Set-LangKeyboard() {
    # Creates a new language list with English (US), together with Belgian Period layout (00000813) and forcefully applies it as the language list in Windows

    $Lang = New-WinUserLanguageList en-US
    $Lang[0].InputMethodTips.Clear()
    $Lang[0].InputMethodTips.Add('0409:00000813')
    Set-WinUserLanguageList -LanguageList $Lang -Force
    Set-Culture -CultureInfo en-BE
}

# Desktop, Taskbar, Themes
Remove-Desktop-Links
Disable-Desktop-Icons
Remove-Chat-Icon
Disable-Search
Remove-Widgets
Set-Dark-Mode
Remove-Quick-Access-Pins
Set-UAC-Notifications
Set-AnimationSpeed
Disable-Notifications

# Performance
Enable-UltimatePowerPlan
Disable-Sleep
Enable-GameMode
Enable-HWAcceleratedGPUScheduling
Disable-Ndu
Enable-WindowsStoreAutoUpdate

# Privacy
Disable-FileExplorerAds

# Windows Updates
Enable-WindowsAutoUpdate

# Set Language & Keyboard Layout
Set-LangKeyboard