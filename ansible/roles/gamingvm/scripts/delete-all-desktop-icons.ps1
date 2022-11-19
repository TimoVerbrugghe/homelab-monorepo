# I like a clean desktop

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