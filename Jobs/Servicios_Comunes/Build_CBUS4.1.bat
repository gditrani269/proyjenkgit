ECHO OFF


:: BUILD CMRM_SIAC Script Compilacion

CLS
:: ---------------------------------------------------------------
:: Parámetros preconfigurados
:: ---------------------------------------------------------------
:: Archivo de Log
set ArchivoLog=C:\Users\l0646482\n\mi_desa\jenkins\jobs\Get-PreDesa\Build_CBUS_OSB.log
:: ---------------------------------------------------------------

:: ---------------------------------------------------------------
:: Parámetros solicitados en tiempo de ejecución
:: ---------------------------------------------------------------


:: ---------------------------------------------------------------
:: Ejecución de comandos
:: ---------------------------------------------------------------
::echo "Salto de linea" > files.txt

::)REP DMINPUT
::echo %DMINPUT. >> files.txt
::)ENDR

rem set JAVA_HOME=D:\jdk1.6.0_07\bin
set JAVA_HOME="C:\Program Files (x86)\Java\jre1.8.0_171\bin\java"

rem set JAVA_LIB=D:\Build_Areas\CBUS_OSB_DESARROLLO\Compilador\lib
rem set JAVA_LIB=C:\Users\l0646482\n\mi_desa\ImportOSBCompartido\lib
set JAVA_LIB=C:\Users\l0646482\n\mi_desa\ImportOSBCompartido\Compilador\Compilador\lib


set JAVA_CP=C:\Users\l0646482\n\mi_desa\ImportOSBCompartido\Compilador\Compilador\bin;%JAVA_LIB%\com.bea.cie.config_5.2.0.0.jar;%JAVA_LIB%\com.bea.common.configfwk.wlinterop_10.3.1.0.jar;%JAVA_LIB%\com.bea.common.configfwk_1.2.1.0.jar;%JAVA_LIB%\com.bea.core.logging_1.4.0.0.jar;%JAVA_LIB%\com.bea.core.management.core_2.3.0.0.jar;%JAVA_LIB%\com.bea.core.management.jmx_1.1.0.0.jar;%JAVA_LIB%\com.bea.core.weblogic.rmi.client_1.4.0.0.jar;%JAVA_LIB%\com.bea.core.weblogic.security.identity_1.1.0.0.jar;%JAVA_LIB%\commons-lang3-3.1.jar;%JAVA_LIB%\sb-kernel-api.jar;%JAVA_LIB%\sb-kernel-impl.jar;%JAVA_LIB%\sb-security.jar;%JAVA_LIB%\wlfullclient.jar
::call d:\Builders\apache-ant-1.7.0\bin\ant >> Build_CBUS_OSB.log

rem call %JAVA_HOME%\java -classpath %JAVA_CP% com.bgba.osbjarexporter.OsbJarExporter D:\Build_Areas\CBUS_OSB_DESARROLLO\files.txt MANTE mi.jar
call "C:\Program Files (x86)\Java\jre1.8.0_171\bin\java" -classpath %JAVA_CP% com.bgba.osbjarexporter.OsbJarExporter files-%ACTIVIDAD%.txt MANTE mi.jar >> %ArchivoLog%
:: ---------------------------------------------------------------
:salida