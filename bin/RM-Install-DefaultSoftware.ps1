<#
.SYNOPSIS
    RM-Install-DefaultSoftware.ps1

.DESCRIPTION
    Installing default software through Chocolatey.
    7zip adobereader eid-belgium  googlechrome vlc javaruntime silverlight dotnetfx office365busines

.NOTES
    VERSION HISTORY:
    1.0     03.04.2023  - Initial create

.COMPONENT 
    Not running any extra Modules.
 
.LINK
    https://github.com/spuzzelsnest/
 
.Parameter ParameterName
 
#>

$pc = read-host "what is the name of the PC "

   if(!($(New-Object System.Net.NetworkInformation.Ping).SendPingAsync($pc).result.status -eq 'Succes')){
            Write-host -NoNewline  "PC " $pc  " is NOT online!!! ... Press any key  " `n
            clear
            
    }else{x}
    
Write-Host -NoNewline "PC " $pc " is online, Lets Install" `n 
write-host -NoNewline "Install CHOCO!" -ForegroundColor Green


Invoke-Command -cn $pc -ScriptBlock { Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))}

Invoke-Command -cn $pc -ScriptBlock {choco install 7zip adobereader eid-belgium  googlechrome vlc javaruntime silverlight dotnetfx office365business -y}

function x{
    write-host "Press any key to go back to the main menu"
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    clear

}
