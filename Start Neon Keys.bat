@echo off
rem Neon Keys launcher
rem 1. Starts the Neon Keys helper (hidden) so your progress and Studio songs save into this folder
rem 2. Makes the list of songs in the Songs folder
rem 3. Opens Neon Keys in Microsoft Edge (Edge talks to your USB keyboard)
start "" powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0neonkeys-helper.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scan-songs.ps1"
start "" msedge "%~dp0NeonKeys.html"
