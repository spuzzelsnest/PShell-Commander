#  ==========================================================================
#
# NAME:		locCleanup.ps1
#
# AUTHOR:	Jan De Smet
# EMAIL:	jan.de-smet@t-systems.com
#
# COMMENT: 
#			Clean the pc locally.
#				
#           	
#       VERSION HISTORY:
#       1.0     01.09.2016 - Initial release
#
#  ==========================================================================

$users = Get-ChildItem C:\Users\ -Directory
remove-item C:\"$"Recycle.Bin\* -recurse -force -verbose
if (Test-Path C:\Windows.old) {	
		Remove-Item C:\windows.old\* -Recurse -Force -Verbose
	}else{
		Write-Host "No Old windows Folder"
}
remove-item C:\Temp\* -recurse -force -verbose
remove-item C:\Windows\Temp\* -recurse -force -verbose

Write-Host "Checking Users folder"

Foreach ($user in $users){ 
remove-Item C:\Users\$user\AppData\Local\Temp\* -recurse -force -verbose -ErrorAction SilentlyContinue
remove-Item C:\Users\$user\AppData\Local\Microsoft\Windows\"Temporary Internet Files"\* -recurse -force -verbose -ErrorAction SilentlyContinue
}