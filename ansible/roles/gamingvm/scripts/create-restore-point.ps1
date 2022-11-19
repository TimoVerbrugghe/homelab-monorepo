function New-RestorePoint() {
    Enable-ComputerRestore -Drive "$env:SystemDrive\"
    Checkpoint-Computer -Description "Win 10+ SDT Restore Point" -RestorePointType "MODIFY_SETTINGS"
}

New-RestorePoint