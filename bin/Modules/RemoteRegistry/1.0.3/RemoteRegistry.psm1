function Test-ElevatedShell
{
	$user = [Security.Principal.WindowsIdentity]::GetCurrent()
	(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}


if(!(Test-ElevatedShell))
{

$warning=@"
	To run commands exposed by this module on Windows Vista, Windows Server 2008, and later versions of Windows,
	you must start an elevated Windows PowerShell console. You must have Administrator privligies on the remote
	computers and the remote registry service has to be running.
"@

	Write-Warning $warning	
	Exit
}

#Get public and private function definition files.
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
    $Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

# Here I might...
    # Read in or create an initial config file and variable
    # Export Public functions ($Public.BaseName) for WIP modules
    # Set variables visible to the module and its functions only

Export-ModuleMember -Function $Public.Basename