#Starting Alive Service
# 
write-host "                 Alive service starting ..." -foreground Green
Write-host "         checking for existance of a Pc-list File" -Foreground Yellow
if((test-path $env:USERPROFILE\Desktop\PC-list.txt) -eq  $False){
    new-item $env:USERPROFILE\Desktop\PC-list.txt -type file
    Write-host creating new PC-list file -foreground Magenta
}else{
    write-host PC-list file exists -Foreground Green
}

if(!( get-service AgentAid-Alive -ErrorAction SilentlyContinue) -eq $True){
    new-service -name AgentAid-Alive -BinaryPathName "powershell.exe -NoLogo -Path $workDir\bin\Alive.ps1" -DisplayName "Pc alive Service for Agent AID" -StartupType Manual
}else {
    restart-service AgentAid-Alive -ErrorAction SilentlyContinue
}
invoke-item "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\pc-report.html"
