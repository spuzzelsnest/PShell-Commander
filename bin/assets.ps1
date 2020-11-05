#--------------------------------------------------------------------------------
#
# NAME:		Assets.ps1
#
# AUTHOR:	Spuzzelsnest
# EMAIL:	j.mpdesmet@gmail.com
#
# COMMENT:
#           get Assets active on the network
#
#
#       VERSION HISTORY:
#       1.0     06.18.2020 	- Initial release
#--------------------------------------------------------------------------------
# get PC names from the list ans check for default values name, version, 


$file = get-content C:\PShell-Commander\bin\Logs\PC-list.txt

write-host $file.count " pc's in list"


#$ErrorActionPreference = "SilentlyContinue"
$pcinfo = @{}

foreach ($f in $file){


if(!($(New-Object System.Net.NetworkInformation.Ping).SendPingAsync($f).result.status -eq 'Succes')){

     write-host $f "is niet online!"

}else{
  
        $Private:pc = $f
        'Processing ' + $Private:pc + '...'
        $PCLog = @{}
        $PCLog.'PC-Name' = $Private:pc
        $PCLog.''

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
                $PCLog.'CPU Name'               = $Private:name -replace '\s+', ' '
            }
                $Private:wmi = $null

# Get BIOS info from WMI
            if ($Private:wmi = Get-WmiObject -Computer $Private:pc -Class Win32_Bios -ErrorAction SilentlyContinue) {

                $PCLog.'BIOS Manufacturer' = $Private:wmi.Manufacturer
                $PCLog.'BIOS SN'           = $Private:wmi.Serial
                $PCLog.'BIOS Name'         = $Private:wmi.Name
                $PCLog.'BIOS Version'      = $Private:wmi.Version
            }

         $Private:wmi = $null

# Get operating system info from WMI
                if ($Private:wmi = Get-WmiObject -Computer $Private:pc -Class Win32_OperatingSystem -ErrorAction SilentlyContinue) {

                $PCLog.'OS Boot Time'     = $Private:wmi.ConvertToDateTime($Private:wmi.LastBootUpTime)
                $PCLog.'OS Language     ' = $Private:wmi.OSLanguage
                $PCLog.'OS Version'       = $Private:wmi.Version
                $PCLog.'OS Name'          = $Private:wmi.Caption
                $PCLog.'OS Install Date'  = $Private:wmi.ConvertToDateTime($Private:wmi.InstallDate)

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
        $PCLog.'AD OU path'                  = $Private:pcObject.CanonicalName
        $PCLog.'AD LDAP Data'                = $Private:pcObject.DistinguishedName
        $PCLog.'AD Operating System Version' = $Private:pcObject.OSVersion
        $PCLog.'AD Service Pack'             = $Private:pcObject.OSServicePack
        $PCLog.'AD Enabled AD Account'       = $( if ($Private:pcObject.AccountIsDisabled) { 'No' } else { 'Yes' } )
        $PCLog.'AD Description'              = $Private:pcObject.Description
    }else {
        
        $PCLog.'AD Computer Object Info Collected' = 'No'
    }

    #$PCLog.GetEnumerator() | Sort-Object 'Name' | Ft -AutoSize -wrap
    #$PCLog.GetEnumerator() | Sort-Object 'Name' | Out-GridView -Title "$Private:pc Information"

}


}