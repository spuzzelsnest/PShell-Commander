#--------------------------------------------------------------------------------
#
# NAME:		RemoveSoftware.ps1
#
# AUTHOR:	Spuzzelsnest
#
# COMMENT:
#			Removeing Software - initiated after 3cx supply chain Attack
#
#
#       VERSION HISTORY:
#       1.0     03.04.2023  - Initial create
#
#--------------------------------------------------------------------------------
#Vars

$list = Get-Content .\Logs\hostnames.txt
$c = Get-Credential

foreach ( $l in $list){

    if( Test-Connection -count 1 $l -ErrorAction SilentlyContinue) {
    
        Write-Host "Processed " $l
        Invoke-Command -ComputerName $l -Credential $c -Scriptblock { Get-Package -name "3CX Desktop App" | Uninstall-Package }
        

    } else {

        Write-Host $l "is Offline" -ForegroundColor Red
    }
}