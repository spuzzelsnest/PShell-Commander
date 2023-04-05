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
cd /d %windir%\system32\wbem
Winmgmt /salvagerepository
net pause winmgmt /y

for %i in (*.dll) do RegSvr32 -s %i >> C:\temp\Logs\result.log

for %i in (*.exe) do %i /RegServer >> C:\temp\Logs\result.log
 

cd /d %windir%\sysWOW64\wbem
for %i in (*.dll) do RegSvr32 -s %i >> C:\temp\Logs\result.log
for %i in (*.exe) do %i /RegServer >> C:\temp\Logs\result.log

net start winmgmt
for /f %%s in ('dir /s /b *.mof *.mfl') do mofcomp %%s >> C:\temp\Logs\result.log

gpupdate /force >> C:\temp\Logs\result.log

cd C:\windows\ccmsetup\
ccmsetup.exe

exit /b