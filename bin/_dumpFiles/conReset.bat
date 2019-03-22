::conReset.bat
::Reset Network Connections 
::
::Created by Spuzzelsnest
::
::Change Log
::-----------
::V1.0 Initial release 24-08-2016
::############################################

@echo off

cd C:\temp\Logs\

ipconfig /release > result.log

ipconfig /renew >> result.log

route print >> result.log

ipconfig /displaydns >> result.log

ipconfig /flushdns >> result.log

ipconfig /registerdns >> result.log

netsh winsock reset catalog

netsh int ipv4 reset resetlog.log

netsh int reset all

Exit