@echo off
setlocal enabledelayedexpansion

:: Audio to MP3 Converter
:: Usage:
::   1. Drop audio files onto this script, or
::   2. Run the script in a folder with audio files

echo Audio to MP3 Converter
echo -----------------------
echo.

:: Path to ffmpeg executable
set "BATCH_DIR=%~dp0"
:: Go up two directories from the batch file location to find the ffmpeg folder
for %%I in ("%BATCH_DIR%..\..") do set "ROOT_DIR=%%~fI\"
set "FFMPEG_PATH=%ROOT_DIR%ffmpeg\bin\ffmpeg.exe"


:: Check if ffmpeg exists
if not exist "%FFMPEG_PATH%" (
    echo Error: ffmpeg executable not found at %FFMPEG_PATH%
    echo Please make sure the ffmpeg folder is in the correct location.
    goto :end
)

:: Create a timestamp for the output directory
set "TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "OUTPUT_DIR=%BATCH_DIR%converted_%TIMESTAMP%"

:: Create output directory if it doesn't exist
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Check if files were dropped onto the script
if "%~1" neq "" (
    :: Process dropped files
    echo Files were dropped onto the script.

    :: Count the number of files
    set file_count=0
    for %%F in (%*) do set /a file_count+=1
    echo Number of files to process: !file_count!
    echo.

    :: Process ONLY the dropped files
    set audio_count=0
    for %%F in (%*) do (
        if /i "%%~xF"==".wav" (
            set /a audio_count+=1
            echo Converting [!audio_count!]: %%~nxF
            "%FFMPEG_PATH%" -y -i "%%~fF" -codec:a libmp3lame -b:a 320k "%OUTPUT_DIR%\%%~nF.mp3"
            echo Converted to: converted_%TIMESTAMP%\%%~nF.mp3
        ) else if /i "%%~xF"==".flac" (
            set /a audio_count+=1
            echo Converting [!audio_count!]: %%~nxF
            "%FFMPEG_PATH%" -y -i "%%~fF" -codec:a libmp3lame -b:a 320k "%OUTPUT_DIR%\%%~nF.mp3"
            echo Converted to: converted_%TIMESTAMP%\%%~nF.mp3
        ) else if /i "%%~xF"==".aac" (
            set /a audio_count+=1
            echo Converting [!audio_count!]: %%~nxF
            "%FFMPEG_PATH%" -y -i "%%~fF" -codec:a libmp3lame -b:a 320k "%OUTPUT_DIR%\%%~nF.mp3"
            echo Converted to: converted_%TIMESTAMP%\%%~nF.mp3
        ) else if /i "%%~xF"==".ogg" (
            set /a audio_count+=1
            echo Converting [!audio_count!]: %%~nxF
            "%FFMPEG_PATH%" -y -i "%%~fF" -codec:a libmp3lame -b:a 320k "%OUTPUT_DIR%\%%~nF.mp3"
            echo Converted to: converted_%TIMESTAMP%\%%~nF.mp3
        ) else if /i "%%~xF"==".m4a" (
            set /a audio_count+=1
            echo Converting [!audio_count!]: %%~nxF
            "%FFMPEG_PATH%" -y -i "%%~fF" -codec:a libmp3lame -b:a 320k "%OUTPUT_DIR%\%%~nF.mp3"
            echo Converted to: converted_%TIMESTAMP%\%%~nF.mp3
        ) else if /i "%%~xF"==".wma" (
            set /a audio_count+=1
            echo Converting [!audio_count!]: %%~nxF
            "%FFMPEG_PATH%" -y -i "%%~fF" -codec:a libmp3lame -b:a 320k "%OUTPUT_DIR%\%%~nF.mp3"
            echo Converted to: converted_%TIMESTAMP%\%%~nF.mp3
        ) else (
            echo Skipped: %%~nxF (not a supported audio file)
        )
    )

    echo Total audio files converted: !audio_count!
) else (
    :: No files were dropped, process all audio files in the current directory
    echo No files specified. Looking for audio files in the current directory...
    echo.

    :: Change to the batch file's directory to ensure we're looking in the right place
    pushd "%BATCH_DIR%"

    set found=0
    :: Check if any audio files exist
    for %%F in (*.wav *.flac *.aac *.ogg *.m4a *.wma) do (
        set found=1
        goto :found_files
    )

    :found_files
    :: If no files found, exit
    if !found! equ 0 (
        echo No audio files found in the current directory.
        echo Please drop audio files onto this script or place audio files in the same folder.
        popd
        goto :end
    )

    :: Convert all audio files in the current directory
    echo Converting all audio files in the current directory...
    echo.

    set audio_count=0
    for %%F in (*.wav *.flac *.aac *.ogg *.m4a *.wma) do (
        set /a audio_count+=1
        echo Converting [!audio_count!]: %%~nxF
        "%FFMPEG_PATH%" -y -i "%%~fF" -codec:a libmp3lame -b:a 320k "%OUTPUT_DIR%\%%~nF.mp3"
        echo Converted to: converted_%TIMESTAMP%\%%~nF.mp3
    )

    echo Total audio files converted: !audio_count!
    echo All files converted to: converted_%TIMESTAMP%

    :: Return to the original directory
    popd
)

echo.
echo Conversion completed!
echo Converted files are in the "converted_%TIMESTAMP%" directory.

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
