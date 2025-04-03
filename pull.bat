@echo off
setlocal enabledelayedexpansion

REM Define the path to yt-dlp and ffmpeg executables
set "ytDlpPath=%~dp0yt-dlp.exe"
set "ffmpegPath=%~dp0ffmpeg.exe"

REM Define the path to the Python executable and script
set "pythonPath=python.exe"  REM Update this to the path of your Python executable
set "pythonScript=%~dp0rename.py"

REM Define the path to the temp directory and videos directory
set "baseDir=H:\youtube"
set "tempDir=%baseDir%\temp"
set "videosDir=%baseDir%\videos"

REM Define the path to the channel list file
set "channelFile=%~dp0channels.txt"

REM Initialize the channel list variable
set "channelList="
set "downloadCount=5"

REM Check if the channel file exists
if not exist "%channelFile%" (
    echo Channel list file not found: %channelFile%
    exit /b 1
)

REM Read the channel names from the file and store them in channelList
for /f "tokens=*" %%i in (%channelFile%) do (
    set "channelList=!channelList! %%i"
)

REM Ensure the temp directory exists
if not exist "%tempDir%" (
    echo Creating temp directory: %tempDir%
    mkdir "%tempDir%"
)

for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
    set "currentDate=%%c-%%a-%%b"
)

REM Loop through each channel name in the list

REM Read and process each line in channels.txt
for /f "usebackq tokens=1,2 delims=:" %%A in ("%channelFile%") do (
    set "channelName=%%A"
    set "customURL=%%B"

    REM If no custom URL, use default YouTube channel videos page
    if "!customURL!"=="" (
        set "channelURL=https://www.youtube.com/@!channelName!/videos"
    ) else (
        set "channelURL=!customURL!"
    )

    set "channelDir=%videosDir%\!channelName!"
    set "outputDir=!channelDir!\Season 1"
    set "channelTempDir=%tempDir%\!channelName!"
    set "archiveFile=!channelTempDir!\downloaded.txt"

    REM Ensure necessary directories exist
    if not exist "!channelTempDir!" mkdir "!channelTempDir!"
    if not exist "!outputDir!" mkdir "!outputDir!"

    REM Determine next episode number
    if exist "!archiveFile!" (
        for /f "delims=" %%j in ('type "!archiveFile!" ^| find /c /v ""') do (
            set "episodeNumber=%%j"
        )
    ) else (
        set "episodeNumber=0"
    )


    REM Check if offset.txt exists and add its value to episodeNumber
    set "offset=0"
    if exist "!channelTempDir!\offset.txt" (
        for /f "delims=" %%o in ('type "!channelTempDir!\offset.txt"') do (
            set /a "offset=%%o"
        )
        set /a "episodeNumber+=offset"
    )

    echo Downloading from !channelURL!...

    rem --format "bestvideo[height>=720]+bestaudio/best" ^
    REM Loop for downloadCount
    for /L %%i in (1,1,%downloadCount%) do (
        set /a "episodeNumber+=1"
        set "episodeNumberPadded=000!episodeNumber!"
        set "episodeNumberPadded=!episodeNumberPadded:~-3!"

        "%ytDlpPath%" --ffmpeg-location "%ffmpegPath%" ^
            --download-archive "!archiveFile!" ^
            --max-downloads 1 ^
            --format "bestvideo[height>=1080]+bestaudio/best" ^
            --merge-output-format mp4 ^
            --playlist-items 1-%downloadCount% ^
            --playlist-reverse ^
            --output "!channelTempDir!\!channelName! - S01E!episodeNumberPadded! - %%(title)s.%%(ext)s" ^
            "!channelURL!"
    )

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
            "%ffmpegPath%" -i "!videoFile!" -metadata title="!episodeTitle!" -metadata date="%currentDate%" -metadata show="!channelName!" -metadata description="Episode !episode! of Season !season!" -metadata season_number=!season! -metadata episode_number=!episode! -codec copy "!channelTempDir!\temp_%%~nxf"

            REM Move the processed file to the channel directory
            move /Y "!channelTempDir!\temp_%%~nxf" "!outputDir!\%%~nxf"

            REM Delete the original file
            del "!videoFile!"
        )
    )
)

endlocal
echo Done!