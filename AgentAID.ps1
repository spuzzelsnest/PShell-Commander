#==========================================================================
#
# NAME:		AgentAID.ps1
#
# AUTHOR:	Spuzzelsnest
# EMAIL:	jan.mpdesmet@gmail.com
#
# COMMENT:
#			Agent Aid to automate the job
#
#
#       VERSION HISTORY:
#       1.0     02.17.2017 	- Initial release
#       1.1     03.03.2017  - Test Connection as a function
#==========================================================================
#MODULES
#-------
#Remove all
Get-Module | Remove-Module
#Exchange
#installed in %ExchangeInstallPath%\bin
#
if( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null )
	{
        Add-PsSnapin Microsoft.Exchange.Management.PowerShell.E2010
	}
#Active Directory
#
if( (Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue) -eq $null)
	{
		Import-Module -Name ActiveDirectory
	}
#
#if (!(Get-PSSnapin Quest.ActiveRoles.ADManagement -registered -ErrorAction SilentlyContinue)) { Plugin needed }
#Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue
#
#
$Title = "Agent AID"
$version = "v 1.1"
$workDir = "D:\_Tools\AgentAid\"
$agent = $env:USERNAME
$log = "$env:USERPROFILE\Desktop\$pc"
$dump = "bin\_dumpFiles\"
$dest = "\\$Private:pc\C$\temp"


#Main window

$h = get-host
$g = $h.UI
$c = $h.UI.RawUI
$c.BackgroundColor = ($bckgrnd = 'black')
#$c.WindowPosition.X = -350
#$c.WindowPosition.Y = 0
$loadscreen = get-content bin\visuals\loadscreen | Out-String
mode con:cols=140 lines=55
cd $workDir
$loadedModules = get-module
write-host $loadscreen -ForegroundColor Magenta
Write-host "              The following Powershell Modules Are loaded
" -ForegroundColor Yellow 
write-Host $loadedModules -ForegroundColor Green

Write-Host "
		... Just a second, script is loading ..." -foregroundcolor Green
start-sleep 5
Clear-Host


#Functions
function CC ($pc){
	If(!(test-connection -Cn $pc -BufferSize 16 -Count 1 -ea 0 -quiet)){
		Write-host -NoNewline  "PC " $pc  " is NOT online!!! ... Press any key  " `n
		return $False
	}else{
	return $True
    }
}
function x{
    write-host "Press any key to go back to the main menu"
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    clear
    mainMenu
}

function UserInfo ($Id){

        $Private:Id = $Id
		if (!(Get-ADUser -Filter {SamAccountName -eq $Id} ))	{
             Write-Host "ID not found " -ForegroundColor Red
		}else{

        'Processing ' + $Private:Id + '...'
        Write-Host User info -ForegroundColor Green

			Get-ADUser -Identity $Id -ErrorAction SilentlyContinue -properties * | select SamAccountName, Name, surName, GivenName,  StreetAddress, PostalCode, City, Country, OfficePhone, otherTelephone, Title, Department, Company, Organization, UserPrincipalName, DistinguishedName, ObjectClass, Enabled,scriptpath, homedrive, homedirectory, SID

			#----------------------------------------------

			Write-Host Groups -ForegroundColor Green
			get-ADPrincipalGroupMembership $Id | select name |Format-Table -HideTableHeaders

			#----------------------------------------------

			Write-Host Manager -ForegroundColor Green
			$manager = Get-ADUser $Id -Properties manager | Select-Object -Property @{label='Manager';expression={$_.manager -replace '^CN=|,.*$'}} | Format-Table -HideTableHeaders |Out-String
			$manager = $manager.Trim()

			get-aduser -filter {displayName -like $manager} -properties * | Select displayName, EmailAddress, mobile | Format-List

			#----------------------------------------------

			Write-Host Email info -ForegroundColor Green

			$migAttr = get-aduser -identity $Id -Properties *  -ErrorAction SilentlyContinue | select-object msExchRecipientTypeDetails
			Write-Output "Migrations status: " $migAttr
			Get-Recipient -Identity $Id | Select Name -ExpandProperty EmailAddresses |  Format-Table Name,  SmtpAddress

	    	#----------------------------------------------
        	$userGroups = Get-ADPrincipalGroupMembership $Private:Id | select name |Format-Table -HideTableHeaders
   			#----------------------------------------------
            $mng = Get-ADUser $Private:Id -Properties manager | Select-Object -Property @{label='Manager';expression={$_.manager -replace '^CN=|,.*$'}} | Format-Table -HideTableHeaders |Out-String
            $mng = $mng.Trim()
            $userLog.'Manager' = Get-ADUser -filter {displayName -like $mng} -properties * | Select displayName, EmailAddress, mobile | Format-List
   			#----------------------------------------------
            $userLog.'Email Info '= Get-Recipient -Identity $Private:Id | Select Name -ExpandProperty EmailAddresses |  Format-Table Name,  SmtpAddress

            $userLog.GetEnumerator() | Sort-Object 'Name' | Format-Table -AutoSize
            $userLog.GetEnumerator() | Sort-Object 'Name' | Out-GridView -Title "$Private:Id Information"
		
        }

mainMenu
}

function PCInfo($pc){

        $Private:pc = $pc
        'Processing ' + $Private:pc + '...'
        $PCLog = @{}
        $PCLog.'PC-Name' = $Private:pc
        $PCLog.''
        # Try an ICMP ping the only way Powershell knows how...
        $Private:ping = Test-Connection -quiet -count 1 $Private:pc
        $PCLog.Ping = $(if ($Private:ping) { 'Yes' } else { 'No' })
                $ErrorActionPreference = 'SilentlyContinue'
                if ( $Private:ips = [System.Net.Dns]::GetHostAddresses($Private:pc) | foreach { $_.IPAddressToString } ) {

                    $PCLog.'IP Address(es) from DNS' = ($Private:ips -join ', ')

                }

                else {

                    $PCLog.'IP Address from DNS' = 'Could not resolve'

                }
                # Make errors visible again
                $ErrorActionPreference = 'Continue'

                # We'll assume no ping reply means it's dead. Try this anyway if -IgnorePing is specified
                if ($Private:ping -or $Private:ignorePing) {

                    $PCLog.'WMI Data Collection Attempt' = 'Yes (ping reply or -IgnorePing)'

                    # Get various info from the ComputerSystem WMI class
                    if ($Private:wmi = Get-WmiObject -Computer $Private:pc -Class Win32_ComputerSystem -ErrorAction SilentlyContinue) {

                        $PCLog.'Computer Hardware Manufacturer' = $Private:wmi.Manufacturer
                        $PCLog.'Computer Hardware Model'        = $Private:wmi.Model
                        $PCLog.'Physical Memory in MB'          = ($Private:wmi.TotalPhysicalMemory/1MB).ToString('N')
                        $PCLog.'Logged On User'                 = $Private:wmi.Username

                    }

                    $Private:wmi = $null

                    # Get the free/total disk space from local disks (DriveType 3)
                    if ($Private:wmi = Get-WmiObject -Computer $Private:pc -Class Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction SilentlyContinue) {

                        $Private:wmi | Select 'DeviceID', 'Size', 'FreeSpace' | Foreach {

                            $PCLog."Local disk $($_.DeviceID)" = ('' + ($_.FreeSpace/1MB).ToString('N') + ' MB free of ' + ($_.Size/1MB).ToString('N') + ' MB total space' )
                        }
                    }
                    $Private:wmi = $null

                    # Get IP addresses from all local network adapters through WMI
                    if ($Private:wmi = Get-WmiObject -Computer $Private:pc -Class Win32_NetworkAdapterConfiguration -ErrorAction SilentlyContinue) {

                        $Private:Ips = @{}

                        $Private:wmi | Where { $_.IPAddress -match '\S+' } | Foreach { $Private:Ips.$($_.IPAddress -join ', ') = $_.MACAddress }

                        $Private:counter = 0
                        $Private:Ips.GetEnumerator() | Foreach {

                        $Private:counter++; $PCLog."IP Address $Private:counter" = '' + $_.Name + ' (MAC: ' + $_.Value + ')'

                        }

                    }

                    $Private:wmi = $null

    # Get CPU information with WMI
    if ($Private:wmi = Get-WmiObject -Computer $Private:pc -Class Win32_Processor -ErrorAction SilentlyContinue) {

        $Private:wmi | Foreach {

            $Private:maxClockSpeed     =  $_.MaxClockSpeed
            $Private:numberOfCores     += $_.NumberOfCores
            $Private:description       =  $_.Description
            $Private:numberOfLogProc   += $_.NumberOfLogicalProcessors
            $Private:socketDesignation =  $_.SocketDesignation
            $Private:status            =  $_.Status
            $Private:manufacturer      =  $_.Manufacturer
            $Private:name              =  $_.Name

            }

            $PCLog.'CPU Clock Speed'        = $Private:maxClockSpeed
            $PCLog.'CPU Cores'              = $Private:numberOfCores
            $PCLog.'CPU Description'        = $Private:description
            $PCLog.'CPU Logical Processors' = $Private:numberOfLogProc
            $PCLog.'CPU Socket'             = $Private:socketDesignation
            $PCLog.'CPU Status'             = $Private:status
            $PCLog.'CPU Manufacturer'       = $Private:manufacturer
            $PCLog.'CPU Name'               = $Private:name -replace '\s+', ' '

            }

            $Private:wmi = $null

            # Get BIOS info from WMI
            if ($Private:wmi = Get-WmiObject -Computer $Private:pc -Class Win32_Bios -ErrorAction SilentlyContinue) {

                $PCLog.'BIOS Manufacturer' = $Private:wmi.Manufacturer
                $PCLog.'BIOS Name'         = $Private:wmi.Name
                $PCLog.'BIOS Version'      = $Private:wmi.Version

            }

         $Private:wmi = $null

             # Get operating system info from WMI
                if ($Private:wmi = Get-WmiObject -Computer $Private:pc -Class Win32_OperatingSystem -ErrorAction SilentlyContinue) {

                        $PCLog.'OS Boot Time'     = $Private:wmi.ConvertToDateTime($Private:wmi.LastBootUpTime)
                        $PCLog.'OS System Drive'  = $Private:wmi.SystemDrive
                        $PCLog.'OS System Device' = $Private:wmi.SystemDevice
                        $PCLog.'OS Language     ' = $Private:wmi.OSLanguage
                        $PCLog.'OS Version'       = $Private:wmi.Version
                        $PCLog.'OS Windows dir'   = $Private:wmi.WindowsDirectory
                        $PCLog.'OS Name'          = $Private:wmi.Caption
                        $PCLog.'OS Install Date'  = $Private:wmi.ConvertToDateTime($Private:wmi.InstallDate)
                        $PCLog.'OS Service Pack'  = [string]$Private:wmi.ServicePackMajorVersion + '.' + $Private:wmi.ServicePackMinorVersion

                 }

            # Scan for open ports
                    $ports = @{
                            'File shares/RPC' = '139' ;
                            'File shares'     = '445' ;
                            'RDP'             = '3389';
                        }

                foreach ($service in $ports.Keys) {

                $Private:socket = New-Object Net.Sockets.TcpClient

        # Suppress error messages
                $ErrorActionPreference = 'SilentlyContinue'

        # Try to connect
                $Private:socket.Connect($Private:pc, $ports.$service)

        # Make error messages visible again
                $ErrorActionPreference = 'Continue'

        if ($Private:socket.Connected) {

                            $PCLog."Port $($ports.$service) ($service)" = 'Open'
                            $Private:socket.Close()

                        }else {

                            $PCLog."Port $($ports.$service) ($service)" = 'Closed or filtered'

                        }

                    $Private:socket = $null

                }

            }else {

            $PCLog.'WMI Data Collected' = 'No (no ping reply and -IgnorePing not specified)'

            }

        # Get data from AD using Quest ActiveRoles Get-ADComputer
        $Private:pcObject = Get-ADComputer $Private:pc -ErrorAction 'SilentlyContinue'
          if ($Private:pcObject) {

                        $PCLog.'AD Operating System'         = $Private:pcObject.OSName
                        $PCLog.'AD Operating System Version' = $Private:pcObject.OSVersion
                        $PCLog.'AD Service Pack'             = $Private:pcObject.OSServicePack
                        $PCLog.'AD Enabled AD Account'       = $( if ($Private:pcObject.AccountIsDisabled) { 'No' } else { 'Yes' } )
                        $PCLog.'AD Description'              = $Private:pcObject.Description

                }else {

                    $PCLog.'AD Computer Object Info Collected' = 'No'

                }


        $PCLog.GetEnumerator() | Sort-Object 'Name' | Format-Table -AutoSize
        $PCLog.GetEnumerator() | Sort-Object 'Name' | Out-GridView -Title "$Private:pc Information"
		mainMenu
}

function cleanUp ($pc){
            $Private:pc = $pc

            if (CC($pc)) {
		            Write-progress "Removing Temp Folders from "  "in Progress:"
		            new-PSdrive IA Filesystem \\$Private:pc\C$

		            remove-item IA:\"$"Recycle.Bin\* -recurse -force -verbose
		            Write-Output "Cleaned up Recycle.Bin"


		            if (Test-Path IA:\Windows.old){
				            Remove-Item IA:\Windows.old\ -Recurse -Force -Verbose
				            }else{
				            Write-Output "no Windows.old Folder found"
				            }

		            remove-item IA:\Windows\Temp\* -recurse -force -verbose
		            write-output "Cleaned up C:\Windows\Temp"

	            $UserFolders = get-childItem IA:\Users\ -Directory

		            foreach ($folder in $UserFolders){

					            $path = "IA:\Users\"+$folder
					            remove-item $path\AppData\Local\Temp\* -recurse -force -verbose -ErrorAction SilentlyContinue
					            remove-item $path\AppData\Local\Microsoft\Windows\"Temporary Internet Files"\* -recurse -force -verbose -ErrorAction SilentlyContinue
					            Write-Output "Cleaned up Temp Items for "$folder.Name
		            }
            net use /delete \\$Private:pc\C$

            }



}

function setAVsrv ($pc){

            $Private:pc = $pc
            If(CC($pc)){
            
                .\bin\PSTools\PsService.exe \\$Private:pc setconfig "OfficeScan NT Listener" auto -accepteula
                .\bin\PSTools\PsService.exe \\$Private:pc setconfig "OfficeScan NT Firewall" auto -accepteula
                .\bin\PSTools\PsService.exe \\$Private:pc setconfig "OfficeScan NT Proxy Service" auto -accepteula
                .\bin\PSTools\PsService.exe \\$Private:pc setconfig "OfficeScan NT RealTime Scan" auto -accepteula
            }
}

function attkScan ($pc) {
            if (CC($pc))
            {
                  $dest = "\\$Private:pc\C$\avlog\"

                  if(!(Test-Path "$dest\attk_x64.exe")){
		                 New-Item -ItemType Directory -Force -Path $dest
                         Write-Host "copying attk scan to C:\avlog" -ForegroundColor White
                         robocopy $dump $dest attk_x64.exe
                        }else{
                            Write-host "
                            - ATTK Files available on local PC
                            " -foregroundcolor green
                        }
		            if(!(Test-Path $log)){
			            New-Item -ItemType Directory -Force -Path $log
			            Write-Host "Creating Log directory at $log" -ForegroundColor White
		                }else{
                           Write-host "
                            - Log directory available
                           " -ForegroundColor Green
                        }

                .\bin\PSTools\PsExec.exe \\$Private:pc cmd /s /k  "cd C:\avlog && attk_x64.exe && exit" -accepteula

                robocopy "\\$Private:pc\C$\avlog\TrendMicro AntiThreat Toolkit\Output" $log * /Z

            }
}

function AVmenu {
                $Title = "Anti Virus and Cleaning Tool"
                $Menu = "
                      (1)   Clean TEMP files
                      (2)   ATTK-Scan
                      (3)   Full-Scan
                      (4)   Back
                      "
                $AVchoice = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 Cleanup", "&2 ATTK", "&3 Full", "&4 Back")
                [int]$defchoice = 3
                $subAV =  $h.UI.PromptForChoice($Title , $Menu , $AVchoice, $defchoice)
                switch($subAV){
                                0{clear
                                    Write-Host "################################################################"
                                    Write-Host "                     Clearnup Temp Files" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address "
                                    cleanUp $pc
                                    x
                                }
                                1{clear
                                    Write-Host "################################################################"
                                    Write-Host "                          ATTK Scan" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address "
                                    attkScan $pc
                                    x
                                }
                                2{clear
                                    Write-Host "################################################################"
                                    Write-Host "                          Full Clearnup" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address: "
                                    setAVsrv $pc
                                    cleanup $pc
                                    attkScan $pc
                                    x
                                }
                                3{mainMenu}
                         }
}

function remoteCMD($pc){
             $Private:pc = $pc
             if(CC($pc)){

              .\bin\PSTools\PsExec.exe -accepteula -s \\$Private:pc cmd
            }
}

function dumpIt ($pc){

          $Private:pc = $pc
          write-host "You can choose from the following Files:
 *For now only Copy pasting the name or rewrite it in the box workx*"
          $files = Get-ChildItem $dump | select Name
                   for ([int]$i = 1; $i -le $files.length; $i++){
                        write-host $i $files[$i-1].name
                   }

          $fileName = Read-Host "What filename will you sent"

          if (CC($pc)){
	         if(!(Test-Path $dest\Logs)){
				New-Item -ItemType Directory -Force -Path $dest\Logs
			}else{
                write-host The $dest\Logs directory exsists -foregroundColor green
		        robocopy $dump $dest $filename
                Write-Host $filename copied to $dest -ForegroundColor green
		        .\bin\PSTools\PsExec.exe -accepteula -s \\$Private:pc powershell C:\Temp\$filename

                 Remove-Item $dest\$filename -Verbose

                 if(!(Test-path $log)){
				          Write-Host $log is not available -Foreground "magenta"
				          new-Item $log -type directory -Force
			               }else{
				               Write-Host Logs will be written to $log -Foreground "green"

                            }

                        Write-Host Files removed from $Private:pc -Foreground "green"
                 }
           }

}

function ATmenu {
                $Title = "Administrator Tools"
                $Menu = "
                      (1)   Remote CMD
                      (2)   Dump File To PC
                      (3)   Back
                      "
                $ATchoice = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 CMD","&2 Dump","&3 Back")
                [int]$defchoice = 2
                $subAT = $h.UI.PromptForChoice($Title, $Menu, $ATchoice,$defchoice)
                switch($subAT){
                        0{clear
                                    Write-Host "################################################################"
                                    Write-Host "                     Remote CMD" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address "

                                    remoteCMD $pc
                                    x
                        }
                        1{clear
                                    Write-Host "################################################################"
                                    Write-Host "                     Remote CMD" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address "
                                    dumpIt $pc
                                    x
                        }
                        2{mainMenu}
                }
}

function mainMenu {
        clear
		$LengthName = $agent.length
		$line = "************************************************" + "*"* $LengthName
        $Menu = "
Welcome  $agent  to Agent AID         version   $version
$line

          What you want to do:

                           (1)   User info
                           (2)   PC info
                           (3)   Antivirus Tools
                           (4)   Admin Tools
                           (Q)   Exit
                           "

        $mainMenu = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 UserInfo", "&2 PCInfo", "&3 AVTools", "&4 ATools", "&Quit")
        [int]$defaultchoice = 4
        $choice =  $h.UI.PromptForChoice($Title, $Menu, $mainMenu, $defaultchoice)

             switch ($choice){
                   '0'
                   { clear
                          write-host "################################################################"
                          write-host "                          USERINFO INFO" -ForegroundColor Green
                          write-host "################################################################
                                     "
                          $Id =  read-host "           What is the userID "
                          userInfo $Id
                   }
                   '1' {clear
                            Write-Host "###############################################################"
                            Write-Host "                           PCINFO INFO" -ForegroundColor Green
                            Write-Host "###############################################################
                                        "
                            $pc =  Read-Host "   What is the PC-Name or IP address "
                            PCInfo $pc
                   }
                   '2' {clear
                            AVmenu
                   }
                   '3' {clear
                            ATmenu
                   }
                   'q' {
                        exit
                   }
             }
}

mainMenu