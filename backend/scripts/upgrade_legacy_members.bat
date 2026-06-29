@echo off
cd /d %~dp0..
if not exist .venv\Scripts\python.exe (
  echo 未找到 .venv，请先在 backend 目录执行: python -m venv .venv
  echo 然后: .venv\Scripts\activate ^& pip install -r requirements.txt
  exit /b 1
)
.venv\Scripts\python.exe scripts\upgrade_legacy_members.py %*
