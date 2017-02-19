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

function dumpIt ($pc){




}



#Main

$h = get-host
$c = $h.UI.RawUI
$c.BackgroundColor = ($bckgrnd = 'black')


mode con:cols=140 lines=70
set-location $env:userprofile\Desktop

$instDir = $env:userprofile +"\Documents\dev\AgentAid"
$version = "v 0.1 - beta"
$agent = $env:UserName
$intro = get-content $instDir\bin\skins\intro1 | out-string
$menu = "


                      Press:
                               (1)   User info
                               (2)   PC info
                               (3)   Antivirus Tools
                               (4)   Admin Tools
                               (Q)   Exit


"
clear
#STart MEnu Build

write-host $intro -ForegroundColor Magenta
write-host "                 Welcome " $agent " to Agent AID         version  " $version -foregroundcolor white
write-host "                                                      powered by Powershell " $ 
write-host $menu -ForegroundColor Green



$mainMenu = [System.Management.Automation.Host.ChoiceDescription[]] @("&1_UserInfo", "&2_PCInfo", "&3_AVTools", "&4_ATools", "&Quit")
[int]$defaultchoice = 0
$opt =  $host.UI.PromptForChoice($Title , $Info , $mainMenu, $defaultchoice)
switch($opt){
0 { clear
                write-host "#####################################################################################"
                write-host "                                       USERINFO INFO" -ForegroundColor Green
                write-host "#####################################################################################"
                write-host ". "
                $Id =  read-host "                    What is the userID: "
                
                Write-Host User info -ForegroundColor Green
                userInfo $Id   
                              
    
  }
1 { clear

                Write-Host "#####################################################################################"
                Write-Host "                                       PCINFO INFO" -ForegroundColor Green
                Write-Host "#####################################################################################"
                Write-Host ". "
                $pc =  Read-Host "   What is the PC-Name or IP address: "
                PCInfo $pc
   }
2 { clear
    
                Write-Host "#####################################################################################"
                Write-Host "                                 Anti Virus and Cleaning Tool" -ForegroundColor Red                                         #
                Write-Host "#####################################################################################
  
                                          (1)   Clean TEMP files
                                          (2)   ATTK-Scan
                                          (3)   Aware-Hunter
                                          (4)   Back"
                
                $AVMenu = [System.Management.Automation.Host.ChoiceDescription[]] @("&1_Cleanup", "&2_ATTK", "&3_AWHunt", "&4_Back")
                [int]$defaultchoice = 0
                $subAV =  $host.UI.PromptForChoice($Title , $Info , $AVMenu, $defaultchoice)
                switch($suvAV){
                                        0{clear
                                Write-Host "#####################################################################################"
                                Write-Host "                                 Clearnup Temp Files" -ForegroundColor Red                                         #
                                Write-Host "#####################################################################################
                                "
                                $pc = Read-Host "What is the PC name or the IP-address: "

                                cleanUp $pc
                                         }
                                        1{clear          
                                Write-Host "#####################################################################################"
                                Write-Host "                                         ATTK Scan" -ForegroundColor Red                                         #
                                Write-Host "#####################################################################################"
                
                                        }
                                        2{clear
                                Write-Host "#####################################################################################"
                                Write-Host "                                         Full Clearnup" -ForegroundColor Red                                         #
                                Write-Host "#####################################################################################"
                
                                        }
                                        3{clear
                
                                Write-Host "#####################################################################################"
                                Write-Host "                                        Go back" -ForegroundColor Red                                         #
                                Write-Host "#####################################################################################"
                                        }
                         }
  }
3 { clear

        Write-Host "Good Bye!!!" -ForegroundColor Green}
4 {
    Write-Host "Good Bye!!!" -ForegroundColor Green
    clear  
    
  }



}