#Script to trigger Dell BIOS upgrade process
$DCU_encryptionKey = "ADD ENC KEY" # Use the same value here as you use in /generateEncryptedPassword -encryptionKey=
$DCU_encryptedPassword = "ADD ENC PWD" # Generate with dcu-cli.exe /generateEncryptedPassword -encryptionKey=<inline value> -password=<inlinevalue> -outputPath=<folderpath>


# Directory for logs.
$Target = "C:\Dell"
 
# If local path for logs doesn't exist, create it
If (!(Test-Path $Target)) { New-Item -Path $Target -Type Directory -Force }
 
 
#Check for AC power and exit if missing
Add-Type -Assembly System.Windows.Forms
$PowerStatus = [System.Windows.Forms.SystemInformation]::PowerStatus
If ($PowerStatus.PowerLineStatus -eq "Offline") {exit 1618}
 
#Make sure device is actually a dell.
$PCInfo = (Get-WMIObject -Query "Select * from Win32_ComputerSystem" | Select-Object -Property Manufacturer, Model) 

 
#Execute Dell Command Update
if ($PCInfo.Manufacturer -eq "Dell Inc." ){
 
	If (Test-Path -Path "c:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe") {$DCUexe = "c:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"}
	If (Test-Path -Path "c:\Program Files\Dell\CommandUpdate\dcu-cli.exe") {$DCUexe = "c:\Program Files\Dell\CommandUpdate\dcu-cli.exe"}
	$DCUparameters = "/applyUpdates -silent -AutoSuspendBitlocker=enable -encryptedPassword=$DCU_encryptedPassword -encryptionKey=$DCU_encryptionkey -outputLog=C:\Dell\DCUinstall.log -updateType=bios,firmware -reboot=Disable"
	$Params = $DCUparameters.Split(" ")
	& $DCUexe $Params
	exit $lastExitCode
}