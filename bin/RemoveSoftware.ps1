
$list = Get-Content H:\hostnames.txt
$c = get-credential

#$ErrorActionPreference = "silentlycontinue"


foreach ( $l in $list){

    if( test-connection -count 1 $l ) {
    
    invoke-command -computername $l -credential $c -Scriptblock { 
        Get-Package -name "3CX Desktop App" | Uninstall-Package 
    }
    write-host "Processed " $l
    } else {

    Write-host $l " offline" -ForegroundColor Red
    }
}