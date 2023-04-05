<#
.SYNOPSIS
    assetsInfo.ps1
 
.DESCRIPTION
    This program looks for a list of pcnames which it wil check for .
 
.NOTES
       VERSION HISTORY:
       1.0     07-11-2017  - Asset Info file
       2.0     05-04-2023  - Update to new ping
 
.COMPONENT 
    Not running any extra Modules.
 
.LINK
    https://github.com/spuzzelsnest/
 
.Parameter ParameterName
 
#>
# START VARS

$hostnameFile = "Logs\hostnames.txt"
$ping = New-Object System.Net.NetworkInformation.Ping
$PCLog = @{}

if ( Test-Path $hostnameFile ){
    $list = Get-Content $hostnameFile
  } else {
    Write-Host "No hostfile was set @ $hostnameFile - running on localhost!" -ForegroundColor Red
    $list = "localhost"
  }

  $list

foreach ($pc in $list){

        'Processing ' + $pc + '...'
        $PCLog.'PC-Name' = $pc
        $PCLog.''
        $PCLog.Ping = if ($ping.send($pc,500).status -eq "Success"){ "Yes" } else { "No" }
                $ErrorActionPreference = 'SilentlyContinue'
                if ( $ips = [System.Net.Dns]::GetHostAddresses($pc) | foreach { $_.IPAddressToString } ) {

                    $PCLog.'IP Address(es) from DNS' = ($ips -join ', ')
                }

                else {

                    $PCLog.'IP Address from DNS' = 'Could not resolve'

                }
# Make errors visible again
                $ErrorActionPreference = 'Continue'

# We'll assume no ping reply means it's dead. Try this anyway if -IgnorePing is specified
                if ($ping -or $ignorePing) {

                    $PCLog.'WMI Data Collection Attempt' = 'Yes (ping reply or -IgnorePing)'

# Get various info from the ComputerSystem WMI class
                    if ($wmi = Get-WmiObject -Computer $pc -Class Win32_ComputerSystem -ErrorAction SilentlyContinue) {

                        $PCLog.'Computer Hardware Manufacturer' = $wmi.Manufacturer
                        $PCLog.'Computer Hardware Model'        = $wmi.Model
                        $PCLog.'Physical Memory in MB'          = ($wmi.TotalPhysicalMemory/1MB).ToString('N')
                        $PCLog.'Logged On User'                 = $wmi.Username
                    }

                    $wmi = $null

# Get the free/total disk space from local disks (DriveType 3)
                    if ($wmi = Get-WmiObject -Computer $pc -Class Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction SilentlyContinue) {

                        $wmi | Select 'DeviceID', 'Size', 'FreeSpace' | Foreach {

                            $PCLog."Local disk $($_.DeviceID)" = ('' + ($_.FreeSpace/1MB).ToString('N') + ' MB free of ' + ($_.Size/1MB).ToString('N') + ' MB total space' )
                        }
                    }
                    $wmi = $null

# Get IP addresses from all local network adapters through WMI
        if ($wmi = Get-WmiObject -Computer $pc -Class Win32_NetworkAdapterConfiguration -ErrorAction SilentlyContinue) {

                $Ips = @{}

                $wmi | Where { $_.IPAddress -match '\S+' } | Foreach { $Ips.$($_.IPAddress -join ', ') = $_.MACAddress }

                $counter = 0
                $Ips.GetEnumerator() | Foreach {

                $counter++; $PCLog."IP Address $counter" = '' + $_.Name + ' (MAC: ' + $_.Value + ')'
                }
        }

            $wmi = $null

# Get CPU information with WMI
    if ($wmi = Get-WmiObject -Computer $pc -Class Win32_Processor -ErrorAction SilentlyContinue) {

        $wmi | Foreach {
                $maxClockSpeed     =  $_.MaxClockSpeed
                $numberOfCores     += $_.NumberOfCores
                $description       =  $_.Description
                $numberOfLogProc   += $_.NumberOfLogicalProcessors
                $socketDesignation =  $_.SocketDesignation
                $status            =  $_.Status
                $manufacturer      =  $_.Manufacturer
                $name              =  $_.Name
            }
                $PCLog.'CPU Clock Speed'        = $maxClockSpeed
                $PCLog.'CPU Cores'              = $numberOfCores
                $PCLog.'CPU Description'        = $description
                $PCLog.'CPU Logical Processors' = $numberOfLogProc
                $PCLog.'CPU Socket'             = $socketDesignation
                $PCLog.'CPU Status'             = $status
                $PCLog.'CPU Manufacturer'       = $manufacturer
                $PCLog.'CPU Name'               = $name -replace '\s+', ' '
            }
                $wmi = $null

# Get BIOS info from WMI
            if ($wmi = Get-WmiObject -Computer $pc -Class Win32_Bios -ErrorAction SilentlyContinue) {

                $PCLog.'BIOS Manufacturer' = $wmi.Manufacturer
                $PCLog.'BIOS Name'         = $wmi.Name
                $PCLog.'BIOS Version'      = $wmi.Version
            }

         $wmi = $null

# Get operating system info from WMI
                if ($wmi = Get-WmiObject -Computer $pc -Class Win32_OperatingSystem -ErrorAction SilentlyContinue) {

                $PCLog.'OS Boot Time'     = $wmi.ConvertToDateTime($wmi.LastBootUpTime)
                $PCLog.'OS System Drive'  = $wmi.SystemDrive
                $PCLog.'OS System Device' = $wmi.SystemDevice
                $PCLog.'OS Language     ' = $wmi.OSLanguage
                $PCLog.'OS Version'       = $wmi.Version
                $PCLog.'OS Windows dir'   = $wmi.WindowsDirectory
                $PCLog.'OS Name'          = $wmi.Caption
                $PCLog.'OS Install Date'  = $wmi.ConvertToDateTime($wmi.InstallDate)
                $PCLog.'OS Service Pack'  = [string]$wmi.ServicePackMajorVersion + '.' + $wmi.ServicePackMinorVersion
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

                $socket = New-Object Net.Sockets.TcpClient

# Suppress error messages
                $ErrorActionPreference = 'SilentlyContinue'

# Try to connect
                $socket.Connect($pc, $ports.$service)

# Make error messages visible again
                $ErrorActionPreference = 'Continue'

        if ($socket.Connected) {

                            $PCLog."Port $($ports.$service) ($service)" = 'Open'
                            $socket.Close()

                        }else {
                            $PCLog."Port $($ports.$service) ($service)" = 'Closed or filtered'
                        }
                    $socket = $null
                }

            }else {

            $PCLog.'WMI Data Collected' = 'No (no ping reply and -IgnorePing not specified)'

            }

# Get data from AD using Quest ActiveRoles Get-ADComputer
    $pcObject = Get-ADComputer $pc -ErrorAction 'SilentlyContinue'
    if ($pcObject) {
        $PCLog.'AD Operating System'         = $pcObject.OSName
        $PCLog.'AD OU path'                  = $pcObject.CanonicalName
        $PCLog.'AD LDAP Data'                = $pcObject.DistinguishedName
        $PCLog.'AD Operating System Version' = $pcObject.OSVersion
        $PCLog.'AD Service Pack'             = $pcObject.OSServicePack
        $PCLog.'AD Enabled AD Account'       = $( if ($pcObject.AccountIsDisabled) { 'No' } else { 'Yes' } )
        $PCLog.'AD Description'              = $pcObject.Description
    }else {
        $PCLog.'AD Computer Object Info Collected' = 'No'
    }
    $PCLog.GetEnumerator() | Sort-Object 'Name' | Ft -AutoSize -wrap
    $PCLog.GetEnumerator() | Sort-Object 'Name' | Out-GridView -Title "$pc Information"
}