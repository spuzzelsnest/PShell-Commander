::sccmRebuild.bat

::Rebuild sccm 

::

::Created by Spuzzelsnest

::

::Change Log

::-----------

::V1.0 Initial release 30-08-2016

::############################################
<<<<<<< HEAD

@echo off

set %Wdir%="C:\windows\System32\wbem"

sc config winmgmt start= disabled
net pause Winmgmt



Winmgmt /salvagerepository %wdir%


winmgmt /resetrepository %wdir%

for %i in (*.dll) do RegSvr32 -s %i

for %i in (*.exe) do %i /RegServer



cd /d %windir%\sysWOW64\wbem

for %i in (*.dll) do RegSvr32 -s %i

for %i in (*.exe) do %i /RegServer

net continue winmgmt


cd C:\windows\ccmsetup\

ccmsetup.exe

=======
@echo off

set %Wdir%="C:\windows\System32\wbem"
sc config winmgmt start= disabled
net pause Winmgmt
Winmgmt /salvagerepository %wdir%
winmgmt /resetrepository %wdir%
for %i in (*.dll) do RegSvr32 -s %i
for %i in (*.exe) do %i /RegServer
cd /d %windir%\sysWOW64\wbem
for %i in (*.dll) do RegSvr32 -s %i
for %i in (*.exe) do %i /RegServer
net continue winmgmt
cd C:\windows\ccmsetup\
ccmsetup.exe
>>>>>>> d47701f667da8db35a1accad2bd4b0588836a71a
