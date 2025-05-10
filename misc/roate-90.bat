@echo off
..\ffmpeg-7.1\bin\ffmpeg -i output.mkv -vf "transpose=1" -c:a copy output-rotated.mp4
pause
