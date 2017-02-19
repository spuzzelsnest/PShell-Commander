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
#							
#==========================================================================
#MODULES
#Exchange 
#installed in %ExchangeInstallPath%\bin
#
#if ( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null )
#      {
#        Add-PsSnapin Microsoft.Exchange.Management.PowerShell.E2010
#      }
#
#if (!(Get-PSSnapin Quest.ActiveRoles.ADManagement -registered -ErrorAction SilentlyContinue)) { Plugin needed }
#Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue
#
#
param(
  [string]$Title = "Agent AID",
  [string]$version = "v 1.0",
  [string]$agent = $env:USERNAME,
  [string]$log = "$env:USERPROFILE\Desktop\",
  [string]$dump = "bin\_dumpFiles\",
  [string]$dest = "\\$Private:pc\C$\temp"
)
#Main window

$h = get-host
$g = $h.UI
$c = $h.UI.RawUI
$c.BackgroundColor = ($bckgrnd = 'black')

$c.WindowPosition.X = -350
$c.WindowPosition.Y = 0

mode con:cols=140 lines=55
Write-Host "..Loading.."
Clear-Host
#Functions

function UserInfo ($Id){

        $private:Id = $Id
        'Processing ' + $private:Id + '...'
        $userLog = @{}
        $userLog. 'UserID' = Get-ADUser -Identity $private:Id -ErrorAction SilentlyContinue -properties * | select SamAccountName, Name, surName, GivenName,  StreetAddress, PostalCode, City, Country, OfficePhone, otherTelephone, Title, Department, Company, Organization, UserPrincipalName, DistinguishedName, ObjectClass, Enabled,scriptpath, homedrive, homedirectory, SID
        $userLog. 'Groups' = Get-ADPrincipalGroupMembership $private:Id | select name |Format-Table -HideTableHeaders
   #----------------------------------------------
        $pritvate:mng = Get-ADUser $pritvate:Id -Properties manager | Select-Object -Property @{label='Manager';expression={$_.manager -replace '^CN=|,.*$'}} | Format-Table -HideTableHeaders |Out-String
        $pritvate:mng = $pritvate:mng.Trim()
        $userLog. 'Manager' = Get-ADUser -filter {displayName -like $pritvate:mng} -properties * | Select displayName, EmailAddress, mobile | Format-List
   #----------------------------------------------
        $userLog. 'Email Info '= Get-Recipient -Identity $private:Id | Select Name -ExpandProperty EmailAddresses |  Format-Table Name,  SmtpAddress 
        
        $userLog.GetEnumerator() | Sort-Object 'Name' | Format-Table -AutoSize
        $userLog.GetEnumerator() | Sort-Object 'Name' | Out-GridView -Title "$private:Id Information"

}

function PCInfo($pc){
    
        $private:pc = $pc
        'Processing ' + $private:pc + '...'
        $PCLog = @{}
        $PCLog. 'PC-Name' = $private:pc
        $PCLog. ''        
        # Try an ICMP ping the only way Powershell knows how...
        $private:ping = Test-Connection -quiet -count 1 $private:pc
        $PCLog.Ping = $(if ($private:ping) { 'Yes' } else { 'No' })
                $ErrorActionPreference = 'SilentlyContinue'
                if ( $private:ips = [System.Net.Dns]::GetHostAddresses($private:pc) | foreach { $_.IPAddressToString } ) {
    
                    $PCLog.'IP Address(es) from DNS' = ($private:ips -join ', ')
    
                }

                else {
    
                    $PCLog.'IP Address from DNS' = 'Could not resolve'
    
                }
                # Make errors visible again
                $ErrorActionPreference = 'Continue'

                # We'll assume no ping reply means it's dead. Try this anyway if -IgnorePing is specified
                if ($private:ping -or $private:ignorePing) {
    
                    $PCLog.'WMI Data Collection Attempt' = 'Yes (ping reply or -IgnorePing)'
    
                    # Get various info from the ComputerSystem WMI class
                    if ($private:wmi = Get-WmiObject -Computer $private:pc -Class Win32_ComputerSystem -ErrorAction SilentlyContinue) {
        
                        $PCLog.'Computer Hardware Manufacturer' = $private:wmi.Manufacturer
                        $PCLog.'Computer Hardware Model'        = $private:wmi.Model
                        $PCLog.'Physical Memory in MB'          = ($private:wmi.TotalPhysicalMemory/1MB).ToString('N')
                        $PCLog.'Logged On User'                 = $private:wmi.Username
        
                    }
    
                    $private:wmi = $null
    
                    # Get the free/total disk space from local disks (DriveType 3)
                    if ($private:wmi = Get-WmiObject -Computer $private:pc -Class Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction SilentlyContinue) {
        
                        $private:wmi | Select 'DeviceID', 'Size', 'FreeSpace' | Foreach {
            
                            $PCLog."Local disk $($_.DeviceID)" = ('' + ($_.FreeSpace/1MB).ToString('N') + ' MB free of ' + ($_.Size/1MB).ToString('N') + ' MB total space' )
            
                        }
        
                    }
    
                    $private:wmi = $null
    
                    # Get IP addresses from all local network adapters through WMI
                    if ($private:wmi = Get-WmiObject -Computer $private:pc -Class Win32_NetworkAdapterConfiguration -ErrorAction SilentlyContinue) {
        
                        $private:Ips = @{}
        
                        $private:wmi | Where { $_.IPAddress -match '\S+' } | Foreach { $private:Ips.$($_.IPAddress -join ', ') = $_.MACAddress }
        
                        $private:counter = 0
                        $private:Ips.GetEnumerator() | Foreach {
            
                            $private:counter++; $PCLog."IP Address $private:counter" = '' + $_.Name + ' (MAC: ' + $_.Value + ')'
            
                        }
        
                    }
    
                    $private:wmi = $null
    
    # Get CPU information with WMI
    if ($private:wmi = Get-WmiObject -Computer $private:pc -Class Win32_Processor -ErrorAction SilentlyContinue) {
        
        $private:wmi | Foreach {
            
            $private:maxClockSpeed     =  $_.MaxClockSpeed
            $private:numberOfCores     += $_.NumberOfCores
            $private:description       =  $_.Description
            $private:numberOfLogProc   += $_.NumberOfLogicalProcessors
            $private:socketDesignation =  $_.SocketDesignation
            $private:status            =  $_.Status
            $private:manufacturer      =  $_.Manufacturer
            $private:name              =  $_.Name
            
            }
        
            $PCLog.'CPU Clock Speed'        = $private:maxClockSpeed
            $PCLog.'CPU Cores'              = $private:numberOfCores
            $PCLog.'CPU Description'        = $private:description
            $PCLog.'CPU Logical Processors' = $private:numberOfLogProc
            $PCLog.'CPU Socket'             = $private:socketDesignation
            $PCLog.'CPU Status'             = $private:status
            $PCLog.'CPU Manufacturer'       = $private:manufacturer
            $PCLog.'CPU Name'               = $private:name -replace '\s+', ' '
        
            }
    
            $private:wmi = $null
    
            # Get BIOS info from WMI
            if ($private:wmi = Get-WmiObject -Computer $private:pc -Class Win32_Bios -ErrorAction SilentlyContinue) {
        
                $PCLog.'BIOS Manufacturer' = $private:wmi.Manufacturer
                $PCLog.'BIOS Name'         = $private:wmi.Name
                $PCLog.'BIOS Version'      = $private:wmi.Version
        
            }
    
         $private:wmi = $null
    
             # Get operating system info from WMI
                if ($private:wmi = Get-WmiObject -Computer $private:pc -Class Win32_OperatingSystem -ErrorAction SilentlyContinue) {
        
                        $PCLog.'OS Boot Time'     = $private:wmi.ConvertToDateTime($private:wmi.LastBootUpTime)
                        $PCLog.'OS System Drive'  = $private:wmi.SystemDrive
                        $PCLog.'OS System Device' = $private:wmi.SystemDevice
                        $PCLog.'OS Language     ' = $private:wmi.OSLanguage
                        $PCLog.'OS Version'       = $private:wmi.Version
                        $PCLog.'OS Windows dir'   = $private:wmi.WindowsDirectory
                        $PCLog.'OS Name'          = $private:wmi.Caption
                        $PCLog.'OS Install Date'  = $private:wmi.ConvertToDateTime($private:wmi.InstallDate)
                        $PCLog.'OS Service Pack'  = [string]$private:wmi.ServicePackMajorVersion + '.' + $private:wmi.ServicePackMinorVersion
        
                 }
    
            # Scan for open ports
                    $ports = @{ 
                            'File shares/RPC' = '139' ;
                            'File shares'     = '445' ;
                            'RDP'             = '3389';
                        }
    
                foreach ($service in $ports.Keys) {
        
                $private:socket = New-Object Net.Sockets.TcpClient
        
        # Suppress error messages
                $ErrorActionPreference = 'SilentlyContinue'
        
        # Try to connect
                $private:socket.Connect($private:pc, $ports.$service)
        
        # Make error messages visible again
                $ErrorActionPreference = 'Continue'
        
        if ($private:socket.Connected) {
            
                            $PCLog."Port $($ports.$service) ($service)" = 'Open'
                            $private:socket.Close()
            
                        }else {
            
                            $PCLog."Port $($ports.$service) ($service)" = 'Closed or filtered'
            
                        }
        
                    $private:socket = $null
        
                }
    
            }else {
    
            $PCLog.'WMI Data Collected' = 'No (no ping reply and -IgnorePing not specified)'
    
            }

        # Get data from AD using Quest ActiveRoles Get-QADComputer
        $private:pcObject = Get-QADComputer $private:pc -ErrorAction 'SilentlyContinue'
          if ($private:pcObject) {
    
                        $PCLog.'AD Operating System'         = $private:pcObject.OSName
                        $PCLog.'AD Operating System Version' = $private:pcObject.OSVersion
                        $PCLog.'AD Service Pack'             = $private:pcObject.OSServicePack
                        $PCLog.'AD Enabled AD Account'       = $( if ($private:pcObject.AccountIsDisabled) { 'No' } else { 'Yes' } )
                        $PCLog.'AD Description'              = $private:pcObject.Description
    
                }else {
    
                    $PCLog.'AD Computer Object Info Collected' = 'No'
    
                }


        $PCLog.GetEnumerator() | Sort-Object 'Name' | Format-Table -AutoSize
        $PCLog.GetEnumerator() | Sort-Object 'Name' | Out-GridView -Title "$private:pc Information"
}

function cleanUp ($pc){
            $Private:pc = $pc

            If(!(test-connection -Cn $Private:pc -BufferSize 16 -Count 1 -ea 0 -quiet)){
          
            Write-host -NoNewline  "PC " $Private:pc  " is NOT online!!! ... Press any key  " `n
            $x = $c.ReadKey("NoEcho,IncludeKeyDown")
            } else {
		            Write-progress "Removing Temp Folders from "  "in Progress:"
		            new-PSdrive IA Filesystem \\$Private:pc\C$ 
		
		            remove-item IA:\"$"Recycle.Bin\* -recurse -force -verbose
		            Write-Output "Cleaned up Recycle.Bin"
		
		
		            if (Test-Path IA:\Windows.old){
				            Remove-Item IA:\Windows.old\ -Recurse -Force -Verbose
				            }else{
				            Write-Output "no Windows.old Folder found" 
				            }
		            remove-item IA:\temp\* -recurse -force -verbose
		            Write-output "Cleaned up C:\temp\"
		
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
            If(!(test-connection -Cn $Private:pc -BufferSize 16 -Count 1 -ea 0 -quiet)){
            Write-host -NoNewline  "PC " $Private:pc  " is NOT online!!! ... Press any key  " `n
            $x = $c.ReadKey("NoEcho,IncludeKeyDown")
            } else {
                .\bin\PSTools\PsService.exe \\$Private:pc setconfig "OfficeScan NT Listener" auto -accepteula
                .\bin\PSTools\PsService.exe \\$Private:pc setconfig "OfficeScan NT Firewall" auto -accepteula
                .\bin\PSTools\PsService.exe \\$Private:pc setconfig "OfficeScan NT Proxy Service" auto -accepteula
                .\bin\PSTools\PsService.exe \\$Private:pc setconfig "OfficeScan NT RealTime Scan" auto -accepteula
            }
}

function attkScan ($pc) {
  
            $Private:pc = $pc
            $dest = "\\$private:pc\C$\avlog\"          
            If(!(test-connection -Cn $Private:pc -BufferSize 16 -Count 1 -ea 0 -quiet)){
            Write-host -NoNewline  "PC " $Private:pc  " is NOT online!!! ... Press any key  " `n
            $x = $c.ReadKey("NoEcho,IncludeKeyDown")
            } else {

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
                                }
                                1{clear          
                                    Write-Host "################################################################"
                                    Write-Host "                          ATTK Scan" -ForegroundColor Red
                                    Write-Host "################################################################
                                    " 
                                    $pc = Read-Host "What is the PC name or the IP-address "
                                    attkScan $pc
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
                                }
                                3{mainMenu}
                         }
}

function remoteCMD($pc){
             $Private:pc = $pc
             if(!(test-connection -Cn $Private:pc -BufferSize 16 -Count 1 -ea 0 -quiet)){
             Write-host -NoNewline  "PC " $Private:pc  " is NOT online!!! ... Press any key  " `n
                $x = $c.ReadKey("NoEcho,IncludeKeyDown")
             }else{
             
              .\bin\PSTools\PsExec.exe -accepteula -s \\$Private:pc cmd
            }
}

function dumpIt ($pc){
                        
          $Private:pc = $pc
          write-host "You can choose from the following Files"
          $files = Get-ChildItem $dump | select Name     
                   for ([int]$i = 1; $i -le $files.length; $i++){
                        write-host $i $files[$i-1].name
                   }
          
          $fileName = Read-Host "What filename will you sent"
         
          If(!(test-connection -Cn $Private:pc -BufferSize 16 -Count 1 -ea 0 -quiet)){
		       Write-host -NoNewline  "PC " $Private:pc  " is NOT online!!! ... Press any key  " `n
		       $x = $c.ReadKey("NoEcho,IncludeKeyDown")
          }else{
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
                        }
                        1{
                        
                            dumpIt $pc
                        }
                        2{mainMenu}     
                
                }

}

function mainMenu {
        cls       
        $Menu = "
Welcome  $agent  to Agent AID         version   $version

          What you want to do:

                           (1)   User info
                           (2)   PC info
                           (3)   Antivirus Tools
                           (4)   Admin Tools
                           (Q)   Exit
                           "

        $mainMenu = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 UserInfo", "&2 PCInfo", "&3 AVTools", "&4 ATools", "&Quit")
        [int]$defaultchoice = 4
        $choice =  $h.UI.PromptForChoice($Title , $Menu , $mainMenu, $defaultchoice)

             switch ($choice){
                   '0' 
                   { cls
                          write-host "################################################################"
                          write-host "                          USERINFO INFO" -ForegroundColor Green
                          write-host "################################################################
                                     "
                          $Id =  read-host "           What is the userID "
                          userInfo $Id
                   }
                   '1' {cls
                            Write-Host "###############################################################"
                            Write-Host "                           PCINFO INFO" -ForegroundColor Green
                            Write-Host "###############################################################
                                        "
                            $pc =  Read-Host "   What is the PC-Name or IP address "
                            PCInfo $pc
                   } 
                   '2' {cls
                            AVmenu
                   }
                   '3' {cls
                            ATmenu
                   }
                   'q' {cls
                        return
                   }
             }

}

mainMenu