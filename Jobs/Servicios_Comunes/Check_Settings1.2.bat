echo off
setlocal enabledelayedexpansion

REM setea la carpeta de trabajo, a partir de la cual se van a verificar los settings
set Items_Temp=%1

REM salida:
REM	0:	Ok
REM	1:	Hay mal un setting

set ACTIVIDAD=
set report=

REM ---------- Variables de salida ---------------
set timeout=30
set /A Counter_timeout=0
set connection-timeout=5
set /A Counter_connection_timeout=0
set retry-count=0
set /A Counter_retry_count=0
set retry-interval=0
set /A Counter_retry_interval=0
set chunked=false
set /A Counter_chunked=0
set dispatch-policy=false
set /A Counter_dispatch_policy=0
set request-encoding=0
set /A Counter_request_encoding=0
set response-encoding=0
set /A Counter_response_encoding=0
set compression=0
set bError=0
REM ----------- FIN variables de salida ----------
echo fin inicializado
REM ----------- archivos de log ------------------
rem set file_us=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\salida_%Padre_BUILD_NUMBER%.txt
rem set fStatus=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Check_Final\status_%Padre_BUILD_NUMBER%.txt
set file_us=salida_%BUILD_NUMBER%.txt
set fStatus=status_%BUILD_NUMBER%.txt
rem El archivo MaliReport.txt se crea en el proceso chs.bat
set fMail_Report=MailReport.txt
set fSalida=salida_%BUILD_NUMBER%.txt
set fMail_Adress=Mail_Address.txt
REM ----------- FIN archivos de log ------------------


set path_inicial=%Items_Temp%
rem set str_a_buscar=^<http:timeout^>0^</http:timeout^>
REM define el patron para identificar cuales archivos son BUSINESS
set str_a_buscar=http:chunked-streaming-mode
set list_of_Business=BusinessList.txt
set arch_salida=car.txt
REM define el patron para identificar cuales archivos son PROXYS
set user_a_buscar=:policy-expression
REM define el patron para identificar cuales archivos son PROXYS ANONIMOS de SOCKETS
set encoding_CP=:request-encoding

if exist %list_of_Business% del %list_of_Business%
if exist %arch_salida% del %arch_salida%


rem echo path raiz donde buscar: %path_inicial%
rem echo cadena a buscar: "%str_a_buscar%"
rem echo archivo de salida: %arch_salida%

REM busca los business
findstr /S /M /c:%str_a_buscar% %path_inicial%\*.* >> %list_of_Business%
rem findstr /S /M /c:%str_a_buscar% %path_inicial%\*.* >> %arch_salida%

REM busca el proxy basica
rem findstr /S /M /c:"/accionescelulargo/basica" C:\shared\ultimo\consolaosbb_20170421\*.* >> out_fnd.txt 
findstr /S /M /c:%user_a_buscar% %path_inicial%\*.* >> %arch_salida% 

REM busca el proxy anonimos de los sockets
findstr /S /M /c:%encoding_CP% %path_inicial%\*.* >> %arch_salida% 

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

for /f "delims=" %%b in (%list_of_Business%) do (
	echo %%b >> %file_us%


REM ----------------------------------------------------------------------------------------
REM -----------------------  INICIO Chequeos eb bussines -----------------------------------
REM ----------------------------------------------------------------------------------------
	REM        http:timeout
	for /f "tokens=* delims=:timeout>" %%x in ('findstr "http:timeout>" %%b') do (
		for /f "tokens=1,2 delims=http:timeout>" %%c in ("%%x") do (
rem			echo %%c %%d
			set timeout=%%d
			set timeout=!timeout:^</=!
		)
		IF not "!timeout!"=="30" (
			set bError=1
			echo timeout !timeout!
			echo timeout: !timeout! >> %file_us%
			set /A Counter_timeout+=1
		)
	)
	
	REM        http:connection-timeout
	for /f "tokens=* delims=:connection-timeout>" %%x in ('findstr ":connection-timeout>" %%b') do (
		for /f "tokens=1,2 delims=http:connection-timeout>" %%c in ("%%x") do (
			set connection-timeout=%%d
			set connection-timeout=!connection-timeout:^</=!
		)
		if not "!connection-timeout!"=="5" (
			set bError=1
			echo connection-timeout !connection-timeout!
			echo connection-timeout: !connection-timeout! >> %file_us%
			set /A Counter_connection_timeout+=1
		)
	)

	REM        retry-count
	for /f "tokens=* delims=:retry-count>" %%x in ('findstr ":retry-count>" %%b') do (
		for /f "tokens=1,2 delims=tran:retry-count>" %%c in ("%%x") do (
			set retry-count=%%d
			set retry-count=!retry-count:^</=!
		if not "!retry-count!"=="0" (
			set bError=1
			echo retry-count !retry-count!
			echo retry-count: !retry-count! >> %file_us%
			set /A Counter_retry_count+=1
		)
		)
	)

	REM        retry-interval
	for /f "tokens=* delims=:retry-interval>" %%x in ('findstr ":retry-interval>" %%b') do (
		for /f "tokens=1,2 delims=tran:retry-interval>" %%c in ("%%x") do (
			set retry-interval=%%d
			set retry-interval=!retry-interval:^</=!
		)
		if not "!retry-interval!"=="0" (
			set bError=1
			echo retry-interval !retry-interval!
			echo retry-interval: !retry-interval! >> %file_us%
			set /A Counter_retry_interval+=1
		)
	)

	REM        chunked-streaming-mode
	for /f "tokens=* delims=:chunked-streaming-mode>" %%x in ('findstr ":chunked-streaming-mode>" %%b') do (
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
		if "!chunked!"=="true" (
			set bError=1
			echo chunked !chunked!
			echo chunked-streaming-mode: !chunked! >> %file_us%
			set /A Counter_chunked+=1
		)
	)
	
	REM Dispatch Policy : SBDefaultResponseWorkManager
	set dispatch-policy=false
	for /f "tokens=* delims=:dispatch-policy>" %%x in ('findstr ":dispatch-policy>" %%b') do (
		set dispatch-policy=true
	)
	 
	if !dispatch-policy!==false (
		set bError=1
		echo dispatch-policy: NO SE SETEO LA POLICY >> %file_us%
		set /A Counter_dispatch_policy+=1
	) else (
		echo dispatch-policy: SBDefaultResponseWorkManager >> %file_us%
	)
	
	

	

REM ----------------------------------------------------------------------------------------
REM -----------------------  FIN Chequeos eb bussines --------------------------------------
REM ----------------------------------------------------------------------------------------
)
for /f "delims=" %%a in (%arch_salida%) do (

	echo %%a >> %file_us%

REM ----------------------------------------------------------------------------------------
REM -----------------------  INICIO Chequeos en proxy anonimos -----------------------------
REM ----------------------------------------------------------------------------------------
	REM request-encoding

	for /f "tokens=* delims=:request-encoding>" %%x in ('findstr ":request-encoding>" %%a') do (
		for /f "tokens=1,2 delims=sock:request-encoding>" %%c in ("%%x") do (
			set request-encoding=%%d
			set request-encoding=!request-encoding:^</=!
		)
	REM Inicio de verificacion seteos de PROXYS anonimos de SOCKETS
		IF not "!request-encoding!"=="p284" (
			set bError=1
			echo request-encoding !request-encoding!
			echo request-encoding: !request-encoding! >> %file_us%
			set /A Counter_request_encoding+=1
		)
	)

	REM response-encoding
	for /f "tokens=* delims=:response-encoding>" %%x in ('findstr ":response-encoding>" %%a') do (
		for /f "tokens=1,2 delims=sock:response-encoding>" %%c in ("%%x") do (
			set response-encoding=%%d
			set response-encoding=!response-encoding:^</=!
		)
		IF not "!response-encoding!"=="284" (
			set bError=1
			echo response-encoding !response-encoding!
			echo response-encoding: !response-encoding! >> %file_us%
			set /A Counter_response_encoding+=1
		)
	REM Fin de verificacion seteos de PROXYS anonimos de SOCKETS
	)
	
REM ----------------------------------------------------------------------------------------
REM -----------------------  FIn Chequeos en proxy anonimos --------------------------------
REM ----------------------------------------------------------------------------------------
	
	REM 	revisa el proxy basica en busca del ussrm99m, falta terminar
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

	REM        http:compression
rem	echo verifica compression
rem	echo verifica compression  >>  %file_us%
	findstr /S /M /c:http:compression %path_inicial%\*.* >>  nul
	If %ERRORLEVEL% EQU 0 (
		set bError=1
		echo Hay al menos un TAG COMPRESSION >>  %file_us% 
		echo Hay al menos un TAG COMPRESSION
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


REM -------------------------------------- FIN 1, 2 y 3 --------------------------------------------------------------------

echo ----FIN Check_Settings.bat

echo Cantidad de Timeout mal: %Counter_timeout% >>  %file_us%
echo Cantidad de Counter timeout mal: %Counter_connection_timeout% >>  %file_us%
echo Cantidad de retry-count mal: %Counter_retry_count% >>  %file_us%
echo Cantidad de retry-interval mal: %Counter_retry_interval% >>  %file_us%
echo Cantidad de chunked mal: %Counter_chunked% >>  %file_us%
echo Cantidad de dispatch-policy mal: %Counter_dispatch_policy% >>  %file_us%
echo Cantidad de request-encoding mal: %Counter_request_encoding% >>  %file_us%
echo Cantidad de response-encoding mal: %Counter_response_encoding% >>  %file_us%


exit /b !bError!