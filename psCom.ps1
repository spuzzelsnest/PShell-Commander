#==========================================================================
#
# NAME:		pShell-Commander.ps1
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
#       1.6     07.06.2017  - Anti Virus update
#       1.7     07.11.2017  - Alive Service
#       2.0     02.21.2018  - Reorder structure
#                           - Added external popup for remote
#                           - Checking Domain or Workgroup
#       2.1.0   06.26.2018  - Adding Unix basic support
#       2.1.1   10.02.2018  - Restructured Module sequence
#
#==========================================================================
#START VARS
#-----------
clear
    $version = "v 2.1.1"
    $psver = $PSVersionTable.PSVersion.tostring()
    $workDir = $pwd 
    $dump = "bin/_dumpFiles"
    $psTools = "bin/PSTools"
    $pcQ= "What is the PC name or the IP-address or press ENTER to Cancel"
    $h = get-host
    $g = $h.UI
    $c = $h.UI.RawUI
    $platform = ($PSVersionTable).Platform
    
#MODULES
#-------

    ##add new local path
    $modsFolder = "$workDir/bin/Modules"
    $env:PSMODULEPATH += ";$modsFolder"

    ##Adding Extras
    
    $mods = get-ChildItem $modsFolder
    
    foreach ($mod in $mods){
     
            if( (Get-Module -Name $mod.name -ErrorAction SilentlyContinue) -eq $null){
                    Import-Module -Name $mod -ErrorAction SilentlyContinue
            }
    }
#PICK OS

if ($platform -eq 'Unix'){

    #MAC OSX / LINUX VARS
    
        $hostn = hostname
        $agent = $env:USER
        $root = "$env:HOME/Desktop"
        $warning = "!!!! NOT AVAILABLE !!!!"

}else{

    #WINDOWS VARS
        $hostn = Get-Childitem Env:Computername
        $agent = $env:USERNAME
        $root = "$env:USERPROFILE/Desktop"
        
        #Set ScreenSize in Windows

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

        ###Exchange
        ###installed in %ExchangeInstallPath%\bin
            if( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null){
                    Add-PsSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue
            }
}
#STARTING ALIVE SERVICE

function Alive{

        if((test-path $root/PC-list.txt) -eq  $False){
            new-item $root/PC-list.txt -type file
            Write-host creating new PC-list file -foreground Magenta
        }else{
            write-host PC-list file exists -Foreground Green
        }

        if(!( get-service AgentAid-Alive -ErrorAction SilentlyContinue) -eq $True){
            new-service -name AgentAid-Alive -BinaryPathName "powershell.exe -NoLogo -Path $workDir/bin/Alive.ps1" -DisplayName "PC alive Service for PShell Commander" -StartupType Manual
        }else {
            restart-service AgentAid-Alive -ErrorAction SilentlyContinue
        }
        invoke-item "$root/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/pc-report.html"
}
#alive

# START PROGRAM
    cd $workDir
    $loadscreen = get-content bin/visuals/loadscreen | Out-String
    $loadedModules = get-module
    write-host $loadscreen -ForegroundColor Magenta

    if ($PSVersionTable.PSVersion.Major -gt 2)
    {
        Write-Output "Yay Powershell is running on version $psver
        "
    }
    else
    {
        Write-Output "Boo, you are running an older version of powershell $psver" -foregroundcolor red
    }
    Write-host "              The following Powershell Modules Are loaded
    " -ForegroundColor Yellow 

    $loadedModules | %{
        Write-Host "            - $_"-Foreground green
    }

    Write-Host "
           ... Just a second, script is loading ..." -foregroundcolor Green
    Write-Host "                      ***if you want to add more Modules add them in bin/Modules***"
    start-sleep 5
    clear
#Global Functions
function CC ($pc){
if(!($pc -eq "c")){
    if(!($(New-Object System.Net.NetworkInformation.Ping).SendPingAsync($pc).result.status -eq 'Succes')){
		Write-host -NoNewline  "PC " $pc  " is NOT online!!! ... Press any key  " `n
        clear
		return $False
	}else{
	   return $True
    }
}else{x}
}

function x{
    write-host "Press any key to go back to the main menu"
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    clear
    cd $workdir
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

function alterName($pc){

    $alterNames = netdom computername $pc /enum
    $alterNames | %{
        write-host $_ "`n" -ForegroundColor Yellow
    }
x
}

function cleanUp ($pc){
    if (CC($pc)){

        Write-progress "Removing Temp Folders from "  "in Progress:"
		new-PSdrive IA Filesystem \\$pc\C$
		remove-item IA:\"$"Recycle.Bin\* -recurse -force -verbose
		Write-host "Cleaned up Recycle.Bin" -foreground Green
		if (Test-Path IA:\Windows.old){
            Remove-Item IA:\Windows.old\ -Recurse -Force -Verbose
		}else{
		    Write-host "no Windows.old Folder found" -foreground green
		}
        remove-item IA:\Windows\Temp\* -recurse -force -verbose
        write-host "Cleaned up C:\Windows\Temp" -foreground Green
      	$UserFolders = get-childItem IA:\Users\ -Directory

        foreach ($folder in $UserFolders){
            $path = "IA:\Users\"+$folder
            remove-item $path\AppData\Local\Temp\* -recurse -force -verbose -ErrorAction SilentlyContinue
            remove-item $path\AppData\Local\Microsoft\Windows\"Temporary Internet Files"\* -recurse -force -verbose -ErrorAction SilentlyContinue
            Write-host "Cleaned up Temp Items for "$folder.Name -foreground Green
        }
        net use /delete \\$pc\C$
    }
x
}

function attkScan ($pc) {
    if (CC($pc)){
    cd $psTools
        $dest = "\\$pc\C$\avlog"
        $log = "$root\$pc"

        if(!(Test-Path "$dest\attk_x64.exe")){
            New-Item -ItemType Directory -Force -Path $dest
            Write-Host "copying attk scan to C:\avlog" -ForegroundColor White
            robocopy.exe $dump $dest attk_x64.exe
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
        PsExec.exe -s  \\$pc cmd /s /k  "cd C:\avlog && attk_x64.exe && exit" -accepteula
        robocopy.exe "\\$pc\C$\avlog\TrendMicro AntiThreat Toolkit\Output" $log *
    }
x
}

function remoteCMD($pc){
    if(CC($pc)){
    cd $psTools
                $args = "-accepteula -s \\$pc -u $sUser powershell"
                Start-Process PsExec.exe -ArgumentList $args
    }
x
}

function interactiveCMD($pc){
    if(CC($pc)){
    cd $psTools
                $args = "-accepteula -s -i \\$pc -u $dom\$AUser powershell"
                Start-Process PsExec.exe -ArgumentList $args
    }
x
}

function loggedon($pc){
    if(CC($pc)){
    cd $psTools
        PsLoggedon.exe /l \\$pc -accepteula
        Write-Host Other USERID´s in this PC.
        Get-ChildItem  \\$pc\C$\Users\ |select name
    }
x
}

function dumpIt ($pc){

$dest = "$pc\C$\Temp"
$log = "$root/$pc"
write-host "You can choose from the following Files or press C to Cancel:
 *For now only Copy pasting the name or rewrite it in the box works*"
          $files = Get-ChildItem $dump | select Name
          
            for ([int]$i = 1; $i -le $files.length; $i++){
                        write-host $i $files[$i-1].name
                   }
            
            $fileName = Read-Host "What File do you want to send"
          

    if (CC($pc)){
   
          
            if(!(Test-Path $dest\Logs)){
                Write-host Creating $dest\Logs -ForegroundColor magenta
				New-Item -ItemType Directory -Force -Path \\$dest\Logs
			}else{
                write-host The $dest\Logs directory exsists -foregroundColor green
			}

		    Copy-Item $dump\$filename $dest
            Write-Host $filename copied to $dest -ForegroundColor green
            cd $psTools
		    PsExec.exe -accepteula -s \\$pc cmd /C C:\Temp\$filename
            
            if(!(Test-path $log)){
				Write-Host $log is not available -Foreground magenta
				new-Item $log -type directory -Force
			}else{
		        Write-Host Logs will be written to $log -Foreground green
            }
            robocopy.exe $dest\Logs $log *.* /move
            Remove-Item $dest\$filename -Verbose
            Write-Host Files removed from $pc -Foreground "green"       
    }
x
}

#Menu's
function ADmenu{
    $Tile = "AD Tools --   $warning"
    $Menu = "
            (1)  AD-User Info
            
            (2)  AD-Server Info
            
            (3)  Find Related Server Names
            
            (4)  Who is logged on
            
            (5)  Back
            "
    $ADchoice = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 ADUser","&2 ADServ","&3 alternateName","&4 Loggedon","&5 Back")
    [int]$defchoice = 4
    $subAD =  $h.UI.PromptForChoice($Title, $Menu, $ADchoice,$defchoice)
    switch($subAD){
            0{
            clear
              write-host "################################################################"
              write-host "                          USERINFO INFO" -ForegroundColor Green
              write-host "################################################################
                         "
              $Id =''
              if(!$id){
                    Write-Host "Please typ in a User ID"
                    
                    $Id =  read-host "What is the userID "
              }
              userInfo $Id
           }1{
           clear
             Write-Host "###############################################################"
             Write-Host "                           PCINFO INFO" -ForegroundColor Green
             Write-Host "###############################################################
                        "
                $pc =''
                    if(!$pc){
                    write-host $pcQ
                    
                    $pc = Read-Host $pcQ
                }
              PCInfo $pc
           }2{
           clear
             Write-Host "################################################################"
             Write-Host "                 Find Alternative Server Name" -ForegroundColor Red
             Write-Host "################################################################
                        "
             $pc =''
            if(!$pc){
                write-host $pcQ
                
                $pc = Read-Host $pcQ
            }
            alterName $pc
           }3{
           clear
            Write-Host "################################################################"
            Write-Host "         Find user who is logged on to PC" -ForegroundColor Red
            Write-Host "################################################################
                    "
            $pc =''
            if(!$pc){
                write-host $pcQ
                
                $pc = Read-Host $pcQ
            }
            loggedOn $pc
            }4{mainMenu}
    }
}

function NTmenu {
    $Title = "Network Tools"
    $Menu = "
          (1)   Remote CMD

          (2)   Interactive CMD

          (3)   Dump File To PC

          (4)   Back
          "
    $NTchoice = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 CMD","&2 iCMD","&3 Dump","&4 Back")
    [int]$defchoice = 3
    $subNT = $h.UI.PromptForChoice($Title, $Menu, $NTchoice,$defchoice)
    switch($subNT){
            0{
            clear
                Write-Host "################################################################"
                Write-Host "                     Remote CMD" -ForegroundColor Red
                Write-Host "################################################################
                "
                $pc =''
                if(!$pc){
                    write-host "Please type in a PC Name or IP address
                    "
                    $pc = Read-Host $pcQ
                }
                remoteCMD $pc

            }1{
            clear
                Write-Host "################################################################"
                Write-Host "                     InterActive CMD" -ForegroundColor Red
                Write-Host "################################################################
                "
                $pc =''
                if(!$pc){
                    write-host "Please type in a PC Name or IP address
                    "
                    $pc = Read-Host $pcQ
                }
                interactiveCMD $pc                      

            }2{
            clear
                Write-Host "################################################################"
                Write-Host "                     Dump file to PC" -ForegroundColor Red
                Write-Host "################################################################
                "
                $pc =''
                if(!$pc){
                    write-host "Please type in a PC Name or IP address
                    "
                    $pc = Read-Host $pcQ
                }
                dumpIt $pc
            }3{mainMenu}
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
                        0{
                        clear
                            Write-Host "################################################################"
                            Write-Host "                     Clearnup Temp Files" -ForegroundColor Red
                            Write-Host "################################################################
                            "
                            $pc =''
                            if(!$pc){
                            write-host "Please type in a PC Name or IP address
                            "
                            $pc = Read-Host 
                            }
                            cleanUp $pc
                            x
                        }1{
                        clear
                            Write-Host "################################################################"
                            Write-Host "                          ATTK Scan" -ForegroundColor Red
                            Write-Host "################################################################
                            "
                            $pc =''
                            if(!$pc){
                            write-host "Please type in a PC Name or IP address
                            "
                            $pc = Read-Host $pcQ
                            }
                            attkScan $pc
                            x
                        }2{
                        clear
                            Write-Host "################################################################"
                            Write-Host "                          Full Clearnup" -ForegroundColor Red
                            Write-Host "################################################################
                            "
                           $pc =''
                            if(!$pc){
                            write-host "Please type in a PC Name or IP address
                            "
                            $pc = Read-Host $pcQ
                            }
                            cleanup $pc
                            attkScan $pc
                            x
                        }3{mainMenu}
        }
}

function ADVmenu{
                $Title = "Advanced Tools"
                $Menu = "
                      (1)   Back
                      "
                $AVchoice = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 Back")
                [int]$defchoice = 0
                $subAV =  $h.UI.PromptForChoice($Title , $Menu , $AVchoice, $defchoice)
                switch($subAV){ 

                        0{mainMenu}

                }
}

function mainMenu {
        $Title = "pShell Commander"
        clear
		$LengthName = $agent.length
		$line = "************************************************" + "*"* $LengthName
        $Menu = "
Welcome $agent to pShell Commander         version: $version on PowerShell $psver

Runnig on $platform from $hostn on $dom
$line

          What you want to do:

                           (1)   AD-Tools  ---  $warning
                           
                           (2)   Network Tools
                           
                           (3)   Antivirus Tools
                           
                           (4)   Advanced Tools
                           
                           (Q)   Exit
                           "
        $mainMenu = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 ADTools", "&2 NTTools", "&3 AVTools", "&4 ADVTools", "&Quit")
        [int]$defaultchoice = 4
        $choice =  $h.UI.PromptForChoice($Title, $Menu, $mainMenu, $defaultchoice)

             switch ($choice){
                   0{
                   clear
                        ADmenu
                   }1{
                   clear
                        NTmenu
                   }2{
                   clear
                        AVmenu
                   }3{
                   clear
                        ADVmenu
                   }q{
                   clear
                        $h.ExitNestedPrompt()
                   }
             }
}

mainMenu