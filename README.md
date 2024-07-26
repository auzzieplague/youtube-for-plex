# Usage

Update `pull.bat` with your preferences:

- Set paths to executables (listed below).
- Add channels to `channelList`. E.g., `set "channelList=channel1 channel2 channel3"`.
- Update quality in yt-dlp options line. E.g., `bestvideo[height>=720]`.
- Set number of downloads to process each run. E.g., `--max-downloads 1`.
- Set playlist items to check. E.g., `--playlist-items 1-10`.
- Set a cron job to run `pull.bat` each night. E.g., Task Scheduler.

# Required .exe's

Install Python, download FFmpeg and a YouTube downloader:

- `yt-dlp_x86.exe` (or equivalent, update `pull.bat` with your version)
- `ffmpeg.exe` (for merging audio/video streams)
- `ffprobe.exe` (not required, just get some warnings without it)
- `python.exe`

# Plex Setup

Plex TV shows require the following naming structure:

`season 1\ channel - s01e01 - title`

When setting up the Plex library:

- Add new TV SHOWS type.
- Add folder `\youtube\videos`.
- Plex TV series.
- Plex series.
- Prefer artwork based on library language.
- Use local assets.
- Prefer local metadata.

Add `folder.jpg` to each folder.

The "Prefer local metadata" setting in Plex uses the names from file metadata. We push the filename as title into metadata during the import with FFmpeg.
