<#
.SYNOPSIS
    lansweep.ps1

.DESCRIPTION
    Get list of online Assets on the connected network and saving it to Logs\hostnames.txt.

.NOTES
    VERSION HISTORY:
    1.0     06-18-2020 	- Initial release
    2.0     05-04-2023  - Rework to new ping
                        - Adding portScan 

.COMPONENT 
    Not running any extra Modules.
 
.LINK
    https://github.com/spuzzelsnest/
 
.Parameter ParameterName
 
#>

$ErrorActionPreference = "silentlycontinue"

$MenuOptions = Get-NetAdapter |? {$_.Status -eq "Up"}
$MenuTitle = "                   found "+ $MenuOptions.count +" interfaces"
$Selection = 0
$EnterPressed = $False
$MaxValue = ($MenuOptions.count) - 1
$TCPports = @(22,80,443)
$ips = @()
$openPorts = @{}

function getLan($Selection){

    $iface = $MenuOptions[$Selection]
    $hostIp = ($iface | Get-NetIPAddress).IPv4Address
    $range = (($hostIp.Split(".")|Select-Object -First 3) -join ".")+"."

    Write-Host "you have selected " $iface.name "with ip $hostIp"
    pingRange($range)
}

function pingRange{
    param($range)

    Write-Host "Let's Try to Ping sweep the Range "$range"x"
    $ping = New-Object System.Net.NetworkInformation.ping
    $ips = @()

    For ($i = 1; $i -lt 255; $i++) {
        $ip = $range+$i
	    if ($ping.send($ip,500).status -eq "Success"){
	    	write-host "$ip online" -foregroundcolor green
	    	$ips += $ip
	    }
    }
   $ips | out-file .\Logs\hostnames.txt
   portScan($ips)
}

function portScan {
    param (
        $ips
    )

    Write-Host "... Starting scan for popular ports ...`n[$TCPports] on "$ips.Count" host(s)"

    foreach ($ip in $ips){
        foreach ($TCPport in $TCPports){
            $socket = New-Object System.Net.Sockets.TcpClient($ip, $TCPport)
            If($socket.Connected) {
                $openPorts.Add($ip,$TCPport) 
                $socket.Close()
            }else{
                Write-Debug "$ip port $TCPport not open"
            }
        }
        
    }
    $openPorts | Out-GridView
}

function MainMenu{
Clear-Host
While($EnterPressed -eq $False){
        
        Write-Host "$MenuTitle"

        For ($i=0; $i -le $MaxValue; $i++){
            
            If ($i -eq $Selection){
                Write-Host -BackgroundColor Cyan -ForegroundColor Black "[ $($MenuOptions[$i].Name) ]"
            } Else {
                Write-Host "  $($MenuOptions[$i].Name)  "
            }

        }

        $KeyInput = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown").virtualkeycode

        Switch($KeyInput){
            13{
                $EnterPressed = $True
               # Return $Selection
                getLAN($Selection)
            }

            38{
                If ($Selection -eq 0){
                    $Selection = $MaxValue
                } Else {
                    $Selection -= 1
                }
                Clear-Host
                break
            }

            40{
                If ($Selection -eq $MaxValue){
                    $Selection = 0
                } Else {
                    $Selection +=1
                }
                Clear-Host
                break
            }
            Default{
                Clear-Host
            }
        }
    }
}

MainMenu