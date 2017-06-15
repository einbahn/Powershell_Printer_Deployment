How to deploy a printer via PowerShell

The printer deployment uses two scripts. They are 

1) \\forum1\dsl$\printers\Powershell Printer Deployment\Install-IPPrinter.ps1
2) \\forum1\dsl$\printers\Powershell Printer Deloyment\Install-Win10x64.ps1

Script 1 contains the logic and functions and Script 2 the parameters. Script 2 dot-sources Script 1.
Never edit Script 1 directly - always only work with Script 2. 

Steps:
1. Download / extract the printer driver for Windows 10.

2. Create the printer folder and the driver folder as usual (see \\forum1\dsl$\printers\Printer Naming Conventions.txt)

3. copy Script 2 (Install-Win10x64.ps1) into the printer folder. 

4. Edit Script 2 and fill out the following parameters. Retain the quotes.

    PrinterName     	= "Printer Name (UTORcsi)";
    PrinterHostAddress  = "Printer IP";
    DriverName          = "Driver Name";
    Location            = "Printer Location";
    InfPath             = "$PSScriptRoot\DriverFolder\DriverINF.inf"

Note: $PSScriptRoot is an automatic variable that references the script root, i.e., where the script is saved. 

To deploy this script with SCCM:

commandline: powershell.exe -nologo -noninteractive -executionpolicy bypass -file \\forum1\dsl$\printers\its_ricoh_mpc3002_1\Install-Win10x64.ps1
only runs on Windows 10 64 bit
Whether or not a user is logged on 


As a security feature of PowerShell, the script will not run from an explorer window by double-clicking on the icon. 

You'll have to run it in a PowerShell console or invoke Powershell in CMD. 

To run the script, you also need to temporarily change the machine's script execution policy and then call the install script:

set-executionpolicy -policy bypass -scope session 

Or, do it all in one line in CMD:

powershell.exe -executionpolicy bypass -file <fully qualified path to the script>


 
