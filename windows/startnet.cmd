@echo off
setlocal enabledelayedexpansion

wpeinit

echo Waiting for network share to become available...
:WAIT_NET
net use z: /delete >nul 2>&1
net use z: \\10.10.10.2\windowsinstall\Windows11 /user:windowsinstall windowsinstall
if errorlevel 1 (
    echo Network not ready yet, retrying in 5 seconds...
    timeout /t 5 /nobreak >nul
    goto WAIT_NET
)

echo.
echo ============================================================
echo  Windows Setup
echo ============================================================
echo.
echo Scanning for unattend files in z:\...
echo.

set COUNT=0
for %%F in (z:\*.xml) do (
    set /a COUNT+=1
    set "FILE_!COUNT!=%%~fF"
    echo  !COUNT!. %%~nxF
)

echo  0. No unattend file ^(manual setup^)
echo.

:PROMPT
set /p CHOICE=Enter your choice [0-%COUNT%]: 

if "%CHOICE%"=="0" (
    echo.
    echo Starting Windows setup without unattend file...
    z:\setup.exe
    goto :EOF
)

set "CHOSEN=!FILE_%CHOICE%!"
if "!CHOSEN!"=="" (
    echo Invalid choice. Please enter a number between 0 and %COUNT%.
    goto :PROMPT
)

echo.
echo Starting Windows setup with: !CHOSEN!
z:\setup.exe /unattend:"!CHOSEN!"

endlocal