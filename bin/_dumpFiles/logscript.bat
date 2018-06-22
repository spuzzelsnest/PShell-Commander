@echo off
REM BATCH file to trigger the Kone logonscript

IF EXIST "%windir%\kixtart\kix32.exe" goto localkix1

IF EXIST "c:\version\kix32.exe" goto localkix2

IF NOT EXIST "c:\version\kix32.exe" goto downloadkix

exit

:downloadkix
copy "%logonserver%\netlogon\bin\kix32.exe" "c:\version\kix32.exe"
IF EXIST "c:\version\kix32.exe" cacls c:\version\kix32.exe /E /C /G Everyone:C
goto start

:Start
IF EXIST "c:\version\kix32.exe" goto localkix2

REM *** The following section is for systems which fail to copy the kix32.exe file ***

"%logonserver%\netlogon\bin\kix32.exe" "%logonserver%\netlogon\kixtart.kix"

goto end

:Localkix1
"%windir%\kixtart\kix32.exe" "%logonserver%\netlogon\kixtart.kix"
goto end


:Localkix2
"c:\version\kix32.exe" "%logonserver%\netlogon\kixtart.kix"
goto end


:end
exit
