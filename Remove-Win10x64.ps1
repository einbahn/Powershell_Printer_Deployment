$parms = @{
    printername = ''
    printerhostaddress = ''
    drivername = ''
}
. ..\bin\remove-ipprinter.ps1

remove-ipprinter @parms
