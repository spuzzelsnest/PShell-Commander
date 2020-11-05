$logs = 'C:\PShell-Commander\bin\Logs'
$dumpFiles = 'C:\PShell-Commander\bin\_dumpFiles'

$parameters = @{
  ComputerName = (Get-Content -Path  $logs\TEST-list.txt)
  InDisconnectedSession = $true
  FilePath = $dumpFiles+"\tryChoco.ps1"
  SessionOption = @{OutputBufferingMode="Drop";IdleTimeout=632000000}
}
Invoke-Command @parameters