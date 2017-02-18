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
if ( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null )
      {
        Add-PsSnapin Microsoft.Exchange.Management.PowerShell.E2010
      }

$version = "v 0.1 - beta"
$agent = $env:UserName
$binPath = "bin/"
write-host @"
                                        sssss:Sss:Sss
                                     ss:===:Ssss:Ssss:Sss:s
                      ____________ sss:==:Ss# X Ss:Sss:Ssss:Sss
                      ````\\\\\\\\\~~~ss===s X+X S:Sss:Ss:Sssss:Ss
                               vvvv ==== ss   X S:Sss:Ss :Ss:Ssss:Sss
                              vv  v ====  s  /   ss:Sss Sss:Ss:Ssss:Sss:s
                               vvv          X     ss:S s:S s:Sss:Sssss:Sss
                                u     __   X+X   s:S s:Ss :Sss Ss:Ss s:Sssss
                                uu   /@@    X       s:Ss Ssss ss:Ss sss:Ssss:s
                                 uu         X         s :Sss s:Sss ss:Sssssss:s
                                   u       X+X      )  Ssss sssss Ssssss :Ssssss:
                                   u        X      ) \  S: sss:S ssss:S sss:S :sss
                                   u       /      /   `\  Ssss:  Sss:s  ssSs:  sssss
                                   uu     X      u      \  Ss     Sss    Sss     Ssss_
                                   u @@) (_)   u'        \ s      ss      s        S  \_
                                   \u    u u  u           \        s
                                    \uuu/  uu/             \
                                                            .
                                                            .
                                                            /
                                                           /
                                            __________    .
                                           /          \. /
                                          /   __       \.
                                         /___/
"@ -ForegroundColor Magenta
 
write-host "                 Welcome "$agent " to Agent AID         version  " $version  -foregroundcolor black
Write-host @"


                      Press:
                               (1)   User info
                               (2)   PC info
                               (3)   Antivirus Tools
                               (4)   Admin Tools
                               (Q)   Exit


"@ -ForegroundColor Green 
 
$mainMenu = [System.Management.Automation.Host.ChoiceDescription[]] @("&1_UserInfo", "&2_PCInfo", "&3_ACTools", "&4_ATools", "&Quit")
[int]$defaultchoice = 0
$opt =  $host.UI.PromptForChoice($Title , $Info , $mainMenu, $defaultchoice)
switch($opt)
{
0 { clear

               

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
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    
  }
1 { Write-Host "Shell" -ForegroundColor Green}
2 {Write-Host "Good Bye!!!" -ForegroundColor Green}
3 {Write-Host "Good Bye!!!" -ForegroundColor Green}
4 {
    Write-Host "Good Bye!!!" -ForegroundColor Green
    clear  
    
  }



}