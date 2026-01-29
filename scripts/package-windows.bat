@echo off

echo Packaging for Windows...
call dart run inno_bundle:build --release
echo Packaging complete.

set SRC_DIR=build\windows\x64\installer\release
set DEST_DIR=build\output
set DEST_FILE=%DEST_DIR%\yamata-launcher-installer.exe

if not exist %DEST_DIR% (
  mkdir %DEST_DIR%
)

set EXE_FILE=

for %%f in (%SRC_DIR%\*.exe) do (
  set EXE_FILE=%%f
  goto :found
)

:found
if "%EXE_FILE%"=="" (
  echo ERROR: No .exe file found in %SRC_DIR%
  exit /b 1
)

echo Moving %EXE_FILE% to %DEST_FILE%
move "%EXE_FILE%" "%DEST_FILE%"

echo Done.
