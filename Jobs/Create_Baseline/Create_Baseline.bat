echo off
setlocal EnableDelayedExpansion
REM IMPORTANTE:
REM este path esta harcodeado C:\Users\l0646482\n\mi_desa\jenkins\jobs_desarrollo\Get_Entregables\Items_Temp\
REM debe ser modificado de acuerdo a la carpeta de trabajo donde se bajaran los archivos de dimensions.

set ConfigFile=C:\Users\l0646482\n\mi_desa\jenkins\jobs_desarrollo\Servicios_Comunes\Ambiente.cfg
set JobWorkPath=
set Dimension_LocalCopy=

for /f "tokens=1,2" %%r in ('findstr "CreateBaselinePath" %ConfigFile%') do (
	set JobWorkPath=%%s
)
echo El path de trabajo es: !JobWorkPath!

rem ruta de la copia local de Dimensions
for /f "tokens=1,2" %%t in ('findstr "DimensionPath" %ConfigFile%') do (
	set Dimension_LocalCopy=%%u
)
echo Dimension_LocalCopy es: !Dimension_LocalCopy!

SET PATH_DEPLOYAUTO=!Dimension_LocalCopy!DeployAutomatico\

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
rem	dir /ad /b /on !pa! >> servicio.txt
dir !pa! /a-d /b /S  >> %JobWorkPath%servicio.txt


echo Contenido de la/s carpetas \Entregables\

rem		actividad con una estructura mala:				1531
rem		actividad con una estructura incompleta			1532
rem		CanalesExternos\AccionesCanalesAlternativos		573
rem		CanalesExternos\AccionesCanalesAlternativos\v2	474
rem		AdministracionRiesgoCliente\AccionesSemaforo
rem		AdministracionRiesgoCliente\AdministracionSolicitudInformeComercial

rem 	caso 1 - Si el servicio no tiene carpeta version, entonces la carpeta Entregables esta en el nivel tres junto con las carpetas de los objetos del servicio.
rem 	caso 2 - Si el servicio tiene como tercer nivel de carpeta una carpeta con version de servicio (Vxx), esa carpeta debe ser unica dentro de la actividad.

rem si se da el caso 2, entonces la carpeta entregables esta en el nivel cuatro, dentro de la version del servicio.

	rem si es true indica que el servicio no tiene version
	set bNivelTres=false
	rem si es true indica que el servicio tiene version
	set bNivelCuatro=false
	rem si las dos son true quiere decir que la estructura del servicio en la actividad esta mal armado.
	
	rem si es true indica que existe la carpeta Entregables.
	set bCarpetaEntregables=false
	
	set sPathDeliver=
	for /f "tokens=*" %%r in (%JobWorkPath%servicio.txt) do (
rem		echo salida Entregable %%r 
rem		echo %%r >> %JobWorkPath%servicio_db.txt
		set tEntre=%%r
		set tEntre=!tEntre:%pa%^\=!
		set PathFile_Entregable=!tEntre!
		for /f "tokens=1,2,3,4,5 delims=^\" %%s in ("!PathFile_Entregable!") do (
			set level3=%%u
			set level3=!level3:.dm=!
			if %%u==!level3! (
				set m=!level3!
				set m=!m:v=!
				set /a m=!m!+1
				if !m!==1 (
rem					echo el tercer nivel no es V, entonces la carpeta Entregables debe estar a nivel 3.
					set bNivelTres=true
					set level3=!level3:Entregables=!
					if not %%u==!level3! (
rem						echo Existe carpeta Entregables en el nivel 3.
						set bCarpetaEntregables=true
						set sPathDeliver=%%s\%%t\%%u
						echo %%v
					)
				) else (
rem					echo el tercer nivel es Vx, entonces debe haber solo una carpeta de nivel 3 con la version del servicio, y en el nivel cuatro debe estar la carpeta Entregables
					set bNivelCuatro=true
					set level3=%%v
					set level3=!level3:Entregables=!
					if not %%v==!level3! (
rem						echo Existe carpeta Entregables en el nivel 4.
						set bCarpetaEntregables=true
						set sPathDeliver=%%s\%%t\%%u\%%v
						echo %%w
					)
				)
			)
		)
	)
	if !bNivelTres!==true (
		if !bNivelCuatro!==true (
			echo La ACTIVIDAD tiene una estructura de carpetas incorrecta.
			echo En caso de que el servicio este versionado, todas las carpetas deben estar dentro de la carpeta version.
			exit /b 1
		)
	)
	
	if !bNivelTres!==false (
		if !bNivelCuatro!==false (
			echo La ACTIVIDAD no tiene la estrcutura adecuada de un servicio.
			exit /b 1
		)
	)
rem Verifica que exista la carpeta "Entregables". Si es un servicio sin version, la carpeta "Entregables" debe estar en el nivel 3, si es versionado debe estar en el nivel 4.
rem verifica si en el nivel 3 de la estructura de carpetas existe la carpeta "Entregables"
	if  !bNivelTres!==true (
		for /f "tokens=1,2,3 delims=^\" %%s in ("!PathFile_Entregable!") do (
			set level3=%%u
			set level3=!level3:.dm=!
			if %%u==!level3! (
				set m=!level3!
				set m=!m:v=!
				set /a m=!m!+1
				if !m!==1 (
rem					echo el tercer nivel no es V, entonces la carpeta Entregables debe estar a nivel 3.
					set bNivelTres=true
				) else (
rem					echo el tercer nivel es Vx, entonces debe haber solo una carpeta de nivel 3 con la version del servicio, y en el nivel cuatro debe estar la carpeta Entregables
					set bNivelCuatro=true
				)
			)
		)
	)

rem verifica si en existe la carpeta "Entregables"
	if  !bCarpetaEntregables!==false (
		echo No se encontro la carpeta "Entregables"
		exit /b 1
	)
	
	echo sPathDeliver !sPathDeliver!
	

========================================================================
REM Comienzo: crea xml de deploy automatico de INTE y arma path

REM FIN: crea xml y arma path
set inp=%ARCHIVOS_INTE%
rem salta y no genera XML de INTE si no se ingresan archivos para INTE.
if "%inp%" == "" goto :FIN_XML_INTE
echo --------------- Armado de deploy automatico para Integracion ---------------------
rem set sOutputFile_inte=%PATH_DEPLOYAUTO%XMLImportJar_Inte.xml
set sOutputFile_inte=!JobWorkPath!XMLImportJar_Inte.xml
REM Pone el XML de deploy automatico como READ-WRITE en el repositorio local
attrib -R %sOutputFile_inte%

REM Elimina la version existente del XML de deploy automatico
if exist %sOutputFile_inte% del %sOutputFile_inte%

echo ^<import^> >> %sOutputFile_inte%
echo			^<jar^> >> %sOutputFile_inte%
REM extrae el primer y ultimo caracter de los parametros ingresados, los cuale se suponene que son comillas
REM usarlo solo si se corre desde batch, si se ejecuta desde jenkins comentarlo porque no deben usar las comillas.
rem set inp=%inp:~1,-1%

:repetir_inte
for /f "tokens=1 delims=; " %%a in ("%inp%") do set out=%%a

REM Verifica que en la carpeta de ingreso esten todos los archivos ingresados al JOB como parametros.

echo !pa!\!sPathDeliver!\!out!
if exist !pa!\!sPathDeliver!\!out! GOTO :DONE3
rem IF NOT ERRORLEVEL 1 GOTO :DONE3
      ECHO  No se encontro el archivo %out% en la carpeta !pa!!sPathDeliver!.
	  goto :FIN
:DONE3

REM aca deberia mover el archivo de la carpeta de intercambio a la carpeta ENTREGABLES correspondiente.
echo !Dimension_LocalCopy!!sPathDeliver!\!out!
copy !pa!\!sPathDeliver!\!out! !Dimension_LocalCopy!!sPathDeliver!
REM move %PATH_FOLDER_IN%%out% C:\Dimensions\Workspace2\%RUTA%\Entregables

REM escribe en el xml de deploy automatico
set sPathDeliver2=!sPathDeliver:\=/!
echo				^<path^>D:/Serena/SDA-AGENT/core/var/work/CBUS_OSB/%sPathDeliver2%/!out!^</path^> >> %sOutputFile_inte%
call :param %out%

if not "%inp%" == "~1" goto :repetir_inte

REM carga numero de TO en el XML
REM set ito=%TO%
set ito=%Release_Package%
echo				^<transferencia^>%ito%^</transferencia^> >> %sOutputFile_inte%
	 		
echo			^</jar^>  >> %sOutputFile_inte%
echo ^</import^>  >> %sOutputFile_inte%

REM Pone el XML de deploy automatico como READONLY en el repositorio local
attrib +R %sOutputFile_inte%
echo --------------- FIN Armado de deploy automatico para Homologacion ---------------------
:FIN_XML_INTE
REM fin del aramdo de xml de deploy automatico de HOMO
========================================================================

	
	
exit /b
	
REM fin del aramdo de xml de deploy automatico de PROD
========================================================================

REM Deliver de XML de deploy automatico y de archivos ENTREGABLES a la actividad indicada en el parametro 5.
REM CBUS_OSB_ACTIVIDAD_1044
rem login en dimensions

rem dm liststreams --user l0646482 --password saile238 --database Galiciass@Dimensions --server Dimensions1

echo Add a Dimension de deploy automatico
dm Add DeployAutomatico --directory C:\Dimensions\Workspace2 --requestId %ACTIVIDAD% --user %USER_DIMENSION% --password %PASS_DIMENSION% --database Galicia@Dimensions --server Dimensions1


echo Deliver a Dimension de xml de deploy automatico

dm deliver --stream CBUS_OSB:DESARROLLO DeployAutomatico --directory C:\Dimensions\Workspace2 --requestId %ACTIVIDAD% --user %USER_DIMENSION% --password %PASS_DIMENSION% --database Galicia@Dimensions --server Dimensions1

echo %RUTA%\Entregables

echo Add a Dimension de entregables
dm add  %RUTA%\Entregables --directory C:\Dimensions\Workspace2 --requestId %ACTIVIDAD% --user %USER_DIMENSION% --password %PASS_DIMENSION% --database Galicia@Dimensions --server Dimensions1

echo Deliver a Dimension de xml de deploy automatico
dm deliver --stream CBUS_OSB:DESARROLLO %RUTA%\Entregables --directory C:\Dimensions\Workspace2 --requestId %ACTIVIDAD% --user %USER_DIMENSION% --password %PASS_DIMENSION% --database Galicia@Dimensions --server Dimensions1

rem CALL :LENGHT 123456789
rem ECHO.%LEN%

========================================================================
REM generacion de baseline
echo BASELINE: %BASELINE_VERSION%

rem set base=%BASELINE_VERSION%
set base=CBUS_OSB:%ACTIVIDAD%
if "%BASELINE_VERSION%" == "" goto :BASELINE_SIN_VERSION
set base=CBUS_OSB:%ACTIVIDAD%_%BASELINE_VERSION%

:BASELINE_SIN_VERSION
echo base: %base%

rem CBL "CBUS_OSB:CBUS_OSB_ACTIVIDAD_1159_V5" /PART="CBUS_OSB:CBUS_OSB.A;1" /TEMPLATE_ID="BASELINE_POR_REQUEST" /WORKSET="CBUS_OSB:DESARROLLO" /LEVEL="0" /TYPE="BASELINE" /CHANGE_DOC_IDS=("CBUS_OSB_ACTIVIDAD_1159",) /INCLUDE_INFO/INCLUDE_CLOSED /SCOPE="PART"
rem dmcli -user %USER_DIMENSION% -pass %PASS_DIMENSION% -host Dimensions1 -dbname Galicia -dsn Dimensions CBL "CBUS_OSB:%ACTIVIDAD%" /PART="CBUS_OSB:CBUS_OSB.A;1" /TEMPLATE_ID="BASELINE_POR_REQUEST" /WORKSET="CBUS_OSB:DESARROLLO" /LEVEL="0" /TYPE="BASELINE" /CHANGE_DOC_IDS=("%base%",) /INCLUDE_INFO/INCLUDE_CLOSED /SCOPE="PART"
dmcli -user %USER_DIMENSION% -pass %PASS_DIMENSION% -host Dimensions1 -dbname Galicia -dsn Dimensions CBL "%base%" /PART="CBUS_OSB:CBUS_OSB.A;1" /TEMPLATE_ID="BASELINE_POR_REQUEST" /WORKSET="CBUS_OSB:DESARROLLO" /LEVEL="0" /TYPE="BASELINE" /CHANGE_DOC_IDS=("%ACTIVIDAD%",) /INCLUDE_INFO /INCLUDE_CLOSED /SCOPE="PART"




:FIN_BASELINE
:FIN



 =======================================================================
:: Mide la longitud de una cadena
:: Devuelve errorlevel=1 si no se especifica la cadena
 
:LENGHT STRING
 
	SETLOCAL ENABLEEXTENSIONS
	SET "STRING=%~1"
	:: Empieza el contador en 0
	IF "%TMPVAR%"=="" SET/A CONT=0
	:: Si no se mandan parametros salimos
	IF NOT DEFINED STRING ENDLOCAL & EXIT/B 1 
	::
	:: Extracción de caracteres que aumenta en 1
	CALL SET "VAR=%%STRING%:~%CONT%,1%%"
	::
	IF DEFINED VAR (
		:: Sumamos el contador y llamamos a la funcion
		SET "TMPVAR=$" & SET/A CONT+=1 & CALL %~0 "%STRING%"
	) ELSE (
		::Declaramos la variable len
		CALL SET LEN=%%CONT%%
	)
	ENDLOCAL & SET "LEN=%LEN%"
EXIT /B
========================================================================

:param str
	SETLOCAL ENABLEEXTENSIONS
	SET "str=%~1"
CALL :LENGHT %str%

set /a LEN=%LEN%+1
rem ECHO.%LEN%

set contador=0 
:bucle 
if %contador% LSS %LEN% (
set /a contador=%contador%+1 
set inp=%inp:~1%
goto :bucle 
)
ENDLOCAL & SET "inp=%inp%"
exit /bucle
========================================================================
