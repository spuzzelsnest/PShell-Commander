sc config winmgmt start= disabled
net stop winmgmt

Winmgmt /salvagerepository %windir%\System32\wbem

Winmgmt /resetrepository %windir%\System32\wbem



cd /d %windir%\system32\wbem
for %i in (*.dll) do RegSvr32 -s %i
for %i in (*.exe) do %i /RegServer


cd /d %windir%\sysWOW64\wbem
for %i in (*.dll) do RegSvr32 -s %i
for %i in (*.exe) do %i /RegServer