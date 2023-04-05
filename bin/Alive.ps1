<#
.SYNOPSIS
    Alive.ps1
 
.DESCRIPTION
    Service used for checking if a PC is online or not, generating a html page that lists the in red and green if PC's or Servers are online.
 
.NOTES
    VERSION HISTORY:
    1.7     07.11.2017  - Alive Service
    2.3.1   26.05.2020  - Rework of the Alive Service
    2.3.2   15-10-2020  - Change dir for Alive to Logs 
                        - Removed auto start for webpage
    2.4.0   15-10-2020  - Stanalone App - no service anymore
    2.4.1   04-05-2023  - Added Test-Path for hostnameFile.
 
.COMPONENT 
    Not running any extra Modules.
 
.LINK
    https://github.com/spuzzelsnest/
 
.Parameter ParameterName
 
#>
# START VARS

$hostnameFile = "Logs\Server-list.txt"
$dump = "Logs\"
$file = "network-report.html"

$i = 1
 
#Test path

if ( Test-Path $hostnameFile ){
  $pcs = Get-Content $hostnameFile
  $tot = ($pcs | Measure-Object -Line).lines
} else {
  $pcs = "localhost"
}

#make backup

if (Test-Path $dump\$file){ 

copy-item $dump\$file -destination $dump\$file-$(Get-Date -format "yyyy_MM_dd_hh_mm_ss")
}

# Iterate Servers

$Complete = @{}

Do {
  $pcs | %{
        $status = (Test-Connection -ComputerName $_ -Buffersize 16 -count 1 -quiet)
        $Complete.Add($_,$status)
      }
      
} While ($Complete.Count -lt $pcs.Count)

# Build the HTML output

  $Head = "
    <title>Status Report</title>
    <meta http-equiv='refresh' content='30' />"

  $Body = @()
  $Body += "<center><table><tr><th>ServerName</th><th>State</th></tr>"
  $Body += $pcs | %{
    If ($Complete.$_ -eq "True") {
    "<tr><td>$_</td><td><font color='green'>Running</font></td></tr>"
    } Else {
    "<tr><td>$_</td><td><font color='red'>Not Available</font></td></tr>"
    }
  }
  $Body += "</table></center>"
  $Html = ConvertTo-Html -Body $Body -Head $Head

# save HTML
  $Html > $dump/$file