
echo off
setlocal EnableDelayedExpansion
REM IMPORTANTE:
REM este path esta arcodeado C:\Users\l0646482\n\mi_desa\jenkins\jobs_desarrollo\Get_Entregables\Items_Temp\
REM debe ser modificado de acuerdo a la carpeta de trabajo donde se bajaran los archivos de dimensions.


set ConfigFile=C:\Users\l0646482\n\mi_desa\jenkins\jobs_desarrollo\Servicios_Comunes\Ambiente.cfg
set JobWorkPath=
set Dimension_LocalCopy=

for /f "tokens=1,2" %%r in ('findstr "HandleCustomPath" %ConfigFile%') do (
	set JobWorkPath=%%s
)
echo El path de trabajo es: !JobWorkPath!

rem ruta de la copia local de Dimensions
for /f "tokens=1,2" %%t in ('findstr "DimensionPath" %ConfigFile%') do (
	set Dimension_LocalCopy=%%u
)
echo Dimension_LocalCopy es: !Dimension_LocalCopy!

rem carpeta de entrega de archivos
set FolderIn_HandleCustom=%JobWorkPath%recursos\%User_Dim%\

REM ------------------------------- Chequeso preliminares B1 -------------------------------------------------------------
rem Verifica que se haya completo el campo con el numero de actividad en el formulario
if "%ACTIVIDAD%"=="CBUS_OSB_ACTIVIDAD_" (
	echo Debe completar el numero de ACTIVIDAD
	exit /b 2
)
REM ------------------------------- FIN Chequeso preliminares B1 -------------------------------------------------------------

REM ------------------------------- Chequeso preliminares B2 -------------------------------------------------------------
rem Verifica que se haya completado el campo con el nombre del CUSTOM
set sCustomName=%CUSTOM_NAME%
if "%sCustomName%"=="" (
	echo Se debe ingresar un nombre del CustomFile a procesar.
	exit /b 3
)
REM ------------------------------- FIN Chequeso preliminares B2 -------------------------------------------------------------

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
	exit /b 4
)
REM ------------------------------- FIN Chequeso Avanzados C1 -------------------------------------------------------------

REM ------------------------------- Chequeso Avanzados C2 -------------------------------------------------------------

REM limpia la carpeta de trabajo del usuario para este JOB
	REM elimina el contenido de la carpeta temporal y la vuelve a crear
	if exist %FolderIn_HandleCustom% rd /s /q %FolderIn_HandleCustom% > NUL
	REM vuelve a crear la carpeta temporarl
	if not exist %FolderIn_HandleCustom% md %FolderIn_HandleCustom% > NUL

	rem baja el contenido de la actividad %cargar la actividad%
	setlocal disabledelayedexpansion
rem	dm get --directory %FolderIn_HandleCustom% --requestId %ACTIVIDAD% --user %User_Dim% --password %Pass_Dim% --database Galicia@Dimensions --server Dimensions1 > NUL
	dm get --FILE %CUSTOM_NAME% --directory %FolderIn_HandleCustom% --user %User_Dim% --password %Pass_Dim% --database Galicia@Dimensions --server Dimensions1	
	setlocal EnableDelayedExpansion

	rem Si se trata de una modificación (Modify_Custom chequeado), verifica que el archivo exista en la ACTIVIDAD.
	echo modificar custom
rem	dm get %CUSTOM_NAME% --directory %FolderIn_HandleCustom% --user %User_Dim% --password %Pass_Dim% --database Galicia@Dimensions --server Dimensions1 > nul
	
	echo %FolderIn_HandleCustom%%CUSTOM_NAME%
	if exist %FolderIn_HandleCustom%%CUSTOM_NAME% (
		echo se bajo de la actividad de dimensions el custom. Se procede a procesarlo
	) else (
		echo no se encontro en la ACTIVIDAD el archivo: %CUSTOM_NAME%
		exit /b 5
	)

REM ------------------------------- FIN Chequeso Avanzados C2 -------------------------------------------------------------

REM ------------------------------- Chequeso Avanzados C3 -------------------------------------------------------------
:l8

rem Procesamiento operacion 1
if "%OPERACION_1%"=="" (
	echo No se indico Operacion 1
	goto :Oper2
)
if "%URI_1%"=="" (
	echo No se indico URI correspondiente a la operacion 1
	goto :Oper2
)
		"C:\Program Files (x86)\Java\jre1.8.0_171\bin\java" -jar C:\Users\l0646482\n\mi_desa\Eclipse\CustomUpDate\CustomUpDate.jar %FolderIn_HandleCustom%%CUSTOM_NAME% %OPERACION_1% "%URI_1%"
		if not %errorlevel%==0 (
			if %errorlevel%==1 (
				echo Problemas con el archivo %FolderIn_HandleCustom%%CUSTOM_NAME%
			) 
			if %errorlevel%==2 (
				echo Error dentro del CustomUpDate.jar
			)
			if %errorlevel%==5 (
				echo Operacion %OPERACION_1%: No se encontro en el Custom especificado 
			)
			if %errorlevel%==9 (
				echo El programa CustomUpDate.jar recibio menos de tres parametros.
			)
			goto :Oper2
		)
		echo Operacion %OPERACION_1%: procesada exitosamente
		del %FolderIn_HandleCustom%%CUSTOM_NAME%
		copy %FolderIn_HandleCustom%%CUSTOM_NAME%.bck %FolderIn_HandleCustom%%CUSTOM_NAME% > nul
rem		del %FolderIn_HandleCustom%%CUSTOM_NAME%.bck

Rem procesamiento operacion 2
:Oper2
if "%OPERACION_2%"=="" (
	echo No se indico Operacion 2
	goto :Oper3
)
if "%URI_2%"=="" (
	echo No se indico URI correspondiente a la operacion 2
	goto :Oper3
)
		"C:\Program Files (x86)\Java\jre1.8.0_171\bin\java" -jar C:\Users\l0646482\n\mi_desa\Eclipse\CustomUpDate\CustomUpDate.jar %FolderIn_HandleCustom%%CUSTOM_NAME% %OPERACION_2% "%URI_2%"
		if not %errorlevel%==0 (
			if %errorlevel%==1 (
				echo Problemas con el archivo %FolderIn_HandleCustom%%CUSTOM_NAME%
			) 
			if %errorlevel%==2 (
				echo Error dentro del CustomUpDate.jar
			)
			if %errorlevel%==5 (
				echo Operacion %OPERACION_2%: No se encontro en el Custom especificado
			)
			if %errorlevel%==9 (
				echo El programa CustomUpDate.jar recibio menos de tres parametros.
			)
			goto :Oper3
		)
		echo Operacion %OPERACION_2%: procesada exitosamente
		del %FolderIn_HandleCustom%%CUSTOM_NAME%
		copy %FolderIn_HandleCustom%%CUSTOM_NAME%.bck %FolderIn_HandleCustom%%CUSTOM_NAME% > nul
		del %FolderIn_HandleCustom%%CUSTOM_NAME%.bck
		
Rem procesamiento operacion 3
:Oper3
if "%OPERACION_3%"=="" (
	echo No se indico Operacion 3
	goto :Oper_Last
)
if "%URI_3%"=="" (
	echo No se indico URI correspondiente a la operacion 3
	goto :Oper_Last
)
		"C:\Program Files (x86)\Java\jre1.8.0_171\bin\java" -jar C:\Users\l0646482\n\mi_desa\Eclipse\CustomUpDate\CustomUpDate.jar %FolderIn_HandleCustom%%CUSTOM_NAME% %OPERACION_3% "%URI_3%"
		if not %errorlevel%==0 (
			if %errorlevel%==1 (
				echo Problemas con el archivo %FolderIn_HandleCustom%%CUSTOM_NAME%
			) 
			if %errorlevel%==2 (
				echo Error dentro del CustomUpDate.jar
			)
			if %errorlevel%==5 (
				echo Operacion %OPERACION_3%: No se encontro en el Custom especificado
			)
			if %errorlevel%==9 (
				echo El programa CustomUpDate.jar recibio menos de tres parametros.
			)
			goto :Oper_Last
		)
		echo Operacion %OPERACION_3%: procesada exitosamente
		del %FolderIn_HandleCustom%%CUSTOM_NAME%
		copy %FolderIn_HandleCustom%%CUSTOM_NAME%.bck %FolderIn_HandleCustom%%CUSTOM_NAME% > nul
		del %FolderIn_HandleCustom%%CUSTOM_NAME%.bck

:Oper_Last

copy %FolderIn_HandleCustom%%CUSTOM_NAME% !Dimension_LocalCopy!%CUSTOM_NAME% > nul


goto :l9
echo Deliver a Dimension del Custom actualizado
rem dm deliver --stream CBUS_OSB:DESARROLLO DeployAutomatico --directory C:\Dimensions\Workspace2 --requestId %ACTIVIDAD% --user %USER_DIMENSION% --password %PASS_DIMENSION% --database Galicia@Dimensions --server Dimensions1
setlocal disabledelayedexpansion
dm deliver --stream CBUS_OSB:DESARROLLO !Dimension_LocalCopy!%CUSTOM_NAME% --directory %FolderIn_HandleCustom% --requestId %ACTIVIDAD% --user %User_Dim% --password %Pass_Dim% --database Galicia@Dimensions --server Dimensions1
setlocal EnableDelayedExpansion


exit 
:l9
setlocal disabledelayedexpansion
echo Add a Dimension de %Dimension_LocalCopy%%CUSTOM_NAME%
dm Add %Dimension_LocalCopy%%CUSTOM_NAME% --directory %Dimension_LocalCopy% --requestId %ACTIVIDAD% --user %User_Dim% --password %Pass_Dim% --database Galicia@Dimensions --server Dimensions1

echo Deliver a Dimension de xml de %Dimension_LocalCopy%%CUSTOM_NAME%
dm deliver --stream CBUS_OSB:DESARROLLO %Dimension_LocalCopy%%CUSTOM_NAME% --directory %Dimension_LocalCopy% --requestId %ACTIVIDAD% --user %User_Dim% --password %Pass_Dim% --database Galicia@Dimensions --server Dimensions1
setlocal EnableDelayedExpansion

exit /b



echo CustomUpDate.jar
"C:\Program Files (x86)\Java\jre1.8.0_171\bin\java" -jar C:\Users\l0646482\n\mi_desa\Eclipse\CustomUpDate\CustomUpDate.jar %FolderIn_HandleCustom%%CUSTOM_NAME% %OPERACION_2% "%URI_2%"
del %FolderIn_HandleCustom%%CUSTOM_NAME%
copy %FolderIn_HandleCustom%%CUSTOM_NAME%.bck %FolderIn_HandleCustom%%CUSTOM_NAME%
del %FolderIn_HandleCustom%%CUSTOM_NAME%.bck
echo END CustomUpDate.jar

echo CustomUpDate.jar
"C:\Program Files (x86)\Java\jre1.8.0_171\bin\java" -jar C:\Users\l0646482\n\mi_desa\Eclipse\CustomUpDate\CustomUpDate.jar %FolderIn_HandleCustom%%CUSTOM_NAME% %OPERACION_3% "%URI_3%"
del %FolderIn_HandleCustom%%CUSTOM_NAME%
copy %FolderIn_HandleCustom%%CUSTOM_NAME%.bck %FolderIn_HandleCustom%%CUSTOM_NAME%
del %FolderIn_HandleCustom%%CUSTOM_NAME%.bck
echo END CustomUpDate.jar


	setlocal disabledelayedexpansion
	dm get --directory %FolderIn_HandleCustom% --requestId %ACTIVIDAD% --user %User_Dim% --password %Pass_Dim% --database Galicia@Dimensions --server Dimensions1 > NUL
	setlocal EnableDelayedExpansion





























	set URI_1_sp=!URI_1:^&=amp;!
	echo URI_1_sp !URI_1_sp!
	set URI_2_sp=!URI_2:^&=amp;!
	echo URI_2_sp !URI_2_sp!
	set URI_3_sp=!URI_3:^&=amp;!
	echo URI_3_sp !URI_3_sp!


rem Procesa la primer operacion-URI
	set /a iCount_Operacion=0
	set tmp_URI=

	for /f "tokens=*" %%n in (%FolderIn_HandleCustom%%CUSTOM_NAME%) do (
		rem imprime solo las lineas que terminan con: /ObtenerRespuesta</xt:path>
		set tter=%%n
		set tter=!tter:^<xt:path^>=!
		set tter2=!tter:/%OPERACION_1%^</xt:path^>=!
		if !iCount_Operacion!==3 (
rem			echo !tter!
			set /a iCount_Operacion+=1
			for /f "tokens=1,2 delims=>" %%o in ("!tter!") do (
rem				echo rrr: %%p
				for /f "tokens=1,2 delims=<" %%q in ("%%p") do (
rem					echo qqqq: %%q
					set tmp_URI=%%q
rem					echo new primer uri= %%o^>%URI_1_sp%^<%%r^>
				)
			)
		)
		if !iCount_Operacion!==2 set /a iCount_Operacion+=1
		if not !tter!==!tter2! (
			set /a iCount_Operacion+=1
		)
	)
	
	set cadorig=%tmp_URI%
	echo cadorig %cadorig%
	set cadorig=%cadorig:"=%
	set cadsust=!URI_1_sp!
	echo cadsust !cadsust!
	set cadsust=!cadsust:"=!
	for %%f in (%FolderIn_HandleCustom%%CUSTOM_NAME%) do (call :cambiar_1 %%f)
	goto fin_Custom1
	:cambiar_1
	set archivo=%FolderIn_HandleCustom%%CUSTOM_NAME%
	for /f "tokens=* delims=" %%i in (%archivo%) do (set ANT=%%i&echo !ANT:%cadorig%=%cadsust%! >>%archivo%.bck1)

	goto :EOF
:fin_Custom1
	
	
rem FIN Procesa la primera operacion-URI

rem Procesa la segunda operacion-URI
	set /a iCount_Operacion=0
	set tmp_URI=

	for /f "tokens=*" %%n in (%FolderIn_HandleCustom%%CUSTOM_NAME%) do (
		rem imprime solo las lineas que terminan con: /ObtenerRespuesta</xt:path>
		set tter=%%n
		set tter=!tter:^<xt:path^>=!
		set tter2=!tter:/%OPERACION_2%^</xt:path^>=!
		if !iCount_Operacion!==3 (
rem			echo !tter!
			set /a iCount_Operacion+=1
			for /f "tokens=1,2 delims=>" %%o in ("!tter!") do (
rem				echo rrr: %%p
				for /f "tokens=1,2 delims=<" %%q in ("%%p") do (
rem					echo qqqq: %%q
					set tmp_URI=%%q
rem					echo new primer uri= %%o^>%URI_1_sp%^<%%r^>
				)
			)
		)
		if !iCount_Operacion!==2 set /a iCount_Operacion+=1
		if not !tter!==!tter2! (
			set /a iCount_Operacion+=1
		)
	)
	
	set cadorig=%tmp_URI%
	echo cadorig %cadorig%
	set cadorig=%cadorig:"=%
	set cadsust=!URI_2_sp!
	echo cadsust !cadsust!
	set cadsust=!cadsust:"=!
	for %%f in (%FolderIn_HandleCustom%%CUSTOM_NAME%.bck1) do (call :cambiar_2 %%f)
	goto fin_Custom2
	:cambiar_2
	set archivo=%FolderIn_HandleCustom%%CUSTOM_NAME%
	for /f "tokens=* delims=" %%i in (%archivo%.bck1) do (set ANT=%%i&echo !ANT:%cadorig%=%cadsust%! >>%archivo%.bck2)

	goto :EOF
:fin_Custom2
	
rem FIN Procesa la segunda operacion-URI

rem Procesa la tercera operacion-URI
	set /a iCount_Operacion=0
	set tmp_URI=

	for /f "tokens=*" %%n in (%FolderIn_HandleCustom%%CUSTOM_NAME%) do (
		rem imprime solo las lineas que terminan con: /ObtenerRespuesta</xt:path>
		set tter=%%n
		set tter=!tter:^<xt:path^>=!
		set tter2=!tter:/%OPERACION_3%^</xt:path^>=!
		if !iCount_Operacion!==3 (
rem			echo !tter!
			set /a iCount_Operacion+=1
			for /f "tokens=1,2 delims=>" %%o in ("!tter!") do (
rem				echo rrr: %%p
				for /f "tokens=1,2 delims=<" %%q in ("%%p") do (
rem					echo qqqq: %%q
					set tmp_URI=%%q
rem					echo new primer uri= %%o^>%URI_1_sp%^<%%r^>
				)
			)
		)
		if !iCount_Operacion!==2 set /a iCount_Operacion+=1
		if not !tter!==!tter2! (
			set /a iCount_Operacion+=1
		)
	)
	
	set cadorig=%tmp_URI%
	echo cadorig %cadorig%
	set cadorig=%cadorig:"=%
	set cadsust=!URI_3_sp!
	echo cadsust !cadsust!
	set cadsust=!cadsust:"=!
	for %%f in (%FolderIn_HandleCustom%%CUSTOM_NAME%.bck2) do (call :cambiar_3 %%f)
	goto fin_Custom3
	:cambiar_3
	set archivo=%FolderIn_HandleCustom%%CUSTOM_NAME%
	for /f "tokens=* delims=" %%i in (%archivo%.bck2) do (set ANT=%%i&echo !ANT:%cadorig%=%cadsust%! >>%archivo%.bck3)

	goto :EOF
:fin_Custom3
	
	for %%f in (%FolderIn_HandleCustom%%CUSTOM_NAME%.bck3) do (call :cambiar_33 %%f)
	goto fin_Custom33
	:cambiar_33
	set archivo=%FolderIn_HandleCustom%%CUSTOM_NAME%.bck3
	for /f "tokens=* delims=" %%i in (%FolderIn_HandleCustom%%CUSTOM_NAME%.bck3) do (set ANT=%%i&echo !ANT:amp;=^&amp;! >>%FolderIn_HandleCustom%%CUSTOM_NAME%.bck4)

	goto :EOF
	
:fin_Custom33	
rem FIN Procesa la tercera operacion-URI

	copy %FolderIn_HandleCustom%%CUSTOM_NAME%.bck3 %Dimension_LocalCopy%%CUSTOM_NAME% 
REM ------------------------------- FIN Chequeso Avanzados C3 -------------------------------------------------------------



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
		set tEntre=!tEntre:^\Entregables\=/!
rem		echo tEntre !tEntre!
		for /f "tokens=1,2 delims=/" %%s in ("!tEntre!") do (
rem			echo %%t

			set Tmp_Path=%%t
			set Tmp_Path=!Tmp_Path:.dm=!
			if %%t==!Tmp_Path! echo !Tmp_Path! 

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


