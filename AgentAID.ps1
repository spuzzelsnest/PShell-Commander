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
#		1.2		04.17.2017  - Changed dump function
#       1.3     04.24.2017  - Changed userinfo layout
#       1.4     04.28.2017  - Return of the scrollbar
#       1.5     05.04.2017  - Loggedon module
#
#==========================================================================
#MODULES
#-------
#Remove all
Get-Module | Remove-Module
#Exchange
#installed in %ExchangeInstallPath%\bin
#
if( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null)
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
#load Module PSRemoteRegistry
#
Import-Module psremoteregistry



$Title = "Agent AID"
$version = "v 1.5"
$workDir = "D:\_Tools\AgentAID"
$agent = $env:USERNAME
$log = "$env:USERPROFILE\Desktop\$pc"
$dump = "bin\_dumpFiles"
$latesVirusPattern = "1351100"

#Main window

$h = get-host
$g = $h.UI
$c = $h.UI.RawUI
$c.BackgroundColor = ($bckgrnd = 'black')

$p = $c.WindowPosition
$p.x = 0
$p.y = 0
$c.WindowPosition = $p

$s = $c.BufferSize
$s.Width = 140
$s.Height = 1000
$c.BufferSize = $s

$w = $c.WindowSize
$w.Width = 140
$w.Height = 46
$c.WindowSize = $w

cd $workDir
$loadscreen = get-content bin\visuals\loadscreen | Out-String
$loadedModules = get-module
write-host $loadscreen -ForegroundColor Magenta
Write-host "              The following Powershell Modules Are loaded
" -ForegroundColor Yellow 
write-Host $loadedModules -ForegroundColor Green

Write-Host "
		... Just a second, script is loading ..." -foregroundcolor Green
start-sleep 5
cls


#Global Functions
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
    cls
    mainMenu
}

#Program
function UserInfo ($Id){
    $Private:Id = $Id

	if (!(Get-ADUser -Filter {SamAccountName -eq $Id} )){
             Write-Host "ID not found " -ForegroundColor Red
             x
	}else{


	$userLog = [ordered]@{}

      'Processing ' + $Private:Id + '...'
 
	#--------------GENERAL USER INFO---------------
	$genInfo = Get-ADUser -Identity $Id -properties * -ErrorAction SilentlyContinue | select SamAccountName, Name, surName, GivenName,  StreetAddress, PostalCode, City, Country, OfficePhone, otherTelephone, Title, Department, Company, Organization, UserPrincipalName, DistinguishedName, ObjectClass, Enabled,scriptpath, homedrive, homedirectory, SID
	#--------------GROUPS--------------------------
	$groupInfo = get-ADPrincipalGroupMembership $Id | select -ExpandProperty name |out-string
	#--------------MANAGER-------------------------
	$manager = Get-ADUser $Id -Properties manager | Select-Object -Property @{label='Manager';expression={$_.manager -replace '^CN=|,.*$'}} |  Format-Table -HideTableHeaders |Out-String
	$manager = $manager.Trim()
	$manInfo = get-aduser -filter {displayName -like $manager} -properties * | Select displayName, EmailAddress, mobile | Format-Table -HideTableHeaders | out-string
	#--------------EMAIL----------------------------
	$migAttr = get-aduser -identity $Id -Properties *  -ErrorAction SilentlyContinue | select-object msExchRecipientTypeDetails
	$mailInfo = Get-Recipient -Identity $Id | Select Name -ExpandProperty EmailAddresses |  select SmtpAddress |Out-String
	#--------------BUILD LIST------------------------
    $genInfo.psobject.Properties | foreach{ $userLog[$_.name]=$_.value}
    $userLog.add('Manager Info', $manInfo)
	$userLog.add('Groups', $groupInfo)
	$userLog.add('Email Addresses', $mailInfo)
	
    
    #foreach ($item in $userLog.GetEnumerator() | Format-Table -AutoSize){$item}
	$userLog.getenumerator()| Ft -AutoSize -wrap | out-string
    $userLog.GetEnumerator() | Out-GridView -Title "$Id Information"
		
    }
x
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
                            'http'            = '80'  ;
                            'https'           = '443' ;
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

	x
}

function cleanUp ($pc){
    if (CC($pc)){

        Write-progress "Removing Temp Folders from "  "in Progress:"
		new-PSdrive IA Filesystem \\$pc\C$
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
        net use /delete \\$pc\C$
    }
}

function setAVsrv ($pc){
    if(CC($pc)){

               $remService = (Get-Service -CN $pc -name RemoteRegistry)
               if (!($remService -eq "running")){
                                write-host checking to start service on $pc -foreground Cyan
                                get-service -CN $pc -name RemoteRegistry|Start-Service
                } 

                $hive = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$pc)
                $pattern = $hive.OpenSubKey('Software\Wow6432Node\TrendMicro\PC-cillinNTCorp\currentVersion\Misc.')
                if($pattern -eq $null){
                    write-host Key not found for $pc -ForegroundColor red -Background white
                }else{
                    
                    If (!( $pattern.getValue('InternalPatternVer'-lt $latesVirusPattern))){
                    
                    write-host $pc has the latest pattern: $pattern.getValue('InternalPatternVer') -foreground Green
                    }else{
                    write-host $pc has an outdated pattern: $pattern.getValue('InternalPatternVer') -foreground red
                     }
                }
                
                .\bin\PSTools\PsService.exe \\$pc setconfig "OfficeScan NT Listener" auto -accepteula
                .\bin\PSTools\PsService.exe \\$pc setconfig "OfficeScan NT Firewall" auto -accepteula
                .\bin\PSTools\PsService.exe \\$pc setconfig "OfficeScan Common Client Solution Framework" auto -accepteula
                .\bin\PSTools\PsService.exe \\$pc setconfig "OfficeScan NT RealTime Scan" auto -accepteula
                
                Get-Service -Name "OfficeScan NT Listener" -CN $pc | Set-Service -Status Running
                Get-Service -Name "OfficeScan NT Firewall" -CN $pc | Set-Service -Status Running
                Get-Service -Name "OfficeScan Common Client Solution Framework" -CN $pc | Set-Service -Status Running
                Get-Service -Name "OfficeScan NT RealTime Scan" -CN $pc | Set-Service -Status Running
            }
}

function attkScan ($pc) {
    if (CC($pc)){
         $dest = "\\$pc\C$\avlog"
         $log = "$env:USERPROFILE\Desktop\$pc"

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
                .\bin\PSTools\PsExec.exe -s  \\$pc cmd /s /k  "cd C:\avlog && attk_x64.exe && exit" -accepteula
                robocopy "\\$pc\C$\avlog\TrendMicro AntiThreat Toolkit\Output" $log *
            }
}

function remoteCMD($pc){
    if(CC($pc)){

              .\bin\PSTools\PsExec.exe -accepteula -s \\$pc cmd
            }
x
}

function interactiveCMD($pc){
    if(CC($pc)){
              .\bin\PSTools\PsExec.exe -accepteula -s -i \\$pc cmd
            }
x
}

function loggedon($pc){
    if(CC($pc)){
        .\bin\PSTools\PsLoggedon.exe /l \\$pc -accepteula
        Write-Host Other USERID´s in this PC.
        Get-ChildItem  \\$pc\C$\Users\ |select name

    }
x
}

function dumpIt ($pc){

$dest = "\\$pc\C$\Temp"
$log = "$env:USERPROFILE\Desktop\$pc"

    if (CC($pc)){
	        
          write-host "You can choose from the following Files:
 *For now only Copy pasting the name or rewrite it in the box works*"
          $files = Get-ChildItem $dump | select Name
          
            for ([int]$i = 1; $i -le $files.length; $i++){
                        write-host $i $files[$i-1].name
                   }
            $fileName = Read-Host "What File do you want to send"
          

            if(!(Test-Path $dest\Logs)){
                Write-host Creating $dest\Logs -ForegroundColor magenta
				New-Item -ItemType Directory -Force -Path $dest\Logs
			}else{
                write-host The $dest\Logs directory exsists -foregroundColor green
			}

		    Copy-Item $dump\$filename $dest
            Write-Host $filename copied to $dest -ForegroundColor green

		    .\bin\PSTools\PsExec.exe -accepteula -s \\$pc powershell C:\Temp\$filename
            
            if(!(Test-path $log)){
				Write-Host $log is not available -Foreground magenta
				new-Item $log -type directory -Force
			}else{
		        Write-Host Logs will be written to $log -Foreground green
            }
            robocopy $dest\Logs $log *.* /move
            Remove-Item $dest\$filename -Verbose
            Write-Host Files removed from $pc -Foreground "green"
            
    }
x
}

#Menu's
function ATmenu {
                $Title = "Administrator Tools"
                $Menu = "
                      (1)   Remote CMD
                      (2)   Interactive CMD
                      (3)   Dump File To PC
                      (4)   Find user logged on to PC
                      (5)   Back
                      "
                $ATchoice = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 CMD","&2 iCMD","&3 Dump","&4 Loggedon","&5 Back")
                [int]$defchoice = 3
                $subAT = $h.UI.PromptForChoice($Title, $Menu, $ATchoice,$defchoice)
                switch($subAT){
                        0{
                        cls
                                    Write-Host "################################################################"
                                    Write-Host "                     Remote CMD" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address "
                                    remoteCMD $pc
                        
                        }1{
                        cls
                                    Write-Host "################################################################"
                                    Write-Host "                     InterActive CMD" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address "
                                    interactiveCMD $pc                      
                        
                        }2{
                        cls
                                    Write-Host "################################################################"
                                    Write-Host "                     Dump file to PC" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address "
                                    dumpIt $pc
                        }3{
                        cls
                                    Write-Host "################################################################"
                                    Write-Host "         Find user who is logged on to PC" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address "
                                    loggedOn $pc
                        }4{mainMenu}
                }
}

function AVmenu {
                $Title = "Anti Virus and Cleaning Tool"
                $Menu = "
                      (1)   Clean TEMP files
                      (2)   Remote Update Trend
                      (3)   ATTK-Scan
                      (4)   Full-Scan
                      (5)   Back
                      "
                $AVchoice = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 Cleanup", "&2 Update", "&3 ATTK", "&4 Full", "&5 Back")
                [int]$defchoice = 3
                $subAV =  $h.UI.PromptForChoice($Title , $Menu , $AVchoice, $defchoice)
                switch($subAV){
                                0{
                                cls
                                    Write-Host "################################################################"
                                    Write-Host "                     Clearnup Temp Files" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address "
                                    cleanUp $pc
                                    x
                                }1{
                                cls
                                    Write-Host "################################################################"
                                    Write-Host "                      Remote update Trend" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address "
                                    setAVsrv $pc
                                    x
                                }2{
                                cls
                                    Write-Host "################################################################"
                                    Write-Host "                          ATTK Scan" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address "
                                    attkScan $pc
                                    x
                                }3{
                                cls
                                    Write-Host "################################################################"
                                    Write-Host "                          Full Clearnup" -ForegroundColor Red
                                    Write-Host "################################################################
                                    "
                                    $pc = Read-Host "What is the PC name or the IP-address: "
                                    setAVsrv $pc
                                    cleanup $pc
                                    attkScan $pc
                                    x
                                }4{mainMenu}
                         }
}

function mainMenu {
        cls
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
                   0{
                   cls
                          write-host "################################################################"
                          write-host "                          USERINFO INFO" -ForegroundColor Green
                          write-host "################################################################
                                     "
                          $Id =  read-host "           What is the userID "
                          userInfo $Id
                   }1{
                   cls
                            Write-Host "###############################################################"
                            Write-Host "                           PCINFO INFO" -ForegroundColor Green
                            Write-Host "###############################################################
                                        "
                            $pc =  Read-Host "   What is the PC-Name or IP address "
                            PCInfo $pc
                   }2{
                   cls
                            AVmenu
                   }3{
                   cls
                            ATmenu
                   }q{
                   cls
                        $h.ExitNestedPrompt()
                   }
             }
}

mainMenu