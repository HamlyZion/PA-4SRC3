Start-Transcript -Path C:\postinstall.log

$cd = (Get-PSDrive -PSProvider FileSystem | Where-Object { Test-Path "$($_.Root)virtio" } | Select-Object -First 1).Root

$msi = Join-Path $cd "virtio\virtio-win-gt-x64.msi"
if (Test-Path $msi) { Start-Process msiexec -ArgumentList "/i `"$msi`" /qn /norestart" -Wait }

$nic = (Get-NetAdapter | Where-Object Status -eq Up | Select-Object -First 1)
New-NetIPAddress -InterfaceIndex $nic.ifIndex -IPAddress 10.10.30.11 -PrefixLength 24 -DefaultGateway 10.10.30.1
Set-DnsClientServerAddress -InterfaceIndex $nic.ifIndex -ServerAddresses 10.10.30.10

Enable-PSRemoting -Force -SkipNetworkProfileCheck
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System `
  -Name LocalAccountTokenFilterPolicy -Value 1 -PropertyType DWord -Force
New-NetFirewallRule -DisplayName "WinRM 5985 (lab)" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow

Stop-Transcript

