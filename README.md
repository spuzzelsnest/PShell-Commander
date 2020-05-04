 # pShell-Commander                

Built and restructured from an old batch program I once wrote, AD-Aid, a tool for Active Directory information gathering. Writen in PowerShell this time and build on a set of tools like Get-ADUser and Get-ADComputer.
Expanded with network capabilities by using the Invoke-Command.

Runs from PowerShell version 3.0  and will be expanded to Unix Systems.

# Tools Available

- AD User info
- Remote PC info
- Track online status of PC's
- Remote Temp file cleaner
- Remote script file execution
- Dump customisable executable files
- Remote CMD
- Remote Registry

# How to run

## Windows

Make sure the execution policy is set in PowerShell, to check use:

```bash
Get-ExecutionPolicy
```

To set the execution policy, run PowerShell as an Administrator and run this code:

```bash
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
```

After downloading the project, you can run the script from powershell.

```bash
.\psCom.ps1
```
