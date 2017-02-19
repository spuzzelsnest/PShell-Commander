#  ==========================================================================
#
# NAME:		noFlag.ps1
#
# AUTHOR:	Jan De Smet
# EMAIL:	jan.de-smet@t-systems.com
#
# COMMENT: 
#			Set the AV services Locally.
#				
#           	
#       VERSION HISTORY:
#       1.0     07.09.2016 - Initial release
#
#  ==========================================================================

$Path = HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer
$name = "HideSCAHealth"
$val = 1

if (!(test-Path $Path)){
 Write-Host "Path not available"

}else{

    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
}