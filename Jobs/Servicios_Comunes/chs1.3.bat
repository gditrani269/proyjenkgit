echo off

REM Esta version del Che.bat parametriza los archivos de entrada y salida par aque se pueda usar como un .bat de servicios desde cualquier lugar.
rem parametros de entrada
rem param 1: ACTIVIDAD
rem param 2: BUILD_NUMBER
rem parma 3: PATH de TRABAJO
set iActividad=%1
set iBuildNum=%2
set sWorkPath=%3

echo ACTIVIDAD:			%iActividad%
echo BUILD_NUMBER:		%iBuildNum%
echo PATH de TRABAJO:	%sWorkPath%

REM salida:
REM	0:	Ok
REM	1:	Hay mas de un fwk/servicio en la actividad
REM	2:	Si no existe la ACTIVIDAD en Dimension
REM 3:  No se pudo conectar a Dimensions
REM 4:  La actividad esta vacia.
setlocal EnableDelayedExpansion

cd %sWorkPath%

set sal=0
rem set ACTIVIDAD=0
set bError=0
set fSalida=salida_%iBuildNum%.txt
set fStatus=status_%iBuildNum%.txt
rem set fMail_Report=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\MailReport_%iBuildNum%.txt
set fMail_Report=MailReport.txt
if exist %fMail_Report% del %fMail_Report%

rem	set ACTIVIDAD=CBUS_OSB_ACTIVIDAD_1388
Rem Verifica si existe la actividad:  
if exist Act_Temp.txt del Act_Temp.txt
setlocal disabledelayedexpansion
dmcli -user %User_Dim% -pass %Pass_Dim% -host Dimensions1 -dbname Galicia -dsn Dimensions reqc %iActividad% >> Act_Temp.txt
setlocal EnableDelayedExpansion

rem si el tamaño del archivo de salida de la conexion a dimension es cero no se puddo conectar a dimension o las credenciales no son validas, se debe abortar
set size=0
for %%A in (Act_Temp.txt) do set size=%%~zA 
echo SIZE: %size%
if %size%==0 (
rem	Echo No se pudo conectar a Dimensions, fin del Job.
	exit /b 3
)

set act_exist=Act_Temp.txt
for /f "tokens=*" %%x in ('findstr "%iActividad%" %act_exist%') do (
	REM echo no existe la iActividad: %iActividad%
	exit /b 2
)

rem echo ACTIVIDAD: %iActividad% >> %fSalida%

REM elimina el contenido de la carpeta temporal y la vuelve a crear

rd /s /q Items_Temp2 > NUL
REM vuelve a crear la carpeta temporarl

if not exist Items_Temp2 md Items_Temp2 > NUL

rem baja el contenido de la actividad %cargar la actividad%
setlocal disabledelayedexpansion
dm get --directory %sWorkPath%Items_Temp2  --requestId %iActividad% --user %User_Dim% --password %Pass_Dim% --database Galicia@Dimensions --server Dimensions1 > NUL
setlocal EnableDelayedExpansion

set pa=%sWorkPath%Items_Temp2

rem --------------- Verifica si la actividad esta vacia -------------------------
if exist servicio.txt del servicio.txt
set bHayArchivos=false
dir /a-d /b /on /s %sWorkPath%Items_Temp2 >> servicio.txt
for /f "tokens=*" %%x in (servicio.txt) do (
	set sItem=%%x
	set sItem=!sItem:.dmdb=!
	if %%x==!sItem! set bHayArchivos=true
)

if !bHayArchivos!==false (
	rem la actividad esta vacia
	exit /b 4
)
rem --------------- FIN Verifica si la actividad esta vacia -------------------------

echo Contenido de la/s carpetas \Entregables\

rem		actividad con una estructura mala:				1531
rem		actividad con una estructura vacia				1532
rem		CanalesExternos\AccionesCanalesAlternativos		573
rem		CanalesExternos\AccionesCanalesAlternativos\v2	474
rem		AdministracionRiesgoCliente\AccionesSemaforo
rem		AdministracionRiesgoCliente\AdministracionSolicitudInformeComercial
rem		servicio con version			761
rem		servici osin version			769

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

	rem lleva el estado inicial de los nombres de las carpetas: framework\servicio\version
	set sFwk=
	set sServ=
	set sVer=
	rem semafaro para inicializar estas variables solo por primera vez
	set bFlagEstructura=false
	rem si es true es que hay mas de un fwk, de un servicio o de una version.
	set bMasDeUnaVersion=false
	
	set sPathDeliver=
	for /f "tokens=*" %%r in (%sWorkPath%servicio.txt) do (
rem		echo salida Entregable %%r 
rem		echo %%r >> %sWorkPath%servicio_db.txt
		set tEntre=%%r
		set tEntre=!tEntre:%pa%^\=!
	
		set PathFile_Entregable=!tEntre!
		
		set PathFile_Entregable=!PathFile_Entregable:.dmdb=!

		if !tEntre!==!PathFile_Entregable! (
			for /f "tokens=1,2,3,4,5 delims=^\" %%s in ("!PathFile_Entregable!") do (
				set level3=%%u
				set level3=!level3:.dmdb=!
				if %%u==!level3! (
rem					echo carpetas: !PathFile_Entregable!
					set m=!level3!
					set m=!m:~1,2!
					set /a m=!m!+1
					if !m!==1 (
rem						echo el tercer nivel no es V, entonces la carpeta Entregables debe estar a nivel 3.
						if !bNivelTres!==false (
							set sPathDeliver=%%s\%%t
						)
						set bNivelTres=true
						if not !sPathDeliver!==%%s\%%t (
							echo framework no ok
							echo !sPathDeliver!
							echo %%s\%%t
							set bMasDeUnaVersion=true
						)
						if !bNivelCuatro!==true (
							echo ERROR: No puede haber carpetas al mismo nivel que la version del servicio.
							echo %%s\%%t
							echo %%s\%%t\%%u
						)
					) else (
rem						echo el tercer nivel es Vx, entonces debe haber solo una carpeta de nivel 3 con la version del servicio, y en el nivel cuatro debe estar la carpeta Entregables
						if !bNivelCuatro!==false (
							set sPathDeliver=%%s\%%t\%%u
						)
						set bNivelCuatro=true
						if not !sPathDeliver!==%%s\%%t\%%u (
							echo framework no ok
							echo !sPathDeliver!
							echo %%s\%%t\%%u
							set bMasDeUnaVersion=true
						)
						if !bNivelTres!==true (
							echo ERROR: No puede haber carpetas al mismo nivel que la version del servicio.
							echo %%s\%%t
							echo %%s\%%t\%%u
						)
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
	if !bMasDeUnaVersion!==true (
			echo Verifique que exista una sola version de servicio dentro de la actividad.
			exit /b 1
	)
	
	if !bNivelTres!==false (
		if !bNivelCuatro!==false (
			echo La ACTIVIDAD no tiene la estrcutura adecuada de un servicio.
			exit /b 1
		)
	)
	
	echo sPathDeliver !sPathDeliver!
	
