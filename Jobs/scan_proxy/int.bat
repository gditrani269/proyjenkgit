echo off
echo String a buscar:
set str_pr=%URL%

echo Nombre del archivo de salida que contendra el nombre de todos los archivos que tiene el parametro anterior:
set file_pr=%File_Proxy%

echo Nombre del archivo de salida que contendra la lista de usuarios en cada archivo que contiene el parametro 1:
set file_us=%File_Users%

echo str_pr %str_pr%
echo file_pr %file_pr%
echo file_us %file_us%
call C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_proxy\findstr_jar.bat %str_pr% %file_pr%
call C:\Users\l0646482\n\mi_desa\jenkins\jobs\scan_proxy\find_tag.bat %file_pr% %file_us%