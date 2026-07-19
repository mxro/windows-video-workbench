@echo off
setlocal enabledelayedexpansion
set HAS_ERROR=0

REM Set ffmpeg path
:: Path to ffmpeg executable
set "BATCH_DIR=%~dp0"
:: Go up two directories from the batch file location to find the ffmpeg folder
for %%I in ("%BATCH_DIR%..\..") do set "ROOT_DIR=%%~fI\"
set "FFMPEG_PATH=%ROOT_DIR%ffmpeg\bin\ffmpeg.exe"

REM Process video files (excluding already processed ones)
for %%F in (*.mp4 *.mkv *.avi *.mov *.wmv *.flv *.webm *.m4v *.3gp *.ts *.mts *.m2ts) do (
    echo %%F | findstr /E /C:".to_mp4.mp4" >nul
    if errorlevel 1 (
        set "INPUT=%%F"
        set "OUTPUT=%%~nF.to_mp4.mp4"

        echo Processing "!INPUT!" -> "!OUTPUT!"
        "%FFMPEG_PATH%" -y -i "!INPUT!" -c copy -map_metadata 0 -movflags +faststart "!OUTPUT!"
        if !ERRORLEVEL! neq 0 set HAS_ERROR=1
    )
)

echo All videos processed.
if !HAS_ERROR! equ 1 (
    echo.
    echo Some errors occurred. Press any key to exit...
    pause >nul
)
endlocal
