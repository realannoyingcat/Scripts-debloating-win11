@echo off
TITLE Ultimate PC Optimization Script by Gemini
CLS
ECHO.
ECHO ============================ W A R N I N G ===================================
ECHO.
ECHO  This script will apply a comprehensive set of system tweaks to maximize
ECHO  gaming performance and reduce input delay.
ECHO.
ECHO  It is a collection of common, safe optimizations found in many FPS packs.
ECHO.
ECHO  A SYSTEM RESTORE POINT IS STRONGLY RECOMMENDED BEFORE PROCEEDING!
ECHO.
ECHO  This script must be run as an Administrator.
ECHO.
ECHO ==============================================================================
ECHO.
CHOICE /C YN /M "Do you understand the risks and want to continue?"
IF ERRORLEVEL 2 GOTO EOF
IF ERRORLEVEL 1 GOTO MainMenu

:MainMenu
CLS
ECHO.
ECHO ======================= OPTIMIZATION MENU ========================
ECHO.
ECHO    1. Apply All Performance Tweaks (Recommended)
ECHO    2. Clear System & Gaming Caches
ECHO    3. System Integrity Check (SFC & DISM)
ECHO    4. Exit
ECHO.
SET /P "M=Please type a number and press ENTER: "
IF /I "%M%"=="1" GOTO ApplyAllTweaks
IF /I "%M%"=="2" GOTO ClearCaches
IF /I "%M%"=="3" GOTO SystemCheck
IF /I "%M%"=="4" GOTO EOF
GOTO MainMenu

:ApplyAllTweaks
CLS
ECHO [*] Applying all performance tweaks...
ECHO.

ECHO [1/7] Applying Power & Performance Settings...
:: Create and activate Ultimate Performance power plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul
:: Disable power throttling
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul
ECHO Done.
ECHO.

ECHO [2/7] Optimizing System Visuals and Effects...
:: Set for best performance
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFxSetting" /t REG_DWORD /d 2 /f >nul
:: Keep smooth fonts and show thumbnails
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "FontSmoothing" /t REG_SZ /d "2" /f >nul
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d 0 /f >nul
ECHO Done.
ECHO.

ECHO [3/7] Applying Gaming & GPU Priority Tweaks...
:: Set Game Mode and disable Game Bar
reg add "HKEY_CURRENT_USER\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f >nul
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul
:: Enable Hardware-Accelerated GPU Scheduling (Requires Restart)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul
:: Prioritize Games in the registry
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul
ECHO Done.
ECHO.

ECHO [4/7] Disabling System Telemetry & Unnecessary Services...
sc config "DiagTrack" start=disabled >nul
sc config "dmwappushservice" start=disabled >nul
sc config "diagsvc" start=disabled >nul
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul
ECHO Done.
ECHO.

ECHO [5/7] Applying Network Optimizations...
:: Disable Network Throttling
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul
:: Disable Nagle's Algorithm for lower latency
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /f >nul
for /f "tokens=*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"') do (
    reg add "%%a" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul
    reg add "%%a" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul
)
ECHO Done.
ECHO.

ECHO [6/7] Reducing System Latency...
:: Set System Responsiveness
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul
:: Disable Memory Compression
PowerShell -Command "Disable-MMAgent -mc" >nul
ECHO Done.
ECHO.

ECHO [7/7] Debloating Windows Features...
:: Disable Storage Sense
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "01" /t REG_DWORD /d 0 /f >nul
:: Disable Suggested Apps
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul
ECHO Done.
ECHO.
ECHO ================= TWEAKS APPLIED SUCCESSFULLY =================
ECHO.
ECHO A system restart is required for all changes to take effect.
PAUSE
GOTO MainMenu

:ClearCaches
CLS
ECHO [*] Clearing temporary files and gaming caches...
ECHO.
del /s /q /f "%temp%\*.*" >nul
del /s /q /f "%windir%\temp\*.*" >nul
del /s /q /f "%localappdata%\NVIDIA\DXCache\*.*" >nul
del /s /q /f "%localappdata%\NVIDIA\GLCache\*.*" >nul
del /s /q /f "%localappdata%\AMD\DxCache\*.*" >nul
del /s /q /f "%localappdata%\D3DSCache\*.*" >nul
ipconfig /flushdns >nul
ECHO.
ECHO [*] Caches cleared successfully.
PAUSE
GOTO MainMenu

:SystemCheck
CLS
ECHO [*] Running System File Checker (SFC)... This may take some time.
sfc /scannow
ECHO.
ECHO [*] Running DISM Health Check... This may also take some time.
Dism /Online /Cleanup-Image /RestoreHealth
ECHO.
ECHO [*] System integrity check complete.
PAUSE
GOTO MainMenu

:EOF
CLS
ECHO.
ECHO Script finished. Exiting now.
ECHO.
TIMEOUT /T 3 /NOBREAK >nul
EXIT
