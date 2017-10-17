#requires -version 3
#requires -module printmanagement

<# 
Author:
Date:

.Synopsis 
Installs IP printer and configures port for Windows 10 desktops.

.Description
This is the "variables" script. This script dot-sources the separate "logic and functions" script.
Only this script needs to be edited for each printer installation.

.Notes
Input printer installation parameters below, retaining all quotations marks as is.
The $PSScriptRoot automatic variable expands to the path of the install script itself. The driver folder and .inf file is relative to this value. 
#>

#Define Variables

[hashtable]$installparms = 

    @{
    PrinterName         = ''

    PrinterHostAddress  = ''

    DriverName          = ''

    Location            = ''

    InfPath             = "$PSScriptRoot"

    Comment             = ''

    }

#call the printer install script with parameter splatting

& ..\bin\Install-IPPrinter.ps1 @installparms
