$parameters = @{
  ComputerName = (Get-Content -Path  c:\TEST-list.txt)
  InDisconnectedSession = $true
  FilePath = "C:\PShell-Commander\tryChoco.ps1"
  SessionOption = @{OutputBufferingMode="Drop";IdleTimeout=632000000}
}
Invoke-Command @parameters