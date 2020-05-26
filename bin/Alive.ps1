$Complete = @{}

Do {
  $pcs = Get-Content $env:USERPROFILE\Desktop\PC-list.txt

  $pcs | %{
    $status = (Test-Connection -CN $_ -BufferSize 16 -Count 1 -ea 0 -quiet)
    If (!$Complete.Containskey($_)){
       If ($status -eq  $True){
       $Complete.Add($_,$status)
      }
    }
  }

# Build the HTML output
  $Head = "
    <title>Status Report</title>
    <meta http-equiv='refresh' content='30' />"

  $Body = @()
  $Body += "<center><table><tr><th>Pc Name</th><th>State</th></tr>"
  $Body += $pcs | %{
    If ($Complete.Contains($_)) {
    "<tr><td>$_</td><td><font color='green'>Running</font></td></tr>"
    } Else {
    "<tr><td>$_</td><td><font color='red'>Not Available</font></td></tr>"
    }
  }
  $Body += "</table></center>"
  $Html = ConvertTo-Html -Body $Body -Head $Head

# save HTML
  $Html >   "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\pc-report.html"

# Sleep a while
  Start-Sleep -Seconds 30
} While ($Complete.Count -lt $pcs.Count)