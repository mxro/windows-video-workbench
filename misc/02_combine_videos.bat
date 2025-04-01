@echo off
ffmpeg-7.1\bin\ffmpeg -f concat -safe 0 -i input.txt -c copy output.mkv
pause