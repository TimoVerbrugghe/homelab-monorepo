function Install-WingetApps() {
    [CmdletBinding()]
    param (
        [Array] $WingetApps
    )

    ForEach ($WingetApp in $WingetApps) {
        Write-Host "Installing $WingetApp"
        winget install -e --id $WingetApp --accept-package-agreements --accept-source-agreements
    }
}

function Install-Apps() {
    $WingetApps = @(
        # Essentials
        "Google.Chrome"
        "Microsoft.WindowsTerminal"
        "7zip.7zip"
        "Nvidia.GeForceExperience"
        "Parsec.Parsec"
        "SoftwareFreedomConservancy.QEMUGuestAgent"
        "Bitwarden.Bitwarden"

        # Gaming
        "EpicGames.EpicGamesLauncher"
        "Valve.Steam"
        "Ubisoft.Connect"
        "ElectronicArts.EADesktop"

        # Emulators
        "DolphinEmulator.Dolphin"
        "SteamGridDB.RomManager"
        "Libretro.RetroArch"
    )

    Install-WingetApps -WingetApps $WingetApps

}

function PreReq() {
    winget source reset --force
    winget source update
    winget upgrade --all --accept-source-agreements
}

Write-Host "Doing prerequisites (resetting/upgrading winget)"
PreReq

Write-Host "Uninstalling Windows Terminal (from the MS Store) in order to reinstall it again through winget sources"
winget uninstall "windows terminal"

Write-Host "Installing Winget Apps"
Install-Apps