::bitlock.bat
::disable and enable protectors for Bitlocker 
::
::Created by Spuzzelsnest
::
::Change Log
::-----------
::V1.0 Initial release 24-04-2017
::############################################
@echo off

manage-bde -protectors -disable C:
manage-bde -protectors -enable C:

exit