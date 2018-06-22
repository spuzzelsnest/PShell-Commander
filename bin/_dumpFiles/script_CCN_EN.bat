rem
rem @Author: CCN-CERT Team
rem @E-mail: info@ccn-cert.cni.es
rem @Website: www.ccn-cert.cni.es
rem @Description:
rem Script to avoid further execution of malware Wannacry
rem The malware creates several files at the beginning of its execution. If it can't get a valid handle to some of those files it will finish the execution without infecting the computer
rem This script creates an empty file with the same name of one of the files created by the malware and without any permissions inside several folders for the purpose explained before
rem Please note, that this script will only stop the execution of the ransomware if it's run from one of the folders included in this script
rem Please, feel free to add more folders if it's needed
rem
copy /y nul t.wnry
icacls t.wnry /deny Everyone:W /T
copy /y nul "C:\Users\%USERNAME%\AppData\local\Temp\t.wnry"
icacls C:\Users\%USERNAME%\AppData\local\Temp\t.wnry /deny Everyone:W /T
copy /y nul "%USERPROFILE%\Downloads\t.wnry"
icacls %USERPROFILE%\Downloads\t.wnry /deny Everyone:W /T
copy /y nul "%USERPROFILE%\Desktop\t.wnry"
icacls %USERPROFILE%\Desktop\t.wnry /deny Everyone:W /T
copy /y nul "%USERPROFILE%\Documents\t.wnry"
icacls %USERPROFILE%\Documents\t.wnry /deny Everyone:W /T
copy /y nul "%USERPROFILE%\Music\t.wnry"
icacls %USERPROFILE%\Music\t.wnry /deny Everyone:W /T
copy /y nul "%USERPROFILE%\Pictures\t.wnry"
icacls %USERPROFILE%\Pictures\t.wnry /deny Everyone:W /T
copy /y nul "%USERPROFILE%\Videos\t.wnry"
icacls %USERPROFILE%\Videos\t.wnry /deny Everyone:W /T
