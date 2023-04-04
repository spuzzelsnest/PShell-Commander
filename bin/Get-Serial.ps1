#--------------------------------------------------------------------------------
#
# NAME:		Assets.ps1
#
# AUTHOR:	Spuzzelsnest
# EMAIL:	j.mpdesmet@protonmail.com
#
# COMMENT:
#           get Assets active on the network
#
#
#       VERSION HISTORY:
#       1.0     06.18.2020 	- Initial release
#--------------------------------------------------------------------------------
# get PC names from the list ans check for default values name, version, 


$file = get-content C:\PShell-Commander\bin\Logs\PC-list_prod.txt | select -Unique 

write-host $file.count " pc's in list"
$serialList = @{}

foreach ($f in $file){


if(!($(New-Object System.Net.NetworkInformation.Ping).SendPingAsync($f).result.status -eq 'Succes')){

     write-host $f "is niet online!"

}else{
      write-host $f
      $serial = (gwmi -computerName $f Win32_bios).serialnumber
      $serialList.add( $f, $serial )
  }

}

$serialList