REM los parametros que recibe son tres:
REM		1 - path completo del repositorio donde se encuentra el entregable 
REM		2 - lista completa de los archivos que se suben  a dimensions y que conformaran el xml de deploy automatico, deben estar separados por ; y entre comillas.
REM			por ejemplo: "arch1.arj;arch2.arj;ar_custom.xml"
REM		3 - Numero de TO

echo off
Setlocal EnableDelayedExpansion

goto :main



========================================================================
 
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

REM Comienzo: crea xml y arma path
set sOutputFile=XMLImportJar_Homo1.xml

echo ^<import^> >> %sOutputFile%
echo			^<jar^> >> %sOutputFile%

set fpath=C:\Dimensions\Workspace2\
set fpath=%fpath:"=%
set recorte=/
set recorte=%recorte:"=%

REM set PAR=%CD%
REM set PAR=C:\Dimensions\Workspace2\ServiciosComunesProductos\AccionesOperatoriaContableSIAC\v1\Entregables
set PAR=%1
set PAR=!PAR:%fpath%=%recorte%!
set PAR=!PAR:\=/!

REM FIN: crea xml y arma path


REM set inp=arsarasa1;arcaca2;artata3
set inp=%2
REM extrae el primer y ultimo caracter de los parametros ingresados, los cuale sse suponene que son comillas
set inp=%inp:~1,-1%
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
set ito=%3
echo				^<transferencia^>%ito%^</transferencia^> >> %sOutputFile%
	 		

echo			^</jar^>  >> %sOutputFile%
echo ^</import^>  >> %sOutputFile%

rem CALL :LENGHT 123456789
rem ECHO.%LEN%



:FIN