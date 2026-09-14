@echo off
setlocal EnableExtensions

set "SELF=%~f0"
set "FLUTTER_COMMAND="
for /f "delims=" %%F in ('where.exe flutter 2^>nul') do (
  if /I not "%%~fF"=="%SELF%" (
    if not defined FLUTTER_COMMAND set "FLUTTER_COMMAND=%%~fF"
  )
)

if not defined FLUTTER_COMMAND if defined FLUTTER_ROOT if exist "%FLUTTER_ROOT%\bin\flutter.bat" set "FLUTTER_COMMAND=%FLUTTER_ROOT%\bin\flutter.bat"
if not defined FLUTTER_COMMAND (
  echo Flutter nao foi encontrado no PATH. Instale o Flutter ou defina FLUTTER_ROOT.
  exit /b 1
)

for %%F in ("%FLUTTER_COMMAND%") do set "LIMITBREAKER_DART_EXECUTABLE=%%~dpFcache\dart-sdk\bin\dart.exe"
if not exist "%LIMITBREAKER_DART_EXECUTABLE%" (
  echo Nao foi possivel localizar o Dart do Flutter em "%LIMITBREAKER_DART_EXECUTABLE%".
  exit /b 1
)

%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0server\start_local_api.ps1"
if errorlevel 1 exit /b %errorlevel%

call "%FLUTTER_COMMAND%" %*
exit /b %errorlevel%
