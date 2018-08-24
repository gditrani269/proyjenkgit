echo off
REM Esta version del Chc.bat parametriza los archivos de entrada y salida par aque se pueda usar como un .bat de servicios desde cualquier lugar.

REM salida:
REM	0:	Ok
REM	1:	Hay mas de un fwk/servicio en la actividad
REM	2:	Si no existe la ACTIVIDAD en Dimension
REM 3:  No se pudo conectar a Dimensions
REM 4:  La actividad esta vacia.
setlocal EnableDelayedExpansion
set sPathWork=%HOMEDRIVE%%HOMEPATH%
set sal=0
rem set ACTIVIDAD=0
set bError=0
set fSalida=salida_%BUILD_NUMBER%.txt
set fStatus=status_%BUILD_NUMBER%.txt
rem set fMail_Report=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\MailReport_%BUILD_NUMBER%.txt
set fMail_Report=MailReport.txt
if exist %fMail_Report% del %fMail_Report%


rem	set ACTIVIDAD=CBUS_OSB_ACTIVIDAD_1388

echo ACTIVIDAD: %ACTIVIDAD%

Rem Verifica si existe la actividad:  
if exist Act_Temp.txt del Act_Temp.txt
dmcli -user %User_Dim% -pass %Pass_Dim% -host Dimensions1 -dbname Galicia -dsn Dimensions reqc %ACTIVIDAD% >> Act_Temp.txt


rem si el tamaño del archivo de salida de la conexion a dimension es cero no se puddo conectar a dimension, se debe abortar
set size=0
for %%A in (Act_Temp.txt) do set size=%%~zA 
echo SIZE: %size%
if %size%==0 (
rem	Echo No se pudo conectar a Dimensions, fin del Job.
	exit /b 3
)


set act_exist=Act_Temp.txt
for /f "tokens=*" %%x in ('findstr "%ACTIVIDAD%" %act_exist%') do (
	REM echo no existe la actividad: %ACTIVIDAD%
	exit /b 2
)

echo ACTIVIDAD: %ACTIVIDAD% >> %fSalida%


dmcli -user %User_Dim% -pass %Pass_Dim% -host Dimensions1 -dbname Galicia -dsn Dimensions log /LOGFILE="l.txt" >> NULL

echo Contenido del "deliver" de la transaccion (version): %version%

for /f "tokens=*" %%i in (l.txt) do (
	set sTer=%%i
	rem  echo !sTer!
	for /f "tokens=1" %%j in ("!sTer!") do (
		if "%%j"=="%version%" (set sal=1)
		if "!sal!"=="1" (
			echo %%i
			echo %%i  >> %fSalida%

			rem guarda la actividad del changeset
			for /f "tokens=7" %%b in ("%%i") do (
				if not "%%b"=="" set ACTIVIDAD=%%b
			)
			
			if %%j == ------------------------------------------------------------------------ (
				set sal=0
			)
		)
	)
)

rem temporal

if exist !sPathWork!filelist.txt del !sPathWork!filelist.txt

dmcli -user %User_Dim%  -pass %Pass_Dim%  -host Dimensions1 -dbname Galicia -dsn Dimensions log /CHANGE_DOC_ID=!ACTIVIDAD! /LOGFILE="!sPathWork!filelist.txt" >> NULL

rem type C:\Users\l0646482\n\mi_desa\jenkins\jobs\ChangeSet\filelist.txt.txt
	 
:invertir
rem la siguietne actividad contiene un renombramiento de carpeta
rem set ACTIVIDAD=CBUS_OSB_ACTIVIDAD_1411
copy !sPathWork!filelist.txt !sPathWork!filelist_bck.txt >> NUL

if exist !sPathWork!invert.txt del !sPathWork!invert.txt
IF EXIST !sPathWork!file_tmp.txt del !sPathWork!file_tmp.txt

set sLasLine=
set bCtrol=0

for /f "tokens=*" %%y in (!sPathWork!filelist.txt) do (
	set bCtrol=0
	for /f "tokens=*" %%z in (!sPathWork!filelist_bck.txt) do (
		if "!bCtrol!"=="1" (
			echo !sLasLine! >> !sPathWork!file_tmp.txt
		)
		set bCtrol=1
		set sLasLine=%%z
	)
	del !sPathWork!filelist_bck.txt
	IF EXIST !sPathWork!file_tmp.txt copy !sPathWork!file_tmp.txt !sPathWork!filelist_bck.txt  >> NUL
	IF EXIST !sPathWork!file_tmp.txt del !sPathWork!file_tmp.txt
	echo !sLasLine! >> !sPathWork!invert.txt
)	


Rem procesa el archivo invert.txt. Lo que hace es tomar solo las lineas que tiene seteados en el primer campo los flags:
Rem C (cambio), M (modificacion), R (borrado) y PR (renombrado) y tambien tienen el ultimo campo indicado en forma explicita una actividad,
rem las lineas que cumplen estas condificiones las copia en el archivo invert2.txt
rem Excepcion: si el segundo flag es "D" se trata de una carpeta entonces esta linea NO LA COPIA al invert2.txt

rem set ACTIVIDAD=CBUS_OSB_ACTIVIDAD_1388
if exist !sPathWork!invert2.txt del !sPathWork!invert2.txt


	Rem procesa el flag "C"
	for /f "tokens=1,3,5,7,9" %%u in (!sPathWork!invert.txt) do (
		if not "%%v"=="D" (rem si el segundo flag no es "D" no es una carpeta, entonces procesa la linea
			if "%%u"=="C" (
				if "%%x"=="!ACTIVIDAD!" (
					for /f "tokens=1 delims=;" %%m in ("%%w") do (
						echo C %%m >> !sPathWork!invert2.txt
					)
				)
			)

			if "%%u"=="M" (
				if "%%x"=="!ACTIVIDAD!" (
					for /f "tokens=1 delims=;" %%m in ("%%w") do (
						echo M %%m >> !sPathWork!invert2.txt
					)
				)
			)

			if "%%u"=="R" (
				if "%%x"=="!ACTIVIDAD!" (
					for /f "tokens=1 delims=;" %%m in ("%%w") do (
						echo R %%m >> !sPathWork!invert2.txt
					)
				)
			)
			
			if "%%u"=="PR" (
				if "%%y"=="!ACTIVIDAD!" (
					for /f "tokens=1 delims=;" %%m in ("%%x") do (
						echo PR %%w %%m >> !sPathWork!invert2.txt
					)
				)
			)
		) else (rem el segundo flag es "D", verifica si renombro una carpeta
			if "%%u"=="PM" (
				echo renombro una carpeta, tambien se debe copiar
				if "%%y"=="!ACTIVIDAD!" (
					for /f "tokens=1 delims=;" %%m in ("%%x") do (
						echo PM %%w %%m >> !sPathWork!invert2.txt
					)
				)
			)
		)
	)

rem procesa las lineas con el flag PR. Toma el archivo invert2.
Rem En las linea con flag PR, al primer nombre de archivo le cambia el flag por ON (original name)
Rem En las linea con flag PR, el segundo nombre de  archivo le cambia el flag por NN (new name)
REM En las lineas con falg PM, al primer nombre de archivo le cambia el flag por CO (Carpeta original )
REM En las lineas con falg PM, al segundo nombre de archivo le cambia el flag por NN (Carpeta original )
rem salida: invert3.txt
if exist !sPathWork!invert3.txt del !sPathWork!invert3.txt
	for /f "tokens=1,2,3" %%u in (!sPathWork!invert2.txt) do (
		if "%%u"=="PR" (
			echo ON %%v >> !sPathWork!invert3.txt
			echo NN %%w >> !sPathWork!invert3.txt
				
		) else (
			if "%%u"=="PM" (
				echo CO %%v >> !sPathWork!invert3.txt
				echo NN %%w >> !sPathWork!invert3.txt
			) else (
				echo %%u %%v >> !sPathWork!invert3.txt
			)
		)
	)

	rem recorre el archivo invert3.txt, si encuentra flag R u ON, elimina esa linea y todas las que vienen despues que tennga nel mismo nombre de archivo.
rem recorre el archivo invert3.txt, si encuentra flag C, M o NN guarda esa linea en el archivo invert4.txt per elimina las lineas siguientes
IF EXIST !sPathWork!invert4.txt del !sPathWork!invert4.txt
rem del !sPathWork!invert4.txt

IF NOT EXIST !sPathWork!invert3.txt GOTO :ACT_VACIA

copy !sPathWork!invert3.txt !sPathWork!invert4.txt >> NUL
set tFlag=flag_desconocido
set inv3_field2=

for /f "tokens=1,2" %%r in (!sPathWork!invert3.txt) do (
	IF EXIST !sPathWork!tmp_inv4.txt del !sPathWork!tmp_inv4.txt
	rem del !sPathWork!tmp_inv4.txt

	if "%%r"=="R" (
		set tFlag=borrar
	)
	if "%%r"=="ON" (
	set tFlag=borrar
	)
	if "%%r"=="CO" (
	set tFlag=borrar_carpeta
	)
	if "%%r"=="C" (
	set tFlag=copiar
	)
	if "%%r"=="M" (
	set tFlag=copiar
	)
	if "%%r"=="NN" (
	set tFlag=copiar
	)
	if "tFlag"=="flag_desconocido" (
		echo flag invalido: %%r
		goto :flag_invalido
	)
	set inv3_field2=%%s
	


	for /f "tokens=1,2" %%t in (!sPathWork!invert4.txt) do (
		if "!tFlag!"=="borrar_carpeta" (
					rem set lin=!lin:^:policy-expression^>= !
					rem verifica si se renombro una carpeta
						set sTemp=%%u
	 					set sTemp=!sTemp:%%s=!
						if not "%%u"=="!sTemp!" (
rem 							echo u==sTemp: !sTemp!
						) else (
							echo %%t %%u >> !sPathWork!tmp_inv4.txt
						)
		) else (
			if "!inv3_field2!"=="%%u" (
				if "!tFlag!"=="borrar" (
					rem
	rem				echo no hace nada porque es un flag borrar
				)
				if "!tFlag!"=="copiar" (
					echo %%t %%u >> !sPathWork!tmp_inv4.txt 
					rem cambia tFlag a borrar para que ignore el resto de las lineas del mismo nombre
					set tFlag=borrar
				)
				
			) else (
				echo %%t %%u >> !sPathWork!tmp_inv4.txt
			)
		)
	)	
	
	IF EXIST !sPathWork!invert4.txt del !sPathWork!invert4.txt 
	IF EXIST !sPathWork!tmp_inv4.txt copy !sPathWork!tmp_inv4.txt !sPathWork!invert4.txt >> NUL
)

IF NOT EXIST !sPathWork!invert4.txt GOTO :ACT_VACIA

rem ----------- detecta si hay mas de un fwk/serv en la actividad

Echo ------------------------------------------- 
rem Echo	Comienza analisis de !sPathWork!invert4.txt para verificar Frameworks incluidos en la actividad

set vFwkTrue=0

for /f "tokens=*" %%k in (!sPathWork!invert4.txt) do (
	set sTer2=%%k
rem	echo Linea: !sTer2!
rem			echo Linea a ser procesada: !sTer2!
			for /f "tokens=2" %%m in ("!sTer2!") do (
				set fwk=%%m
rem		 		echo fwk !fwk!
		rem	Verifica si la linea esta relacionada al fwk: DeployAutomatico, si es asi la ignora y sigue adelante
				IF /i NOT "!fwk:DeployAutomatico=!"=="!fwk!" (
rem						Echo String not found.
				) ELSE (
rem					Echo String SI found.
		rem		la linea corresponde a un item en dimension, por lo que va a verificar a que fwk/serv corresponde
						for /f "tokens=1,2 delims=/" %%c in ("!fwk!") do (
		rem					set fwk_serv=%%c/%%d
		rem					echo c-d %%c/%%d
							if "!vFwkTrue!"=="0" (
		rem						echo vFwkTrue !vFwkTrue!
								set vFwkTrue=1
								set fwk_serv=%%c/%%d
							) ELSE (
		rem						echo vFwkTrue !vFwkTrue!
		rem						echo fwk_serv !fwk_serv!
								if "%%c/%%d"=="!fwk_serv!" (
		rem							echo frameworek ok
								) ELSE (
									echo Hay mas de un FRAMEWORK en la actividad
									echo Hay mas de un FRAMEWORK en la actividad. >> %fSalida%
									Echo Primer Fwk/Serv detectado:	!fwk_serv!
									echo Primer Fwk/Serv detectado:	!fwk_serv! >> %fSalida%
									Echo Nuevo  Fwk/Serv encontrado: %%c/%%d
									echo Nuevo  Fwk/Serv encontrado: %%c/%%d >> %fSalida%
									Echo -------------------------------------------
									echo ------------------------------------------- >> %fSalida%
									set bError=1
								)
							)
						)
					
				)
			)
)
rem echo crea archivo !ACTIVIDAD!-%version%.txt
copy !sPathWork!invert4.txt !sPathWork!!ACTIVIDAD!-%version%.txt >> NUL
:fin

echo %bError% >> %fStatus%

IF "%bError%"=="1" (
rem	echo FIN con ERROR: hay mas de un framework en la actividad: %ACTIVIDAD%.
	echo FIN con ERROR: hay mas de un framework en la actividad: %ACTIVIDAD%. >> %fSalida%
	echo FWK=Fail>> %fMail_Report%
	) ELSE (
	echo FIN OK: la actividad esta en orden.
	echo FIN OK: la actividad esta en orden. >> %fSalida%
	echo FWK=OK>> %fMail_Report%
)

rem exit %bError%
exit /b %bError%

:ACT_VACIA
set bError=4
echo %bError% >> %fStatus%

rem echo La activiadad !ACTIVIDAD! esta vacia.
rem echo FIN OK: la actividad esta en orden.
echo FWK=Actividad_Vacia>> %fMail_Report%

rem exit %bError%
exit /b %bError%