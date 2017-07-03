echo off
REM busca a partir de la posicion indicada por path_inicial la cadena indicada en el parametro 1
REM el primer parametro indica la cadena a buscar (por ejemplo una url o un usuario especifico).
REM el segundo parametro indica el nombre del archivo de salida que contendra path y nombre de todos los archivos que contengan el string indicado en parametro 1

setlocal enabledelayedexpansion

set path_inicial=D:\n\IC\Jenkins\consolas
set str_a_buscar=%1
set arch_salida=%2

echo cadena a buscar: %str_a_buscar%
echo path raiz donde buscar: %path_inicial%
echo archivo de salida: %arch_salida%
set var=""
echo %var%

REM busca en todas las carpetas y archivos la cadena "asi", los que la contienen se almacenana en el archivo "out_fnd.txt"
rem findstr /S /M /c:"/accionescelulargo/basica" C:\shared\ultimo\consolaosbb_20170421\*.* >> out_fnd.txt 
findstr /S /M /c:%str_a_buscar% %path_inicial%\*.* >> %arch_salida% 

REM lee el archivo %arch_salida% linea por linea 
FOR /F "tokens=*" %%A IN (%arch_salida%) DO (
	@ECHO Linea: %%A
	copy %%A D:\n\IC\Jenkins\temp
rem	call temp5.bat %%A
)

