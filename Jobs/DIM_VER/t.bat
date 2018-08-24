echo off
set file_us=D:\n\jenkins\DIM_VER\dar.txt

REM falta tomar el archivo de log de salida del comando LOG de dimension, dejar solo las lineass de objetos, y despues ir tomando esas lineas que
REM quedaron de a una, ir asignandolas a la variable dim y dejar que se se ejecute el codigode abajo, para extraer de la linea:
REM los primeros 18 caracteres, la parte final del ";" en adelante y despus de lo que queda buscar en el archivo completo de logs.


set dim1="         M | I | CanalesExternos/AccionesCanalesAlternativos/v2/MFL/RegistrarOperacionesMonetariasRequest-1.0.0.mfl;cbus_osb_desarrollo#4 | CBUS_OSB_ACTIVIDAD_755"
set dim2="%dim1:~18%
FOR /F "tokens=1 delims=;" %%i IN (%dim2%) DO set dim3=%%i


echo %dim3%

for /f "delims=" %%a in ("l.txt") do (

	echo %%a >> %file_us%

	for /f "tokens=* delims=%dim3%" %%x in ('findstr %dim3% %%a') do (
	echo %%x

	)

)
