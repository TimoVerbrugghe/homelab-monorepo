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

        # Gaming
        "EpicGames.EpicGamesLauncher"
        "Valve.Steam"
        "Ubisoft.Connect"

        # Emulators
        "DolphinEmulator.Dolphin"
        "SteamGridDB.RomManager"
        "Libretro.RetroArch"
    )

    Install-WingetApps -WingetApps $WingetApps

}

Write-Host "Uninstalling Windows Terminal (from the MS Store) in order to reinstall it again through winget sources"
winget uninstall "windows terminal"

Write-Host "Installing Winget Apps"
Install-Apps


