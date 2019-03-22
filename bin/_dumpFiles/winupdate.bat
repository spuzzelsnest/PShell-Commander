::winupdate.bat
::clean up windows update 
::
::
::Created by Spuzzelsnest
::
::Change Log
::-----------
::V1.0 - 10-05-2017 - Initial release
::############################################
@echo off
net stop wuauserv
move C:\Windows\SoftwareDistribution C:\Windows\SoftwareDistribution.old
net start wuauserv

control /name Microsoft.WindowsUpdate

exit /b