@echo off
setlocal enabledelayedexpansion

REM Set ffmpeg path
:: Path to ffmpeg executable
set "BATCH_DIR=%~dp0"
:: Go up two directories from the batch file location to find the ffmpeg folder
for %%I in ("%BATCH_DIR%..\..") do set "ROOT_DIR=%%~fI\"
set "FFMPEG_PATH=%ROOT_DIR%ffmpeg\bin\ffmpeg.exe"

REM Process only original MP4 and MKV files (excluding already processed ones)
for %%F in (*.mp4 *.mkv) do (
    echo %%F | findstr /E /C:".h264.mp4" /C:".h264.mkv" >nul
    if errorlevel 1 (
        set "INPUT=%%F"
        set "OUTPUT=%%~nF.h264%%~xF"

        echo Processing "!INPUT!" -> "!OUTPUT!"
        "%FFMPEG_PATH%" -y -i "!INPUT!" -c:v libx264 -pix_fmt yuv420p -preset slow -crf 23 -c:a copy "!OUTPUT!"
    )
)

echo All videos processed.
pause
