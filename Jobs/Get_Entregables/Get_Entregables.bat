echo off
setlocal EnableDelayedExpansion
REM IMPORTANTE:
REM este path esta harcodeado C:\Users\l0646482\n\mi_desa\jenkins\jobs_desarrollo\Get_Entregables\Items_Temp\
REM debe ser modificado de acuerdo a la carpeta de trabajo donde se bajaran los archivos de dimensions.

set ConfigFile=C:\Users\l0646482\n\mi_desa\jenkins\jobs_desarrollo\Servicios_Comunes\Ambiente.cfg
set JobWorkPath=
set Dimension_LocalCopy=

goto :s1

for /f "tokens=*" %%w in ('findstr "Get_EntregablesPath" %ConfigFile%') do (
	set JobWorkPath=%%w
	set JobWorkPath=!JobWorkPath:Get_EntregablesPath =!
)
echo El path de trabajo es: !JobWorkPath!

for /f "tokens=*" %%w in ('findstr "DimensionPath" %ConfigFile%') do (
	set Dimension_LocalCopy=%%w
	set Dimension_LocalCopy=!Dimension_LocalCopy:DimensionPath =!
)
echo Dimension_LocalCopy es: !Dimension_LocalCopy!

:s1

for /f "tokens=1,2" %%r in ('findstr "Get_EntregablesPath" %ConfigFile%') do (
	set JobWorkPath=%%s
)
echo El path de trabajo es: !JobWorkPath!

rem ruta de la copia local de Dimensions
for /f "tokens=1,2" %%t in ('findstr "DimensionPath" %ConfigFile%') do (
	set Dimension_LocalCopy=%%u
)
echo Dimension_LocalCopy es: !Dimension_LocalCopy!



REM ------------------------------- Chequeso Avanzados B1 -------------------------------------------------------------
rem Verifica que se haya completo el campo con el numero de actividad en el formulario
if "%ACTIVIDAD%"=="CBUS_OSB_ACTIVIDAD_" (
	echo Debe completar el numero de ACTIVIDAD
	exit /b 2
)
REM ------------------------------- FIN Chequeso Avanzados B1 -------------------------------------------------------------

REM ------------------------------- Chequeso Avanzados C1 -------------------------------------------------------------
Rem Verifica si existe la actividad:  
if exist Act_Temp.txt del Act_Temp.txt
setlocal disabledelayedexpansion
dmcli -user %User_Dim% -pass %Pass_Dim% -host Dimensions1 -dbname Galicia -dsn Dimensions reqc %ACTIVIDAD% >> Act_Temp.txt
setlocal EnableDelayedExpansion

rem si el tamaño del archivo de salida de la conexion a dimension es cero no se puddo conectar a dimension, se debe abortar
set size=0
for %%A in (Act_Temp.txt) do set size=%%~zA 
echo SIZE: %size%
if %size%==0 (
rem	Echo No se pudo conectar a Dimensions, fin del Job.
	echo No se pudo conectar a Dimensions.
	exit /b 1
)
REM ------------------------------- FIN Chequeso Avanzados C1 -------------------------------------------------------------

REM elimina el contenido de la carpeta temporal y la vuelve a crear
if exist %JobWorkPath%Items_Temp rd /s /q %JobWorkPath%Items_Temp > NUL
REM vuelve a crear la carpeta temporarl
if not exist %JobWorkPath%Items_Temp md %JobWorkPath%Items_Temp > NUL


rem baja el contenido de la actividad %cargar la actividad%
setlocal disabledelayedexpansion
dm get --directory %JobWorkPath%Items_Temp --requestId %ACTIVIDAD% --user %User_Dim% --password %Pass_Dim% --database Galicia@Dimensions --server Dimensions1 > NUL
setlocal EnableDelayedExpansion

set pa=%JobWorkPath%Items_Temp

if exist %JobWorkPath%servicio.txt del %JobWorkPath%servicio.txt
if exist %JobWorkPath%servicio_db.txt del %JobWorkPath%servicio_db.txt
if exist %JobWorkPath%servicio_db2.txt del %JobWorkPath%servicio_db2.txt
if exist %JobWorkPath%servicio_db3.txt del %JobWorkPath%servicio_db3.txt
rem	dir /ad /b /on !pa! >> servicio.txt
dir !pa! /a-d /b /S  >> %JobWorkPath%servicio.txt


echo Contenido de la/s carpetas \Entregables\

	for /f "tokens=*" %%r in ('findstr "\\Entregables\\" %JobWorkPath%servicio.txt') do (
rem		echo salida Entregable %%r 
rem		echo %%r >> %JobWorkPath%servicio_db.txt
		set tEntre=%%r
		set tEntre=!tEntre:%pa%^\=!
		set PathFile_Entregable=!tEntre!
rem		echo !tEntre!
		set tEntre=!tEntre:^\Entregables\=/!
rem		echo tEntre !tEntre!
	
		for /f "tokens=1,2 delims=/" %%s in ("!tEntre!") do (
rem			echo %%t

				set Tmp_Path=%%t
				set Tmp_Path=!Tmp_Path:.dm=!
				if %%t==!Tmp_Path! (
					echo !Tmp_Path! 
					echo !PathFile_Entregable!
				)
			)
	)

	
echo IMPORTANTE: si dentro de la actividad hay mas de un carpeta que responda a la forma: \Entregables\  se recomienda dejar solo una carpeta.
exit /b

	for /f "tokens=*" %%x in (%JobWorkPath%servicio.txt) do (
		set Tmp_Path=%%x
		set Tmp_Path=!Tmp_Path:\Entregables\=!
		if not %%x==!Tmp_Path! echo salida Entregable !Tmp_Path! 
		if not %%x==!Tmp_Path! echo !Tmp_Path! >> %JobWorkPath%servicio_db.txt
	)

	for /f "tokens=*" %%x in (%JobWorkPath%servicio_db.txt) do (
		set Tmp_Path=%%x
		set Tmp_Path=!Tmp_Path:.dm=!
		if %%x==!Tmp_Path! echo salida DM !Tmp_Path! 
		if %%x==!Tmp_Path! echo !Tmp_Path! >> %JobWorkPath%servicio_db2.txt
	)

	for /f "tokens=*" %%x in (%JobWorkPath%servicio_db2.txt) do (
		set Tmp_Path=%%x
		set Tmp_Path=!Tmp_Path:^C:\Users\l0646482\n\mi_desa\jenkins\jobs_desarrollo\Get_Entregables\Items_Temp\=!
		if not %%x==!Tmp_Path! echo !Tmp_Path!
		if not %%x==!Tmp_Path! echo !Tmp_Path! >> %JobWorkPath%servicio_db3.txt
		for /f "tokens=1,2 delims=\" %%y in ("!Tmp_Path!") do (
			echo %%z
		)
	)
	
	 

exit /b

	set tmp_Fwk=
	set tmp_Ser=
	set tmp_Ver=
	set tmp_First=primero
	set b_Fwk_Serv=ES_unico
	for /f "tokens=1,2,3 delims=\" %%t in (servicio_db3.txt) do (
		echo %%t\%%u\%%v

		if !tmp_First!==primero ( 
			rem Primer pasada de servicio_db3.txt
			echo primero
			set tmp_First=no_primero
			set tmp_Fwk=%%t
			set tmp_Ser=%%u
			set tmp_Ver=%%v
		) else ( 
			rem de segunda pasada hasta el final del archivo servicio_db3.txt
			if not !tmp_Fwk!==%%t (
				set b_Fwk_Serv=NO_unico
			)
			if not !tmp_Ser!==%%u set b_Fwk_Serv=NO_unico
			if not !tmp_Ver!==%%v set b_Fwk_Serv=NO_unico
		)
	)
	
	if !b_Fwk_Serv!==ES_unico (
		echo OK: Hay un solo fwk/serv/version
	) else (
		echo ERROR: Hay mas de un fwk/serv/version
	)
rem echo !pa! 

exit /b


