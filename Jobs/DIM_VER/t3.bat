echo off
set file_us=D:\n\jenkins\DIM_VER\dar.txt

REM falta tomar el archivo de log de salida del comando LOG de dimension, dejar solo las lineass de objetos, y despues ir tomando esas lineas que
REM quedaron de a una, ir asignandolas a la variable dim y dejar que se se ejecute el codigode abajo, para extraer de la linea:
REM los primeros 18 caracteres, la parte final del ";" en adelante y despus de lo que queda buscar en el archivo completo de logs.

REM ----------------------------------------------

set ACT=CBUS_OSB_ACTIVIDAD_1244

set file_act=D:\n\jenkins\DIM_VER\file_act.txt

del %file_act%
for /f "delims=" %%b in ("l6.txt") do (

rem	echo %%b >> %file_us%

	for /f "tokens=* delims=%dim3%" %%n in ('findstr %ACT% %%b') do (
	echo %%n >> %file_act%

	)

)


REM --------------------------------------------------

rem copy %file_act% old_%file_act%
echo file_act
echo %file_act%

for /f "tokens=*" %%t in (D:\n\jenkins\DIM_VER\file_act.txt) do (

	set dim1=%%t
	echo DIM1
	echo %dim1%
	set dim2="%dim1:~18%
	echo DIM2
	echo %dim2%
	
	FOR /F "tokens=1 delims=;" %%i IN (%dim2%) DO set dim3=%%i


	echo DIM3
	echo %dim3%

	for /f "delims=" %%a in ("l.txt") do (

		echo %%a >> %file_us%

		for /f "tokens=* delims=%dim3%" %%x in ('findstr %dim3% %%a') do (
		echo %%x
		)

	)

)






REM ----------------------------------------------

