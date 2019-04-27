echo off
REM Baja el contenido de la baseline indicada como parametro de entrada
REM Guarda el historia en el archivo C:\Users\l0646482\n\mi_desa\Eclipse\ChangeSets\GetBase.txt

REM Parametros de entrada
REM el primer parametro es el user de Dimensions
REM el segundo parametro es la pass del user de Dimensions
REM el tercer parametro es la Baseline de dimensions de la que se quiere tener bajar el contenido
REM el cuarto  path de trabajo

setlocal enabledelayedexpansion

set sUserDim=%1
set sPassDim=%2
set sActDim=%3
set sWorkPath=%4

rem al finalizar descomentar estas tres lineas
rem del /Q /S /F C:\BajadaBaseline3\*.* > nul
rem rd /S /Q C:\BajadaBaseline3\
rem mkdir C:\BajadaBaseline3

dmcli -user %sUserDim% -pass %sPassDim% -host Dimensions1 -dbname Galicia -dsn Dimensions download /DIRECTORY="" /BASELINE="CBUS_OSB:%sActDim%" /USER_DIRECTORY="C:\BajadaBaseline3" > nul

rem echo termino el Get de la actividad

echo getbaseline
if exist C:\BajadaBaseline3\DeployAutomatico\XMLImportJar_Homo1.xml (
	call :Nro_RP XMLImportJar_Homo1.xml
) else (
	echo No tiene deploy automatico a Homologacion.
)

if exist C:\BajadaBaseline3\DeployAutomatico\XMLImportJar_Prod.xml (
	call :Nro_RP XMLImportJar_Prod.xml
) else (
	echo No tiene deploy automatico a Produccion.
)
echo termino la busqueda del deploy automatico

exit /b 0

:Nro_RP
set sMensajeBaseline=Contiene deploy automatico %1
rem echo Existe el Deploy %1
set RPNumber=
rem exit /b 0
for /f "tokens=* delims=transferencia>" %%x in ('findstr "transferencia>"  C:\BajadaBaseline3\DeployAutomatico\%1') do (
	set RPNumber=%%x
	set RPNumber=!RPNumber:^<transferencia^>=!
	set RPNumber=!RPNumber:^</transferencia^>=!
	rem tabulador
	set RPNumber=!RPNumber:	=!
	rem espacio
	set RPNumber=!RPNumber: =!
rem 	echo El %1 hace referencia al RP: !RPNumber!
	set sMensajeBaseline=!sMensajeBaseline! y referencia al RP : !RPNumber!

rem	findstr /S /M /c:!RPNumber! C:\shared\Changset\rep_Homo.html
	if %1==XMLImportJar_Homo1.xml (
		for /f "tokens=*" %%x in ('findstr "!RPNumber!" C:\shared\Changset\rep_Homo.html') do (
			echo El RP esta en Homo
		)
	)
rem	if errorlevel 1 echo El RP NO esta en Homo
rem	findstr /S /M /c:!RPNumber! C:\shared\Changset\rep_Prod.html
	if %1==XMLImportJar_Prod.xml (
		for /f "tokens=*" %%x in ('findstr "!RPNumber!" C:\shared\Changset\rep_Prod.html') do (
			echo El RP esta en Prod
		)
	)
	
	for /f "tokens=* delims=path>" %%y in ('findstr "path>"  C:\BajadaBaseline3\DeployAutomatico\%1') do (
		set FileName=%%y
		set FileName=!FileName:^<path^>=!
		set FileName=!FileName:^</path^>=!
		rem tabulador
		set FileName=!FileName:	=!
		rem espacio
		set FileName=!FileName: =!
	rem 	echo El %1 hace referencia al RP: !FileName!
rem		echo referencia al archivo : !FileName!
		set FileName=!FileName:D:/Serena/SDA-AGENT/core/var/work/CBUS_OSB=C:\BajadaBaseline3!
		set FileName=!FileName:/=\!
		echo referencia al archivo : !FileName!
		if exist !FileName! (
			echo El archivo esta en la baseline
		) else (
			echo ERROR: No se encuentra el archivo en la baseline
		)
	)
rem	if errorlevel 1 echo El RP NO esta en Prod
)

set bFlagRpExist=false;
set /a iCount=0

rem for /f "tokens=*" %%y in ('findstr "!RPNumber!"  C:\shared\Changset\rep.html') do (
for /f "tokens=*" %%t in (C:\shared\Changset\rep.html) do (
rem 	echo El RP: !RPNumber! se encuentra en el estado de Homologacion.
	set sTmp=%%t
	set sTmp=!sTmp:%RPNumber%=TBD!
	 
	if !bFlagRpExist!==true set /a iCount=!iCount!+1
	if not %%t==!sTmp! (
		set bFlagRpExist=true
	)
	if !iCount!==5 (
		echo !sTmp!
		set bFlagRpExist=false;
		set /a iCount=0
	)
)
echo !sMensajeBaseline!
exit /b 0
