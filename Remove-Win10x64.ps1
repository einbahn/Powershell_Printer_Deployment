$parms = @{
    printername = 'CFP_XRX_7855_1 (UTORcsi)'
    printerhostaddress = '128.100.174.176'
    drivername = 'Xerox GPD PCL6 V3.8.496.7.0'
}
. '\\forum1\dsl$\printers\Powershell_Printer_Deployment\remove-ipprinter.ps1'

remove-ipprinter @parms
