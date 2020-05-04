 # pShell-Commander                

Built and restructured from an old batch program I once wrote, AD-Aid, a tool for Active Directory information gathering. Writen in PowerShell this time and build on a set of tools like Get-ADUser and Get-ADComputer.
Expanded with network capabilities by using the Invoke-Command.

Runs from PowerShell version 3.0  and will be expanded to Unix Systems.

# Tools Available

- AD User info (domain)
- Remote PC info (domnain/local)
- Track online status of PC's (domain/local)
- Remote Temp file cleaner (domain/local)
- Remote script file execution (domain/local)
- Dump customisable executable files (domain/local)
- Remote CMD (domain/local)
- Remote Registry (domain/local)

# How to run

## Windows

Make sure the execution policy is set in PowerShell, to check use:

```bash
Get-ExecutionPolicy
```

To set the execution policy, run PowerShell as an Administrator and  to open scripts use:

```bash
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
```

## Unix (Linux / OSX)

- install powershell
- run the script like "pwsh psCom.ps1"


# Latest News

05-10-2018
I Have been messing with versioning but got it right this time: this is the last update, v 2.1.1!
I have taken on the chalange of going multi platform and I am partionally testing on Mac OSX. Although some of the network tools are not supported yet. 
I plan to update tools and multi platform support soon!
