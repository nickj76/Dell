<#
.SYNOPSIS

PSApppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION

- The script is provided as a template to perform an install or uninstall of an application(s).
- The script either performs an "Install" deployment type or an "Uninstall" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.

PSApppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2024 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham and Muhammad Mashwani).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType

The type of deployment to perform. Default is: Install.

.PARAMETER DeployMode

Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru

Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode

Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging

Disables logging to file for the script. Default is: $false.

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"

.EXAMPLE

Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"

.INPUTS

None

You cannot pipe objects to this script.

.OUTPUTS

None

This script does not generate any output.

.NOTES

Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
- 69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
- 70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1

.LINK

https://psappdeploytoolkit.com
#>


[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [String]$DeploymentType = 'Install',
    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [String]$DeployMode = 'Interactive',
    [ValidateSet('Application','Bios','Driver','Firmware','Others','All')]
	[string]$UpdateType = 'All',
    [Parameter(Mandatory = $false)]
    [switch]$AllowRebootPassThru = $false,
    [Parameter(Mandatory = $false)]
    [switch]$TerminalServerMode = $false,
    [Parameter(Mandatory = $false)]
    [switch]$DisableLogging = $false
)

Try {
    ## Set the script execution policy for this process
    Try {
        Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop'
    } Catch {
    }

    ##*===============================================
    ##* VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
    [String]$appVendor = 'University of Surrey'
    [String]$appName = 'Deploy Driver Updates'
    [String]$appVersion = '1.4'
    [String]$appArch = 'x86/x64'
    [String]$appLang = 'EN'
    [String]$appRevision = '01'
    [String]$appScriptVersion = '1.0.0'
    [String]$appScriptDate = '30/04/2024'
    [String]$appScriptAuthor = 'Nick Jenkins'
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
    [String]$installName = ''
    [String]$installTitle = ''

    ##* Do not modify section below
    #region DoNotModify

    ## Variables: Exit Code
    [Int32]$mainExitCode = 0

    ## Variables: Script
    [String]$deployAppScriptFriendlyName = 'Deploy Application'
    [Version]$deployAppScriptVersion = [Version]'3.10.0'
    [String]$deployAppScriptDate = '03/27/2024'
    [Hashtable]$deployAppScriptParameters = $PsBoundParameters

    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') {
        $InvocationInfo = $HostInvocation
    }
    Else {
        $InvocationInfo = $MyInvocation
    }
    [String]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [String]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) {
            Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]."
        }
        If ($DisableLogging) {
            . $moduleAppDeployToolkitMain -DisableLogging
        }
        Else {
            . $moduleAppDeployToolkitMain
        }
    }
    Catch {
        If ($mainExitCode -eq 0) {
            [Int32]$mainExitCode = 60008
        }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') {
            $script:ExitCode = $mainExitCode; Exit
        }
        Else {
            Exit $mainExitCode
        }
    }

    #endregion
    ##* Do not modify section above
    ##*===============================================
    ##* END VARIABLE DECLARATION
    ##*===============================================

    If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
        ##*===============================================
        ##* PRE-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Installation'

        ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
       ##  Show-InstallationWelcome -CloseApps 'processName' -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Installation tasks here>
        ## Check if Run Once Schedule task to delete intune detection method is present and delete.
        $DELTaskName = "Dell_Driver_Updates"

        # Check if the task exists
        $DELTaskExists = Get-ScheduledTask -TaskName $DELTaskName -ErrorAction SilentlyContinue

        if ($DELTaskExists) {
            # Delete the task
            Unregister-ScheduledTask -TaskName $DELTaskName -Confirm:$false
            Write-Log "(Pre-Install) Task '$DELTaskName' has been deleted."
        } else {
            Write-Log "(Pre-Install) Task '$DELTaskName' does not exist.  Moving on to Installation"
        }

        ## Check computer connected to AC Power
        While (-not (Test-Battery))
            {
            if ((Show-InstallationPrompt -Message 'Connect AC power to proceed with Dell updates or Cancel installation' -ButtonRightText 'Cancel' -ButtonLeftText 'Proceed' -PersistPrompt) -eq 'Cancel')
        {
            Write-Log -Message 'User canceled' -Severity 2
            Exit-Script 60012
        }
            }
            Write-Log -Message 'User has AC connected'

        ##*===============================================
        ##* INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Installation'

        ## Handle Zero-Config MSI Installations
        If ($useDefaultMsi) {
            [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
            }
            Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) {
                $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ }
            }
        }

        ## <Perform Installation tasks here>
        $DCU_DIR = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
        $DCU_Report = "C:\Temp\DCU_Report\"
        $DCU_Log = "C:\Temp\DCU_Report\DCU.log"
        $DCU_category = "bios,driver,application,firmware,others" ## bios,firmware,driver,application,others 
        $DCU_encryptionKey = "" ## Use the same value here as you use in /generateEncryptedPassword -encryptionKey=
        $DCU_encryptedPassword = "" ## Generate with dcu-cli.exe /generateEncryptedPassword -encryptionKey=<inline value> -password=<inlinevalue> -outputPath=<folderpath>
        
        ## Disabling DCU update notifications
        Write-Log "Disabling update notifications"
        Start-Process "$($DCU_DIR)" -ArgumentList "/configure -updatesNotification=disable" -NoNewWindow -Wait

        Write-Log -Message "Create update report using Dell Command Update Cli"
        show-installationprogress -statusmessage "Scanning system for updates..."
        Start-Process "$($DCU_DIR)" -ArgumentList "/scan -updateType=$DCU_category -report=$($DCU_Report)" -Wait -WindowStyle Hidden
        Write-Log "Checking for results." 

        Write-Log -Message "Check dell_report.xml exists"
        if(Test-Path C:\Temp\DCU_Report\DCUApplicableUpdates.xml)
            {
                $data = [XML](Get-Content C:\Temp\DCU_Report\DCUApplicableUpdates.xml)
                
                switch ($UpdateType)
                    {
                        "All"
                            {
                                foreach($update in $data.updates.update)
                                    {
                                        $release = $update.release
                                        $updatename = $update.name
                                        show-installationprogress -statusmessage "Installing $updatename"
                                        Write-Log -Message "Updating Bios" 
                                        if($update.type -like "*bios*")
                                            {
                                                Start-Process "$($DCU_DIR)" -ArgumentList "/applyUpdates -silent -reboot=disable -updateType=bios -outputlog=$DCU_Log -autoSuspendBitLocker=enable -encryptedPassword=$DCU_encryptedPassword -encryptionKey=$DCU_encryptionKey" -Wait -WindowStyle Hidden
                                            }
                                        else
                                            {
                                                Start-Process "$($DCU_DIR)" -ArgumentList "/applyUpdates -silent -reboot=disable -updateType=driver,application,firmware,others -outputlog=$DCU_Log" -Wait -WindowStyle Hidden
                                            }
                                    }
                            }
                        "Bios"
                            {
                                foreach($update in $data.updates.update)
                                    {
                                        $release = $update.release
                                        $updatename = $update.name
                                        Write-Log -Message "Updating Bios"
                                        if($update.type -like "*bios*")
                                            {
                                                show-installationprogress -statusmessage "Installing $updatename"
                                                Start-Process "$($DCU_DIR)" -ArgumentList "/applyUpdates -silent -reboot=disable -updateType=bios -outputlog=$DCU_Log -autoSuspendBitLocker=enable -encryptedPassword=$DCU_encryptedPassword -encryptionKey=$DCU_encryptionKey" -Wait -WindowStyle Hidden
                                            }
                                    }
                            }
                        "Driver"
                            {
                                foreach($update in $data.updates.update)
                                    {
                                        $release = $update.release
                                        $updatename = $update.name
                                        Write-Log -Message "Updating Drivers"                                        
                                        if($update.type -like "*driver*")
                                            {
                                                show-installationprogress -statusmessage "Installing $updatename"
                                                Start-Process "$($DCU_DIR)" -ArgumentList "/applyUpdates -silent -reboot=disable -updateType=driver -outputlog=$DCU_Log" -Wait -WindowStyle Hidden
                                            }
                                    }
                            }
                        "Application"
                            {
                                foreach($update in $data.updates.update)
                                    {
                                        $release = $update.release
                                        $updatename = $update.name  
                                        Write-Log -Message "Updating Dell Application"                                      
                                        if($update.type -like "*application*")
                                            {
                                                show-installationprogress -statusmessage "Installing $updatename"
                                                Start-Process "$($DCU_DIR)" -ArgumentList "/applyUpdates -silent -reboot=disable -updateType=application -outputlog=$DCU_Log" -Wait -WindowStyle Hidden
                                            }
                                    }
                            }
                        "Firmware"
                            {
                                foreach($update in $data.updates.update)
                                    {
                                        $release = $update.release
                                        $updatename = $update.name
                                        Write-Log -Message "Updating Dell Firmware"  
                                        if($update.type -like "*firmware*")
                                            {
                                                show-installationprogress -statusmessage "Installing $updatename"
                                                Start-Process "$($DCU_DIR)" -ArgumentList "/applyUpdates -silent -reboot=disable -updateType=firmware -outputlog=$DCU_Log" -Wait -WindowStyle Hidden
                                            }
                                    }
                            }
                        "Other"
                            {
                                foreach($update in $data.updates.update)
                                    {
                                        $release = $update.release
                                        $updatename = $update.name
                                        Write-Log -Message "Updating Other Drivers"  
                                        if($update.category -like "*other*")
                                            {
                                                show-installationprogress -statusmessage "Installing $updatename"
                                                Start-Process "$($DCU_DIR)" -ArgumentList "/applyUpdates -silent -reboot=disable -updateType=other -outputlog=$DCU_Log" -Wait -WindowStyle Hidden
                                            }
                                    }
                            }
                    }
            }
        else
            {
                Write-Log -Message "No updates available.."
                show-installationprogress -statusmessage "No updates available.."
                start-sleep -Seconds 5
            }

        ##*===============================================
        ##* POST-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Installation'

        ## <Perform Post-Installation tasks here>
        ## Create Intune detection method
        Set-RegistryKey -Key HKEY_LOCAL_MACHINE\SOFTWARE\Intune_Installations -Name 'Dell_Driver_Updates' -Value '"Installed"'-Type String
        
        ## Schedule Task to delete Dell driver update detection method 1 hour after running this app.
        ## Create schedule task 
        $STTriggerTime = (Get-Date).AddHours(1)
        # The name of your scheduled task.
        $taskName = "Dell_Driver_Updates"
        # Describe the scheduled task.
        $description = "Delete Dell Driver Update Detection Method 1 hours after run so it could be run again."
        # Create a new task action
        $taskAction = New-ScheduledTaskAction `
            -Execute 'powershell.exe' `
            -Argument 'Remove-ItemProperty -Path "HKLM:\SOFTWARE\Intune_Installations" -Name "Dell_Driver_Updates"'
        #Create task trigger
        $taskTrigger = New-ScheduledTaskTrigger -Once -At $STTriggerTime
        # create a SYSTEM principle
        $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

        # Register the new PowerShell scheduled task
        # Register the scheduled task
        Register-ScheduledTask `
            -TaskName $taskName `
            -Action $taskAction `
            -Trigger $taskTrigger `
            -Description $description `
            -Principal $principal

        # Show reboot notification
        Show-InstallationRestartPrompt -Countdownseconds 600 -CountdownNoHideSeconds 60
        
        ## Display a message at the end of the install - ## See original PSADT Deploy-Application.ps1 file from GitHub if you want to use this feature
        If (-not $useDefaultMsi) {}
    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
        ##*===============================================
        ##* PRE-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Uninstallation'

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
        #Show-InstallationWelcome -CloseApps 'processName' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Uninstallation tasks here>


        ##*===============================================
        ##* UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Uninstallation'

        ## Handle Zero-Config MSI Uninstallations
        If ($useDefaultMsi) {
            [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
            }
            Execute-MSI @ExecuteDefaultMSISplat
        }

        ## <Perform Uninstallation tasks here>
        ## Check if Run Once Schedule task to delete intune detection method is present and delete.
        $DELTaskName = "Dell_Driver_Updates"

        # Check if the task exists
        $DELTaskExists = Get-ScheduledTask -TaskName $DELTaskName -ErrorAction SilentlyContinue

        if ($DELTaskExists) {
            # Delete the task
            Unregister-ScheduledTask -TaskName $DELTaskName -Confirm:$false
            Write-Log "(Pre-Install) Task '$DELTaskName' has been deleted."
        } else {
            Write-Log "(Pre-Install) Task '$DELTaskName' does not exist.  Moving on to Installation"
        }

        ##*===============================================
        ##* POST-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Uninstallation'

        ## <Perform Post-Uninstallation tasks here>
        Remove-RegistryKey -Key HKEY_LOCAL_MACHINE\SOFTWARE\Intune_Installations -Name 'Dell_Driver_Updates'

    }
    ElseIf ($deploymentType -ieq 'Repair') {
        ##*===============================================
        ##* PRE-REPAIR
        ##*===============================================
        [String]$installPhase = 'Pre-Repair'

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
        Show-InstallationWelcome -CloseApps 'processName' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Repair tasks here>

        ##*===============================================
        ##* REPAIR
        ##*===============================================
        [String]$installPhase = 'Repair'

        ## Handle Zero-Config MSI Repairs
        If ($useDefaultMsi) {
            [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Repair'; Path = $defaultMsiFile; }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
            }
            Execute-MSI @ExecuteDefaultMSISplat
        }
        ## <Perform Repair tasks here>

        ##*===============================================
        ##* POST-REPAIR
        ##*===============================================
        [String]$installPhase = 'Post-Repair'

        ## <Perform Post-Repair tasks here>


    }
    ##*===============================================
    ##* END SCRIPT BODY
    ##*===============================================

    ## Call the Exit-Script function to perform final cleanup operations
    Exit-Script -ExitCode $mainExitCode
}
Catch {
    [Int32]$mainExitCode = 60001
    [String]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}
