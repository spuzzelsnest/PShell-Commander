$prog = "DBSLocal"
if(! (ps |? { $_.Name -eq $prog })) {
    write-host "NOT RUNNING"
} else {
    Stop-Process $prog
    Remove-Item -Recurse -Force $env:USERPROFILE\Appdata\local\apps\2.0 
}
