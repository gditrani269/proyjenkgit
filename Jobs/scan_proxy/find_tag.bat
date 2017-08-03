echo off
setlocal enabledelayedexpansion
REM abre el archivo indicado en el parametro 1 y recorre todos los archivos ahi indicados para buscar y mostrar lo que esta contenido
REM entre los TAGS: <con3:policy-expression>  y  </con3:policy-expression>

REM Control de camios
REM el 11-07-2017 se modificaron los tags de busqueda y reemplazo <con3, ya que en algunos archivos aparece como: <con5
REM por este motivo se modifico el criterio de busqueda y remplazo a: ":policy-expression>"
set file_proc=C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_proxy\%1
set file_us=C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_proxy\%2

echo el archivo contendor con el nombre de los archivos a escanear es: %file_proc%
echo el archivo contendor con los usuarios configurados para cosnumir el servicio es: %file_us%

rem set file_proc=D:\n\IC\Jenkins\consolas\consolaosbb-new_20170421\ApoyoYSoporteALaEntidad\ConsultaGestionDocumental\V1\ProxyService\ConsultaGestionDocumental-1.0.0_Basica.ProxyService


for /f "delims=" %%a in (%file_proc%) do (

	echo %%a >> %file_us%

	for /f "tokens=* delims=:policy-expression>" %%x in ('findstr ":policy-expression>" %%a') do (
	rem echo %%x
	set lin=%%x
	rem set linea=!linea:^<^= !
	set lin=!lin:^:policy-expression^>= !
	set lin=!lin:^:policy-expression^>= !
rem	echo !lin!
	echo !lin! >> %file_us%
		
	echo "" >> %file_us%
	echo -------------------------------------------- >> %file_us%
	echo "" >> %file_us%

	)

)

echo el archivo contendor con el nombre de los archivos a escanear es: %file_proc%
