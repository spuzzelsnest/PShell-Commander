$list = get-content .\Logs\hostnames.txt
$PCLog = @{}

foreach ($pc in $list){

        $Private:pc = $pc
        'Processing ' + $Private:pc + '...'
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
        $PCLog.'AD OU path'                  = $Private:pcObject.CanonicalName
        $PCLog.'AD LDAP Data'                = $Private:pcObject.DistinguishedName
        $PCLog.'AD Operating System Version' = $Private:pcObject.OSVersion
        $PCLog.'AD Service Pack'             = $Private:pcObject.OSServicePack
        $PCLog.'AD Enabled AD Account'       = $( if ($Private:pcObject.AccountIsDisabled) { 'No' } else { 'Yes' } )
        $PCLog.'AD Description'              = $Private:pcObject.Description
    }else {
        $PCLog.'AD Computer Object Info Collected' = 'No'
    }
    $PCLog.GetEnumerator() | Sort-Object 'Name' | Ft -AutoSize -wrap
    $PCLog.GetEnumerator() | Sort-Object 'Name' | Out-GridView -Title "$Private:pc Information"
}