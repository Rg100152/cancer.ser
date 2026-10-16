@echo off
REM ============================================================
REM  Cancer Survey - Windows Uninstaller
REM  Dev: Raj Gautam  |  Project: Cancer.ser
REM ============================================================

setlocal EnableDelayedExpansion
title Cancer Survey Uninstaller
color 0C

cls
echo.
echo  ====================================================
echo   Cancer Survey - Uninstaller
echo  ====================================================
echo.
echo   This will remove:
echo     - App files  (%%LOCALAPPDATA%%\CancerSurvey^)
echo     - Launcher   (%%USERPROFILE%%\bin\cancer.cmd^)
echo     - Shortcuts  (Desktop + Start Menu^)
echo.
echo   Your JSON results in:
echo     %%USERPROFILE%%\cancer_survey_results\
echo   will NOT be deleted (your data is safe^).
echo.
echo  ====================================================
echo.
set /p CONFIRM="Are you sure? (y/n): "
if /I not "%CONFIRM%"=="y" (
    echo Cancelled.
    pause
    exit /b 0
)

echo.
echo  [*] Removing app files...
if exist "%LOCALAPPDATA%\CancerSurvey" (
    rmdir /S /Q "%LOCALAPPDATA%\CancerSurvey"
    echo  [OK] Removed app folder
)

echo  [*] Removing launcher...
if exist "%USERPROFILE%\bin\cancer.cmd" (
    del /Q "%USERPROFILE%\bin\cancer.cmd"
    echo  [OK] Removed cancer.cmd
)

echo  [*] Removing shortcuts...
if exist "%USERPROFILE%\Desktop\Cancer Survey.lnk" (
    del /Q "%USERPROFILE%\Desktop\Cancer Survey.lnk"
    echo  [OK] Desktop shortcut removed
)
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Cancer Survey.lnk" (
    del /Q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Cancer Survey.lnk"
    echo  [OK] Start Menu shortcut removed
)

echo.
echo  ====================================================
echo   UNINSTALL COMPLETE
echo  ====================================================
echo.
echo   Your JSON results are still in:
echo     %USERPROFILE%\cancer_survey_results\
echo.
echo   Developer: Raj Gautam  ^|  Cancer.ser
echo.
pause
endlocal