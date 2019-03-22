#printer issues

#Import Module

Import-Module BitsTransfer

$pc = read-host "what is the pc name"

$locRun = "D:\_Tools\poer"

#Creating Network drive and copy files to Temp

new-PSdrive IA Filesystem \\$pc\C$

if (!(Test-Path IA:\temp\VPSX)){
    
    write-host Path not found, Creating VPSX folder
    mkdir IA:\temp\VPSX

}else{

    write-Host files will be copied to the VPSX directory

}

cd IA:\temp\VPSX

Start-BitsTransfer -source "\\de35s024fsv02\VPSX$\PDM_new\*"

cd $locRun

.\pstools\PsExec.exe -s  \\$pc cmd /s /k  "cd C:\temp\VPSX && msiexe /i DRVINST64.exe && exit" -accepteula
.\pstools\PsService.exe \\$pc stop spooler -accepteula
.\pstools\PsService.exe \\$pc stop "VPSX printer driver Manager service" -accepteula
Move-Item IA:\windows\system32\spool\PRINTERS IA:\windows\system32\spool\PRINTERS.old
.\pstools\PsService.exe \\$pc start spooler -accepteula



net use /delete \\$pc\C$