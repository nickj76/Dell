$module_name = "DellBIOSProvider"
Write-Output "Loading Dell module"
Import-Module $module_name -Force

$IsPasswordSet = (Get-Item -Path DellSmbios:\Security\IsAdminPasswordSet).currentvalue
If($IsPasswordSet -eq "true") {
	write-output "Your BIOS is password protected"
	#Exit 0
} Else {
	write-output "Your BIOS is not password protected"
	#Exit 1
}
