#  ==========================================================================
#
# NAME:		locSetAVServices.ps1
#
# AUTHOR:	Jan De Smet
# EMAIL:	jan.de-smet@t-systems.com
#
# COMMENT: 
#			Set the AV services Locally.
#				
#           	
#       VERSION HISTORY:
#       1.0     01.12.2015 - Initial release
#
#  ==========================================================================

$servs = get-service -DisplayName 'OfficeScan*'
foreach($serv in $servs){
set-service $serv.Name -StartupType Automatic
Restart-service -DisplayName $serv
}