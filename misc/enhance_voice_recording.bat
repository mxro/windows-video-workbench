@echo off
setlocal

:: Set FFmpeg path
set FFMPEG_PATH=C:\Users\Max\Videos\ffmpeg-7.1\bin\ffmpeg.exe

:: Check if input file is provided
if "%~1"=="" (
    echo Usage: Drag and drop an M4A file onto this script or run it with an input file.
    pause
    exit /b
)

:: Define input and output file names
set INPUT_FILE=%~1
set OUTPUT_FILE=%~dpn1_processed.m4a

:: Apply noise gate and normalization
"%FFMPEG_PATH%" -i "%INPUT_FILE%" -af "volume=10dB,highpass=f=80,afftdn=nr=20" "%OUTPUT_FILE%"

echo Processing complete! Output file: %OUTPUT_FILE%
pause
