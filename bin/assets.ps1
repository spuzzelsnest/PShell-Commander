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


$file = get-content "$env:USERPROFILE\Desktop\PC-list.txt"

foreach ($f in $file){


if(!($(New-Object System.Net.NetworkInformation.Ping).SendPingAsync($f).result.status -eq 'Succes')){

     write-host $f "is niet online!"

}else{

    $pcinfo = get-adcomputer $f -Properties * | Select-object samAccountName, OperatingSystem, Lastlogondate
    
    $wmi = Get-WmiObject -Computer $f -Class Win32_ComputerSystem
    
    $pcinfo
    $wmi.model

    }
}