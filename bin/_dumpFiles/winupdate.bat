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
ren C:\Windows\SoftwareDistribution C:\Windows\SoftwareDistribution.old
net start wuauserv
exit /b