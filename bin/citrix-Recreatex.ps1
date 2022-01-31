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
# Set execution Policy
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
set-executionpolicy -executionpolicy bypass


#test if script is running
$wshell = New-Object -ComObject Wscript.Shell
$clk = $wshell.Popup("Recreatex install ",0,"Installing Recreatex",0x1)

# check if registry key exists > base for install

$check = (Get-ItemProperty "HKCU:\SOFTWARE\Citrix\Receiver\InstallDetect\*" | Where { $_.DisplayName -like "Citrix Workspace*" }) -ne $null

If( $check -ne $true) {
	Write-Host "$software NOT is installed." -ForegroundColor Magenta
    
    choco install citrix-workspace -y
 }
