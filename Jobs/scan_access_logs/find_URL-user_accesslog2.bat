echo off
rem previemante ejecutar la extraccion con el comando:
rem  D:\n\IC\Jenkins>type sasa.txt | find /i "/consultapromociones/basica" >> texto.txt
rem  esto busca todas la lineas en el archivo sasa.txt que contengan el string "/consultapromociones/basica", y esas las lineas las almacena en texto.txt
rem  despues correr el bat de abajo, el cual toma el archivo texto.txt, extrae la segunda columna, la ordenas y luego elimina los registro repetidos y consecutivos

rem echo  >> temp2.txt

del C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\temp1.txt
REM verificar si no e snecesario tambien borrar el temp2.txt
del C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\temp2.txt
echo - >> C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\temp2.txt
REM verificar si existe temp3.txt y si existe borarlo

set URL_Scan=%URL%
set file_out=C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\%File_Usr%

echo: %URL_Scan%

echo %file_out%
type C:\Users\l0646482\n\mi_desa\jenkins\consolidados\access\*.* | find /i "%URL_Scan%" >> C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\temp1.txt

setlocal
set usuarios=

for /f "tokens=2" %%b in (C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\temp1.txt) do (
	echo %%b >> C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\temp2.txt

)
rem guarda la primera linea del archivo temp2.txt en la variable primera_linea

:repetir

set primera_linea=vacio
<"C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\temp2.txt" set /p "primera_linea="

rem set "primera_linea" 
echo %primera_linea%

rem verifica si termino de revisar el archivo
if %primera_linea% EQU vacio goto :salir
echo %primera_linea% >> %file_out%

type C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\temp2.txt | find /i /v "%primera_linea%" >> C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\temp3.txt
del C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\temp2.txt
ren C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_access_logs\temp3.txt temp2.txt
goto :repetir

:salir
exit 0