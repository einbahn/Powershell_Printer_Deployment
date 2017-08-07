'==========================================================
'
' LANG			: VBScript 
' NAME			: Install.vbs
' AUTHOR		: Leroy Tang
' DATE  		: July 28, 2017
' Description 		: Configure port and install printer driver for direct IP printing
' Notes			: Printer bin directory is relative to script directory (..\bin)
'			: See "\\forum1\dsl$\Printers\Printer Naming Conventions.txt" for information on printer script/driver/GPO naming conventions
'
'==========================================================
'==========================================================
Dim sName,sDriverName,sDescription,sIPAddr,sLocation,sPort,oShell,oMaster,oPrinter
Set oShell=WScript.CreateObject("WScript.Shell")

' Determine Script Environment
sScriptPath = GetScriptPath
sBinPath = sScriptPath & "\..\bin"

'===========Define Specific Printer Variables==============
sName = "UTC_167_COL_2_HP_LJ_M401n_1 (UTORcsi)"
sDriverName = "HP Universal Printing PCL 6"
sDriverPath = sScriptPath & "\disk1"
sInfPath = sScriptPath & "\disk1\hpcu196u.INF"
sLocation = "167 College, 2nd Floor"
sDescription = "HP LaserJet M401n"
sIPAddr = "128.100.252.71"
sPort = "9100"
'==========================================================

'Determine printer status on current computer and make appropriate changes/updates
Select Case sSearchPrinter(sName,"IP_" & sIPAddr)
	Case 2
	    'Printer and Port Found!
	Case 1
	    'Printer Found but wrong port!
	    'Redefine printer port
	    Call CreatePort(sIPAddr,sPort)
	    Call ResetPort(sName,sIPAddr)
	Case 0
	    'Printer not found!
	    Call CreatePort(sIPAddr,sPort)
	    Call CreatePrinter(sName,sDriverName,sDriverPath,sIPAddr,sInfPath)
	    Call SetPerms(sName)
End Select

'Set Description and Location info
Call SetDescLoc(sName,sDescription,sLocation)

Wscript.quit


Function CreatePort(sIPAddr,sPort)
' Create new IP Port
oShell.Run "CScript " & Chr(34) & sBinPath & "\portmgr.vbs" & Chr(34) & " -a -p IP_" & sIPAddr & " -h " & sIPAddr & " -t raw -n " & sPort, 0, True
End Function


Function CreatePrinter(sName,sDriverName,sDriverPath,sIPAddr,sInfPath)
oShell.Run "CScript " & Chr(34) & sBinPath & "\prnmgr.vbs" & Chr(34) & " -a -b " & Chr(34) & sName & Chr(34) & " -m " & Chr(34) & sDriverName & Chr(34) & " -p " & Chr(34) & sDriverPath & Chr(34) & " -r IP_" & sIPAddr & " -f " & Chr(34) & sInfPath & Chr(34), 0, True
End Function


Function SetDescLoc(sName,sDescription,sLocation)
oShell.Run "CScript " & Chr(34) & sBinPath & "\prncfg.vbs" & Chr(34) & " -s -b " & Chr(34) & sName & Chr(34) & " -m " & Chr(34) & sDescription & Chr(34) & " -l " & Chr(34) & sLocation & Chr(34), 0, True
End Function


Function sSearchPrinter(sName,sPrinterPort)
iFound = 0
    set oMaster = CreateObject("PrintMaster.PrintMaster.1")
    for each oPrinter in oMaster.Printers(strServer)
	'Wscript.echo oprinter.printername
	'Wscript.echo oprinter.portname
	if oPrinter.PrinterName = sName then
		if oPrinter.portname = sPrinterPort then 
			iFound = 2
		else
			iFound = 1
		end if
	end if
    next
sSearchPrinter = iFound
End Function


Function SetPerms(sName)
' Grant local users group full permissions to the printer
oShell.Run Chr(34) & sBinPath & "\SetACL.exe" & Chr(34) & " -on " & Chr(34) & sName & Chr(34) & " -ot prn -actn ace -ace " & Chr(34) & "n:Users;p:full" & Chr(34), 0, True
End Function


Function ResetPort(sName,sIPAddr)
oShell.Run "CScript " & Chr(34) & sBinPath & "\prncfg.vbs" & Chr(34) & " -s -b " & Chr(34) & sName & Chr(34) & " -r IP_" & sIPAddr, 0, True
End Function


Function GetScriptPath()
scriptfile = WScript.ScriptFullName
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.GetFile(scriptfile)
GetScriptPath = f.ParentFolder
End Function

