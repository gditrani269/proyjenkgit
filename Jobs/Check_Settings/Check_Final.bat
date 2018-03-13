echo off
setlocal enabledelayedexpansion

set bError=
set sUser=
set fStatus=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\status_%BUILD_NUMBER%.txt
rem set fStatus=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\status_831.txt
rem set fStatus=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\status_%BUILD_NUMBER%.txt
rem set fMail_Adress=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Settings\Mail_Address.txt
rem set fSalida=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\salida_%Padre_BUILD_NUMBER%.txt
rem set fSalida=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\salida_990.txt

echo verifica el estado del archivo: %fStatus%

for /f "tokens=*" %%y in (%fStatus%) do (
	set bError=%%y
)

echo bError %bError%

exit %bError%
rem exit %bError%