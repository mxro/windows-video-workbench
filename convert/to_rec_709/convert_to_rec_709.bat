@echo off
setlocal enabledelayedexpansion

:: Convert Rec 2020 to Rec 709 color space
:: Usage: 
::   1. Drop a file onto this script, or
::   2. Run the script in a folder with media files

echo Convert Rec 2020 to Rec 709 Tool
echo ---------------------------------
echo.

REM Set ffmpeg path
:: Path to ffmpeg executable
set "BATCH_DIR=%~dp0"
:: Go up two directories from the batch file location to find the ffmpeg folder
for %%I in ("%BATCH_DIR%..\..") do set "ROOT_DIR=%%~fI\"
set "FFMPEG_PATH=%ROOT_DIR%ffmpeg\bin\ffmpeg.exe"
set "FFPROBE_PATH=%ROOT_DIR%ffmpeg\bin\ffprobe.exe"

:: Check if ffmpeg exists
if not exist "%FFMPEG_PATH%" (
    echo Error: ffmpeg executable not found at %FFMPEG_PATH%
    echo Please make sure the ffmpeg folder is in the correct location.
    goto :end
)

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
for %%F in (*.mp4 *.mkv) do (
    echo %%F | findstr /E /C:".rec709.mp4" /C:".rec709.mkv" >nul
    if errorlevel 1 (
        set found=1
        call :process_file "%%F"
    )
)

if !found! equ 0 (
    echo No suitable video files found in the current directory.
    echo Looking for *.mp4 and *.mkv files that haven't been processed yet.
    echo Please drop a file onto this script or place media files in the same folder.
)

:: Return to the original directory
popd

goto :end

:process_file
set input_file=%~1
set file_name=%~n1
set file_ext=%~x1

echo Processing: %input_file%

set "INPUT=%input_file%"
set "OUTPUT=%~n1.rec709%~x1"

echo Converting "!INPUT!" -> "!OUTPUT!"
echo.

echo File metadata:
echo --------------
"%FFPROBE_PATH%" -v quiet -print_format json -show_format -show_streams "!INPUT!"
echo.
echo Converting Rec 2020 to Rec 709...
echo.

"%FFMPEG_PATH%" -y -i "!INPUT!" ^
  -vf "zscale=primaries=bt709:transfer=bt709:matrix=bt709" ^
  -c:v libx264 ^
  -pix_fmt yuv420p ^
  -preset slow ^
  -crf 23 ^
  -c:a copy ^
  "!OUTPUT!"

echo.
echo Conversion complete for "!INPUT!"
echo.
goto :eof

echo All videos processed.

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
