@echo off
setlocal enableextensions

:: --- Self-elevate to Administrator (UAC) ---
:: If not admin, relaunch this script as admin with an "ELEVATED" arg.
>nul 2>&1 net session
if %errorlevel% NEQ 0 (
  echo [*] Elevation required. Prompting for administrator...
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Start-Process -FilePath '%~f0' -ArgumentList 'ELEVATED' -Verb RunAs"
  exit /b
)

:: --- Optional: avoid double elevation flag noise ---
if /I "%1"=="ELEVATED" shift

:: --- Check Winget availability ---
where winget >nul 2>&1
if %errorlevel% NEQ 0 (
  echo [!] winget not found.
  echo     Install "App Installer" from the Microsoft Store, then re-run this script.
  pause
  exit /b 1
)

:: --- Log setup ---
set "STAMP=%DATE%_%TIME%"
:: Sanitize timestamp for filename
set "STAMP=%STAMP::=-%"
set "STAMP=%STAMP:/=-%"
set "STAMP=%STAMP: =_%"
set "STAMP=%STAMP:.=-%"
set "LOG=%TEMP%\winget-upgrade-%STAMP%.log"

echo [*] Logging to: %LOG%
echo ==== WINGET UPGRADE RUN %DATE% %TIME% ==== > "%LOG%"

:: --- Update winget sources first ---
echo [*] Updating winget sources...
winget source update >> "%LOG%" 2>&1

:: --- Snapshot before state ---
echo [*] Capturing package list (before)...
winget list >> "%LOG%" 2>&1

:: --- Show what’s upgradable (for console) ---
echo.
echo [*] Packages with available upgrades BEFORE:
winget list --upgrade-available

:: --- Do the upgrades ---
echo.
echo [*] Upgrading all packages to latest versions...
echo     This may take a while. See log for details: %LOG%
:: Notes:
:: --include-unknown catches packages without detectable current versions
:: --accept-* auto-accepts terms; --silent prefers unattended where possible
winget upgrade --all ^
  --include-unknown ^
  --silent ^
  --accept-source-agreements ^
  --accept-package-agreements >> "%LOG%" 2>&1

set "UPG_RC=%errorlevel%"

:: --- Optional second pass (some packages behave better non-silent) ---
echo.
echo [*] Running a non-silent second pass for any stragglers...
winget upgrade --all ^
  --include-unknown ^
  --accept-source-agreements ^
  --accept-package-agreements >> "%LOG%" 2>&1

:: --- Snapshot after state ---
echo.
echo [*] Packages with available upgrades AFTER:
winget list --upgrade-available

echo.
echo [*] Done. Full log here:
echo     %LOG%
echo     If a few items are still listed above, they may require:
echo       - A reboot, or
echo       - You to sign in to the Microsoft Store, or
echo       - Manual updates for legacy/portable apps

:: Return the first upgrade pass code if nonzero; otherwise the second pass code
exit /b %UPG_RC%
