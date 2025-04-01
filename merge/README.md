# Video/Audio Merger

A simple batch script that merges multiple video or audio files into a single file without re-encoding.

## Features

- Merges any audio or video files into a single output file
- Preserves original quality (uses stream copy, no re-encoding)
- Works with files dropped onto the script
- Automatically processes all media files in the same folder when run directly
- Creates output filename based on current date and time

## Requirements

- Windows operating system
- FFmpeg (included in the `ffmpeg` folder)

## Usage

### Method 1: Drag and Drop

1. Select multiple video or audio files you want to merge
2. Drag and drop them onto the `merge.bat` file
3. The script will automatically merge the files in the order they were selected
4. The output file will be created in the same folder with a name like `merged_YYYYMMDD_HHMM.mp4`

### Method 2: Run in Folder

1. Place all the media files you want to merge in the same folder as the `merge.bat` script
2. Double-click the `merge.bat` script to run it
3. The script will process all supported media files in the folder in alphabetical order
4. The output file will be created in the same folder with a name like `merged_YYYYMMDD_HHMM.mp4`

## Supported File Formats

The script supports most common audio and video formats, including:

- Video: mp4, avi, mkv, mov, wmv, flv, webm
- Audio: mp3, wav, aac, ogg, flac, m4a

## Important Notes

- Files will be merged in the order they were selected (for drag and drop) or in alphabetical order (when running in folder)
- All input files should have compatible formats (same codec, resolution, etc.) for best results
- At least two files are required for merging
- The output format is MP4 by default

## How It Works

The script uses FFmpeg's concat demuxer to:
1. Create a temporary text file listing all input files
2. Merge the files into a single output file without re-encoding
3. Clean up the temporary file after processing

The merging process uses FFmpeg's stream copy mode, which means:
- No quality loss (no re-encoding)
- Fast processing (much quicker than re-encoding)
- Compatible formats are required for proper merging

## Customization

To change the output format or filename:

1. Open `merge.bat` in a text editor
2. Find the lines that set `OUTPUT_FILE` (there are two instances)
3. Modify the extension (default is .mp4) or naming pattern as desired
4. Save the file

## Troubleshooting

- **Error: ffmpeg executable not found**: Make sure the ffmpeg folder is in the correct location relative to the script
- **No media files found**: Ensure your files have one of the supported extensions
- **Error during merging**: This usually happens when trying to merge incompatible files. Try to ensure all files have the same format and codec
- **Files merged in wrong order**: When using the "Run in Folder" method, files are processed in alphabetical order. Use the drag and drop method to control the order
