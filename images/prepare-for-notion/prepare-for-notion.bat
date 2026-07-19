@echo off
setlocal enabledelayedexpansion

:: Notion Image Preparer
:: Usage: 
::   1. Drop image files onto this script, or
::   2. Run the script in a folder with image files
::
:: Creates .notion.jpg versions of files larger than 4.8 MB,
:: compressed to under 4.5 MB for Notion uploads.
:: HEIC/HEIF files are converted to JPEG since Notion doesn't support them.

echo Notion Image Preparer
echo ---------------------
echo.

set "BATCH_DIR=%~dp0"
for %%I in ("%BATCH_DIR%..\..") do set "ROOT_DIR=%%~fI\"
set "FFMPEG_PATH=%ROOT_DIR%ffmpeg\bin\ffmpeg.exe"
set "CONVERTER_PATH=%ROOT_DIR%tools\heicConverter.exe"

if not exist "%FFMPEG_PATH%" (
    echo Error: ffmpeg not found at %FFMPEG_PATH%
    goto :end
)

:: 4.8 MB threshold, 4.5 MB target (in bytes)
set SIZE_THRESHOLD=5033165
set MAX_SIZE=4718592

if "%~1" neq "" (
    echo Files were dropped onto the script.
    set file_count=0
    for %%F in (%*) do set /a file_count+=1
    echo Number of files: !file_count!
    echo.

    set processed=0
    for %%F in (%*) do call :process_file "%%~fF"

    echo.
    echo Total files processed: !processed!
) else (
    echo No files specified. Looking in the current directory...
    echo.

    pushd "%BATCH_DIR%"

    set found=0
    for %%F in (*.jpg *.jpeg *.heic *.heif) do (
        set found=1
        goto :found_files
    )

    :found_files
    if !found! equ 0 (
        echo No supported image files found.
        popd
        goto :end
    )

    echo Processing all image files...
    echo.

    set processed=0
    for %%F in (*.jpg *.jpeg *.heic *.heif) do call :process_file "%%~fF"

    echo.
    echo Total files processed: !processed!
    popd
)

echo.
echo Done!
goto :end

:process_file
set "fp=%~1"
set "ext=%~x1"
set "dir=%~dp1"
set "dir=!dir:~0,-1!"
set "name=%~n1"
set "fsize=%~z1"

set "output=!dir!\!name!.notion.jpg"

if /i "!ext!"==".heic" (
    echo Processing: %~nx1 [HEIC, !fsize! bytes]
    if exist "%CONVERTER_PATH%" (
        set "TMPJPG=!dir!\!name!.tmp.jpg"
        "%CONVERTER_PATH%" --files "!fp!" -q 100 -t "!dir!" --skip-prompt >nul 2>&1
        if exist "!dir!\!name!.jpg" move /y "!dir!\!name!.jpg" "!TMPJPG!" >nul
        if exist "!TMPJPG!" (
            call :maybe_compress "!TMPJPG!" "!output!"
            del "!TMPJPG!" >nul 2>&1
            set /a processed+=1
        ) else (
            echo   Error: conversion failed
        )
    ) else (
        echo   Error: heicConverter not found, skipping
    )
) else if /i "!ext!"==".heif" (
    echo Processing: %~nx1 [HEIF, !fsize! bytes]
    if exist "%CONVERTER_PATH%" (
        set "TMPJPG=!dir!\!name!.tmp.jpg"
        set "TMPHEIC=%TEMP%\!name!.heic"
        copy /y "!fp!" "!TMPHEIC!" >nul
        "%CONVERTER_PATH%" --files "!TMPHEIC!" -q 100 -t "!dir!" --skip-prompt >nul 2>&1
        if exist "!dir!\!name!.jpg" move /y "!dir!\!name!.jpg" "!TMPJPG!" >nul
        del "!TMPHEIC!" >nul 2>&1
        if exist "!TMPJPG!" (
            call :maybe_compress "!TMPJPG!" "!output!"
            del "!TMPJPG!" >nul 2>&1
            set /a processed+=1
        ) else (
            echo   Error: conversion failed
        )
    ) else (
        echo   Error: heicConverter not found, skipping
    )
) else if /i "!ext!"==".jpg" (
    if !fsize! leq %SIZE_THRESHOLD% (
        echo Skipped: %~nx1 ^(already under 4.8 MB^)
        goto :eof
    )
    echo Processing: %~nx1 [JPEG, !fsize! bytes]
    call :compress_to_target "!fp!" "!output!"
    set /a processed+=1
) else if /i "!ext!"==".jpeg" (
    if !fsize! leq %SIZE_THRESHOLD% (
        echo Skipped: %~nx1 ^(already under 4.8 MB^)
        goto :eof
    )
    echo Processing: %~nx1 [JPEG, !fsize! bytes]
    call :compress_to_target "!fp!" "!output!"
    set /a processed+=1
) else (
    echo Skipped: %~nx1 ^(unsupported format^)
)
goto :eof

:maybe_compress
for %%S in (%1) do set tmpsize=%%~zS
if !tmpsize! leq %MAX_SIZE% (
    echo   Already under 4.5 MB, no compression needed
    copy /y %1 %2 >nul
) else (
    call :compress_to_target %1 %2
)
goto :eof

:compress_to_target
for %%q in (2 3 4 5 6 7 8 10 12 14 17 20 24 28 31) do (
    "%FFMPEG_PATH%" -y -i %1 -q:v %%q %2
    for %%S in (%2) do set outsize=%%~zS
    if !outsize! leq %MAX_SIZE% goto :eof
)
goto :eof

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
