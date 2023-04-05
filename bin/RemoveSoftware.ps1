<#
.SYNOPSIS
    RemoveSoftware.ps1

.DESCRIPTION
    Removeing Software - initiated after 3cx supply chain Attack

.NOTES
    VERSION HISTORY:
    1.0     03.04.2023  - Initial create

.COMPONENT 
    Not running any extra Modules.
 
.LINK
    https://github.com/spuzzelsnest/
 
.Parameter ParameterName
 
#>

$hostnameFile = "Logs\hostnames.txt"
$ping = New-Object System.Net.NetworkInformation.Ping
$c = Get-Credential

if ( Test-Path $hostnameFile ){
    $list = Get-Content $hostnameFile
  } else {
    Write-Host "No hostfile was set @ $hostnameFile - running on localhost!" -ForegroundColor Red
    $list = "localhost"
  }

foreach ( $l in $list){

    if ($ping.send($l,500).status -eq "Success"){

        Write-Host "Processed " $l
        Invoke-Command -ComputerName $l -Credential $c -Scriptblock { Get-Package -name "3CX Desktop App" | Uninstall-Package }

    } else {

        Write-Host $l "is Offline" -ForegroundColor Red

    }
}