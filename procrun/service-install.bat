@echo off
::---------------------------------------------
:: Adapted by Etienne Dube. Original author:
::
::- Author: Ulrich Palha
::- Date: 11/14/2011
::- http://www.ulrichpalha.com
::---------------------------------------------

if "%OS%" == "Windows_NT" setlocal

pushd %~dp0\..
set APPLICATION_SERVICE_HOME=%CD%
popd

::---------------------------------------------
:: -- Update this section to match your needs 
::---------------------------------------------

::-- 1. This name should match the name you gave to the prunsrv executable
set SERVICE_NAME=simpledaemon
set EXECUTABLE_NAME=%SERVICE_NAME%.exe
set EXECUTABLE=%APPLICATION_SERVICE_HOME%\bin\%EXECUTABLE_NAME%

::-- 2. The fully qualified start and stop classes
set CG_START_CLASS=daemon.test.SimpleDaemon
set CG_STOP_CLASS=%CG_START_CLASS%

::-- 3. The start and stop methods for the class(es) in 2 above
set CG_START_METHOD=windowsService
set CG_STOP_METHOD=windowsService

::-- 4. and their respective arguments/params if any
set CG_START_PARAMS=start
set CG_STOP_PARAMS=stop

::-- 5. the classpath for all jars needed to run your service
setlocal enabledelayedexpansion
SET CLASSPATH=%APPLICATION_SERVICE_HOME%\etc
for /R %APPLICATION_SERVICE_HOME%\lib %%a in (*.jar) do (
  set CLASSPATH=!CLASSPATH!;%%a
)
rem ECHO CLASSPATH: %CLASSPATH%
 
set CG_PATH_TO_JAR_CONTAINING_SERVICE=%CLASSPATH%

::-- 6. Set to auto if you want the service to startup automatically. The default is manual
set CG_STARTUP_TYPE=auto

::-- 7. Set this if you want to use a different JVM than configured in your registry, or if it is not configured in windows registry
set CG_PATH_TO_JVM="%JAVA_HOME%\jre\bin\server\jvm.dll"

::---- Set other options via environment variables, just as an example -------
set PR_DESCRIPTION=simpledaemon
set PR_INSTALL=%EXECUTABLE%
set PR_LOGPATH=%APPLICATION_SERVICE_HOME%\logs
set PR_CLASSPATH=%CLASSPATH%
set PR_DISPLAYNAME=simpledaemon


if "%1" == "" goto displayUsage
if /i %1 == install goto install
if /i %1 == remove goto  remove

:displayUsage
echo Usage: service.bat install/remove [service_name] 
goto end


:remove
::---- Remove the service -------
"%EXECUTABLE%" //DS//%SERVICE_NAME%
echo The service '%SERVICE_NAME%' has been removed
goto end

:install
::---- Install the Service -------
echo Installing service '%SERVICE_NAME%' ...
echo.

set EXECUTE_STRING= %EXECUTABLE% //IS//%SERVICE_NAME%  --Startup %CG_STARTUP_TYPE%  --StartClass %CG_START_CLASS% --StopClass %CG_STOP_CLASS%
call:executeAndPrint %EXECUTE_STRING%

set EXECUTE_STRING= "%EXECUTABLE%" //US//%SERVICE_NAME% --StartMode jvm --StopMode jvm --Jvm %CG_PATH_TO_JVM%
call:executeAndPrint %EXECUTE_STRING%

set EXECUTE_STRING= "%EXECUTABLE%" //US//%SERVICE_NAME% --StartMethod %CG_START_METHOD% --StopMethod  %CG_STOP_METHOD% 
call:executeAndPrint %EXECUTE_STRING%

set EXECUTE_STRING= "%EXECUTABLE%" //US//%SERVICE_NAME% --StartParams %CG_START_PARAMS% --StopParams %CG_STOP_PARAMS% 
call:executeAndPrint %EXECUTE_STRING%

set EXECUTE_STRING= "%EXECUTABLE%" //US//%SERVICE_NAME% ++JvmOptions "-Djava.io.tmpdir=%APPLICATION_SERVICE_HOME%\temp;" --JvmMs 128 --JvmMx 256
call:executeAndPrint %EXECUTE_STRING%

echo. 
echo The service '%SERVICE_NAME%' has been installed.

goto end

::--------
::- Functions
::-------
:executeAndPrint
%*
echo %*

goto:eof

:end
