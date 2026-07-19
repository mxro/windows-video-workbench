@echo off
echo Generating input.txt...

:: Delete existing input.txt if it exists
if exist input.txt del input.txt

:: Loop through MKV and MP4 files and write to input.txt
(for %%i in (*.mkv *.mp4) do echo file '%%i') > input.txt
if %ERRORLEVEL% neq 0 (
    echo.
    echo Error generating input.txt. Press any key to exit...
    pause
) else (
    echo input.txt generated successfully!
)