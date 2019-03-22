::lync.bat
::Cleanup lync/skype profile after server change 
::
::
::Created by Spuzzelsnest
::
::Change Log
::-----------
::V1.0 - 30-06-2016 - Initial release
::V1.1 - 10-05-2017 auto user check from local pc
::############################################
@echo off
cd C:\temp

set loggedon="wmic /node:127.0.0.1 computerSystem Get UserName | findstr %userdomain%"

for /f "tokens=*" %%i IN (' %loggedon% ') do set X=%%i
for /f "tokens=* delims=%userdomain%\" %%a in ("%X%") do set user=%%a

echo Closing open instances of Communicator/Lync/Skype and Outlook

tasklist /fi "imagename eq lync*" | find ":" > nul
if errorlevel 1 taskkill /f /im "lync*" 


taskkill /fi "imagename eq communicator.exe" | find ":" > nul
if errorlevel 1 taskkill /f /im "communicator.exe"

taskkill /fi "imagename eq Outlook.exe" | find ":" > nul
if errorlevel 1 taskkill /f /im "Outlook.exe"

echo Removing local directories for %user%

rd /s /q C:\Users\%user%\appdata\local\microsoft\communicator lync.old
rd /s /q C:\Users\%user%\appdata\local\microsoft\office\15.0\lync 

::reg delete HKEY_CURRENT_USER\Software\Microsoft\Communicator /f
::reg delete HKEY_CURRENT_USER\Software\Microsoft\Office\15.0\lync /f

exit /b