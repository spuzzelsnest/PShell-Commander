<<<<<<< HEAD
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


=======
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


>>>>>>> b69d0509a6d6dfdd1e1b9b7b4e878e2ab2773dc0
exit /b