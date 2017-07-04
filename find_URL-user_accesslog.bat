echo off
rem previemante ejecutar la extraccion con el comando:
rem  D:\n\IC\Jenkins>type sasa.txt | find /i "/consultapromociones/basica" >> texto.txt
rem  esto busca todas la lineas en el archivo sasa.txt que contengan el string "/consultapromociones/basica", y esas las lineas las almacena en texto.txt
rem  despues correr el bat de abajo, el cual toma el archivo texto.txt, extrae la segunda columna, la ordenas y luego elimina los registro repetidos y consecutivos

rem echo  >> f_u.txt

setlocal
set usuarios=

for /f "tokens=2" %%b in (texto.txt) do (
	echo %%b >> f_u.txt

)

sort f_u.txt >> f_u2.txt

@echo off
setlocal
for /f "tokens=*" %%s in (f_u2.txt) do (
	set "record=%%s"
	call :output
)
endlocal
goto :EOF
 
:output
if not defined prev_rec goto:write
if "%record%" EQU "%prev_rec%" goto:EOF
 
:write
@echo %record% >> final.txt
set "prev_rec=%record%"
 







