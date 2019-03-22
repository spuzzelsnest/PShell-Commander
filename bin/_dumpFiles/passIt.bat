<<<<<<< HEAD
::passIt.bat

::Create Hash File from registry
::

::Created by Spuzzelsnest

::

::Change Log

::-----------

::V1.0 Initial release 18-08-2016

::############################################


@echo off

reg.exe save hklm\sam c:\temp\Logs\sam.hiv

reg.exe save hklm\security c:\temp\Logs\security.hiv

reg.exe save hklm\system c:\temp\Logs\system.hiv


exit


=======
::passIt.bat

::Create Hash File from registry
::

::Created by Spuzzelsnest

::

::Change Log

::-----------

::V1.0 Initial release 18-08-2016

::############################################


@echo off

reg.exe save hklm\sam c:\temp\Logs\sam.hiv

reg.exe save hklm\security c:\temp\Logs\security.hiv

reg.exe save hklm\system c:\temp\Logs\system.hiv


exit


>>>>>>> b69d0509a6d6dfdd1e1b9b7b4e878e2ab2773dc0
