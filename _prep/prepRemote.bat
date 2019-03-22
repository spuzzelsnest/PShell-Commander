<<<<<<< HEAD
@echo off

net user administrador /active:yes W33dm4ps*

for /f "usebackq skip=1 tokens=*" %%i in (`wmic computersystem get workgroup ^| findstr /r /v "^$" ^| findstr /r /v "^$"`) do @set wGrp=%%i

if NOT %wGrp% == "WM-BCN-OFFICE" (
WMIC ComputerSystem Where Name="%COMPUTERNAME%" Call JoinDomainOrWorkgroup Name="WM-BCN-OFFICE"
)


set key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
set key2="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
set val=LocalAccountTokenFilterPolicy 
set val2=Administrator
set val3=Administrador

reg query %key% /v %val% |find "1"
If %errorlevel% EQU 0 (
	echo %val% exists 
) else (
	echo %val% does not exists - create it
	reg add %key% /f /v %val% /t REG_DWORD /d 1
)


reg query %key2% /v %val2% |find "0"
if %errorlevel% EQU 0 (
	echo %val2% exists
) else (
	echo %val2% does not exists - create it
	reg add %key2% /f /v %val2% /t REG_DWORD /d 0
)

reg query %key2% /v %val3% |find "0"
if %errorlevel% EQU 0 (
	echo %val3% exists
) else (
	echo %Val3% does not exists - create it
	reg add %key2% /f /v %val3% /t REG_DWORD /d 0	
)

=======
@echo off

net user administrador /active:yes W33dm4ps*

for /f "usebackq skip=1 tokens=*" %%i in (`wmic computersystem get workgroup ^| findstr /r /v "^$" ^| findstr /r /v "^$"`) do @set wGrp=%%i

if NOT %wGrp% == "WM-BCN-OFFICE" (
WMIC ComputerSystem Where Name="%COMPUTERNAME%" Call JoinDomainOrWorkgroup Name="WM-BCN-OFFICE"
)


set key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
set key2="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
set val=LocalAccountTokenFilterPolicy 
set val2=Administrator
set val3=Administrador

reg query %key% /v %val% |find "1"
If %errorlevel% EQU 0 (
	echo %val% exists 
) else (
	echo %val% does not exists - create it
	reg add %key% /f /v %val% /t REG_DWORD /d 1
)


reg query %key2% /v %val2% |find "0"
if %errorlevel% EQU 0 (
	echo %val2% exists
) else (
	echo %val2% does not exists - create it
	reg add %key2% /f /v %val2% /t REG_DWORD /d 0
)

reg query %key2% /v %val3% |find "0"
if %errorlevel% EQU 0 (
	echo %val3% exists
) else (
	echo %Val3% does not exists - create it
	reg add %key2% /f /v %val3% /t REG_DWORD /d 0	
)

>>>>>>> b69d0509a6d6dfdd1e1b9b7b4e878e2ab2773dc0
shutdown -r -t 10