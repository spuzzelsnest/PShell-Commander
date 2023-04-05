#--------------------------------------------------------------------------------
#
# NAME:		lansweep.ps1
#
# AUTHOR:	Spuzzelsnest
# EMAIL:	j.mpdesmet@gmail.com
#
# COMMENT:
#           get Assets active on the network
#
#
#       VERSION HISTORY:
#       1.0     11.05.2020 	- Initial release
#--------------------------------------------------------------------------------

$MenuOptions = Get-NetAdapter |? {$_.Status -eq "Up"}
$MenuTitle = "                   found "+ $MenuOptions.count +" interfaces"
$Selection = 0
$EnterPressed = $False
$MaxValue = ($MenuOptions.count) - 1

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