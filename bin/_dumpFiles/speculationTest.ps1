$expol =  Get-ExecutionPolicy
$pvs = $PSVersionTable.PSVersion.Major
if ($expol -eq "Bypass"){

    if(!(Test-Path -Path "$env:ProgramData\Chocolatey")){

	    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    }else{

        If ($pvs -gt 4) {
		    
            Write-Host "################################################################"
            Write-Host "    Supports PowerShell Version 5 checking for latest update" -ForegroundColor Green
            Write-Host "################################################################"
            choco upgrade PowerShell
            Write-Host "################################################################"
            Write-Host "               Starting the Speculation Test" -ForegroundColor Green
            Write-Host "################################################################"
            
            if(!(Get-PackageProvider -Name NuGet)){
                Install-packageprovider -name NuGet -MinimumVersion 2.8.5.201 -Force
            }

            if(!(Get-Module -Name SpeculationControl)){
                Install-Module SpeculationControl -Force
            }

            Import-Module SpeculationControl
            Get-SpeculationControlSettings | Out-file $pwd\log.txt 
        }else {
              Write-Host "#################################################################"
              Write-Host " You have version "$pvs " of Powershell,you need to update first!" -ForegroundColor DarkRed
              Write-Host "#################################################################"
   		      choco install PowerShell
	    }
    }

}else{

	Set-ExecutionPolicy Bypass
    Write-Host "#################################################################"
    Write-Host "   Reopen your Powershell and make sure you run it as an admin" -ForegroundColor DarkRed
    Write-Host "#################################################################"
}
