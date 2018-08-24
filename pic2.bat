
@echo off
Setlocal EnableDelayedExpansion

set cadorig=;;
echo %cadorig%
set cadsust=;m;
echo %cadsust%

rem for %%f in (%1) do (call :cambiar %%f)

FOR /L %%i IN (0,1,35) DO (call :cambiar %1)

goto columnas
:cambiar
set archivo=%1
for /f "tokens=* delims=" %%i in (%archivo%) do (set ANT=%%i&echo !ANT:%cadorig%=%cadsust%! >>kk_temp.txt)
copy /y kk_temp.txt %archivo%
del /q kk_temp.txt
goto :EOF
:Ayuda
Echo Reemplaza una cadena por otra en el contenido de archivos (con comodines)
echo Utiliza un archivo temporal kk_temp.txt que no debe existir previamente
echo Formato: %0 cadorig cadsust archivos
echo Si las cadenas contienen espacios deben escribirse entrecomilladas
echo No funciona si la cadena original contiene un "="
Echo Ejemplo:
echo %0 de DE *.txt
:Fin


:columnas
FOR /F "tokens=1,4,5,9,16 delims=;" %%i IN (pic0_1.csv) DO echo %%i %%j %%k %%l %%m >> mipic.txt