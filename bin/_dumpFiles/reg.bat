::reg.bat

::Save reg hive
::

::Created by Spuzzelsnest

::

::Change Log

::-----------

::V1.0 Initial release 24-08-2016

::############################################

@echo off


REG SAVE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"  C:\temp\Logs\IE.hiv

exit