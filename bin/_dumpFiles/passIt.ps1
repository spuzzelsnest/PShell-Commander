<#
.SYNOPSIS
    passIt.ps1

.DESCRIPTION
    Get Registry hive.

.NOTES
    VERSION HISTORY:
    1.0     18-08-2016  - Initial release 

.COMPONENT 
    Not running any extra Modules.
 
.LINK
    https://github.com/spuzzelsnest/
 
#>

invoke-command -ScriptBlock{ reg.exe save HKLM\SAM c:\temp\Logs\sam.hiv }
invoke-command -ScriptBlock{ reg.exe save HKLM\SECURITY c:\temp\Logs\security.hiv }
invoke-command -ScriptBlock{ reg.exe save HKLM\SYSTEM c:\temp\Logs\system.hiv }
