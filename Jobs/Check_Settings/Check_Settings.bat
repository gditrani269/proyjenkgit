echo off
setlocal enabledelayedexpansion

set ACTIVIDAD=
set report=

REM ---------- Variables de salida ---------------
set timeout=30
set connection-timeout=5
set retry-count=0
set retry-interval=0
set chunked=false
set request-encoding=0
set bError=0
REM ----------- FIN variables de salida ----------

REM ----------- archivos de log ------------------
rem set file_us=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\salida_%Padre_BUILD_NUMBER%.txt
rem set fStatus=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\status_%Padre_BUILD_NUMBER%.txt
set file_us=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\salida_%BUILD_NUMBER%.txt
set fStatus=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\status_%BUILD_NUMBER%.txt
rem set fMail_Report=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\MailReport_%BUILD_NUMBER%.txt
set fMail_Report=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\MailReport.txt
set fSalida=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\salida_%BUILD_NUMBER%.txt
set fMail_Adress=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Settings\Mail_Address.txt
REM ----------- FIN archivos de log ------------------


REM obtiene el numero de actividad que disparo la cadena de JOBs
for /f "tokens=1,2" %%y in ('findstr "ACTIVIDAD:" %file_us%') do (
	set ACTIVIDAD=%%z
	echo actividad !ACTIVIDAD!
)

REM elimina el contenido de la carpeta temporal y la vuelve a crear
rd /s /q C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Settings\Items_Temp
REM vuelve a crear la carpeta temporarl
md C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Settings\Items_Temp
rem baja el contenido de la actividad %cargar la actividad%

dm get --directory C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Settings\Items_Temp  --requestId !ACTIVIDAD! --user l0646482 --password saile246 --database Galicia@Dimensions --server Dimensions1


set path_inicial=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Settings\Items_Temp
rem set str_a_buscar=^<http:timeout^>0^</http:timeout^>
set str_a_buscar=http:chunked-streaming-mode
set arch_salida=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Settings\car.txt
set user_a_buscar=:policy-expression


del %arch_salida%


rem echo path raiz donde buscar: %path_inicial%
rem echo cadena a buscar: "%str_a_buscar%"
rem echo archivo de salida: %arch_salida%

REM busca los business
findstr /S /M /c:%str_a_buscar% %path_inicial%\*.* >> %arch_salida%

REM busca el proxy basica
rem findstr /S /M /c:"/accionescelulargo/basica" C:\shared\ultimo\consolaosbb_20170421\*.* >> out_fnd.txt 
findstr /S /M /c:%user_a_buscar% %path_inicial%\*.* >> %arch_salida% 


REM va a buscar los campos especificos de timeout, reconet, ect.
REM        <http:timeout>0</http:timeout>
REM        <http:connection-timeout>0</http:connection-timeout>
REM        <tran:retry-count>0</tran:retry-count>
REM        <tran:retry-interval>0</tran:retry-interval>
REM        <http:chunked-streaming-mode>true</http:chunked-streaming-mode>

REM entre los TAGS: <con3:policy-expression>  y  </con3:policy-expression>

REM Control de camios
REM el 11-07-2017 se modificaron los tags de busqueda y reemplazo <con3, ya que en algunos archivos aparece como: <con5
REM por este motivo se modifico el criterio de busqueda y remplazo a: ":policy-expression>"
rem set file_us=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Settings\settings.txt

rem echo el archivo contendor con SETTING encontrados es: %file_us%

rem del %file_us%
rem set arch_salida=D:\n\IC\Jenkins\consolas\consolaosbb-new_20170421\ApoyoYSoporteALaEntidad\ConsultaGestionDocumental\V1\ProxyService\ConsultaGestionDocumental-1.0.0_Basica.ProxyService


for /f "delims=" %%a in (%arch_salida%) do (

	echo %%a >> %file_us%

REM ----------------------------------------------------------------------------------------
REM -----------------------  INICIO Chequeos eb bussines -----------------------------------
REM ----------------------------------------------------------------------------------------
	REM        http:timeout
	for /f "tokens=* delims=:timeout>" %%x in ('findstr ":timeout>" %%a') do (
		for /f "tokens=1,2 delims=http:timeout>" %%c in ("%%x") do (
rem			echo %%c %%d
			set timeout=%%d
			set timeout=!timeout:^</=!
			echo timeout: !timeout! >> %file_us%
		)
	)
	
	REM        http:connection-timeout
	for /f "tokens=* delims=:connection-timeout>" %%x in ('findstr ":connection-timeout>" %%a') do (
		for /f "tokens=1,2 delims=http:connection-timeout>" %%c in ("%%x") do (
			set connection-timeout=%%d
			set connection-timeout=!connection-timeout:^</=!
			echo connection-timeout: !connection-timeout! >> %file_us%
		)
	)

	REM        retry-count
	for /f "tokens=* delims=:retry-count>" %%x in ('findstr ":retry-count>" %%a') do (
		for /f "tokens=1,2 delims=tran:retry-count>" %%c in ("%%x") do (
			set retry-count=%%d
			set retry-count=!retry-count:^</=!
			echo retry-count: !retry-count! >> %file_us%
		)
	)

	REM        retry-interval
	for /f "tokens=* delims=:retry-interval>" %%x in ('findstr ":retry-interval>" %%a') do (
		for /f "tokens=1,2 delims=tran:retry-interval>" %%c in ("%%x") do (
			set retry-interval=%%d
			set retry-interval=!retry-interval:^</=!
			echo retry-interval: !retry-interval! >> %file_us%
		)
	)

	REM        chunked-streaming-mode
	for /f "tokens=* delims=:chunked-streaming-mode>" %%x in ('findstr ":chunked-streaming-mode>" %%a') do (
rem        <http:chunked-streaming-mode>true</http:chunked-streaming-mode>
			set chunked=%%x
rem			echo %%x
			set chunked=!chunked:true= !
rem 		echo !chunked!
			if "%%x"=="!chunked!" (
				set chunked=false
			) else (
				set chunked=true
			)
			echo chunked-streaming-mode: !chunked! >> %file_us%
	)
REM ----------------------------------------------------------------------------------------
REM -----------------------  FIN Chequeos eb bussines --------------------------------------
REM ----------------------------------------------------------------------------------------
	
REM ----------------------------------------------------------------------------------------
REM -----------------------  INICIO Chequeos en proxy anonimos -----------------------------
REM ----------------------------------------------------------------------------------------
	REM        retry-interval
	for /f "tokens=* delims=:request-encoding>" %%x in ('findstr ":request-encoding>" %%a') do (
		for /f "tokens=1,2 delims=sock:request-encoding>" %%c in ("%%x") do (
			set request-encoding=%%d
			set request-encoding=!request-encoding:^</=!
			echo request-encoding: !request-encoding! >> %file_us%
		)
	)
	
REM ----------------------------------------------------------------------------------------
REM -----------------------  FIn Chequeos en proxy anonimos --------------------------------
REM ----------------------------------------------------------------------------------------
	
	REM 	revisa el proxy basica en busca del user 99, falta terminar
	for /f "tokens=* delims=:policy-expression>" %%x in ('findstr ":policy-expression>" %%a') do (
		rem echo %%x
		set lin=%%x
		rem set linea=!linea:^<^= !
		set lin=!lin:^:policy-expression^>= !
		set lin=!lin:^:policy-expression^>= !
	rem	echo !lin!
		echo !lin! >> %file_us%
	)

)

	IF not "!timeout!"=="30" (
		set bError=1
		echo timeout !timeout!
	)
	if not "!connection-timeout!"=="5" (
		set bError=1
		echo connection-timeout !connection-timeout!
	)
	if not "!retry-count!"=="0" (
		set bError=1
		echo retry-count !retry-count!
	)
	if not "!retry-interval!"=="0" (
		set bError=1
		echo retry-interval !retry-interval!
	)
	if "!chunked!"=="true" (
		set bError=1
		set chunked !chunked!
	)

echo bError= !bError!

rem si bError es 0 deja el archivo fStatus como esta. Si bError es 1, borra el archivo fStatus y lo cre cargandole un 1 para indicar el error.
rem ---------------------------------------------------

for /f "tokens=*" %%y in (%fMail_Report%) do (
	set report=%%y
)
del %fMail_Report%


rem ---------------------------------------------------

if "!bError!"=="1" (
		del %fStatus%
		echo !bError! >> %fStatus%
		echo %report%---BS=Fail >> %fMail_Report%
	) else (
		echo %report%---BS=OK >> %fMail_Report%
	)

REM ----- 1 - Recupera el ID del usuario que realizo el cambio en la ACTIVIDAD ---------------------------------------------
REM ----- 2 - Con el Id del usuario busca en el archivo Mail_Address.txt la direccion de mail que le corresponde -----------
REM ----- 3 - Guarda enel archivo MailReport.txt bajo la clave MAIL --------------------------------------------------------
for /f "tokens=3" %%x in (%fSalida%) do (
	if "!sUser!" == "" (
		set sUser=%%x
	)
)
echo ID de usuario de la ACTIVIDAD: %sUser%

for /f "tokens=3" %%t in ('findstr "%sUser%" %fMail_Adress%') do (
	echo MAIL: %%t
	echo MAIL=%%t>> %fMail_Report%

)



REM -------------------------------------- FIN 1, 2 y 3 --------------------------------------------------------------------

echo ----FIN Check_Settings.bat

exit 0