$username = "Administrator"
$password = ConvertTo-SecureString -String "administrator" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

$session_option = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Invoke-Command -ComputerName localhost -UseSSL -ScriptBlock { ipconfig } -Credential $cred -SessionOption $session_option