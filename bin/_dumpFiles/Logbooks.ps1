<#
.SYNOPSIS
    Logbooks.ps1

.DESCRIPTION
    Get Logbooks of a remote pc.

.NOTES
    VERSION HISTORY:
    1.0     24-08-2016  - Initial release 

.COMPONENT 
    Not running any extra Modules.
 
.LINK
    https://github.com/spuzzelsnest/
 
#>

cd C:\temp\Logs

$now = Get-Date
$startDate = $now.adddays(-7)

Get-EventLog -log Application -after $startDate | Export-csv "$(get-date -f yyyy-MM-dd)-APP.csv"
Get-EventLog -log Security -after $startDate | Export-csv "$(get-date -f yyyy-MM-dd)-SEC.csv"
