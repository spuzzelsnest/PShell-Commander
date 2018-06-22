::noFlag.bat
::Remove the Action Center Flag
::
::Created by Spuzzelsnest
::
::Change Log
::-----------
::v1.0     07.09.2016 - Initial release
::############################################
@echo off

echo "Remove the fucking flag"

REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer /f /v HideSCAHealth /t REG_SZ /d 1

echo "Make Sure the user reboots after this!"


exit /b