echo off

REM Esta es la version que esta corriendo en JENKINS
REM los parametros que recibe son tres:
REM		1 - path completo del repositorio donde se encuentra el entregable 
REM		2 - lista completa de los archivos que se suben  a dimensions y que conformaran el xml de deploy automatico, deben estar separados por ; y entre comillas.
REM			por ejemplo: "arch1.arj;arch2.arj;ar_custom.xml"
REM		3 - Numero de TO de SERENA
REM		4 - Numero de ACTIVIDAD de DIMENSIONS


Setlocal EnableDelayedExpansion

goto :main

========================================================================
:Chek_Ruta DirName
REM Verifica si existe en el repositorio local (workplace) el Framework\Servicio\Vx
REM Entrada: Framework\Servicio\Version
REM Salida: Si la ruta existe retorna 		0
REM Salida: Si la ruta NO existe retorna 	1

	SET "DirName=%~1"
	SETLOCAL ENABLEEXTENSIONS
	SET DirName=C:\Dimensions\Workspace2\%DirName% 
If exist "%DirName%" (
  REM El archivo existe...
  echo existe %DirName%
  exit /b 0
) ELSE (
   REM El archivo no existe...
  echo NO existe %DirName%
  exit /b  1
)
========================================================================
:Chek_Carpeta_Entregables FolderEntregables

	SETLOCAL ENABLEEXTENSIONS
	SET "FolderEntregables=%~1"
	SET FolderEntregables=%FolderEntregables%\Entregables
	If exist "%FolderEntregables%" (
	REM la carpeta existe
	echo existe %FolderEntregables%
	exit /b 0
	) ELSE (
		REM La carpeta no existe, va a crearla
		echo NO existe %FolderEntregables%
		MD %FolderEntregables%
		REM verifica si se pudo crear la carpeta
		If exist "%FolderEntregables%" (
		REM La carpeta se creo bien.
		echo Se creo %FolderEntregables%
		exit /b 0
		) ELSE (
		REM No se pudocrear la carpeta, avisa y termina con error.
		echo NO se pudo crear %FolderEntregables%
		exit /b  1
		)
	)
 
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
ECHO.%LEN%

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

:main

REM FIN de la verificacion de la existencia de la ruta ingresada. Si no existe termian, si existe continua con la ejecucion.
call :Chek_Ruta %1
IF NOT ERRORLEVEL 1 GOTO :DONE
      ECHO  Verificar el correcto de ingreso de la Ruta o que en el repositorio exista dicha ruta.
	  goto :FIN
:DONE

REM FIN de la verificacion de la existencia de la carpeta ENTREGABLES dentro del path del servicio sobre el que s eesta trabajando. Si no existe la crea.
SET ServPath=C:\Dimensions\Workspace2\%1 
call :Chek_Carpeta_Entregables %ServPath%
IF NOT ERRORLEVEL 1 GOTO :DONE2
      ECHO  No se pudo crear la carpeta ENTREGABLES dentro de la estructura del servicio %ServPath%.
	  goto :FIN
:DONE2


goto :FIN




REM Comienzo: crea xml y arma path
set sOutputFile=C:\Dimensions\Workspace2\DeployAutomatico\XMLImportJar_Homo1.xml
echo ^<import^> >> %sOutputFile%
echo			^<jar^> >> %sOutputFile%
set fpath=C:\Dimensions\Workspace2\
set fpath=%fpath:"=%
set recorte=/
set recorte=%recorte:"=%
REM set PAR=%CD%
REM set PAR=C:\Dimensions\Workspace2\ServiciosComunesProductos\AccionesOperatoriaContableSIAC\v1\Entregables
set PAR=%RUTA%/Entregables
set PAR=!PAR:%fpath%=%recorte%!
set PAR=!PAR:\=/!
REM FIN: crea xml y arma path
REM set inp=arsarasa1;arcaca2;artata3
set inp=%ARCHIVOS%
REM extrae el primer y ultimo caracter de los parametros ingresados, los cuale sse suponene que son comillas
REM set inp=%inp:~1,-1%
echo inp
echo %inp%
:repetir
for /f "tokens=1 delims=; " %%a in ("%inp%") do set out=%%a
echo out
echo %out%
REM escribe en el xml de deploy automatico
echo				^<path^>D:/Serena/SDA-AGENT/core/var/work/CBUS_OSB%PAR%/!out!^</path^> >> %sOutputFile%
call :param %out%
echo inp
echo %inp%
rem if not %out% == "%inp%" goto :repetir
if not "%inp%" == "~1" goto :repetir
REM carga numero d eTO en el XML
set ito=%TO%
echo				^<transferencia^>%ito%^</transferencia^> >> %sOutputFile%
	 		
echo			^</jar^>  >> %sOutputFile%
echo ^</import^>  >> %sOutputFile%
rem CALL :LENGHT 123456789
rem ECHO.%LEN%
:FIN