# spotdl Docker Usage

After deploying the spotdl Docker container, configure it as follows:

- **Web GUI:** Place `spotdl-config-web.json` file in the spotdl config directory.
- **Headless:** Place `spotdl-config.json` file in the spotdl config directory.

**Important:**  
You must fill out the `client_id` and `client_secret` fields in your config file.  
To obtain these values:

1. Go to the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/applications).
2. Log in and create a new application (or select an existing one).
3. Copy the `Client ID` and `Client Secret` from your app's settings.
4. Paste these values into the corresponding fields in your `spotdl-config-web.json` or `spotdl-config.json` file.

For more details, see [this GitHub issue](https://github.com/spotDL/spotify-downloader/issues/2142).

Additionally, you must add a `cookies.txt` file to the config directory. For instructions on generating this file, refer to the [official spotdl documentation](https://spotdl.readthedocs.io/en/latest/usage/#youtube-music-premium).
