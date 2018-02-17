echo off
setlocal EnableDelayedExpansion
set sPathWork=C:\Users\l0646482\n\mi_desa\jenkins\jobs\ChangeSet\
set sal=0
set ACTIVIDAD=0
set bError=0

dmcli -user l0646482 -pass saile245 -host Dimensions1 -dbname Galicia -dsn Dimensions log /LOGFILE="C:\Users\l0646482\n\mi_desa\jenkins\Carpeta-Out\l.txt"

echo Contenido del "deliver" de la transaccion (version): %version%

for /f "tokens=*" %%i in (C:\Users\l0646482\n\mi_desa\jenkins\Carpeta-Out\l.txt) do (
	set sTer=%%i
	rem  echo !sTer!
	for /f "tokens=1" %%j in ("!sTer!") do (
		if "%%j"=="%version%" (set sal=1)
		if "!sal!"=="1" (
			echo %%i

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
rem	set ACTIVIDAD=CBUS_OSB_ACTIVIDAD_1388

echo La ACTIVIDAD es: %ACTIVIDAD%

rem echo El contenido completo de la actividad es:

del !sPathWork!filelist.txt

dmcli -user l0646482  -pass saile245  -host Dimensions1 -dbname Galicia -dsn Dimensions log /CHANGE_DOC_ID=!ACTIVIDAD! /LOGFILE="!sPathWork!filelist.txt"

rem type C:\Users\l0646482\n\mi_desa\jenkins\jobs\ChangeSet\filelist.txt.txt
	 
:invertir
copy !sPathWork!filelist.txt !sPathWork!filelist_bck.txt >> NUL

del !sPathWork!invert.txt
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
del !sPathWork!invert2.txt


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
		)
	)

rem procesa las lineas con el flag PR. Toma el archivo invert2.
Rem En las linea con flag PR, al primer nombre de archivo le cambia el flag por ON (original name)
Rem En las linea con flag PR, el segundo nombre de  archivo le cambia el flag por NN (new name)
rem salida: invert3.txt
del !sPathWork!invert3.txt
	for /f "tokens=1,2,3" %%u in (!sPathWork!invert2.txt) do (
		if "%%u"=="PR" (
			echo ON %%v >> !sPathWork!invert3.txt
			echo NN %%w >> !sPathWork!invert3.txt
				
		) else (
			echo %%u %%v >> !sPathWork!invert3.txt
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
									Echo Primer Fwk/Serv detectado:	!fwk_serv!
									Echo Nuevo  Fwk/Serv encontrado: %%c/%%d
									Echo -------------------------------------------
									set bError=1
								)
							)
						)
					
				)
			)
)
copy !sPathWork!invert4.txt !sPathWork!!ACTIVIDAD!-%version%.txt >> NUL
:fin

IF "%bError%"=="1" (
	echo FIN con ERROR: hay mas de un framework en la actividad: %ACTIVIDAD%.
) ELSE (
	echo FIN OK: la actividad esta en orden.
)

exit %bError%

:ACT_VACIA

echo La activiadad !ACTIVIDAD! esta vacia.
echo FIN OK: la actividad esta en orden.

exit %bError%