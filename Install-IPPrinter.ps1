#---------------------------------------------------------------------------
# Author: Derek Liu
# Desc:   Configure port and install printer for direct IP printing.
# Date:   April 10, 2017
#---------------------------------------------------------------------------
#requires -module PrintManagement
#requires -version 3

function Install-IPPrinter {
    [cmdletbinding()]
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
        function AddIPPort 
        { 
            Add-PrinterPort -name $PortName -PrinterHostAddress $PrinterHostAddress -PortNumber $PortNumber -verbose -ea continue
        }

        function AddIPPrinter 
        {
            Add-Printer -name $PrinterName -DriverName $DriverName -Location `
            $Location -PortName $PortName -Comment $Comment -verbose -ea continue
        }

        function SetIPPrinter 
        {
            Set-Printer -Name $PrinterName -PortName $PortName -Location $Location -DriverName $DriverName -comment $comment -verbose -ea continue
        }

        #import driver into the driver store
        if (Get-PrinterDriver -Name $DriverName) {
            Write-Output  "Driver `"$DriverName`" already exists in the driver store."     
        } else {
            $pnputilpath = resolve-path c:\windows\winsxs\amd64_microsoft-windows-pnputil_*\ | join-path -childpath pnputil.exe
            Start-Process -FilePath $pnputilpath -ArgumentList "/add-driver $InfPath" -wait -nonewwindow
            Add-PrinterDriver -name $DriverName -verbose
        } 

  if (get-printer -name $printername)
  {
    write-verbose "Target printer already exists - updating printer settings..." -verbose
    AddIPPort
    SetIPPrinter
  } else {
    write-verbose "Installing Printer..." -verbose
    AddIPPort
    AddIPPrinter
    }
}

