# Dell_Driver_Updates
Dell Driver Updates PSADT Template

This package will use Dell's Command Update command line to scan the computers for hardware, then cross check it with Dell's model catalog and install the drivers from Dell's site. 

If computer not connected to AC Power user will be prompted to connect to AC power before proceeding or cancel.

Script contains a shedule task which will delete the intune detection after 12 hours so it can be run again at a later date from Company Portal.   

Added switch for UpdateType (All, Bios, Firmware, Driver, Application, Others) Default: All

Example: Deploy-Application.exe -UpdateType Bios
Result: Updates ONLY the bios on the computer

Example: Deploy-Application.exe -UpdateType Drivers
Result: Updates ONLY the drivers on the computer

Example: Deploy-Application.exe -UpdateType Firmware
Result: Updates ONLY the firmware on the computer

Example: Deploy-Application.exe -UpdateType Application
Result: Updates ONLY the dell applications on the computer

Example: Deploy-Application.exe -UpdateType Others
Result: Updates ONLY the other drivers on the computer

Example: Deploy-Application.exe
Result: Updates ALL the drivers & bios on the computer

