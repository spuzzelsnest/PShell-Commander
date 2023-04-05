<#
.SYNOPSIS
    sendScriptblock.ps1
 
.DESCRIPTION
    Send a scriptblock to multiple PC's from a hostname file located in the directory Logs/hostnames.txt
 
.NOTES
       VERSION HISTORY:
       1.0     11.05.2020 	- Initial release
 
.COMPONENT 
    Exchange Modules
    Azure Modules
 
.LINK
    https://github.com/spuzzelsnest/
 
.Parameter ParameterName
 
#>

$hostnameFile = "Logs/hostnames.txt"
$scriptBlock = Read-Host "What command do you want to send`n  (example: net localgroup Administrators ): "

Write-Host "Checking if file exists `n"

if ( Test-Path $hostnameFile ){
    $hosts = Get-Content $hostnameFile
    foreach ($host in $hosts) {
        Write-Output "Computer: $host"
        Invoke-Command -ComputerName $host -ScriptBlock { $scriptBlock }
    }
} else {
    Write-Host "no file found at "
}
