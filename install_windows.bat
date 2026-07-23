@echo off
chcp 65001 >nul
title Coinmania - AI Training Setup
color 0B

:: ============================================================
::  Coinmania AI Training - 1-click installer (Windows)
::  Double-click this file. It asks for admin (UAC) and then
::  downloads + runs the latest installer automatically.
:: ============================================================

:: --- Step 1: self-elevate to Administrator (UAC) ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo   Administrator permission is required.
    echo   Please click "Yes" on the popup window...
    echo.
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
    exit /b
)

:: --- Step 2: run the installer straight from the web ---
echo.
echo   ============================================================
echo      Coinmania - AI Training Setup
echo      Downloading and starting the installer...
echo   ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $ProgressPreference='SilentlyContinue'; try { $s = Invoke-RestMethod 'https://coinmania-ai-pulse-training.vercel.app/setup_windows.ps1'; if ($s.Length -gt 0 -and $s[0] -eq [char]0xFEFF) { $s = $s.Substring(1) }; Invoke-Expression $s } catch { Write-Host ''; Write-Host ('  ERROR: ' + $_.Exception.Message) -ForegroundColor Red; Write-Host '  Check your internet connection and try again,' -ForegroundColor Yellow; Write-Host '  or use the manual steps on the website.' -ForegroundColor Yellow; Write-Host ''; Read-Host '  Press Enter to close' }"

exit /b
