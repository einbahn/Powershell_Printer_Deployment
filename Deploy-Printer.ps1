<#
.SYNOPSIS
	This script performs the installation or uninstallation of a printer.
.DESCRIPTION
	The script either performs an "Install" deployment type or an "Uninstall" deployment type.
	The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
	The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
.EXAMPLE
    Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"
.NOTES
	Toolkit Exit Code Ranges:
	60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
	69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall')]
    [string]$DeploymentType = 'Install',
    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [string]$DeployMode = 'Silent'
)

Try {
    ## Set the script execution policy for this process
    Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}
	
    ##*===============================================
    ##* VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
    [string]$appVendor = 'UTORCSI Printer Deployment'
    [string]$appName = "$Printername"
    [string]$appVersion = ''
    [string]$appArch = ''
    [string]$appLang = 'EN'
    [string]$appRevision = '01'
    [string]$appScriptVersion = '1.0.0'
    [string]$appScriptDate = '08/07/2017'
    [string]$appScriptAuthor = 'Derek liu'
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
    [string]$installName = ''
    [string]$installTitle = ''
	
    ##* Do not modify section below
    #region DoNotModify
	
    ## Variables: Exit Code
    [int32]$mainExitCode = 0
	
    ## Variables: Script
    [string]$deployAppScriptFriendlyName = 'Deploy Printer'
    [version]$deployAppScriptVersion = [version]'3.6.9'
    [string]$deployAppScriptDate = '02/12/2017'
    [hashtable]$deployAppScriptParameters = $psBoundParameters
	
    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
    [string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent
	
    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
        If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
    }
    Catch {
        If ($mainExitCode -eq 0) { [int32]$mainExitCode = 60008 }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
    }
	
    #endregion
    ##* Do not modify section above
    ##*===============================================
    ##* END VARIABLE DECLARATION
    ##*===============================================

    #DECLARE PRINTER VARIABLES
    [string]$PrinterName = 'UTC_167_COL_2_HP_LJ_M401n_1 (UTORcsi)'
    [string]$PrinterHostAddress = '128.100.252.71'
    [string]$PortName = "IP_$PrinterHostAddress"
    [string]$DriverName = 'HP Universal Printing PCL 6'
    [string]$Location = '167 College, 2nd Floor'
    [string]$PortNumber = '9100'
    [string]$InfPath = "$dirFiles\hpcu196u.inf"
    [string]$Comment = 'HP LaserJet M401n'
		
    If ($deploymentType -ine 'Uninstall') {
        ##*===============================================
        ##* PRE-INSTALLATION
        ##*===============================================
        [string]$installPhase = 'Pre-Installation'
	
        ## <Perform Pre-Installation tasks here>
        #import driver into the driver store

        if (Get-PrinterDriver -Name $DriverName -ErrorAction silentlycontinue) {
            Write-Log  -message "Driver `"$DriverName`" already exists in the driver store." -severity 1 -Source $deployAppScriptFriendlyName
        }
        else {
            execute-process -path (resolve-path $env:windir\winsxs\amd64_microsoft-windows-pnputil_* | join-path -ChildPath "pnputil.exe") `
            -Parameters "/add-driver $infpath" -WindowStyle 'Hidden'
            Add-PrinterDriver -name $DriverName -verbose
        } 
       
        function DoesPrinterAlreadyExist ($Name) {
            if (Get-Printer -Name $Name -ErrorAction SilentlyContinue) {
                return $true
            }
            else { return $false}
        }

        function DoesPortAlreadyExist ($Name) {
            if (Get-PrinterPort -Name $Name -ErrorAction SilentlyContinue) {
                return $true
            }
            else {return $false}
        }
        function AddIPPort { 
            Add-PrinterPort -name $PortName -PrinterHostAddress $PrinterHostAddress -PortNumber $PortNumber -verbose 
        }
    }
    function AddIPPrinter {
        Add-Printer -name $PrinterName -DriverName $DriverName -Location $Location -PortName $PortName -Comment $Comment -verbose 
    }
    function SetIPPrinter {
        Set-Printer -Name $PrinterName -PortName $PortName -Location $Location -DriverName $DriverName -comment $comment -verbose 
    }

    ##*===============================================
    ##* INSTALLATION 
    ##*===============================================
    [string]$installPhase = 'Installation'
		
    ## <Perform Installation tasks here>
    if (DoesPrinterAlreadyExist -Name $PrinterName) {
        if (DoesPortAlreadyExist -Name $PortName) {
            write-log -message "Printer with same name already exists, updating printer settings..." -severity 1 -Source $deployAppScriptFriendlyName
            SetIPPrinter
        }
        else {
            AddIPPort
            SetIPPrinter
        } 
    }
    else {
        if (DoesPortAlreadyExist -Name $PortName) {
            AddIPPrinter 
        }
        else {
            write-log -message "Installing Printer..." -severity 1 -Source $deployAppScriptFriendlyName
            AddIPPort
            AddIPPrinter 
        }
    }
		
        ##*===============================================
        ##* POST-INSTALLATION
        ##*===============================================
        [string]$installPhase = 'Post-Installation'
		
        ## <Perform Post-Installation tasks here>
        Try {
            $TargetPrinter = Get-Printer | Where-Object {$_.Name -eq $PrinterName -and $_.PortName -eq $PortName}
            if ($TargetPrinter) {
                write-log -message "Printer installation / configuration successful." -severity 1 -source $deployAppScriptFriendlyName
            }
            else {throw "Printer installation / configuration failed."}
        }
        Catch {
            If ($mainExitCode -eq 0) { [int32]$mainExitCode = 70000 }
            Write-Error -Message "Module $PrinterName failed to install: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
            ## Exit the script, returning the exit code to SCCM
            If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
        }
    ##*===============================================
    ##* END SCRIPT BODY
    ##*===============================================
	
    ## Call the Exit-Script function to perform final cleanup operations
    Exit-Script -ExitCode $mainExitCode
}
Catch {
    [int32]$mainExitCode = 60001
    [string]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}