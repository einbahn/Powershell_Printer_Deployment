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
            Add-PrinterPort -name $PortName -PrinterHostAddress $PrinterHostAddress -PortNumber $PortNumber -verbose -ea Continue
        }

        function AddIPPrinter 
        {
            Add-Printer -name $PrinterName -DriverName $DriverName -Location `
            $Location -PortName $PortName -Comment $Comment -verbose -ea continue
        }

        function SetIPPrinter 
        {
            Set-Printer -Name $PrinterName -PortName $PortName -Location $Location -DriverName $DriverName -verbose -ea continue
        }

        #import driver into the driver store
        if (Get-PrinterDriver -Name $DriverName) {
            Write-Output  "Driver `"$DriverName`" already exists in the driver store."
                
        }
        else {
            Start-Process -FilePath "$ENV:SystemRoot\system32\pnputil.exe" -ArgumentList "/add-driver $InfPath" -wait -nonewwindow
            Add-PrinterDriver -name $DriverName -verbose
        } 

  if (get-printer -name $printername -ea SilentlyContinue)
  {
    AddIPPort
    SetIPPrinter
  } else {
    AddIPPort
    AddIPPrinter
    }
}

