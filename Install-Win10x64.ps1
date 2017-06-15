#requires -version 3
#requires -module printmanagement

<# 
Author:
Date:

.Notes
Input printer installation parameters below, retaining all quotations marks as is.

The $PSScriptRoot automatic variable expands to the path of the install script itself. The driver folder and .inf file is relative to this value. 
#>

#define variables
[hashtable]$installparms = 

    @{
    PrinterName         = 'ITS_Ricoh_MPC_3002_1 (UTORcsi)'

    PrinterHostAddress  = '142.1.209.215'

    DriverName          = 'RICOH Aficio MP C3002 PCL 6'

    Location            = '246 Bloor, 6th Floor'

    InfPath             = "$PSScriptRoot\PCL6-WIN7x64\OEMSETUP.inf"
    }

#dot-source the printer install function
. '\\forum1\dsl$\printers\Powershell_Printer_Deployment\Install-IPPrinter.ps1'

#call printer install function
Install-IPPrinter @installparms