echo off

REM Esta es la version que esta corriendo en JENKINS
REM los parametros que recibe son tres:
REM		1 - path parcial del repositorio donde se encuentra o se debe crear la carpeta ENTREGABLE en el repositorio local de Dimensions (ej: ServiciosComunesProductos\ConsultaTransaccionesVentaSeguro\V1)
REM		2 - lista completa de los archivos que se suben  a dimensions y que conformaran el xml de deploy automatico de homo, deben estar separados por ";". Y si se corre desde .bat entre comillas, desde junekins sin comillas
REM			por ejemplo: "arch1.arj;arch2.arj;ar_custom_homo.xml"
REM		3 - lista completa de los archivos que se suben  a dimensions y que conformaran el xml de deploy automatico de prod, deben estar separados por ";". Y si se corre desde .bat entre comillas, desde junekins sin comillas
REM			por ejemplo: "arch1.arj;arch2.arj;ar_custom_prod.xml"

REM		4 - Numero de TO de SERENA
REM		5 - Numero de ACTIVIDAD de DIMENSIONS

Setlocal EnableDelayedExpansion

REM caso de ejecutar desde JENKINS comentar esta seccion y en el job d eJenkins los parametros deben tener los nombres de las cinco variables de aqui abajo
rem SET RUTA=%1
rem SET ARCHIVOS_HOMO=%2
rem SET ARCHIVOS_PROD=%3
rem SET TO=%4
rem SET ACTIVIDAD=%5
REM Fin de la seccion a comentar en caso de correr en JENKINS

REM segmento de varibables de la infraestructura
SET PATH_DEPLOYAUTO=C:\Dimensions\Workspace2\DeployAutomatico\
SET PATH_LOCAL_WORSPACE=C:\Dimensions\Workspace2\
SET PATH_FOLDER_IN=C:\Users\l0646482\n\mi_desa\jenkins\Carpeta_In\
goto :main

========================================================================
:Chek_Ruta DirName
REM Verifica si existe en el repositorio local (workplace) el Framework\Servicio\Vx
REM Entrada: Framework\Servicio\Version
REM Salida: Si la ruta existe retorna 		0
REM Salida: Si la ruta NO existe retorna 	1

	SET "DirName=%~1"
	SETLOCAL ENABLEEXTENSIONS
	SET DirName=%PATH_LOCAL_WORSPACE%%DirName% 
If exist "%DirName%" (
  REM El archivo existe...
  echo existe %DirName%
  exit /b 0
) ELSE (
   REM El archivo no existe...
  echo NO existe %DirName%
  exit /b  1
)
========================================================================
:Chek_Carpeta_Entregables FolderEntregables

	SETLOCAL ENABLEEXTENSIONS
	SET "FolderEntregables=%~1"
	SET FolderEntregables=%FolderEntregables%\Entregables
	If exist "%FolderEntregables%" (
	REM la carpeta existe
	echo existe %FolderEntregables%
	exit /b 0
	) ELSE (
		REM La carpeta no existe, va a crearla
		echo NO existe %FolderEntregables%
		MD %FolderEntregables%
		REM verifica si se pudo crear la carpeta
		If exist "%FolderEntregables%" (
		REM La carpeta se creo bien.
		echo Se creo %FolderEntregables%
		exit /b 0
		) ELSE (
		REM No se pudocrear la carpeta, avisa y termina con error.
		echo NO se pudo crear %FolderEntregables%
		exit /b  1
		)
	)
 
 =======================================================================
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

:Chek_File_Exist FileName
REM Verifica si existe en el la carpeta de ingreso el archivo Filename
REM Entrada: Nombre del archivo a verificar
REM Salida: Si el archivo existe retorna 		0
REM Salida: Si el archivo NO existe retorna 	1

	SET "FileName=%~1"
	SETLOCAL ENABLEEXTENSIONS
REM	SET ChkName=C:\Jenkins\Carpeta_In\%FileName%
	SET ChkName=%PATH_FOLDER_IN%%FileName%
If exist "%ChkName%" (
  REM El archivo existe...
  echo existe %ChkName%
  exit /b 0
) ELSE (
   REM El archivo no existe...
  echo NO existe %ChkName%
  exit /b  1
)
========================================================================

:main

REM Verificacion de la existencia de la ruta ingresada. Si no existe termina, si existe continua con la ejecucion.
call :Chek_Ruta %RUTA%
IF NOT ERRORLEVEL 1 GOTO :DONE
      ECHO  Verificar el correcto de ingreso de la Ruta o que en el repositorio exista dicha ruta.
	  goto :FIN
:DONE

REM Verificacion de la existencia de la carpeta ENTREGABLES dentro del path del servicio sobre el que se esta trabajando. Si no existe la crea.
SET ServPath=%PATH_LOCAL_WORSPACE%%RUTA% 
call :Chek_Carpeta_Entregables %ServPath%
IF NOT ERRORLEVEL 1 GOTO :DONE2
      ECHO  No se pudo crear la carpeta ENTREGABLES dentro de la estructura del servicio %ServPath%.
	  goto :FIN
:DONE2

rem goto :FIN

REM arma el path para el repositorio en server de dimensions 
set fpath=%PATH_LOCAL_WORSPACE%
set fpath=%fpath:"=%
set recorte=/
set recorte=%recorte:"=%
REM set PAR=%CD%
REM set PAR=C:\Dimensions\Workspace2\ServiciosComunesProductos\AccionesOperatoriaContableSIAC\v1\Entregables
REM set PAR=%RUTA%/Entregables
set PAR=%RUTA%/Entregables
echo %PAR%
set PAR=!PAR:%fpath%=%recorte%!
set PAR=!PAR:\=/!
REM fin de arma el path del repositorio del server de dimensions.

========================================================================
REM Comienzo: crea xml de deploy automatico de HOMO y arma path
echo --------------- Armado de deploy automatico para Homologacion ---------------------
set sOutputFile_homo=%PATH_DEPLOYAUTO%XMLImportJar_Homo1.xml
REM set sOutputFile_homo=C:\Users\l0646482\n\mi_desa\jenkins\XMLImportJar_Homo1.xml

REM Pone el XML de deploy automatico como READ-WRITE en el repositorio local
attrib -R %sOutputFile_homo%

REM Elimina la version existente del XML de deploy automatico
del %sOutputFile_homo%

echo ^<import^> >> %sOutputFile_homo%
echo			^<jar^> >> %sOutputFile_homo%
REM FIN: crea xml y arma path
REM set inp=arsarasa1;arcaca2;artata3
REM set inp=%ARCHIVOS_HOMO%
set inp=%ARCHIVOS_HOMO%
REM extrae el primer y ultimo caracter de los parametros ingresados, los cuale se suponene que son comillas
REM usarlo solo si se corre desde batch, si se ejecuta desde jenkins comentarlo porque no deben usar las comillas.
rem set inp=%inp:~1,-1%

echo inp
echo %inp%
:repetir
for /f "tokens=1 delims=; " %%a in ("%inp%") do set out=%%a
echo out
echo %out%

REM Verifica que en la carpeta de ingreso esten todos los archivos ingresados al JOB como parametros.
call :Chek_File_Exist %out%
IF NOT ERRORLEVEL 1 GOTO :DONE3
      ECHO  No se encontro el archivo %out% en la carpeta %PATH_FOLDER_IN%.
	  goto :FIN
:DONE3
REM aca deberia mover el archivo de la carpeta de intercambio a la carpeta ENTREGABLES correspondiente.
copy %PATH_FOLDER_IN%%out% %PATH_LOCAL_WORSPACE%%RUTA%\Entregables
REM move %PATH_FOLDER_IN%%out% C:\Dimensions\Workspace2\%RUTA%\Entregables



REM escribe en el xml de deploy automatico
echo				^<path^>D:/Serena/SDA-AGENT/core/var/work/CBUS_OSB/%PAR%/!out!^</path^> >> %sOutputFile_homo%
call :param %out%
echo inp
echo %inp%
rem if not %out% == "%inp%" goto :repetir
if not "%inp%" == "~1" goto :repetir
REM carga numero de TO en el XML
REM set ito=%TO%
set ito=%TO%
echo				^<transferencia^>%ito%^</transferencia^> >> %sOutputFile_homo%
	 		
echo			^</jar^>  >> %sOutputFile_homo%
echo ^</import^>  >> %sOutputFile_homo%

REM Pone el XML de deploy automatico como READONLY en el repositorio local
attrib +R %sOutputFile_homo%
echo --------------- FIN Armado de deploy automatico para Homologacion ---------------------
REM fin del aramdo de xml de deploy automatico de HOMO
========================================================================

========================================================================
REM Comienzo: crea xml de deploy automatico de PROD y arma path
echo --------------- Armado de deploy automatico para Produccion ---------------------
set sOutputFile_prod=%PATH_DEPLOYAUTO%XMLImportJar_Prod.xml
REM set sOutputFile_prod=C:\Users\l0646482\n\mi_desa\jenkins\XMLImportJar_Prod.xml

REM Pone el XML de deploy automatico como READ-WRITE en el repositorio local
attrib -R %sOutputFile_prod%

REM Elimina la version existente del XML de deploy automatico
del %sOutputFile_prod%

echo ^<import^> >> %sOutputFile_prod%
echo			^<jar^> >> %sOutputFile_prod%
REM FIN: crea xml y arma path
REM set inp=arsarasa1;arcaca2;artata3
REM set inp=%ARCHIVOS_PROD%
set inp=%ARCHIVOS_PROD%
REM extrae el primer y ultimo caracter de los parametros ingresados, los cuale se suponene que son comillas
REM usarlo solo si se corre desde batch, si se ejecuta desde jenkins comentarlo porque no deben usar las comillas.
rem set inp=%inp:~1,-1%

echo inp
echo %inp%
:repetir2
for /f "tokens=1 delims=; " %%a in ("%inp%") do set out=%%a
echo out
echo %out%

REM Verifica que en la carpeta de ingreso esten todos los archivos ingresados al JOB como parametros.
call :Chek_File_Exist %out%
IF NOT ERRORLEVEL 1 GOTO :DONE4
      ECHO  No se encontro el archivo %out% en la carpeta %PATH_FOLDER_IN%.
	  goto :FIN
:DONE4
REM aca deberia mover el archivo de la carpeta de intercambio a la carpeta ENTREGABLES correspondiente.
copy %PATH_FOLDER_IN%%out% %PATH_LOCAL_WORSPACE%%RUTA%\Entregables
REM move %PATH_FOLDER_IN%%out% C:\Dimensions\Workspace2\%RUTA%\Entregables


REM escribe en el xml de deploy automatico
echo				^<path^>D:/Serena/SDA-AGENT/core/var/work/CBUS_OSB/%PAR%/!out!^</path^> >> %sOutputFile_prod%
call :param %out%
echo inp
echo %inp%
rem if not %out% == "%inp%" goto :repetir
if not "%inp%" == "~1" goto :repetir2
REM carga numero de TO en el XML
REM set ito=%TO%
set ito=%TO%
echo				^<transferencia^>%ito%^</transferencia^> >> %sOutputFile_prod%
	 		
echo			^</jar^>  >> %sOutputFile_prod%
echo ^</import^>  >> %sOutputFile_prod%

REM Pone el XML de deploy automatico como READONLY en el repositorio local
attrib +R %sOutputFile_prod%
echo --------------- FIN Armado de deploy automatico para Produccion ---------------------
REM fin del aramdo de xml de deploy automatico de PROD
========================================================================

REM Deliver de XML de deploy automatico y de archivos ENTREGABLES a la actividad indicada en el parametro 5.
REM CBUS_OSB_ACTIVIDAD_1044
rem login en dimensions

rem dm liststreams --user l0646482 --password saile238 --database Galiciass@Dimensions --server Dimensions1

echo Add a Dimension de deploy automatico
dm Add DeployAutomatico --directory C:\Dimensions\Workspace2 --requestId %ACTIVIDAD% --user %USER_DIMENSION% --password %PASS_DIMENSION% --database Galicia@Dimensions --server Dimensions1


echo Deliver a Dimension de xml de deploy automatico
dm deliver DeployAutomatico --directory C:\Dimensions\Workspace2 --requestId %ACTIVIDAD% --user %USER_DIMENSION% --password %PASS_DIMENSION% --database Galicia@Dimensions --server Dimensions1

echo %RUTA%\Entregables

echo Add a Dimension de entregables
dm add  %RUTA%\Entregables --directory C:\Dimensions\Workspace2 --requestId %ACTIVIDAD% --user %USER_DIMENSION% --password %PASS_DIMENSION% --database Galicia@Dimensions --server Dimensions1

echo Deliver a Dimension de xml de deploy automatico
dm deliver %RUTA%\Entregables --directory C:\Dimensions\Workspace2 --requestId %ACTIVIDAD% --user %USER_DIMENSION% --password %PASS_DIMENSION% --database Galicia@Dimensions --server Dimensions1

rem CALL :LENGHT 123456789
rem ECHO.%LEN%
:FIN