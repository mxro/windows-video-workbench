@echo off
..\ffmpeg-7.1\bin\ffmpeg -i output.mkv -vf "transpose=1" -c:a copy output-rotated.mp4
if %ERRORLEVEL% neq 0 (
    echo.
    echo Error occurred. Press any key to exit...
    pause
)
