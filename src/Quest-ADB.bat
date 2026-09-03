@echo off
chcp 65001 >nul
cd /d "%~dp0"
title LTC Quest Helper
if not exist "%~dp0adb.exe" (
  echo adb.exe not found in this folder.
  echo Put these files inside official Google platform-tools.
  echo https://developer.android.com/tools/releases/platform-tools
  pause
  exit /b 1
)
start "" /min powershell -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0Quest-ADB.ps1"
