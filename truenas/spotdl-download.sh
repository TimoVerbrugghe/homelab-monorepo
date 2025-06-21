#!/bin/sh
## Script which should be run from the terminal manually to download spotify liked songs & albums. Cannot be run as a cron job due to interactive authentication that's needed

SPOTDL_CONFIG="/mnt/FranzHopper/appdata/spotdl"
SPOTDL_MUSIC_FOLDER="/mnt/X.A.N.A./media/spotdl"

## SpotDL - Download all user saved albums
docker run -it --rm -v $SPOTDL_CONFIG:/root/.spotdl -v $SPOTDL_MUSIC_FOLDER:/music spotdl/spotify-downloader download all-user-saved-albums --config --user-auth --headless --output "{album}/{artists} - {title}.{output-ext}"

## SpotDL - Download all user liked songs
docker run -it --rm -v $SPOTDL_CONFIG:/root/.spotdl -v $SPOTDL_MUSIC_FOLDER/music spotdl/spotify-downloader download saved --config --user-auth --headless --output "{list-name}/{artists} - {title}.{output-ext}"
