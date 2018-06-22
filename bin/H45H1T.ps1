Set-ExecutionPolicy Unrestricted

$floc = read-host "Location of the hives: "
$user = $env:username
$webproxy = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer
$pwd = Read-Host "Password?" -assecurestring

#$PSVersionTable.PSVersion
#[Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\Python27\;C:\Python27\Scripts\", "User")
#$env:path="$env:Path;C:\Python27\;C:\Python27\Scripts"

#read requirements.txt located in deps folder
pip.exe install -U -r deps\requirements.txt

Write-Output "###################################################################"
Write-Output "#                           H45H1n T1m3                           #"
Write-Output "###################################################################"

python.exe .\deps\passIt.py -sam $floc\sam.save -security $floc\security.save -system ..\Examples\system.save -hashes LMHASH:NTHASH -history -k -outputfile dumps/restult local
