@echo off
setlocal enabledelayedexpansion

REM Set ffmpeg path
set FFMPEG_PATH=C:\Users\Max\Videos\ffmpeg-7.1\bin\ffmpeg.exe

REM Process only original MP4 and MKV files (excluding already processed ones)
for %%F in (*.mp4 *.mkv) do (
    echo %%F | findstr /E /C:".h264.mp4" /C:".h264.mkv" >nul
    if errorlevel 1 (
        set "INPUT=%%F"
        set "OUTPUT=%%~nF.h264%%~xF"

        echo Processing "!INPUT!" -> "!OUTPUT!"
        "%FFMPEG_PATH%" -y -i "!INPUT!" -c:v libx264 -preset slow -crf 23 -c:a copy "!OUTPUT!"
    )
)

echo All videos processed.
pause
