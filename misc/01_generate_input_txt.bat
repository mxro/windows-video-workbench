@echo off
echo Generating input.txt...

:: Delete existing input.txt if it exists
if exist input.txt del input.txt

:: Loop through MKV and MP4 files and write to input.txt
(for %%i in (*.mkv *.mp4) do echo file '%%i') > input.txt

echo input.txt generated successfully!
pause