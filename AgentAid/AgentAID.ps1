$Title = "Welcome"
$Info = "The renewed Agent Aid"
$version = "*beta*"
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

                                   Hello  %UserName%  
                                   Welcome to AD-Aid (v1.05)
                      Press:
                               (1)   User info
                               (2)   PC info
                               (3)   Antivirus Tools
                               (4)   User Loggedon to PC
                               (5)   Exit
	
"@ -forgroundcolor magenta

 
$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&UserInfo", "&Shell", "&Quit")
[int]$defaultchoice = 2
$opt =  $host.UI.PromptForChoice($Title , $Info , $Options,$defaultchoice)
switch($opt)
{
0 { Write-Host "Power" -ForegroundColor Green}
1 { Write-Host "Shell" -ForegroundColor Green}
2 {Write-Host "Good Bye!!!" -ForegroundColor Green}
}