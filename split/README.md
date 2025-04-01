# Video/Audio Splitter

A simple batch script that splits video or audio files into segments of a specified maximum length (default: 25 minutes).

## Features

- Splits any audio or video file into segments of a specified length
- Preserves original quality (uses stream copy, no re-encoding)
- Works with files dropped onto the script
- Automatically processes all media files in the same folder when run directly
- Creates a separate output folder for each split file

## Requirements

- Windows operating system
- FFmpeg (included in the `ffmpeg` folder)

## Usage

### Method 1: Drag and Drop

1. Simply drag and drop any video or audio file onto the `split.bat` file
2. The script will automatically split the file into segments of 25 minutes or less
3. Output files will be placed in a new folder named `[original_filename]_split`

### Method 2: Run in Folder

1. Place your media files in the same folder as the `split.bat` script
2. Double-click the `split.bat` script to run it
3. The script will process all supported media files in the folder
4. Output files will be placed in separate folders for each input file

## Supported File Formats

The script supports most common audio and video formats, including:

- Video: mp4, avi, mkv, mov, wmv, flv, webm
- Audio: mp3, wav, aac, ogg, flac, m4a

## Configuration

To change the maximum segment length (default is 25 minutes):

1. Open `split.bat` in a text editor
2. Find the line: `set MAX_LENGTH=1500`
3. Change `1500` to your desired length in seconds
   - For example, for 10-minute segments, use `set MAX_LENGTH=600`
   - For 1-hour segments, use `set MAX_LENGTH=3600`
4. Save the file

## How It Works

The script uses FFmpeg to:
1. Determine the duration of the input file
2. Calculate how many segments are needed
3. Split the file into segments of the specified maximum length
4. Place the output files in a dedicated folder

The splitting process uses FFmpeg's segment feature with stream copying, which means:
- No quality loss (no re-encoding)
- Fast processing (much quicker than re-encoding)
- Segments are cut at the nearest keyframe, so the exact length may vary slightly

## Troubleshooting

- **Error: ffmpeg executable not found**: Make sure the ffmpeg folder is in the correct location relative to the script
- **No media files found**: Ensure your files have one of the supported extensions
- **Output files have incorrect timing**: This is normal as the script splits at keyframes for better compatibility
