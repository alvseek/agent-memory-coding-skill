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

if not exist "%SH%" (
    echo Error: installer not found: %SH%
    exit /b 1
)

set "BASH="
where bash >nul 2>&1 && set "BASH=bash"
if not defined BASH if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not defined BASH if exist "%LocalAppData%\Programs\Git\bin\bash.exe" set "BASH=%LocalAppData%\Programs\Git\bin\bash.exe"

if not defined BASH (
    echo Error: bash not found. Install Git for Windows ^(https://git-scm.com/download/win^) or WSL,
    echo        then re-run. Alternatively run the installer directly from Git Bash:
    echo            bash setup-scripts/setup-all-claude-code.sh
    exit /b 1
)

"%BASH%" "%SH%"
exit /b %ERRORLEVEL%
