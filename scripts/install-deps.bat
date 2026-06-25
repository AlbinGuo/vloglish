@echo off
setlocal EnableExtensions

echo.
echo === Vloglish: installing backend and frontend dependencies ===
echo.

REM --- Backend (Python venv + pip) ---
cd /d "%~dp0..\backend"
if errorlevel 1 (
  echo [ERROR] backend directory not found.
  exit /b 1
)

if not exist .venv (
  echo [backend] Creating virtual environment...
  python -m venv .venv
  if errorlevel 1 (
    echo [ERROR] Failed to create venv. Make sure Python 3.10+ is installed and on PATH.
    exit /b 1
  )
)

echo [backend] Installing Python packages...
call .venv\Scripts\activate.bat
if errorlevel 1 (
  echo [ERROR] Failed to activate virtual environment.
  exit /b 1
)

pip install -r requirements.txt
if errorlevel 1 (
  echo [ERROR] pip install failed.
  exit /b 1
)

echo [backend] Done.
echo.

REM --- Frontend (npm) ---
cd /d "%~dp0..\frontend"
if errorlevel 1 (
  echo [ERROR] frontend directory not found.
  exit /b 1
)

echo [frontend] Installing npm packages...
call npm install
if errorlevel 1 (
  echo [ERROR] npm install failed. Make sure Node.js and npm are installed.
  exit /b 1
)

echo [frontend] Done.
echo.
echo === All dependencies installed ===
echo.
echo Next steps:
echo   1. Import sample data (first time only):
echo        cd backend ^& .venv\Scripts\activate ^& python seed.py
echo   2. Start dev servers:
echo        scripts\start-dev.bat
echo.
echo Backend:  http://127.0.0.1:8000/api/health
echo Frontend: http://localhost:5173
echo.

endlocal
