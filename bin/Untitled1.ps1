set pass=G9gqtc^MPw3Y9t6WbjLE6pfrGae%%RP&G8BT*9AAFCJuja6GefbT@VFx4Q=m2cYj

"C:\WinSCP\WinSCP.com" ^
  /log="C:\WinSCP\log\WinSCP.log" /ini=nul ^
  /command ^
    "open ftpes://SINTLIEVENSSTAD:Sedi,IS4f@secureEDI.belfius.be:7806/ -clientcert=C:\Certificaat\belfiuscertificaat.pfx -passphrase=" pass% "" ^
    "cd /MS/Personal/INBOX" ^
    "lcd ""\\vmgeap02\nhtmp\Belfius coda\import\""" ^
    "get -delete *" ^
    "exit"

set WINSCP_RESULT=%ERRORLEVEL%
if %WINSCP_RESULT% equ 0 (
  echo Success
  copy "\\vmgeap02\nhtmp\Belfius coda\import\*.*" "\\vmgeap02\nhtmp\Belfius coda\cultuur\"
  
) else (
  echo Error
)

xcopy "\\vmgeap02\nhtmp\Belfius coda\import\*.pdf" "\\vmgeap02\nhtmp\Belfius uittreksels\"

exit /b %WINSCP_RESULT%





try
{
    # Load WinSCP .NET assembly
    Add-Type -Path "WinSCPnet.dll"
 
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = "secureEDI.belfius.be:7806"
        UserName = "IS4f"
        Password = "G9gqtc^MPw3Y9t6WbjLE6pfrGae%%RP&G8BT*9AAFCJuja6GefbT@VFx4Q=m2cYj"
        SshHostKeyFingerprint = "ssh-rsa 2048 xxxxxxxxxxx...="
    }
 
    $session = New-Object WinSCP.Session
 
    try
    {
        # Connect
        $session.Open($sessionOptions)
 
        # Download files
        $transferOptions = New-Object WinSCP.TransferOptions
        $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
 
        $transferResult =
            $session.GetFiles("/MS/Personal/INBOX", "d:\download\", $False, $transferOptions)
 
        # Throw on any error
        $transferResult.Check()
 
        # Print results
        foreach ($transfer in $transferResult.Transfers)
        {
            Write-Host "Download of $($transfer.FileName) succeeded"
        }
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
 
    exit 0
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}