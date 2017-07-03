echo off
setlocal enabledelayedexpansion
REM abre el archivo indicado en el parametro 1 y recorre todos los archivos ahi indicados para buscar y mostrar lo que esta contenido
REM entre los TAGS: <con3:policy-expression>  y  </con3:policy-expression>

set file_proc=%1
echo el archivo contendor con el nombre de los archivos a escanear es: %file_proc%

rem set file_proc=D:\n\IC\Jenkins\consolas\consolaosbb-new_20170421\ApoyoYSoporteALaEntidad\ConsultaGestionDocumental\V1\ProxyService\ConsultaGestionDocumental-1.0.0_Basica.ProxyService


for /f "delims=" %%a in (%file_proc%) do (

	for /f "tokens=* delims=<con3:policy-expression>" %%x in ('findstr "<con3:policy-expression>" %%a') do (
	rem echo %%x
	set lin=%%x
	rem set linea=!linea:^<^= !
	set lin=!lin:^<con3:policy-expression^>= !
	set lin=!lin:^</con3:policy-expression^>= !
	echo !lin!
	)

)






