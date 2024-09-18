# Usage
![Logo](https://github.com/auzzieplague/youtube-for-plex/blob/main/Icons/Plex.jpg?raw=true)

I created this helper tool to dump my selected youtube channels into plex so I can stream them locally on my network.
The batch script will leverage yt-dlp to pull a single video/audio feed at high quality, if that fails it will pull them independently 
and merge them. The meta data is then injected into the file using ffmpeg and the file is dropped into a season 1 folder that plex
can understand. Optionally you can add folder.jpg for the channel, you must setup the plex youtube library as described below.

---
# Setup

Update `pull.bat` with your preferences:

- Set paths to executables (listed below).
- Add channels to channels.txt file (a channel on each line)
- Update quality in yt-dlp options line. E.g., `bestvideo[height>=720]`.
- Set number of downloads to process each run. E.g., `--max-downloads 1`.
- Set playlist items to check. E.g., `--playlist-items 1-10`.
- Set a cron job to run `pull.bat` each night. E.g., Task Scheduler.

# Required .exe's

Install Python, download ffmpeg and a YouTube downloader:

- `yt-dlp_x86.exe` (or equivalent, update `pull.bat` with your version) https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
- `ffmpeg.exe` (for merging audio/video streams) https://github.com/BtbN/FFmpeg-Builds/releases
- `ffprobe.exe` (not required, just get some warnings without it)
- `python.exe` https://www.python.org/downloads/windows/
> place these exe's into the project folder along side pull.bat or adjust the paths in pull.bat (e.g "ffmpegPath=%~dp0ffmpeg.exe")

# Plex Setup

Plex TV shows require the following naming structure:

`season 1\ channel - s01e01 - title`

When setting up the Plex library:

- Add new TV SHOWS type.
- Add folder `\youtube\videos` (or whatever you have set `videosDir=%baseDir%\videos` set to in pull.bat)
- Select Plex TV series.
- Select Plex series.
- Select Prefer artwork based on library language.
- Select Use local assets.
- Select Prefer local metadata.

Add `folder.jpg` to each folder.

The "prefer local metadata" setting in Plex gets the names from file metadata. 
We push the filename as the title into metadata during the import with ffmpeg, this is how we capture episode names.
