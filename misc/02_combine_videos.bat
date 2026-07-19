@echo off
ffmpeg-7.1\bin\ffmpeg -f concat -safe 0 -i input.txt -c copy output.mkv
if %ERRORLEVEL% neq 0 (
    echo.
    echo Error occurred during merging. Press any key to exit...
    pause
)