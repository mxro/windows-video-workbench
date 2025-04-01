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

:: Variables to store the first file's extension
set "FIRST_FILE_EXT=.mp4"
set "FIRST_FILE="

:: Create a simple timestamp for the output file
set "TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"

:: Check if files were dropped onto the script
if "%~1" neq "" (
    :: Process dropped files
    echo Files were dropped onto the script.
    echo.
    
    :: Get the first file and its extension
    set "FIRST_FILE=%~1"
    set "FIRST_FILE_EXT=%~x1"
    
    echo First file: %FIRST_FILE%
    echo Extension detected: %FIRST_FILE_EXT%
    
    :: Create file list for ffmpeg
    for %%F in (%*) do (
        echo file '%%~fF' >> "%FILELIST%"
        echo Added: %%~nxF
    )
) else (
    :: No files were dropped, process all media files in the current directory
    echo No files specified. Looking for media files in the current directory...
    echo.
    
    set found=0
    :: First pass to find the first file and get its extension
    for %%F in (*.mp4 *.avi *.mkv *.mov *.wmv *.flv *.webm *.mp3 *.wav *.aac *.ogg *.flac *.m4a) do (
        if !found! equ 0 (
            set "FIRST_FILE=%%F"
            set "FIRST_FILE_EXT=%%~xF"
            echo First file found: !FIRST_FILE!
            echo Extension detected: !FIRST_FILE_EXT!
            set found=1
        )
        echo file '%%~fF' >> "%FILELIST%"
        echo Added: %%~nxF
    )
    
    :: If no files found, exit
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

:: Ensure extension starts with a dot
if "!FIRST_FILE_EXT:~0,1!" neq "." (
    set "FIRST_FILE_EXT=.!FIRST_FILE_EXT!"
)

:: If extension is empty or invalid, default to .mp4
if "!FIRST_FILE_EXT!"=="" (
    set "FIRST_FILE_EXT=.mp4"
    echo No extension detected, defaulting to .mp4
)

:: Create the output filename
set "OUTPUT_FILE=merged_%TIMESTAMP%%FIRST_FILE_EXT%"

echo.
echo Found %count% files to merge.
echo Output file will be: %OUTPUT_FILE%
echo Using extension: %FIRST_FILE_EXT%
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
    echo Command used: "%FFMPEG_PATH%" -f concat -safe 0 -i "%FILELIST%" -c copy "%OUTPUT_FILE%"
)

:cleanup
:: Clean up temporary file
if exist "%FILELIST%" del "%FILELIST%"

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
