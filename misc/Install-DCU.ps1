# Description - Script to install Dell Command Update
# Created - 05/10/2022
# Updated - 30/01/2023
# Dell Command Update Version - 4.7.1_A00
# MSI Version ID - 1309CCD0-A923-4203-8A92-377F37EE2C29
# Reference - https://www.dell.com/support/home/en-uk/drivers/driversdetails?driverid=cj0g9
# Reference - https://www.dell.com/support/manuals/en-uk/command-update/dellcommandupdate_rg/dell-command-%7C-update-cli-commands?guid=guid-92619086-5f7c-4a05-bce2-0d560c15e8ed&lang=en-us

Push-Location

# Set Variables
$DellCommandPath = "C:\Program Files\Dell\CommandUpdate"

# Start Logging
$PackageName = "Dell-Command-Update"
$PathLocal = "$Env:Programfiles\MDM"
Start-Transcript -Path "$PathLocal\Log\$PackageName-install.log" -Force

try {
		
	# Create Temp folder
	New-Item -ItemType Directory -Path "$PathLocal\Temp\$PackageName" -Force

	# Install Latest Dell Command Update
	Start-Process "Dell-Command-Update-Windows-Universal-Application_CJ0G9_WIN_4.7.1_A00.exe" -ArgumentList "/s" -Wait
	
	# Import Config - Force Overwrite of Existing Settings XML
	Copy-Item -Path "DellCommandMySettings.xml" -Destination "$PathLocal\Temp\$PackageName" -Force
	Set-Location -Path "$DellCommandPath"
	./dcu-cli.exe /configure -importSettings="$PathLocal\Temp\$PackageName\DellCommandMySettings.xml"
			
	# Disable Initial Welcome Screen
	if (Test-Path -Path "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG") {
		[void](New-ItemProperty -Path "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG" -Name "ShowSetupPopup" -Value 0 -PropertyType DWord -Force)
	}
	
}
catch {
	Write-Error $_
}

Stop-Transcript
Pop-Location