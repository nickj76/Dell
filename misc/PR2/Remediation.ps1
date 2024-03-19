<#
.SYNOPSIS
    Update Dell Drivers using Dell Command Update. 

.DESCRIPTION
    Please make sure that Dell Command update is installed on the machines.
    
.NOTES
    Filename: DCU-Remediate.ps1
    1.0   -   Script created.
    1.1   -   Modified DCU_Severity setting to "Security,critial".
    1.2   -   fixed error with logging and update command.
    1.3   -   Modified /scan command to fix detection issue.

#>

$DCU_DIR = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
$DCU_Report = "C:\Temp\Dell_report"
$DCU_Log = "C:\Temp\Dell_report\DCU.log"
$DCU_category = "driver"  # bios,firmware,driver,application,others
$DCU_Severity = "security,critical" # recommended,urgent

Start-Process "$($DCU_DIR)" -ArgumentList "/scan -updateSeverity=$DCU_Severity -updateType=$DCU_category -report=$($DCU_Report)" -Wait
write-host "Checking for results."

$XMLExists = Test-Path "$DCU_Report\DCUApplicableUpdates.xml"
if (!$XMLExists) {
    write-host "Something went wrong. Waiting 60 seconds then trying again..."
    Start-Sleep -s 60
    Start-Process "$($DCU_DIR)" -ArgumentList "/scan -updateSeverity=$DCU_Severity -updateType=$DCU_category -report=$($DCU_Report)" -Wait
    $XMLExists = Test-Path "$DCU_Report\DCUApplicableUpdates.xml"
    write-host "Did the scan work this time? $XMLExists"
    if (!$XMLExists) {
        write-host "Something went wrong again, exiting.."
        Exit 0
    }
}

try{
    Start-Process "$($DCU_DIR)" -ArgumentList "/applyUpdates -silent -reboot=disable -updateSeverity=$DCU_Severity -updateType=$DCU_category -outputlog=$DCU_Log" -Wait
    Write-Output "Installation completed"
}catch{
    Write-Error $_.Exception
}
            
