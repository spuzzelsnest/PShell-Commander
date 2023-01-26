#--------------------------------------------------------------------------------
#
# NAME:		localAdmin.ps1
#
# AUTHOR:	Spuzzelsnest
# EMAIL:	j.mpdesmet@protonmail.com
#
# COMMENT:
#           get Assets active on the network
#
#
#       VERSION HISTORY:
#       1.0     11.05.2020 	- Initial release
#--------------------------------------------------------------------------------


$computers = Get-Content "Logs/PC-list_prod.txt"
foreach ($computer in $computers) {
    Write-Output "Computer: $computer"
    Invoke-Command -ComputerName $computer -ScriptBlock {net localgroup Administrators}
}

