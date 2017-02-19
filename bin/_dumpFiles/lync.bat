::lync.bat
::Cleanup lync/skype profile after server change 
::
::
::Created by Spuzzelsnest
::
::Change Log
::-----------
::V1.0 Initial release 30-06-2016
::############################################
@echo off
gpupdate /force
taskkill /f /im lync*
taskkill /f /im communicator.exe
taskkill /f /im Outlook.exe
rd /s /q %userprofile%\appdata\local\microsoft\communicator lync.old
rd /s /q %userprofile%\appdata\local\microsoft\office\15.0\lync 
Reg delete HKEY_CURRENT_USER\Software\Microsoft\Communicator /f
reg delete HKEY_CURRENT_USER\Software\Microsoft\Office\15.0\lync /f
