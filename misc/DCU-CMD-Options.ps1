# Execute the script
Start-Process -FilePath "\\server\apps\Dell-Command-Update-Windows-Universal-Application_1WR6C_WIN_5.0.0_A00.exe" -ArgumentList '/s' -Wait

# Disable the initial setup popup in the Windows Registry for Dell Command Update
New-ItemProperty -Path "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG" -Name "ShowSetupPopup" -PropertyType DWORD -Value 0 -Force

# Define the paths for the Dell Command Update executable and the settings XML
$DellCommandPath = "C:\Program Files\Dell\CommandUpdate"
$SettingsXmlPath = "\\server\apps\SML\5.0.0\DCUMySettings.xml"

# Run the Dell Command Update tool to import settings
Start-Process -FilePath "$DellCommandPath\dcu-cli.exe" -ArgumentList "/configure -importSettings=$SettingsXmlPath" -NoNewWindow -Wait

# Lock the Dell Command Update settings
Start-Process -FilePath "$DellCommandPath\dcu-cli.exe" -ArgumentList "/configure -lockSettings=enable" -NoNewWindow -Wait

# Scan for updates (BIOS and firmware)
Start-Process -FilePath "$DellCommandPath\dcu-cli.exe" -ArgumentList "/scan -updateType=bios,firmware" -NoNewWindow -Wait

# Disable updates notification
Start-Process -FilePath "$DellCommandPath\dcu-cli.exe" -ArgumentList "/configure -updatesNotification=disable" -NoNewWindow -Wait

# Apply updates silently, enable reboot, and log the output
$LogPath = "C:\Dell-CU-apply.log"
Start-Process -FilePath "$DellCommandPath\dcu-cli.exe" -ArgumentList "/applyUpdates -silent -reboot=disable -outputLog=$LogPath" -NoNewWindow -Wait

# Run the Dell Command Update tool to import settings
Start-Process -FilePath "$DellCommandPath\dcu-cli.exe" -ArgumentList "/configure -importSettings=$SettingsXmlPath" -NoNewWindow -Wait

# Define the paths for the Dell Command Update executable and the settings XML using registery
$process = Start-Process reg -ArgumentList "import \\server\apps\reg\5.0.0\DCU_Preferences_Value.reg" -PassThru -Wait 
$process.ExitCode

# Define the paths for the Dell Command Update executable and the settings XML using registery #2

if((Test-Path -LiteralPath "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences") -ne $true) {  New-Item "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\CFG") -ne $true) {  New-Item "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\CFG" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings") -ne $true) {  New-Item "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\AdvancedDriverRestore") -ne $true) {  New-Item "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\AdvancedDriverRestore" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\General") -ne $true) {  New-Item "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\General" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule") -ne $true) {  New-Item "HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\CFG' -Name '(default)' -Value '' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\CFG' -Name 'ShowSetupPopup' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\CFG' -Name 'LockSettings' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings' -Name 'InstallPath' -Value 'C:\Program Files\Dell\CommandUpdate\' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings' -Name 'ProductVersion' -Value '5.0.0' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings' -Name 'AppCode' -Value 'Universal' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\AdvancedDriverRestore' -Name 'IsAdvancedDriverRestoreEnabled' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\General' -Name 'UserConsentDefault' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\General' -Name 'SuspendBitLocker' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\General' -Name 'SettingsModifiedTime' -Value '10/16/2023 9:19:49 PM' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule' -Name 'DisableNotification' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule' -Name 'ScheduleMode' -Value 'Monthly' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule' -Name 'MonthlyScheduleMode' -Value 'WeekDayOfMonth' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule' -Name 'WeekOfMonth' -Value 'last' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule' -Name 'Time' -Value '2023-10-11T23:45:00' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule' -Name 'DayOfWeek' -Value 'Sunday' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule' -Name 'DayOfMonth' -Value '28' -PropertyType String -Force -ea SilentlyContinue;