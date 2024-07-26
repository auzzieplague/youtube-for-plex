@echo off
setlocal enabledelayedexpansion

REM Define the path to yt-dlp and ffmpeg executables
set "ytDlpPath=%~dp0yt-dlp_x86.exe"
set "ffmpegPath=%~dp0ffmpeg.exe"

REM Define the path to the Python executable and script
set "pythonPath=python.exe"  REM Update this to the path of your Python executable
set "pythonScript=%~dp0rename.py"

REM Define the path to the temp directory and videos directory
set "baseDir=H:\youtube"
set "tempDir=%baseDir%\temp"
set "videosDir=%baseDir%\videos"

REM Define the list of channel names
set "channelList="

REM Ensure the temp directory exists
if not exist "%tempDir%" (
    echo Creating temp directory: %tempDir%
    mkdir "%tempDir%"
)

REM Loop through each channel name in the list
for %%i in (%channelList%) do (
    set "channelName=%%i"
    set "channelDir=%videosDir%\!channelName!"
    set "outputDir=!channelDir!\Season 1"
    set "channelTempDir=%tempDir%\!channelName!"
    set "archiveFile=!channelTempDir!\downloaded.txt"

    REM Ensure the channel temp directory and output directory exist, create them if they don't
    if not exist "!channelTempDir!" (
        echo Creating directory: !channelTempDir!
        mkdir "!channelTempDir!"
    )
    if not exist "!outputDir!" (
        echo Creating directory: !outputDir!
        mkdir "!outputDir!"
    )

    REM Determine the next episode number by counting entries in the archive file
    if exist "!archiveFile!" (
        for /f "delims=" %%j in ('type "!archiveFile!" ^| find /c /v ""') do (
            set "episodeNumber=%%j"
        )
    ) else (
        set "episodeNumber=0"
    )

    set /a "episodeNumber+=1"
    set "episodeNumberPadded=000!episodeNumber!"
    set "episodeNumberPadded=!episodeNumberPadded:~-3!"

    REM Call yt-dlp with the specified settings for the current channel
    echo Downloading from https://www.youtube.com/@!channelName!/videos...
    "%ytDlpPath%" --download-archive "!archiveFile!" --max-downloads 1 --format "bestvideo[height>=720]+bestaudio/best[height>=720]" --merge-output-format mp4 --output "!channelTempDir!\!channelName! - S01E!episodeNumberPadded! - %%(title)s.%%(ext)s" --playlist-items 1-10 https://www.youtube.com/@!channelName!/videos

    REM Call the Python script to rename files
    echo Renaming files in !channelTempDir!...
    "%pythonPath%" "%pythonScript%" "!channelTempDir!"

    REM Process each downloaded video file
    for %%f in ("!channelTempDir!\*.mp4") do (
        set "videoFile=%%f"
        set "filename=%%~nxf"
        
        REM Extract parts from filename using multiple delimiters
        for /f "tokens=1-3 delims=-" %%a in ("!filename!") do (
            set "seriesTitle=%%a"
            set "seasonEpisode=%%b"
            set "episodeTitle=%%c"

            REM Clean up extracted titles
            set "seriesTitle=!seriesTitle: =!"
            set "seasonEpisode=!seasonEpisode: =!"
            set "episodeTitle=!episodeTitle:.mp4=!"
            
            REM Extract season and episode number
            for /f "tokens=1,2 delims= " %%x in ("!seasonEpisode!") do (
                set "season=%%x"
                set "episode=%%y"
            )
            
            REM Remove leading 'S' and 'E' from season and episode
            set "season=!season:S=!"
            set "episode=!episode:E=!"

            REM Set metadata
            echo Setting metadata for !videoFile!...
            "%ffmpegPath%" -i "!videoFile!" -metadata title="!episodeTitle!" -metadata description="Episode !episode! of Season !season!" -metadata season_number=!season! -metadata episode_number=!episode! -codec copy "!channelTempDir!\temp_%%~nxf"
            
            REM Move the processed file to the channel directory
            move /Y "!channelTempDir!\temp_%%~nxf" "!outputDir!\%%~nxf"
            
            REM Delete the original file
            del "!videoFile!"
        )
    )
)

endlocal
echo Done!
