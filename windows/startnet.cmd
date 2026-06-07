@echo off
setlocal enabledelayedexpansion

wpeinit
net use z: \\10.10.10.2\windowsinstall\Windows11 /user:windowsinstall windowsinstall

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
    pushd z:\
    setup.exe
    popd
    goto :EOF
)

set "CHOSEN=!FILE_%CHOICE%!"
if "!CHOSEN!"=="" (
    echo Invalid choice. Please enter a number between 0 and %COUNT%.
    goto :PROMPT
)

echo.
echo Starting Windows setup with: !CHOSEN!
pushd z:\
setup.exe /unattend:"!CHOSEN!"
popd

endlocal