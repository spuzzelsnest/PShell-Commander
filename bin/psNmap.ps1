<#
.SYNOPSIS
    Portscan that scans for Online hosts on the subnet of the first connected network Adapter on your PC.

.DESCRIPTION
    Portscan that scans for Online hosts on the subnet of the first connected network Adapter on your PC.
    The range of ports can be edited to change results. Scanning a Subnet can take up to 15 minutes.
    Limiting the amount of ports will drop the time.

.NOTES
    Run in default powershell.

.COMPONENT 
    Not running any extra Modules.

.LINK
    https://github.com/spuzzelsnest/

.Parameter ParameterName
    $ifList     - list of all found Network Adaptors with the status UP.
    $ownIP      - IP from the first in the list of Network Adaptors that was found wit the status UP. 
    $ipRange    - IP Range define of the first 3 octets of the variable Own IP.
    $TCPports   - List of Popuplar ports.
    $ips        - Empty array for storing Online IP's
    $openPorts  - Empty hashtable for storing Online IP's with Open Ports

#>

# env

$ErrorActionPreference = "silentlycontinue"

# Vars
$ifList = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
$ifIndex = 0
$TCPports = @(22,80,443)
$ips = @()
$openPorts = @{}

# Start Program
Get-Date

# Select wich Network Adapter to use

Write-Host $ifList.Count "Networkadapter(s) found.`nPlease select a network adapter to use.`n"

for  ($i = 0; $i -lt $($ifList).Count; $i++){
    Write-Host " $i. " $($ifList[$i]).Name " - "  (Get-NetIPAddress -InterfaceIndex $ifList[$i].ifIndex).IPv4Address
}

$selectedAdapter = -1

do {
    $inputValid = $false
    $selectedAdapter = Read-Host "`nEnter the index of the adapter to use"
    if ($selectedAdapter -ge 0 -and $selectedAdapter -lt $ifList.Count) {
        
        $inputValid = $true
        $ifIndex = $ifList[$selectedAdapter].ifIndex 

    } else {
        Write-Host "Invalid input. Please enter a number between 0 and $($ifList.Count - 1)"
    }
} while (-not $inputValid)


$ownIP = (Get-NetIPAddress -InterfaceIndex $ifIndex).IPv4Address | Out-String
$ipRange = (($ownIP.Split(".")|Select-Object -First 3) -join ".")+"."

Write-Host "Selected interface " $ifList[$selectedAdapter].Name " With IP range $ipRange.1/24"

Clear-Content -Path .\hostname.txt

# Running ping scan on default range from 1 to 254

For ($i = 1; $i -lt 254; $i++) {
    $ip = $ipRange+$i
    if ($ip -eq $ownIP){
        Write-Debug "Removing own IP from List so no time is wasted scanning ports on localhost"
    }else{
        if ( Test-Connection -count 1 -comp $ip -quiet ){
            $ips += $ip
        }
    }
}

Write-Host "... Starting scan for popular ports ...`n[$TCPports] on "$ips.Count" host(s)"

foreach ($ip in $ips){
    foreach ($TCPport in $TCPports){
        If(Test-Connection -BufferSize 32 -Count 1 -Quiet -ComputerName $ip){
            $socket = New-Object System.Net.Sockets.TcpClient($ip, $TCPport)
            If($socket.Connected) {
                $openPorts.Add($ip,$TCPport) 
                $socket.Close()
            }else{
                Write-Debug "$ip port $TCPport not open"
            }
        }
    }
}

Write-host "`nFound the folling open ports" -ForegroundColor Green

# Opening Hashtable in GridView

$openPorts | Out-GridView