<#
.SYNOPSIS
    Simplefied youtube downlaoder

.DESCRIPTION
    Script based on youtube dl to make it easier to use for none commandline users

.NOTES
    VERSION HISTORY:
    1.0     10-04-2021 	- Initial release

.COMPONENT 
    Not running any extra Modules.
 
.LINK
    https://github.com/spuzzelsnest/
 
#>


$ErrorActionPreference = "silentlycontinue"


Set-ExecutionPolicy Bypass -Scope Process -Force


Write-host "`n

                             _                  _                   _                 _ 
                   _        | |                | |                 | |               | |
 _   _  ___  _   _| |_ _   _| | _   ____     _ | | ___  _ _ _ ____ | | ___   ____  _ | |
| | | |/ _ \| | | |  _) | | | || \ / _  )   / || |/ _ \| | | |  _ \| |/ _ \ / _  |/ || |
| |_| | |_| | |_| | |_| |_| | |_) | (/ /   ( (_| | |_| | | | | | | | | |_| ( ( | ( (_| |
 \__  |\___/ \____|\___)____|____/ \____)   \____|\___/ \____|_| |_|_|\___/ \_||_|\____|
(____/  

`n"



function setURL{
    while (( $null -eq $url) -or ($url -eq '')){
        $url =  read-host "Geef de volledige URL van het filmpje dat je wilt downloaden? (druk C om de operatie af te breken)"
    }
}

setURL

if(! $url.tostring().ToLower() -eq 'c'){


} else {
    Write-Host "Programma wordt afgesloten" -ForegroundColor Red
}
#.\yt-dlp.exe -F $url
#$Version = Read-Host "Geef het nummer aan van de kwaliteit van de versie die je wilt downloaden (vb 137)"
#.\yt-dlp.exe -f $Version $url