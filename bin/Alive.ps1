$PCs = Get-Content $env:USERPROFILE\Desktop\PC-list.txt
$Complete = @{}

Do {

  $PCs | %{

    If (!$Complete.containsValue($_)) {

	  $status = (Test-Connection -ComputerName $_ -Buffersize 16 -count 1 -quiet) 
	  #-and (Get-WmiObject Win32_ComputerSystem $_ -ErrorAction SilentlyContinue)
	  
      
	   If ($status -eq "True"){
             $Complete.Add($_)
      }
    }
  }

  #
  # Build the HTML output
  #

  $Head = "<Center><title>Status Report</title> <meta http-equiv='refresh' content='30' />"
  $Body = @()
  $Body += "<table><tr><th>PC</th><th>State</th></tr>"
  $Body += $PCs | %{
    If ($Complete.containsValue($_)) {
    "<tr><td>$_</td><td><font color='green'>Running</font></td></tr>"
    } Else {
    "<tr><td>$_</td><td><font color='red'>Not Available</font></td></tr>"
    }
  }
  $Body += "</table></Center>"

  $Html = ConvertTo-Html -Body $Body -Head $Head

  #
  # Write HTML to the file
  #

  $Html > "statusPage.html"

  #
  # Sleep a while
  #

  Start-Sleep -Seconds 30

} While ($Complete.Count -lt $PCs.Count)