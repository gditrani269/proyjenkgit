echo off
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
set inp=arsarasa1;arcaca2;artata3

:repetir
for /f "tokens=1 delims=; " %%a in ("%inp%") do set out=%%a

echo out
echo %out%
@ECHO OFF

call :param %out%

echo inp
echo %inp%

rem if not %out% == "%inp%" goto :repetir
if not "%inp%" == "~1" goto :repetir

rem CALL :LENGHT 123456789
rem ECHO.%LEN%



:FIN