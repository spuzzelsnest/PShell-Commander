<<<<<<< HEAD
::getLogbooks.bat
::Create Archive of Event Viewer
::    - Security, Application, Junos Pulse
::
::Created by Spuzzelsnest
::
::Change Log
::-----------
::V1.0 Initial release 24-08-2016
::############################################
@echo off

cd C:\temp\
set PC=%COMPUTERNAME%

for /f "tokens=2-8 delims=.:/ " %%a in ("%date% %time%") do set stamp=%%c-%%a-%%b_%%d-%%e

wevtutil.exe epl Security Logs\%stamp%-%PC%_Sec.evtx
wevtutil.exe epl Application Logs\%stamp%-%PC%_App%.evtx

=======
::getLogbooks.bat
::Create Archive of Event Viewer
::    - Security, Application, Junos Pulse
::
::Created by Spuzzelsnest
::
::Change Log
::-----------
::V1.0 Initial release 24-08-2016
::############################################
@echo off

cd C:\temp\
set PC=%COMPUTERNAME%

for /f "tokens=2-8 delims=.:/ " %%a in ("%date% %time%") do set stamp=%%c-%%a-%%b_%%d-%%e

wevtutil.exe epl Security Logs\%stamp%-%PC%_Sec.evtx
wevtutil.exe epl Application Logs\%stamp%-%PC%_App%.evtx

>>>>>>> b69d0509a6d6dfdd1e1b9b7b4e878e2ab2773dc0
Exit /b