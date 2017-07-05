echo off
rem previemante ejecutar la extraccion con el comando:
rem  D:\n\IC\Jenkins>type sasa.txt | find /i "/consultapromociones/basica" >> texto.txt
rem  esto busca todas la lineas en el archivo sasa.txt que contengan el string "/consultapromociones/basica", y esas las lineas las almacena en texto.txt
rem  despues correr el bat de abajo, el cual toma el archivo texto.txt, extrae la segunda columna, la ordenas y luego elimina los registro repetidos y consecutivos

rem echo  >> f_u.txt
type D:\n\IC\Jenkins\access\*.* | find /i "/consultapromociones/basica" >> url.txt

setlocal
set usuarios=

for /f "tokens=2" %%b in (url.txt) do (
	echo %%b >> f_u.txt

)
rem guarda la primera linea del archivo f_u.txt en la variable primera_linea

:repetir

set primera_linea=vacio
<"f_u.txt" set /p "primera_linea="

rem set "primera_linea" 
echo %primera_linea%

rem verifica si termino de revisar el archivo
if %primera_linea% EQU vacio goto :salir
echo %primera_linea% >> lista.txt

type f_u.txt | find /i /v "%primera_linea%" >> texto.txt
del f_u.txt
ren texto.txt f_u.txt
goto :repetir

:salir