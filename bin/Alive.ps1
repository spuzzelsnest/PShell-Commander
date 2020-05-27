
$Complete = @{}
$dump = $env:USERPROFILE+"\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\pc-report.html"
Do {

  $pcs = Get-Content $env:USERPROFILE\Desktop\PC-list.txt

  $pcs | %{
    $status = (Test-Connection -CN $_ -Count 1 -quiet)

    Write-Output $cnName
    If (!$Complete.Containskey($_)){
       If ($status -eq  $True){
    
       $Complete.Add($_,$status)

      }
    }
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
  $html >  $dump

# Sleep a while
  Start-Sleep -Seconds 30
} While ($Complete.Count -lt $pcs.Count)