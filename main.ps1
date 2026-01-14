$start = cscript.exe //nologo "start_message.vbs"
if ($LASTEXITCODE -ne 0) { exit }

$log = Join-Path $PSScriptRoot "log.log"
function Log($m) {
    $t = (Get-Date).ToString("HH:mm:ss.ffff")
    $line = "$t $m"
    Add-Content -Path $log -Value $line
    Write-Host $line
}

Log "Starting Windows 11 cleanup"

$bloat = @(
    "Microsoft.3DBuilder"
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.MicrosoftTeams"
    "Microsoft.MicrosoftTips"
    "Microsoft.MicrosoftWhiteboard"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.SkypeApp"
    "Microsoft.Todos"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "Microsoft.MicrosoftNews"
    "Microsoft.WindowsCommunicationsApps"
)

foreach ($p in $bloat) {
    Log "Removing app: $p"
    Get-AppxPackage -AllUsers -Name $p -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "$p*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    if ($LASTEXITCODE -ne 0) { Log "Failed to remove $p" }
}

Log "Disabling Copilot"
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type DWord -Value 0

Log "Disabling ads and suggestions"
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0

Log "Disabling lock screen tips"
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen" -Name "SlideshowEnabled" -Type DWord -Value 0

Log "Disabling Bing in Start"
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1

Log "Disabling Widgets"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0

Log "Disabling Teams autostart"
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MicrosoftTeams" -ErrorAction SilentlyContinue

Log "Disabling Xbox services"
$svcs = @(
    "XboxGipSvc"
    "XboxNetApiSvc"
    "XblAuthManager"
    "XblGameSave"
)
foreach ($s in $svcs) {
    Log "Stopping service: $s"
    Get-Service -Name $s -ErrorAction SilentlyContinue | ForEach-Object {
        Stop-Service $_ -ErrorAction SilentlyContinue
        Set-Service $_ -StartupType Disabled
    }
    if ($LASTEXITCODE -ne 0) { Log "Could not stop $s" }
}

Log "Restoring classic context menu"
New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(default)" -Value ""

Log "Disabling user engagement suggestions"
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0

Log "Disabling Start recent items"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type DWord -Value 0

Log "Disabling Start frequent apps"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0

Log "Disabling Start web search"
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1

Log "Configuring Start menu for classic style"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_ShowClassicMode" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 0

Log "Setting CMD font"
New-Item -Path "HKCU:\Console" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Console" -Name "FaceName" -Value ""
Set-ItemProperty -Path "HKCU:\Console" -Name "FontFamily" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Console" -Name "FontSize" -Type DWord -Value 0x00120000

Log "Blocking Bing"
$hosts = "C:\Windows\System32\drivers\etc\hosts"
$bingEntries = @(
"127.0.0.1 bing.com"
"127.0.0.1 www.bing.com"
"127.0.0.1 cn.bing.com"
"127.0.0.1 api.bing.com"
"127.0.0.1 bingapis.com"
"127.0.0.1 www.bingapis.com"
"127.0.0.1 edgeservices.bing.com"
"127.0.0.1 www.bing.net"
)
foreach ($e in $bingEntries) {
    Add-Content -Path $hosts -Value $e
    Log "Blocked Bing URL: $e"
}
New-NetFirewallRule -DisplayName "Block Bing" -Direction Outbound -RemoteFqdn "*.bing.com" -Action Block | Out-Null
New-NetFirewallRule -DisplayName "Block Bing APIs" -Direction Outbound -RemoteFqdn "*.bingapis.com" -Action Block | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows NT\DNSClient" /v DoHPolicy /t REG_DWORD /d 0 /f | Out-Null

Log "Cleanup complete."
cscript.exe //nologo "end_message.vbs"

cscript.exe //nologo "open_log.vbs"