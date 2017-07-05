echo off
echo String a buscar:
set /p str_pr=

echo Nombre del archivo de salida que contendra el nombre de todos los archivos que tiene el parametro anterior:
set /p file_nm=

echo Nombre del archivo de salida que contendra la lista de usuarios en cada archivo que contiene el parametro 1:
set /p file_us=

call findstr_jar.bat %str_pr% %file_nm%
call find_tag.bat %file_nm% %file_us%