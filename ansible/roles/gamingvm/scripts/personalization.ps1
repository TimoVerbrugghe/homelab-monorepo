## Cleanup Desktop
# Remove links on public desktop (might have been created due to winget/chocolatey installation)
$public_desktop_location = "C:\Users\Public\Desktop"
$public_desktop_links = Get-ChildItem -Path $public_desktop_location -file -filter *.lnk -Recurse | ForEach-Object{$_.FullName}
foreach ($link in $public_desktop_links) {
    Remove-Item $link
}

# Remove links on user desktop (might have been created due to winget/chocolatey installation)
$private_desktop_location = "$env:HOMEPATH\Desktop"
$private_desktop_links = Get-ChildItem -Path $private_desktop_location -file -filter *.lnk -Recurse | ForEach-Object{$_.FullName}
foreach ($link in $private_desktop_links) {
    Remove-Item $link
}

# Disable showing of any desktop icon
$Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$Setting="NoDesktop"
$Exist="Get-ItemProperty -Path $Path -Name $Setting"
if ($Exist)
{
    Set-ItemProperty -Path $Path -Name $Setting -Value 1 -Force
}
Else
{
    New-ItemProperty -Path $path -Name $Setting -Value 1 -Force
}

## Cleanup Taskbar
# Remove Chat Icon

# Remove search bar

# Remove widget icon

# $Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
# $Setting="NoDesktop"
# $Exist="Get-ItemProperty -Path $Path -Name $Setting"
# if ($exist)
# {
#     Set-ItemProperty -Path $Path -Name $Setting -Value 1 -Force
# }
# Else
# {
#     New-ItemProperty -Path $path -Name $Setting -Value 1 -Force
# }


## Set Dark Mode