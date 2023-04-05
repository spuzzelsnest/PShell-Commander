<#
.SYNOPSIS
    Alive.ps1
 
.DESCRIPTION
    Get PC names from the list of PC's of IP's and check for default values serialnumber
 
.NOTES
    VERSION HISTORY:
    1.0     06-18-2020 	- Initial release
    2.0     05-04-2023  - Rework if file does not exists

.COMPONENT 
    Not running any extra Modules.
 
.LINK
    https://github.com/spuzzelsnest/
 
.Parameter ParameterName
 
#>

$hostnameFile =  "Logs\hostnames.txt"

if ( Test-Path $hostnameFile ){
    $list = Get-Content $hostnameFile
  } else {
    Write-Host "No hostfile was set @ $hostnameFile - running on localhost!" -ForegroundColor Red
    $list = "localhost"
  }


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