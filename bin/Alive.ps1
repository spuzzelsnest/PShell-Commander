#--------------------------------------------------------------------------------
#
# NAME:		Alive.ps1
#
# AUTHOR:	Spuzzelsnest
#
# COMMENT:
#			Network scan - Automating the job
#
#
#       VERSION HISTORY:
#       1.7     07.11.2017  - Alive Service
#       2.3.1   26.05.2020  - Rework of the Alive Service
#       2.3.2   15-10-2020  - Change dir for Alive to Logs 
#                           - Removed auto start for webpage
#       2.4.0   15-10-2020  - Stanalone App - no service anymore
#--------------------------------------------------------------------------------
# START VARS

$pcs = Get-Content bin\Logs\PC-list.txt
$dump = "bin\Logs\"
$file = "network-report.html"
$tot = ($pcs | Measure-Object -Line).lines
$i = 1
 
#make backup 

if (Test-Path $dump\$file){ 

copy-item $dump\$file -destination $dump\$file-$(Get-Date -format "yyyy_MM_dd_hh_mm_ss")
}



  $pcs | %{

     $j = [math]::Round((($i / $tot) * 100),2)

    Write-Progress -Activity "Creating report" -Status "$j% Complete:" -PercentComplete $j
   

    $status = (Test-Connection -CN $_ -Count 1 -quiet)

    Write-Output $cnName
   
    $i++
  }
  
# Build the HTML output
  $head = "
    <title>Status Report</title>
    <meta http-equiv='refresh' content='30' />"

  $body = @()
  $body += "<center><table><tr><th>Pc Name</th><th>State</th></tr>"
  $body += $pcs | %{
    If ($Complete.Contains($_)) {
    "<tr><td>$_</td><td><font color='green'>Running</font></td></tr>"
    } Else {
    "<tr><td>$_</td><td><font color='red'>Not Available</font></td></tr>"
    }
  }
  $body += "</table></center>"
  $html = ConvertTo-Html -Body $body -Head $head

# save HTML
  $html >  $dump/$file
