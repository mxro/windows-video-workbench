# Media File Merger

This script allows you to easily merge multiple audio or video files into a single file using FFmpeg.

## Features

- Merges multiple media files into a single file
- Preserves the original quality (no re-encoding)
- Uses the file extension of the first file for the output
- Works with both drag-and-drop and files in the same directory
- Supports common media formats (mp4, avi, mkv, mov, wmv, flv, webm, mp3, wav, aac, ogg, flac, m4a)

## Requirements

- Windows operating system
- FFmpeg (included in the `ffmpeg` folder)

## Usage

### Method 1: Drag and Drop

1. Select the files you want to merge in File Explorer
2. Drag and drop them onto the `merge.bat` file
3. The files will be merged in the order they were selected
4. The output file will be created in the same directory as the script

### Method 2: Run in Directory

1. Place the media files you want to merge in the same directory as the `merge.bat` file
2. Double-click the `merge.bat` file to run it
3. The files will be merged in alphabetical order
4. The output file will be created in the same directory as the script

## Output File

- The output filename follows the format: `merged_YYYYMMDD_HHMMSS.ext`
- The file extension (`.ext`) is taken from the first file being merged
- For example: `merged_20250401_152842.mp4`

## How It Works

The script:
1. Checks if FFmpeg is available in the expected location
2. Creates a temporary file list for FFmpeg
3. Processes either dropped files or files in the current directory
4. Uses FFmpeg's concat demuxer to merge the files without re-encoding
5. Cleans up temporary files when done

## Troubleshooting

- **Error: ffmpeg executable not found**: Make sure the ffmpeg folder is in the correct location relative to the script
- **No media files found**: Ensure your media files are in the same directory as the script or that you've selected files to drop
- **Error during merging**: Check that all files are valid media files with compatible formats

## Customization

To add support for additional file formats, edit the script and add the extensions to the file search pattern:
```
for %%F in (*.mp4 *.avi *.mkv ... *.your_format) do (
```

## Notes

- The script preserves the original quality by using the `-c copy` option, which copies the streams without re-encoding
- For the best results, merge files with the same codec, resolution, and audio settings
- The script uses FFmpeg's concat demuxer, which is suitable for most media files
