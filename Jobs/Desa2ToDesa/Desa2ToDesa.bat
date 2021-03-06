echo off
setlocal EnableDelayedExpansion

REM debe ser modificado de acuerdo a la carpeta de trabajo donde se bajaran los archivos de dimensions.
set pathServiciosComunes=C:\Users\l0646482\n\mi_desa\jenkins\jobs_desarrollo\Servicios_Comunes\
set ConfigFile=!pathServiciosComunes!Ambiente.cfg
set JobWorkPath=
set Dimension_LocalCopy=

for /f "tokens=1,2" %%r in ('findstr "Desa2ToDesa" %ConfigFile%') do (
	set JobWorkPath=%%s
)
echo El path de trabajo es: !JobWorkPath!
rem setea el path de trabajo
cd %JobWorkPath%

rem ruta de la copia local de Dimensions
for /f "tokens=1,2" %%t in ('findstr "DimensionPath" %ConfigFile%') do (
	set Dimension_LocalCopy=%%u
)
echo Dimension_LocalCopy es: !Dimension_LocalCopy!

REM ------------------------------- Chequeso Avanzados B1  ----------------------------------------------------------------
rem Verifica que se haya completo el campo con el numero de actividad en el formulario
if "%ACTIVIDAD%"=="CBUS_OSB_ACTIVIDAD_" (
	echo Debe completar el numero de ACTIVIDAD
	exit /b 2
)
REM ------------------------------- FIN Chequeso Avanzados B1 -------------------------------------------------------------
REM ------------------------------- Chequeso Avanzados C1 -------------------------------------------------------------
Rem Verifica si existe la actividad y si las credenciale sson validas  
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

REM ------------------------------- Chequeso Avanzados B 2 y 3  ----------------------------------------------------------------
Rem Verifica que haya un solo FWK/Servicio en la actividad  
Echo ------------------- Inicio de verificacion de Framework/servicio --------------------

call %pathServiciosComunes%chs1.3.bat %ACTIVIDAD% %BUILD_NUMBER% %JobWorkPath%
if not %errorlevel%==0 (
rem	echo Hubo un erro en el chs1.1.bat, el codigo de error es: %errorlevel%
	if %errorlevel%==1 (
		echo Hay mas de un framework/servicio en la actividad %ACTIVIDAD%.
		exit /b 1	
	)
	
	if %errorlevel%==2 (
		echo No existe la ACTIVIDAD %ACTIVIDAD% en Dimensions.
		exit /b 1
	)			
	
	if %errorlevel%==3 (
		echo No se pudo conectar a Dimensions.
	exit /b 1	
	)
	
	if %errorlevel%==4 (
		echo Ls actividad: %ACTIVIDAD% esta vacia.
	exit /b 1	
	)

	echo Error Desconocido
	exit /b 1	
)
rem echo errorlevel de chs1.1.bat %errorlevel%, todo OK
	echo Actividad OK
Echo -------------------- FIN de verificacion de Framework/servicio --------------------


rem el goto es para evitarque vuelva a bajar el contenido de la actividad ya que eso lo hizo previamente dentro de chs1.3.bat
goto :chequeos



REM ------------------------------- FIN Chequeso Avanzados B 2 y 3 -------------------------------------------------------------

REM ------------------------------- Chequeso Avanzados B4  ----------------------------------------------------------------
REM Verifica los serttings que el agilizador deja en los fuentes.

Rem Baja a una carpeta temporal el contenido de la actividad
REM elimina el contenido de la carpeta temporal y la vuelve a crear

rd /s /q Items_Temp > NUL
REM vuelve a crear la carpeta temporarl

if not exist Items_Temp md Items_Temp > NUL

rem baja el contenido de la actividad %cargar la actividad%
setlocal disabledelayedexpansion
dm get --directory Items_Temp  --requestId %ACTIVIDAD% --user %User_Dim% --password %Pass_Dim% --database Galicia@Dimensions --server Dimensions1 > NUL
setlocal EnableDelayedExpansion


:chequeos


Echo -------------------- Comienzo de la verificacion de settings en fuentes de Dimensions --------------------
call %pathServiciosComunes%Check_Settings1.2.bat %JobWorkPath%

if not %errorlevel%==0 (
rem	echo Hubo un erro en el Check_Settings1.1.bat, el codigo de error es: %errorlevel%
	echo Hay settings incorrectos en los fuentes de Dimensions
	exit /b 1	
)
rem echo errorlevel de Check_Settings1.1.bat %errorlevel%, todo OK
echo Los settings de los fuentes de Dimensions estan OK
Echo -------------------- FIN de la verificacion de settings en fuentes de Dimensions --------------------
REM ------------------------------- FIN Chequeso Avanzados B5 -------------------------------------------------------------


REM ------------------------------- Acciones C1  ----------------------------------------------------------------
REM 1.	Genera el Build automatico.
REM genera el archivo de entrada del BUILD automatico, este archivo contiene una linea con el path por cada archivo de la actividad, se toma el archivo de salida de chs1.1.bat

	set pa=%JobWorkPath%Items_Temp2
	for /f "tokens=*" %%r in (%JobWorkPath%servicio.txt) do (
rem		echo salida Entregable %%r 
rem		echo %%r >> %sWorkPath%servicio_db.txt
		set tEntre=%%r
		set tEntre=!tEntre:%pa%^\=!
	
		set PathFile_Entregable=!tEntre!
		
		set PathFile_Entregable=!PathFile_Entregable:.dmdb=!
		if !tEntre!==!PathFile_Entregable! (
			echo !PathFile_Entregable%!
		)
	)

exit /b
REM Invoca al proceso que arma el .jar

REM elimina el ultimo log de salida
if exist sal_buil.txt del sal_buil.txt
REM elimina los .jar previos que puedan existir
del /Q c:\shared\IC\*.*

Echo -------------------- Comienzo del Build --------------------
call C:\Users\l0646482\n\mi_desa\jenkins\jobs\Servicios_Comunes\Build_CBUS4.1.bat  >> sal_buil.txt
if not %errorlevel%==0 (
rem	echo Hubo un erro en el Build_CBUS4.1.bat durante el BUIL automatico, el codigo de error es: %errorlevel%
	echo Hubo un error en el Build automatico. Puede probar ejecutar el Buiild automatico desde Dimensions para obtener mas informacion.
	exit /b 1	
)
rem echo errorlevel de Build_CBUS4.1.bat %errorlevel%
	echo Build automatico OK.
Echo -------------------- FIN del Build --------------------
)	
REM ------------------------------- FIN Acciones C1 -------------------------------------------------------------

REM ------------------------------- Acciones C2  ----------------------------------------------------------------
REM 1. Extre el contenido del .Jar

md %User_Dim%\%BUILD_NUMBER%
if exist %User_Dim%\%BUILD_NUMBER%\dir-tmp.txt del %User_Dim%\%BUILD_NUMBER%\dir-tmp.txt
dir c:\shared\IC\ /b >> %User_Dim%\%BUILD_NUMBER%\dir-tmp.txt
copy c:\shared\IC\*.* %User_Dim%\%BUILD_NUMBER%\
for /f "tokens=*" %%y in (%User_Dim%\%BUILD_NUMBER%\dir-tmp.txt) do (
rem	echo "%User_Dim%\%BUILD_NUMBER%\%%y"
	"C:\Program Files (x86)\Java\jre1.8.0_171\bin\java" -jar ReadExportResourcesJarOSB_v2.jar "%User_Dim%\%BUILD_NUMBER%\%%y" %User_Dim%\%BUILD_NUMBER%\CBUS\
)

REM 2. Verifica los setings de los atchivos extraidos del .Jar. Chequeos B5
Echo -------------------- Comienzo de la verificacion de settings de los archivos del .Jar --------------------
call C:\Users\l0646482\n\mi_desa\jenkins\jobs\Servicios_Comunes\Check_Settings1.1.bat %User_Dim%\%BUILD_NUMBER%\CBUS


if not %errorlevel%==0 (
rem	echo Hubo un error en el Check_Settings1.1.bat, el codigo de error es: %errorlevel%
	echo Hay settings incorrectos en el servicio en la consola
	exit /b 1	
)
rem echo errorlevel de Check_Settings1.1.bat %errorlevel%, todo OK
echo Los settings del servicio en la consola estan OK
Echo -------------------- FIN de la verificacion de settings de los archivos del .Jar --------------------
REM ------------------------------- FIN Acciones C2 -------------------------------------------------------------

:cinco
REM ------------------------------- Acciones C3  ----------------------------------------------------------------
REM 3.	Sube el/los .jar a la actividad
set pa=%User_Dim%\%BUILD_NUMBER%\CBUS

if exist servicio.txt del servicio.txt

FOR /L %%y IN (1, 1, 3) DO (
	dir /ad /b /on !pa! >> servicio.txt
	for /f "tokens=*" %%x in (servicio.txt) do set t_ser=%%x
	set pa=!pa!\!t_ser!
	del servicio.txt
	echo !pa! >> servicio.txt
)
set pa=!pa:%User_Dim%\%BUILD_NUMBER%\CBUS=!

rem echo !pa! 
set pa2=!pa:\=/!
if not exist !Dimension_LocalCopy!!pa!\Entregables MD !Dimension_LocalCopy!!pa!\Entregables


Echo -------------------- Comienza la importacion a la consola ESB --------------------
call C:\Users\l0646482\n\mi_desa\jenkins\jobs\Servicios_Comunes\Import_ESB1.1.bat %User_Dim%\%BUILD_NUMBER%\dir-tmp.txt %cd%\%User_Dim%\%BUILD_NUMBER% !Dimension_LocalCopy!!pa!\Entregables !pa2! "%ACTIVIDAD% - %Descripcion%"
Echo -------------------- FIN de la importacion a la consola ESB --------------------
REM ------------------------------- FIN Acciones C3 -------------------------------------------------------------
