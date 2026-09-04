@echo off
chcp 65001 >nul
cd /d "%~dp0"
title LTC Quest Helper
echo.
echo  LTC Quest Helper
echo  Lumen Technologies Co.
echo  https://LT-C.iddns.ir
echo.
if not exist "%~dp0adb.exe" (
  echo adb.exe not found in this folder.
  echo Put this program inside official Google platform-tools.
  echo https://developer.android.com/tools/releases/platform-tools
  pause
  exit /b 1
)
if not exist "%~dp0Quest-ADB.ps1" (
  echo Quest-ADB.ps1 is missing.
  pause
  exit /b 1
)
start "" /min powershell -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0Quest-ADB.ps1"
