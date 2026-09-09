@ECHO off
SETLOCAL

IF NOT DEFINED ANDROID_USER_HOME SET "ANDROID_USER_HOME=%USERPROFILE%\.android"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0server\start_local_api.ps1"
IF ERRORLEVEL 1 EXIT /B %ERRORLEVEL%

FOR /F "usebackq delims=" %%i IN (`powershell.exe -NoProfile -Command "(Get-Command dart.bat -ErrorAction Stop).Source"`) DO SET "DART_COMMAND=%%i"
IF NOT DEFINED DART_COMMAND (
  ECHO Dart nao foi encontrado no PATH. 1>&2
  EXIT /B 1
)

FOR %%i IN ("%DART_COMMAND%\..") DO SET "FLUTTER_BIN=%%~fi"
CALL "%FLUTTER_BIN%\flutter.bat" %*
