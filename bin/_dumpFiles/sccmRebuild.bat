::sccmRebuild.bat
::Rebuild sccm 
::
::Created by Spuzzelsnest
::
::Change Log
::-----------
::V1.0 Initial release 30-08-2016
::############################################
@echo off
set %Wdir%="C:\windows\System32\wbem"
net pause Winmgmt
move %wdir%\Repository %wdir%\repository.old
net continue winmgmt
C:\windows\ccmsetup\ccmsetup.exe

