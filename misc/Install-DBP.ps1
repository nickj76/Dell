# Trust PowerShell Gallery
Write-Output "Trust Powershell gallery"
If (Get-PSRepository | Where-Object { $_.Name -eq "PSGallery" -and $_.InstallationPolicy -ne "Trusted" }) {
    Install-PackageProvider -Name "NuGet" -MinimumVersion 2.8.5.208 -Force
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
}


# VC redist is required
#Write-Output "Installing VC redist for Dell BIOS module"
#Install-Module VcRedist -Force
#Import-Module VcRedist
#New-Item -Path "C:\temp\vcredist" -ItemType directory -Force
#$VcList = Get-VcList -Release 2022 | Get-VcRedist -Path "C:\temp\vcredist"
#$VcList | Install-VcRedist -Silent -Path C:\temp\vcredist


# Install or update module
$module_name = "DellBIOSProvider"
Write-Output "Install or update $module_name module"
$Installed = Get-Module -Name "$module_name" -ListAvailable | `
    Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | `
    Select-Object -First 1
$Published = Find-Module -Name "$module_name"
If ($Null -eq $Installed) {
    Install-Module -Name "$module_name"
}
ElseIf ([System.Version]$Published.Version -gt [System.Version]$Installed.Version) {
    Update-Module -Name "$module_name"
}
