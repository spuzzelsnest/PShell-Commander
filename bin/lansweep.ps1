#--------------------------------------------------------------------------------
#
# NAME:		lansweep.ps1
#
# AUTHOR:	Spuzzelsnest
# EMAIL:	j.mpdesmet@protomail.com
#
# COMMENT:
#           get Assets active on the network
#
#
#       VERSION HISTORY:
#       1.0     11.05.2020 	- Initial release
#--------------------------------------------------------------------------------

#get active network adaptors

#$ErrorActionPreference = "SilentlyContinue"

$MenuOptions = Get-NetAdapter |? {$_.status -eq 'up'}
$MenuTitle = "                   found "+ $MenuOptions.count +" interfaces"
$Selection = 0
$EnterPressed = $False
$MaxValue = ($MenuOptions.count) - 1

function getLan($Selection){

    $iface = $MenuOptions[$Selection]
    $hostIp = ($iface | Get-NetIPAddress).IPv4Address
    $range = $hostIp -split '.', -3

    Write-Host "you have selected " $iface.name "with ip " $hostIp " in range " $range "x"

    #1..254 | % {"10.38.1.$($_): $(Test-Connection -count 1 -comp 10.38.1.$($_) -quiet)"} | select-string "True" | Foreach-Object {$_ -replace ": True"} | ForEach-Object {([system.net.dns]::GetHostByAddress($_)).hostname >>hostnames.txt}

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
