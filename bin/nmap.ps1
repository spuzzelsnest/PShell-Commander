#--------------------------------------------------------------------------------
#
# NAME:		nmap.ps1
#
# AUTHOR:	Spuzzelsnest
#
# COMMENT:
#			Network scan - Automating the job
#
#
#       VERSION HISTORY:
#       0.0.1   15-10-2020  - My powershell NMAP
#--------------------------------------------------------------------------------
# START VARS

param([string] [string]$iface = 'Ethernet',
                       $T)

$ErrorActionPreference = "SilentlyContinue"

if(!(Get-NetAdapter -Name $iface).Status -eq 'Up'){
    Write-Host  $iface ' is down!'

}else{

$hostIp = (Get-NetAdapter -Name $iface | Get-NetIPAddress).IPv4Address

Write-Host "Host IP: " $hostIp


if (!(Test-Connection -CN $T -count 1 -quiet)){

        Write-Host "Target is down" -ForegroundColor Red
    
    } else {

        Write-Host "Target is up"
        write-Host "Trying to get hostname" -ForegroundColor Yellow
        $hostName = (nslookup $T | Select-String 'Name').tostring().Trimstart('Name: ') 
        
        if( $hostName -eq $null ) {
            write-host 'hostname not found' -ForegroundColor red
        }else{
            write-host 'hostname ' $hostName -ForegroundColor Green
       }
    }

}
#1..255 | % { Test-NetConnection -ComputerName x.x.x.$_ } | FT -AutoSize

#Test-NetConnection -ComputerName www.thomasmaurer.ch -Port 80  
