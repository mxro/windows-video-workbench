@echo off
setlocal enabledelayedexpansion

:: Display video metadata information
:: Usage: 
::   1. Drop a file onto this script, or
::   2. Run the script in a folder with media files

echo Video Metadata Information Tool
echo --------------------------------
echo.

REM Set ffmpeg path
:: Path to ffprobe executable
set "BATCH_DIR=%~dp0"
:: Go up one directory from the batch file location to find the ffmpeg folder
for %%I in ("%BATCH_DIR%..") do set "ROOT_DIR=%%~fI\"
set "FFPROBE_PATH=%ROOT_DIR%ffmpeg\bin\ffprobe.exe"

:: Check if ffprobe exists
if not exist "%FFPROBE_PATH%" (
    echo Error: ffprobe executable not found at %FFPROBE_PATH%
    echo Please make sure the ffmpeg folder is in the correct location.
    goto :end
)

:: Check if a file was dropped onto the script
if "%~1" neq "" (
    echo File was dropped onto the script.
    
    :: Count the number of files
    set file_count=0
    for %%F in (%*) do set /a file_count+=1
    echo Number of files to process: !file_count!
    echo.
    
    :: Process only the first file if multiple files were dropped
    if !file_count! GTR 1 (
        echo Note: Only the first file will be processed.
        echo.
    )
    
    call :process_file "%~1"
    goto :end
)

:: No file was dropped, process all media files in the current directory
echo No file specified. Looking for media files in the current directory...
echo.

:: Change to the batch file's directory to ensure we're looking in the right place
pushd "%BATCH_DIR%"

set found=0
for %%F in (*.mp4 *.mkv *.avi *.mov *.wmv *.flv *.webm) do (
    set found=1
    call :process_file "%%F"
)

if !found! equ 0 (
    echo No video files found in the current directory.
    echo Looking for *.mp4, *.mkv, *.avi, *.mov, *.wmv, *.flv, *.webm files.
    echo Please drop a file onto this script or place media files in the same folder.
)

:: Return to the original directory
popd

goto :end

:process_file
set input_file=%~1

echo ================================================================================
echo Processing: %input_file%
echo ================================================================================
echo.

set "INPUT=%input_file%"

echo File metadata (JSON format):
echo ----------------------------
"%FFPROBE_PATH%" -v quiet -print_format json -show_format -show_streams "!INPUT!"
echo.

echo File metadata (readable format):
echo --------------------------------
"%FFPROBE_PATH%" -v quiet -show_format -show_streams "!INPUT!"
echo.

echo Codec information:
echo ------------------
"%FFPROBE_PATH%" -v quiet -select_streams v:0 -show_entries stream=codec_name,codec_long_name,width,height,r_frame_rate,bit_rate,pix_fmt,color_space,color_primaries,color_transfer "!INPUT!"
echo.

echo Audio information:
echo ------------------
"%FFPROBE_PATH%" -v quiet -select_streams a:0 -show_entries stream=codec_name,codec_long_name,sample_rate,channels,bit_rate "!INPUT!"
echo.

echo File completed: "!INPUT!"
echo.
goto :eof

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
