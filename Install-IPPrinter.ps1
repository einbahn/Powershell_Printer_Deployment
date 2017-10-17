#---------------------------------------------------------------------------
# Author: Derek Liu
# Desc:   Configure port and install printer for direct IP printing.
# Date:   April 10, 2017
#---------------------------------------------------------------------------
#requires -module PrintManagement
#requires -version 3

#Variables
param(
[string]$PrinterName,
[string]$PrinterHostAddress,
[string]$PortName = "IP_$PrinterHostAddress",
[string]$DriverName,
[string]$Location,
[string]$PortNumber = '9100',
[string]$InfPath,
[string]$Comment
)
#import driver into the driver store
if (-not (Get-PrinterDriver -Name $DriverName -ErrorAction silentlycontinue)) {
    start-process -FilePath (resolve-path $env:windir\winsxs\amd64_microsoft-windows-pnputil_* | join-path -ChildPath "pnputil.exe") `
        -ArgumentList "/add-driver $infpath" -WindowStyle 'Hidden' -Wait
    Add-PrinterDriver -name $DriverName -verbose -ErrorAction Stop
} 

#function declarations
function PrinterAlreadyExists {
    if (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue) {
        return $true
    }
    else { return $false}
}
function PortAlreadyExists {
    if (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue) {
        return $true
    }
    else {return $false}
}
function AddIPPort { 
    Add-PrinterPort -name $PortName -PrinterHostAddress $PrinterHostAddress -PortNumber $PortNumber -verbose 
}

function AddIPPrinter {
    Add-Printer -name $PrinterName -DriverName $DriverName -Location $Location -PortName $PortName -Comment $Comment -verbose 
}
function SetIPPrinter {
    Set-Printer -Name $PrinterName -PortName $PortName -Location $Location -DriverName $DriverName -comment $comment -verbose 
}

#Install main
if (PrinterAlreadyExists) {
    if (PortAlreadyExists) {
        SetIPPrinter
    }
    else {
        AddIPPort
        SetIPPrinter
    } 
}
else {
    if (PortAlreadyExists) {
        AddIPPrinter 
    }
    else {
        AddIPPort
        AddIPPrinter 
    }
}
    