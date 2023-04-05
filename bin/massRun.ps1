$logs = 'Logs'
$dumpFiles = '_dumpFiles'

$parameters = @{
  ComputerName = (Get-Content -Path  $logs\TEST-list.txt)
  InDisconnectedSession = $true
  FilePath = $dumpFiles+"\tryChoco.ps1"
  SessionOption = @{OutputBufferingMode="Drop";IdleTimeout=632000000}
}
Invoke-Command @parameters