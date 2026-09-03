@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ==========================================
echo Quest ADB check
echo Folder: %CD%
echo ==========================================
if not exist "%~dp0adb.exe" (
  echo ERROR: adb.exe is not in this folder.
  pause
  exit /b 1
)
echo -- adb version --
"%~dp0adb.exe" version
echo.
echo -- killing other adb servers --
taskkill /F /IM adb.exe >nul 2>&1
timeout /t 1 /nobreak >nul
echo -- start server with THIS adb.exe --
"%~dp0adb.exe" start-server
echo.
echo -- adb devices -l --
"%~dp0adb.exe" devices -l
echo.
echo If the list is empty, Windows/driver/cable is the problem,
echo not the GUI. Install Meta ADB drivers and use a data USB-C cable.
echo Driver: https://developer.oculus.com/downloads/package/oculus-adb-drivers/
echo.
pause
