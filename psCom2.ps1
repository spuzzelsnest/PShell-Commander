<#
.SYNOPSIS
    pShell-Commander.ps1
 
.DESCRIPTION
    Set of programs for for remote management on a network.

.NOTES
    VERSION HISTORY:
       1.0     02.17.2017 	- Initial release
       1.1     03.03.2017  - Test Connection as a function
       1.2		04.17.2017  - Changed dump function
       1.3     04.24.2017  - Changed userinfo layout
       1.4     04.28.2017  - Return of the scrollbar
       1.5     05.04.2017  - Loggedon module
       1.6     07.06.2017  - Anti Virus update
       1.7     07.11.2017  - Alive Service
       2.0     02.21.2018  - Reorder structure
                           - Added external popup for remote
                           - Checking Domain or Workgroup
       2.1.0   06-26-2018  - Adding Unix basic support
       2.1.1   10-02-2018  - Restructured Module sequence
                           - More Unix adaptions
                           - More Messaging
       2.1.2   22-03-2019  - Windows 10 out of the box fixes
       2.2.0   24-11-2019  - Download PSTools Automatically
       2.3.0   27-04-2020  - Rework with invoke-command
       2.3.1   26-05-2020  - Rework of the Alive Service
       2.3.2   15-10-2020  - Change dir for Alive to Logs 
                           - Removed auto start for webpage
       2.4.0   05-04-2023  - Merge with old version.
 
.COMPONENT 
    Not running any extra Modules.
 
.LINK
    https://github.com/spuzzelsnest/
 
.Parameter ParameterName
 
#>

    $version = "v 2.4.0"
    $psver = $PSVersionTable.PSVersion.tostring()
    $ping = New-Object System.Net.NetworkInformation.Ping
    $workDir = $pwd
    $dump = "bin\_dumpFiles\"
    $logs = "bin\Logs"
    $report = "network-report.html"
    $modsFolder = "$workDir/bin/Modules"

    $h = get-host
    $c = $h.UI.RawUI
   
# TEXT VARS

    $pcQ= "What is the PC name or the IP-address or press c to Cancel"
    $userQ = "What is the UserID or press c to Cancel"

# Set Env
# WINDOWS VARS

        $hostn = $env:Computername
        $agent = $env:USERNAME
        $dom = $env:USERDNSDOMAIN
        if (!$dom) { 
            $dom = "."
            $warning = "!!NOT in Domain!!"
         }
        $logs = "$workdir/bin/Logs"
        
# Set ScreenSize in Windows
            $c.BackgroundColor = ($bckgrnd = 'black')
            $p = $c.WindowPosition
            $p.x = 0
            $p.y = 0
            $c.WindowPosition = $p

            $s = $c.BufferSize
            $s.Width = 140
            $s.Height = 1000
            $c.BufferSize = $s

            $w = $c.WindowSize
            $w.Width = 140
            $w.Height = 46
            $c.WindowSize = $w

  # Exchange
  # Installed in %ExchangeInstallPath%\bin
            if( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null){
                    Add-PsSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue
            }

# MODULES
# Adding Extras
        $mods = get-ChildItem $modsFolder
        foreach ($mod in $mods){
            if( (Get-Module -Name $mod.name -ErrorAction SilentlyContinue) -eq $null){
                Import-Module -Name $mod -ErrorAction SilentlyContinue
            }
        }

# Global Functions
function exit{
    clear
    $h.ExitNestedPrompt()
}

function CC ($pc){
    if(!($pc -eq "c")){
        if(!($(New-Object System.Net.NetworkInformation.Ping).SendPingAsync($pc).result.status -eq 'Succes')){
            Write-host -NoNewline  "PC " $pc  " is NOT online!!! ... Press any key  " `n
            clear
            return $False
        }else{
           return $True
        }
    }else{x}
}

function x{
    Write-Host "Press any key to go back to the main menu"
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    clear
    cd $workdir
    mainMenu
}

# ALIVE SERVICE

function Alive{

        if(!(test-path $logs\PC-list.txt)){
                
                Write-host No PC list found -ForegroundColor Magenta
            
            }else{


                $Complete = @{}
                $i=0
            
                if (Test-Path $logs\$report){

                    copy-item $logs\$report -destination $logs\$report-$(Get-Date -format "yyyy_MM_dd_hh_mm_ss")
                 }

                 $pcs = Get-Content $logs\PC-list.txt

               
                 
                 $pcs | %{

                        $j = [math]::Round((($i / $pcs.Count) * 100),2)

                        Write-Progress -Activity "Creating report" -Status "$j% Complete:" -PercentComplete $j
                        $status = ( $ping.send($_,500).status )

                        Write-Output $cnName
                        If (!$Complete.Containskey($_)){
                            If ($status -eq  $True){
                                $Complete.Add($_,$status)
                            }
                        }
   
                        $i++
                   }
  
            # Build the HTML output
                    $head = "
                    <title>Status Report</title>
                    <meta http-equiv='refresh' content='30' />"

                    $body = @()
                    $body += "<center><table><tr><th>Pc Name</th><th>State</th></tr>"
                    $body += $pcs | %{
                    if ($Complete.Contains($_)) {
                        "<tr><td>$_</td><td><font color='green'>Running</font></td></tr>"
                        } else {
                        "<tr><td>$_</td><td><font color='red'>Not Available</font></td></tr>"
                        }
                    }
                    $body += "</table></center>"
                    $html = ConvertTo-Html -Body $body -Head $head

                # save HTML
                    $html >  $logs/$report

             
                
                invoke-item "bin/Logs/network-report.html"
            }
}
    

# START PROGRAM

    cd $workDir
    $loadscreen = get-content bin/visuals/loadscreen | Out-String
    $loadedModules = get-module
    write-host $loadscreen -ForegroundColor Magenta

    if ($PSVersionTable.PSVersion.Major -gt 2)
    {
        Write-Host "Yay Powershell is running on version $psver
        "
    }else{
        Write-Host "Boo, you are running an older version of powershell $psver" -foregroundcolor Red
    }
    if ($warning){
        Write-Host "      $warning" -ForegroundColor Red
    }
    
    Write-host "
                  The following Powershell Modules Are loaded
    " -ForegroundColor Yellow 

    $loadedModules | %{
        Write-Host "            - $_"-ForegroundColor Green
    }

    Write-Host "
    ***if you want to add more Modules add them in bin/Modules***" -ForegroundColor Yellow
    
    Write-Host "
           ... Just a second, Alive Script is loading ..." -ForegroundColor Green
    #Alive

    start-sleep 5

# Program
function UserInfo ($Id){

	if (!(Get-ADUser -Filter {SamAccountName -eq $Id} )){
        Write-Host "ID not found " -ForegroundColor Red
        x
	}else{
        $userLog = [ordered]@{}
        'Processing ' + $Id + '...'
#--------------GENERAL USER INFO---------------
        $genInfo = Get-ADUser -Identity $Id -properties * -ErrorAction SilentlyContinue | select SamAccountName, Name, surName, GivenName,  StreetAddress, PostalCode, City, Country, OfficePhone, otherTelephone, Title, Department, Company, Organization, UserPrincipalName, DistinguishedName, ObjectClass, Enabled,scriptpath, homedrive, homedirectory, SID
#--------------GROUPS--------------------------
        $groupInfo = get-ADPrincipalGroupMembership $Id | select -ExpandProperty name |out-string
#--------------MANAGER-------------------------
        $manager = Get-ADUser $Id -Properties manager | Select-Object -Property @{label='Manager';expression={$_.manager -replace '^CN=|,.*$'}} |  Format-Table -HideTableHeaders |Out-String
        $manager = $manager.Trim()
        $manInfo = get-aduser -filter {displayName -like $manager} -properties * | Select displayName, EmailAddress, mobile | Format-Table -HideTableHeaders | out-string
#--------------EMAIL----------------------------
        $migAttr = get-aduser -identity $Id -Properties *  -ErrorAction SilentlyContinue | select-object msExchRecipientTypeDetails
        $mailInfo = Get-Recipient -Identity $Id | Select Name -ExpandProperty EmailAddresses |  select SmtpAddress |Out-String
#--------------BUILD LIST------------------------
        $genInfo.psobject.Properties | foreach{ $userLog[$_.name]=$_.value}
        $userLog.add('Manager Info', $manInfo)
        $userLog.add('Groups', $groupInfo)
        $userLog.add('Email Addresses', $mailInfo)
            #foreach ($item in $userLog.GetEnumerator() | Format-Table -AutoSize){$item}
        $userLog.getenumerator()| Ft -AutoSize -wrap | out-string
        $userLog.GetEnumerator() | Out-GridView -Title "$Id Information"
    }
x
}

function alterName($pc){

    $alterNames = netdom computername $pc /enum
    $alterNames | %{
        write-host $_ "`n" -ForegroundColor Yellow
    }
x
}

function cleanUp ($pc){
    if (CC($pc)){

        Write-progress "Removing Temp Folders from "  "in Progress:"
		new-PSdrive IA Filesystem \\$pc\C$
		remove-item IA:\"$"Recycle.Bin\* -recurse -force -verbose
		Write-host "Cleaned up Recycle.Bin" -ForegroundColor Green
		if (Test-Path IA:\Windows.old){
            Remove-Item IA:\Windows.old\ -Recurse -Force -Verbose
		}else{
		    Write-host "no Windows.old Folder found" -ForegroundColor Green
		}
        remove-item IA:\Windows\Temp\* -recurse -Force -Verbose
        write-host "Cleaned up C:\Windows\Temp" -ForegroundColor Green
      	$UserFolders = get-childItem IA:\Users\ -Directory

        foreach ($folder in $UserFolders){
            $path = "IA:\Users\"+$folder
            remove-item $path\AppData\Local\Temp\* -recurse -force -verbose -ErrorAction SilentlyContinue
            remove-item $path\AppData\Local\Microsoft\Windows\"Temporary Internet Files"\* -recurse -force -verbose -ErrorAction SilentlyContinue
            Write-host "Cleaned up Temp Items for "$folder.Name -foreground Green
        }
        net use /delete \\$pc\C$
    }
x
}

function remotePS($pc){
    if(CC($pc)){
        start-process powershell.exe -ArgumentList "-noexit & Enter-PSSession $pc"
    }
x
}

function loggedon($pc){
    if(CC($pc)){
        Invoke-Command -CN $pc -ScriptBlock { quser }
    }
x
}

function dumpIt ($pc){

$dest = "\\$pc\C$\Temp"
$log = "$root\$pc"
Write-Host "You can choose from the following Files or press C to Cancel:
 *For now only Copy pasting the name or rewrite it in the box works*"
          $files = Get-ChildItem $dump | select Name
          
            for ([int]$i = 1; $i -le $files.length; $i++){
                        Write-Host $i $files[$i-1].name
                   }
            
            $fileName = Read-Host "What File do you want to send"
 
    if (CC($pc)){
 
            if(!(Test-Path $dest\Logs)){

                Write-Host Creating $dest\Logs -ForegroundColor magenta
				New-Item -ItemType Directory -Force -Path $dest\Logs

			}else{

                Write-Host The $dest\Logs directory exsists -ForegroundColor Green
			}


		    Copy-Item $dump\$filename $dest
            Write-Host $filename copied to $dest -ForegroundColor Green
		    
            cd $workDir\$psTools
             
            Invoke-Command -CN $pc -FilePath $workDir/bin/_dumpFiles/$filename
            
            if(!(Test-path $log)){
				Write-Host $log is not available -Foreground magenta
				new-Item $log -type directory -Force
			}else{
		        Write-Host Logs will be written to $log -Foreground green
            }
            robocopy.exe $dest\Logs $log *.* /move
            Remove-Item $dest\$filename -Verbose
            Write-Host Files removed from $pc -Foreground "green"       
    }
x
}

#Menu's
function ADmenu{
    clear
    $Tile = "AD Tools"
    $Menu = "
            (1)  AD-User Info
            
            (2)  AD-Computer Info
            
            (3)  Find Related Server Names
            
            (4)  Who is logged on
            
            (5)  Back
            "
    $ADchoice = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 ADUser","&2 ADServ","&3 alternateName","&4 Loggedon","&5 Back")
    [int]$defchoice = 4
    $subAD =  $h.UI.PromptForChoice($Title, $Menu, $ADchoice,$defchoice)
    switch($subAD){
            0{
            clear
             Write-Host "################################################################"
             Write-Host "                          USERINFO INFO" -ForegroundColor Green
             Write-Host "################################################################
                         "
             $Id =''
             if(!$id){
                $Id =  Read-Host $userQ
                Write-Host $Id
             }
             userInfo $Id
           }1{
           clear
             Write-Host "###############################################################"
             Write-Host "                           PCINFO INFO" -ForegroundColor Green
             Write-Host "###############################################################
                        "
             $pc =''
             if(!$pc){
                $pc = Read-Host $pcQ
             }
             PCInfo $pc
           }2{
           clear
             Write-Host "################################################################"
             Write-Host "                 Find Alternative Server Name" -ForegroundColor Red
             Write-Host "################################################################
                        "
             $pc =''
             if(!$pc){
                $pc = Read-Host $pcQ
             }
             alterName $pc
           }3{
           clear
            Write-Host "################################################################"
            Write-Host "         Find user who is logged on to PC" -ForegroundColor Red
            Write-Host "################################################################
                    "
            $pc =''
            if(!$pc){
                
                $pc = Read-Host $pcQ
            }
            loggedOn $pc
            }4{mainMenu}
    }
}

function NTmenu {
    clear
    $Title = "Network Tools"
    $Menu = "
          (1)   Remote PowerShell

          (2)   Dump File To PC

          (3)   Back
          "
    $NTchoice = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 CMD","&2 Dump","&3 Back")
    [int]$defchoice = 2
    $subNT = $h.UI.PromptForChoice($Title, $Menu, $NTchoice,$defchoice)
    switch($subNT){
        0{
        clear
            Write-Host "################################################################"
            Write-Host "                     Remote PowerShell" -ForegroundColor Red
            Write-Host "################################################################
            "
            $pc =''
            if(!$pc){
                $pc = Read-Host $pcQ
            }
            remotePS $pc                   

        }1{
        clear
            Write-Host "################################################################"
            Write-Host "                     Dump file to PC" -ForegroundColor Red
            Write-Host "################################################################
            "
            $pc =''
            if(!$pc){
                $pc = Read-Host $pcQ
            }
            dumpIt $pc
        }2{mainMenu}
    }
}

function ADVmenu{
        clear
        $Title = "Advanced Tools"
        $Menu = "
              (1)   Cleanup Temp

              (2)   Back
              "
        $AVchoice = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 Cleanup","&2 Back")
        [int]$defchoice = -1
        $subAV =  $h.UI.PromptForChoice($Title , $Menu , $AVchoice, $defchoice)
        switch($subAV){ 

              0{
                clear
                Write-Host "################################################################"
                Write-Host "                     Clearnup Temp Files" -ForegroundColor Red
                Write-Host "################################################################
                "
                $pc =''
                if(!$pc){

                    $pc = Read-Host $pcQ
                }
                cleanUp $pc
                x
            }1{mainMenu}

        }
}

function mainMenu {
    $Title = "pShell Commander $version"
    clear
    $LengthName = $agent.length
    $lengthDom = $dom.Length
    $line = "*****************************************************" + "*"* $LengthName +"*"* $lengthDom 
    $Menu = "
Welcome $agent                                   PowerShell $psver

      Running from $hostn on $dom $warning
$line

       What do you want to do:

                           (1)   AD-Tools
                           
                           (2)   Network Tools
                                                      
                           (3)   Advanced Tools
                           
                           (Q)   Exit
                           "
    $mainMenu = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 ADTools", "&2 NTTools", "&3 ADVTools", "&Quit")
    [int]$defaultchoice = 3
    $choice =  $h.UI.PromptForChoice($Title, $Menu, $mainMenu, $defaultchoice)

         switch ($choice){
               0{
                    clear
                    ADmenu
               }1{
                    clear
                    NTmenu

               }2{
                    clear
                    ADVmenu
               }q{exit}
         }
}

mainMenu