@echo off
set ffmpeg_path=..\ffmpeg-7.1\bin\ffmpeg.exe
set input_file=IMG_4981.MOV
set output_file=output_all.mp4

%ffmpeg_path% -i "%input_file%" -vf "transpose=2" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 192k "%output_file%"

echo Conversion complete! Output saved as %output_file%
pause
