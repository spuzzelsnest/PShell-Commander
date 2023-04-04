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
# get PC names from the list of pcna and check for default values name, version, 


$list = Get-Content .\Logs\hostnames.txt

Write-Host $list.count " pc's in list"

$serialList = @{}

foreach ($l in $list){

    if ( Test-Connection -Count 1 $l -ErrorAction SilentlyContinue) {
        Write-Host "Checking PC " $l
        $serial = (Get-WmiObject -ComputerName $l Win32_bios).serialnumber
        $serialList.add($l,$serial)
    }else{
        write-host $l "is niet online!" -ForegroundColor Red
    }
}

$serialList | Out-GridView