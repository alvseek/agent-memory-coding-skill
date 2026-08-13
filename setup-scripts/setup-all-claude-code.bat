@echo off
REM setup-all-claude-code.bat - Windows convenience wrapper for setup-all-claude-code.sh.
REM
REM Runs the .sh installer (single source of truth) via bash so there's no separate logic to
REM keep in sync. Requires bash — Git for Windows (bundled bash) or WSL. Finds bash on PATH,
REM else falls back to the standard Git-for-Windows location.
REM
REM Usage:        setup-scripts\setup-all-claude-code.bat
REM Env override: AGENT_MEMORY_TARGET_DIR (passed through to the .sh)

setlocal
set "SH=%~dp0setup-all-claude-code.sh"

REM Detect a double-click launch (Explorer runs us via cmd /c "...bat") so we can keep the window
REM open at the end — otherwise a fast success or failure just flashes a black window shut ("only black").
set "DOUBLECLICK="
echo %cmdcmdline% | find /i "%~nx0" >nul && set "DOUBLECLICK=1"

if not exist "%SH%" (
    echo Error: installer not found: %SH%
    if defined DOUBLECLICK pause
    exit /b 1
)

REM Prefer Git-for-Windows bash (MSYS2 — runs a Windows-path .sh fine). Fall back to a PATH lookup
REM LAST, skipping the System32/WindowsApps WSL launchers: WSL can't run a C:\... path .sh, and with
REM no distro installed it fails silently (no output/, nothing installed) — so it must never win here.
set "BASH="
if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not defined BASH if exist "%LocalAppData%\Programs\Git\bin\bash.exe" set "BASH=%LocalAppData%\Programs\Git\bin\bash.exe"
if not defined BASH for /f "delims=" %%i in ('where bash 2^>nul ^| findstr /v /i "System32 WindowsApps"') do if not defined BASH set "BASH=%%i"

if not defined BASH (
    echo Error: Git Bash not found. Install Git for Windows ^(https://git-scm.com/download/win^),
    echo        then re-run. Alternatively run the installer directly from Git Bash:
    echo            bash setup-scripts/setup-all-claude-code.sh
    if defined DOUBLECLICK pause
    exit /b 1
)

"%BASH%" "%SH%"
set "RC=%ERRORLEVEL%"
if defined DOUBLECLICK pause
exit /b %RC%
