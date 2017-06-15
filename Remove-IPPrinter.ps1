function Remove-IPPrinter {
    [cmdletbinding()]
    param (
        [parameter(mandatory=$true)]
        [string]$printername,
        [string]$printerhostaddress,
        [string]$portname = "IP_$printerhostaddress",
        [string]$drivername
    )
    get-printer -name $printername | remove-printer
    get-printerport -name $portname | remove-printerport
    get-printerdriver -name $drivername | remove-printerdriver
} 