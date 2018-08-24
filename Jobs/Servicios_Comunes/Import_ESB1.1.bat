REM recibe como 1° parametro el archivo que contiene la lista de .jar a subir a la actividad
REM recibe como 2° parametro path de la carpeta temporal del proceso padre
REM recibe como 3° parametro la carpeta del servicio en el repositorio local de dimension
REM recibe como 4° parametro el path del entregable para el deploy automatico: fwk/ser/version/Entregables
REM recibe como 5° parametro leyenda a mostrar en el view de la consola 

set fList_JAR=%1
set folder=%2
set Dimmension_Serv=%3
set Entregable=%4
set ito=%5
goto :seis
rem set Folder_Ppal=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Pre-Desa
set PATH_FOLDER_IN=%Folder_Input%\%BUILD_USER_ID%
set PATH_FOLDER_IN=C:\Users\l0646482\n\mi_desa\jenkins\Carpeta_In\L0646482
REM Comienzo: crea xml de deploy automatico de PROD y arma path

set inp=%Jar_Name%
rem set Jar_Name=sapbasic.jar

set TO=%Actividad_Numero%
rem set TO=testIC2

:seis

echo --------------- Armado de deploy automatico para DESA ---------------------
set sOutputFile_homo=%folder%\Desa.xml

REM Elimina la version existente del XML de deploy automatico, pero no deberia existir nunca
if exist %sOutputFile_homo% del %sOutputFile_homo%

echo ^<import^> >> %sOutputFile_homo%
echo			^<jar^> >> %sOutputFile_homo%

:repetir_homo

:DONE3
REM aca deberia mover el archivo de la carpeta de intercambio a la carpeta ENTREGABLES correspondiente.
for /f "tokens=*" %%y in (%fList_JAR%) do (
	echo %folder%\%%y
	echo %Dimmension_Serv%
	copy %folder%\%%y %Dimmension_Serv%
	REM escribe en el xml de deploy automatico
rem	echo				^<path^>D:/Serena/SDA-AGENT/core/var/work/CBUS_OSB%Entregable%/%%y^</path^> >> %sOutputFile_homo%
	echo				^<path^>%folder%\%%y^</path^> >> %sOutputFile_homo%
)

REM carga numero de TO en el XML
REM set ito=%TO%

echo				^<transferencia^>%ito%^</transferencia^> >> %sOutputFile_homo%
	 		
echo			^</jar^>  >> %sOutputFile_homo%
echo ^</import^>  >> %sOutputFile_homo%

echo --------------- FIN Armado de deploy automatico para DESA ---------------------


set pathxml="%sOutputFile_xml%"
REM parametros de conexion al OSB donde se realiza la importacion
set usuario="integracionDesa2toDesa"
set pass="jenkins2018"
set ambiente="desaosb"
rem set usuario="weblogic"
rem set pass="12345678"
rem set ambiente="localhost"
set puerto="8021"
:echo %pathxml%

set JAVA_LIB=C:\Users\l0646482\n\mi_desa\ImportOSBCompartido\Compilador\Compilador\lib


set JAVA_CP=C:\Users\l0646482\n\mi_desa\ImportOSBCompartido\Compilador\Compilador\bin;%JAVA_LIB%\com.bea.cie.config_5.2.0.0.jar;%JAVA_LIB%\com.bea.common.configfwk.wlinterop_10.3.1.0.jar;%JAVA_LIB%\com.bea.common.configfwk_1.2.1.0.jar;%JAVA_LIB%\com.bea.core.logging_1.4.0.0.jar;%JAVA_LIB%\com.bea.core.management.core_2.3.0.0.jar;%JAVA_LIB%\com.bea.core.management.jmx_1.1.0.0.jar;%JAVA_LIB%\com.bea.core.weblogic.rmi.client_1.4.0.0.jar;%JAVA_LIB%\com.bea.core.weblogic.security.identity_1.1.0.0.jar;%JAVA_LIB%\commons-lang3-3.1.jar;%JAVA_LIB%\sb-kernel-api.jar;%JAVA_LIB%\sb-kernel-impl.jar;%JAVA_LIB%\sb-security.jar;%JAVA_LIB%\wlfullclient.jar

rem "C:\Program Files (x86)\Java\jre6\bin\java" -jar C:\Users\l0646482\n\mi_desa\ImportOSBCompartido\ImportJarOSB.jar %pathxml% %usuario% %pass% %ambiente% %puerto%
"C:\Program Files (x86)\Java\jre1.8.0_171\bin\java" -jar C:\Users\l0646482\n\mi_desa\ImportOSBCompartido\ImportJarOSB.jar %sOutputFile_homo% %usuario% %pass% %ambiente% %puerto%












