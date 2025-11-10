@echo off
setlocal EnableDelayedExpansion

:: Audio Splitter — robust for MP4/M4A using segment muxer
:: Splits audio into 5-minute parts. Keeps original codec when possible.

echo Audio Splitter
echo --------------
echo Splits audio files into 5-minute segments

:: Paths
set "BATCH_DIR=%~dp0"
for %%I in ("%BATCH_DIR%..\..") do set "ROOT_DIR=%%~fI\"
set "FFMPEG_PATH=%ROOT_DIR%ffmpeg\bin\ffmpeg.exe"

if not exist "%FFMPEG_PATH%" (
	echo Error: ffmpeg executable not found at "%FFMPEG_PATH%"
	goto :end
)

:: Timestamp and output dir
set "TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "OUTPUT_DIR=%BATCH_DIR%split_%TIMESTAMP%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

if "%~1" neq "" (
	set audio_count=0
	for %%F in (%*) do (
		call :process_file "%%~fF" "%%~nF" "%%~xF"
	)
) else (
	pushd "%BATCH_DIR%"
	echo Current directory: %CD%
	echo Looking for audio files...
	set found=0
	for %%F in (*.wav *.flac *.aac *.ogg *.m4a *.wma *.mp3 *.mp4) do (
		echo Found file: %%F
		set found=1
		goto :found_files
	)
:found_files
	if !found! equ 0 (
		echo No audio files found in the current directory.
		popd
		goto :end
	)
	set audio_count=0
	for %%F in (*.wav *.flac *.aac *.ogg *.m4a *.wma *.mp3 *.mp4) do (
		call :process_file "%%~fF" "%%~nF" "%%~xF"
	)
	popd
)

echo.
echo Done. Output folder: "%OUTPUT_DIR%"

goto :eof

:process_file
set "input_file=%~1"
set "base_name=%~2"
set "ext=%~3"

echo Processing file: %base_name%%ext% with extension: %ext%


set /a audio_count+=1
set "file_output_dir=%OUTPUT_DIR%\%base_name%"
if not exist "%file_output_dir%" mkdir "%file_output_dir%"

echo Processing [!audio_count!]: %base_name%%ext%

:: Try fast split with stream copy using segment muxer
:: - segment_time 300 seconds (5 minutes)
:: - reset_timestamps to keep each part starting at 0
echo Running stream copy ffmpeg for %base_name%%ext%...
"%FFMPEG_PATH%" -hide_banner -loglevel warning -y -i "%input_file%" ^
  -map 0:a:0 -f segment -segment_time 300 -reset_timestamps 1 -c copy ^
  "%file_output_dir%\%base_name%_part%%03d%ext%"
echo Stream copy errorlevel: %errorlevel%

if errorlevel 1 (
	:: Fallback: re-encode audio to ensure clean cut points
	echo Stream-copy split failed. Falling back to re-encode for %base_name%%ext%...
	set "acodec=aac"
	if /i "%ext%"==".mp3" set "acodec=libmp3lame"
	if /i "%ext%"==".wav" set "acodec=pcm_s16le"
	echo Running re-encode ffmpeg with acodec=%acodec% for %base_name%%ext%...
	"%FFMPEG_PATH%" -hide_banner -loglevel warning -y -i "%input_file%" ^
	  -map 0:a:0 -f segment -segment_time 300 -reset_timestamps 1 -c:a %acodec% -b:a 192k ^
	  "%file_output_dir%\%base_name%_part%%03d%ext%"
	echo Re-encode errorlevel: %errorlevel%
)

:: Report parts created
echo Looking for parts: "%file_output_dir%\%base_name%_part*.%ext:~1%"
set parts_created=0
for %%P in ("%file_output_dir%\%base_name%_part*.%ext:~1%") do (
	echo Found part: %%P
	set /a parts_created+=1
	goto :have_parts
)
:have_parts
if !parts_created! gtr 0 (
	echo   Created !parts_created! parts for %base_name%%ext%
) else (
	echo   No parts created for %base_name%%ext% (see messages above)
)

goto :eof

:end
endlocal
