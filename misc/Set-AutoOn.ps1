$adm_pw = "password"

(Get-Item -Path DellSmbios:\PowerManagement\AutoOn).currentvalue

# can be Disabled, Everyday, Weekdays, and SelectDays
# disable
Set-Item -Path DellSmbios:\PowerManagement\AutoOn -Value "Disabled" -Password "$adm_pw"

# every day
Set-Item -Path DellSmbios:\PowerManagement\AutoOn -Value "Everyday" -Password "$adm_pw"

# weekdays
Set-Item -Path DellSmbios:\PowerManagement\AutoOn -Value "Weekdays" -Password "$adm_pw"

# select days
Set-Item -Path DellSmbios:\PowerManagement\AutoOn -Value "SelectDays" -Password "$adm_pw"


