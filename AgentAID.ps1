#==========================================================================
#
# NAME:		AgentAID.ps1
#
# AUTHOR:	Spuzzelsnest
# EMAIL:	jan.mpdesmet@gmail.com
#
# COMMENT: 
#			Agent Aid to automate the job 
#
#           	
#       VERSION HISTORY:
#       1.0     02.17.2017 	- Initial release
#							
#==========================================================================
#MODULES
#if ( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null )
#      {
#        Add-PsSnapin Microsoft.Exchange.Management.PowerShell.E2010
#      }
#
#if (!(Get-PSSnapin Quest.ActiveRoles.ADManagement -registered -ErrorAction SilentlyContinue)) { Plugin needed }
#Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue
#
#


#Main

$h = get-host
$c = $h.UI.RawUI
$c.BackgroundColor = ($bckgrnd = 'black')
$c.BufferSize = new-object System.Management.Automation.Host.Size(175,20000)
$c.WindowSize = new-object System.Management.Automation.Host.Size(175,60)

#mode con:cols=140 lines=100


#set-location $env:userprofile\Desktop

$instDir = $env:userprofile +"\Documents\dev\AgentAid"
$version = "v 0.1 - beta"
$agent = $env:UserName
$intro = get-content $instDir\bin\skins\intro1 | out-string
$menu =  @"


                      Press:
                               (1)   User info
                               (2)   PC info
                               (3)   Antivirus Tools
                               (4)   Admin Tools
                               (Q)   Exit


"@  

clear
#STart MEnu Build

write-host $intro -ForegroundColor Magenta
write-host "                 Welcome " $agent " to Agent AID         version  " $version -foregroundcolor white
write-host "                                                      powered by Powershell " $ 
write-host $menu -ForegroundColor Green



$mainMenu = [System.Management.Automation.Host.ChoiceDescription[]] @("&1_UserInfo", "&2_PCInfo", "&3_ACTools", "&4_ATools", "&Quit")
[int]$defaultchoice = 0
$opt =  $host.UI.PromptForChoice($Title , $Info , $mainMenu, $defaultchoice)
switch($opt)
{
0 { clear
                write-host "#####################################################################################"
                write-host "                                       USERINFO INFO" -ForegroundColor Green
                write-host "#####################################################################################"
                wirte-host " "
                $Id =  read-host "What is the userID: "
                
                $private:Id = $Id
                'Processing ' + $private:Id + '...'
                $userLog = @{}
                $userLog.'UserID' = $private:Id
                
                Write-Host User info -ForegroundColor Green

                Get-ADUser -Identity $Id -ErrorAction SilentlyContinue -properties * | select SamAccountName, Name, surName, GivenName,  StreetAddress, PostalCode, City, Country, OfficePhone, otherTelephone, Title, Department, Company, Organization, UserPrincipalName, DistinguishedName, ObjectClass, Enabled,scriptpath, homedrive, homedirectory, SID
                Write-Host Groups -ForegroundColor Green
                get-ADPrincipalGroupMembership $Id | select name |Format-Table -HideTableHeaders

                #----------------------------------------------

                Write-Host Manager -ForegroundColor Green 
                $manager = Get-ADUser $Id -Properties manager | Select-Object -Property @{label='Manager';expression={$_.manager -replace '^CN=|,.*$'}} | Format-Table -HideTableHeaders |Out-String
                $manager = $manager.Trim()

                get-aduser -filter {displayName -like $manager} -properties * | Select displayName, EmailAddress, mobile | Format-List


                #----------------------------------------------

                Write-Host Email info -ForegroundColor Green

                $migAttr = get-aduser -identity $Id -Properties *  -ErrorAction SilentlyContinue | select-object msExchRecipientTypeDetails
                Write-Output "Migrations status: " $migAttr
                Get-Recipient -Identity $Id | Select Name -ExpandProperty EmailAddresses |  Format-Table Name,  SmtpAddress 
                Write-Host "Press any key to continue ..."
         
                #END 
                #Might add choice to write to file...
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    
  }
1 { clear
        Write-Host "PC INFO" -ForegroundColor Green
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
   }
2 { clear
        set-location $instDir
        Write-Host "Good Bye!!!" -ForegroundColor Green}
3 { clear

        Write-Host "Good Bye!!!" -ForegroundColor Green}
4 {
    Write-Host "Good Bye!!!" -ForegroundColor Green
    clear  
    
  }



}