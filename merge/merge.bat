@echo off
setlocal enabledelayedexpansion

:: Merge video/audio files into a single file
:: Usage: 
::   1. Drop files onto this script, or
::   2. Run the script in a folder with media files

echo Merge Video/Audio Tool
echo ---------------------
echo.

:: Path to ffmpeg executable
set FFMPEG_PATH=..\ffmpeg\bin\ffmpeg.exe

:: Check if ffmpeg exists
if not exist "%FFMPEG_PATH%" (
    echo Error: ffmpeg executable not found at %FFMPEG_PATH%
    echo Please make sure the ffmpeg folder is in the correct location.
    goto :end
)

:: Create a temporary file list
set "FILELIST=%TEMP%\merge_filelist.txt"
if exist "%FILELIST%" del "%FILELIST%"

:: Check if files were dropped onto the script
if "%~1" neq "" (
    :: Process dropped files
    echo Files were dropped onto the script.
    echo.
    
    :: Create output filename based on current date and time
    for /f "tokens=1-5 delims=/ " %%a in ('echo %date% %time%') do (
        set "OUTPUT_FILE=merged_%%a%%b%%c_%%d%%e.mp4"
        set "OUTPUT_FILE=!OUTPUT_FILE::=!"
    )
    
    :: Create file list for ffmpeg
    for %%F in (%*) do (
        echo file '%%~fF' >> "%FILELIST%"
        echo Added: %%~nxF
    )
) else (
    :: No files were dropped, process all media files in the current directory
    echo No files specified. Looking for media files in the current directory...
    echo.
    
    :: Create output filename based on current date and time
    for /f "tokens=1-5 delims=/ " %%a in ('echo %date% %time%') do (
        set "OUTPUT_FILE=merged_%%a%%b%%c_%%d%%e.mp4"
        set "OUTPUT_FILE=!OUTPUT_FILE::=!"
    )
    
    set found=0
    for %%F in (*.mp4 *.avi *.mkv *.mov *.wmv *.flv *.webm *.mp3 *.wav *.aac *.ogg *.flac *.m4a) do (
        set found=1
        echo file '%%~fF' >> "%FILELIST%"
        echo Added: %%~nxF
    )
    
    if !found! equ 0 (
        echo No media files found in the current directory.
        echo Please drop files onto this script or place media files in the same folder.
        goto :cleanup
    )
)

:: Check if we have files to merge
if not exist "%FILELIST%" (
    echo No files to merge.
    goto :cleanup
)

:: Count the number of files to merge
set /a count=0
for /f "usebackq" %%A in ("%FILELIST%") do set /a count+=1

if %count% LSS 2 (
    echo At least two files are required for merging.
    goto :cleanup
)

echo.
echo Found %count% files to merge.
echo Output file will be: %OUTPUT_FILE%
echo.
echo Starting merge process...

:: Merge the files using ffmpeg's concat demuxer
"%FFMPEG_PATH%" -f concat -safe 0 -i "%FILELIST%" -c copy "%OUTPUT_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Merge completed successfully!
    echo Output file: %OUTPUT_FILE%
) else (
    echo.
    echo Error occurred during merging.
)

:cleanup
:: Clean up temporary file
if exist "%FILELIST%" del "%FILELIST%"

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
