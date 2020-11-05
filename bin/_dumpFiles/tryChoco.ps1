try{

    $command = 'choco -v'
    Write-host "Attempting to run: [ $command ]"`n
    Invoke-Expression -Command $command 

}

Catch {

    if($Error[0].Exception.Message.Contains("The term 'choco' is not recognized as the name of a cmdlet")){
    
        Write-host "choco not installed" -foreground magenta  `n
        Write-host "Lets install" -foreground Green

        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    
    }else {
    
        Write-Host "Choco has version " $_.Exception.Message -foreground green `n
    }
}