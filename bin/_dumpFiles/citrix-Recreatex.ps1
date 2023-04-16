#--------------------------------------------------------------------------------
#
# NAME:		citrix-Recreatex.ps1
#
# AUTHOR:	Spuzzelsnest
# EMAIL:	j.mpdesmet@protonmail.com
#
# COMMENT:
#           Auto deploy Citrix
#
#
#       VERSION HISTORY:
#       1.0     10.19.2021 	- Initial release
#--------------------------------------------------------------------------------

Write-host "Citrix Install - Recreatex"

$ErrorActionPreference = "silentlycontinue"

# check if registry key exists > base for install

$check = (Get-ItemProperty "HKCU:\SOFTWARE\Citrix\Receiver\InstallDetect\*" | Where { $_.DisplayName -like "Citrix Workspace*" }) -ne $null -ErrorAction SilentlyContinue

If( $check -ne $true) {
	Write-Host "$software NOT is installed." -ForegroundColor Magenta
    
    choco install citrix-workspace --force -y
 }
