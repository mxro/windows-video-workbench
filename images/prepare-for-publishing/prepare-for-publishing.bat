@echo off
setlocal enabledelayedexpansion

:: Image Prepare for Publishing
:: Usage: 
::   1. Drop image files onto this script, or
::   2. Run the script in a folder with image files
:: Converts all image formats to JPEG with medium quality and removes metadata

echo Image Prepare for Publishing
echo ----------------------------
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
set "OUTPUT_DIR=%BATCH_DIR%published_%TIMESTAMP%"

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
    set image_count=0
    for %%F in (%*) do (
        call :process_image "%%~fF" "%%~nxF" "%%~nF" "%%~xF"
    )
    
    echo Total image files processed: !image_count!
) else (
    :: No files were dropped, process all image files in the current directory
    echo No files specified. Looking for image files in the current directory...
    echo.
    
    :: Change to the batch file's directory to ensure we're looking in the right place
    pushd "%BATCH_DIR%"
    
    set found=0
    :: Check if any image files exist
    for %%F in (*.jpg *.jpeg *.png *.bmp *.tiff *.tif *.webp *.gif *.heic *.heif) do (
        set found=1
        goto :found_files
    )
    
    :found_files
    :: If no files found, exit
    if !found! equ 0 (
        echo No image files found in the current directory.
        echo Please drop image files onto this script or place image files in the same folder.
        echo Supported formats: JPG, JPEG, PNG, BMP, TIFF, TIF, WEBP, GIF, HEIC, HEIF
        popd
        goto :end
    )
    
    :: Process all image files in the current directory
    echo Processing all image files in the current directory...
    echo.
    
    set image_count=0
    for %%F in (*.jpg *.jpeg *.png *.bmp *.tiff *.tif *.webp *.gif *.heic *.heif) do (
        call :process_image "%%~fF" "%%~nxF" "%%~nF" "%%~xF"
    )
    
    echo Total image files processed: !image_count!
    echo All files processed to: published_%TIMESTAMP%
    
    :: Return to the original directory
    popd
)

echo.
echo Processing completed!
echo Published files are in the "published_%TIMESTAMP%" directory.

:end
echo.
echo Press any key to exit...
pause >nul
endlocal
goto :eof

:: Function to process individual image files
:process_image
set "file_path=%~1"
set "file_name=%~2"
set "base_name=%~3"
set "extension=%~4"

:: Check if it's a supported image format
set "is_image=0"
if /i "%extension%"==".jpg" set "is_image=1"
if /i "%extension%"==".jpeg" set "is_image=1"
if /i "%extension%"==".png" set "is_image=1"
if /i "%extension%"==".bmp" set "is_image=1"
if /i "%extension%"==".tiff" set "is_image=1"
if /i "%extension%"==".tif" set "is_image=1"
if /i "%extension%"==".webp" set "is_image=1"
if /i "%extension%"==".gif" set "is_image=1"
if /i "%extension%"==".heic" set "is_image=1"
if /i "%extension%"==".heif" set "is_image=1"

if !is_image! equ 1 (
    set /a image_count+=1
    echo Processing [!image_count!]: %file_name%
    "%FFMPEG_PATH%" -y -i "%file_path%" -q:v 5 -map_metadata -1 "%OUTPUT_DIR%\%base_name%.jpg"
    echo Converted to: published_%TIMESTAMP%\%base_name%.jpg
) else (
    echo Skipped: %file_name% (not a supported image file)
)

goto :eof
