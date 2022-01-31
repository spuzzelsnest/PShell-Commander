 $OnlineMachines = @()
 $OffLineMachines = @()
 $Machines = get-content C:\PShell-Commander\bin\Logs\Server-list.txt
 $Report = @()
 [array]$OnlineMachines = Test-Connection -ComputerName $machines -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Select-Object -Expand Address |
                         Sort-Object -Unique
 $Machines |
     ForEach-Object{
         if ($OnlineMachines -notcontains $_){
             $OffLineMachines += $_
         }
     }

 $Report |
     Export-CSV "C:\PShell-Commander\bin\Logs\Space.CSV"