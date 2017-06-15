#requires -version 3
#requires -module printmanagement

<# 
Author:
Date:

.Synopsis
Configure port and install printer for direct IP printing on Windows 10. For detailed instructions, see README.txt in the same folder.
#>

#define variables
[hashtable]$installparms = 

    @{
    PrinterName         = 'ITS_Ricoh_MPC_3002_1 (UTORcsi)';
    PrinterHostAddress  = '142.1.209.215';
    DriverName          = 'RICOH Aficio MP C3002 PCL 6';
    Location            = '246 Bloor, 6th Floor';
    InfPath             = "$PSScriptRoot\PCL6-WIN7x64\OEMSETUP.inf"
    }

#dot-source the printer install function
. '\\forum1\dsl$\printers\Powershell Printer Deployment\Install-IPPrinter.ps1'

#call printer install function
Install-IPPrinter @installparms