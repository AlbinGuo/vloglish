@echo off
echo Starting Vloglish backend on http://127.0.0.1:8000 ...
start "vloglish-backend" cmd /k "cd /d %~dp0..\backend && .venv\Scripts\uvicorn app.main:app --reload --host 127.0.0.1 --port 8000"
timeout /t 2 /nobreak >nul
echo Starting frontend on http://localhost:5173 ...
start "vloglish-frontend" cmd /k "cd /d %~dp0..\frontend && npm run dev"
echo.
echo Backend: http://127.0.0.1:8000/api/health
echo Frontend: http://localhost:5173
