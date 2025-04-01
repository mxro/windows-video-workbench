@echo off
setlocal enabledelayedexpansion

:: Split video/audio files into 25-minute segments
:: Usage: 
::   1. Drop a file onto this script, or
::   2. Run the script in a folder with media files

echo Split Video/Audio Tool
echo ----------------------
echo.

:: Set the maximum segment length in seconds (25 minutes = 1500 seconds)
set MAX_LENGTH=1500

:: Path to ffmpeg executable
set FFMPEG_PATH=..\ffmpeg\bin\ffmpeg.exe
set FFPROBE_PATH=..\ffmpeg\bin\ffprobe.exe

:: Check if ffmpeg exists
if not exist "%FFMPEG_PATH%" (
    echo Error: ffmpeg executable not found at %FFMPEG_PATH%
    echo Please make sure the ffmpeg folder is in the correct location.
    goto :end
)

:: Check if a file was dropped onto the script
if "%~1" neq "" (
    call :process_file "%~1"
    goto :end
)

:: No file was dropped, process all media files in the current directory
echo No file specified. Looking for media files in the current directory...
echo.

set found=0
for %%F in (*.mp4 *.avi *.mkv *.mov *.wmv *.flv *.webm *.mp3 *.wav *.aac *.ogg *.flac *.m4a) do (
    set found=1
    call :process_file "%%F"
)

if !found! equ 0 (
    echo No media files found in the current directory.
    echo Please drop a file onto this script or place media files in the same folder.
)

goto :end

:process_file
set input_file=%~1
set file_name=%~n1
set file_ext=%~x1

echo Processing: %input_file%

:: Get duration in seconds using ffprobe
for /f "tokens=*" %%a in ('"%FFPROBE_PATH%" -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%input_file%"') do (
    set duration=%%a
)

:: Remove decimal part
for /f "tokens=1 delims=." %%a in ("!duration!") do set duration=%%a

echo File duration: !duration! seconds
echo Maximum segment length: %MAX_LENGTH% seconds

:: Calculate number of segments needed
set /a segments=(!duration!+%MAX_LENGTH%-1)/%MAX_LENGTH%
echo Number of segments: !segments!

:: Create output directory if it doesn't exist
set output_dir=%file_name%_split
if not exist "%output_dir%" mkdir "%output_dir%"

:: Split the file into segments
echo Splitting file into !segments! segments...
echo.

"%FFMPEG_PATH%" -i "%input_file%" -c copy -map 0 -segment_time %MAX_LENGTH% -f segment -reset_timestamps 1 "%output_dir%\%file_name%_part%%02d%file_ext%"

echo.
echo Splitting complete! Output files are in the "%output_dir%" folder.
echo.
goto :eof

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
