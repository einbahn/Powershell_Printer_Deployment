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
   

  $targetprinter = get-printer -name $printername -ea SilentlyContinue

  if ($targetprinter) {
    AddIPPort
    SetIPPrinter
  } else {
    AddIPPort
    AddIPPrinter
    }
}




<#  if (!$targetprinter) 
     {
        if (!$targetport) 
        {
          write-output "no printer no port"
          AddIPPort
          AddIPPrinter
          else 
          {
          write-output "no printer yes port"
            AddIPPrinter
          }  
          else {
            if (!$targetport) 
              {
                write-output "yes printer no port"
                AddIPPort
                SetIPPrinter
              } else 
                {
                write-output "yes printer yes port"
                SetIPPrinter
                }
            } 
        }  
      }
        
}#>


  <#
    if ($targetprinter -and ($targetprinter.portname -eq $targetport))
    {write-output "Printer already exists with right port."}
    elseif ($targetprinter -and ($targetprinter.portname -ne $portname)) {
      write-output "$($targetprinter).name exists but with a different port."
      AddIPPort
      SetIPPrinter
    }
    elseif (!$targetprinter -and $targetport) {
      write-output "Target printer not found but port already exists."
      AddIPPrinter
    }
    elseif (!$targetprinter -and !$targetport) {
      write-output "Neither printer nor port found."
      AddIPPort
      AddIPPrinter
      }

       
    }
      <#  switch (get-printer) {
            {$_.name -eq $PrinterName -and $_.PortName -eq $PortName} {
                Write-Output "`"$($_.name)`" is already installed."
                break
            }
            {$_.name -eq $PrinterName} {
                Write-Output "`"$($_.name)`" exists but with different parameters."
                AddIPPort
                SetIPPrinter
                break
            }
            default {
                Write-Output "Proceeding with printer installation."
                AddIPPort
                AddIPPrinter
                break
            }
        }#>
   

