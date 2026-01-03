# Installing Older PC Games on SteamOS/Steam Deck

This guide was written to explain how to install some specific older PC games that I have on the Steam Deck using SteamOS. Heavily inspired by [this guide](https://rentry.co/steamdeckpiratescove).

## steamos-installed folder

It might be that I have already installed these games in the past in `/home/deck/Games/Games` and zipped that folder onto my NAS. In that case, extract the zipped folder back to `/home/deck/Games/Games` and follow only the post-installation steps described below.

## Default Installation Steps

1. **Extract the Game Files**  
    Unpack the game's ISO or ZIP file.

2. **Add Setup to Steam**  
    Add the game's `setup.exe` as a non-Steam game in Steam.

3. **Enable Compatibility Mode**  
    In Steam, set the non-Steam game to run with **Proton Experimental** (right-click > Properties > Compatibility).

4. **Install the Game**  
    Run the setup and install the game to:  

    ```bash
    /home/deck/Games/Games/<game-name>
    ```

5. **Replace Setup with Game Executable**  
    Remove the setup entry from Steam.  
    Add the installed game's executable (found in `/home/deck/Games/Games/<game-name>`) as a non-Steam game.  
    Enable **Proton Experimental** compatibility for this entry.

---

## Additional Requirements for Some Games

Some games may need extra steps or tools:

### Tools to Install

- **Protontricks**  
  Install from the Discover store.
- **Flatseal**  
  Install from the Discover store.  
  Use Flatseal to grant Protontricks full access to your home folder.

---

### Enable Virtual Desktop

Some games force a specific resolution and need a virtual desktop:

1. Open **Protontricks**.
2. Select the game (as added in Steam).
3. Choose "Use the default wineprefix".
4. Go to "Change Settings".
5. Set `vd=<resolution>` (e.g., `vd=1024x768`).

**Games needing this:**  

- Miel Monteur Bouwt Auto's  
- Miel Monteur Vliegt De Wereld Rond  
- Miel Monteur Verkent de Ruimte  
- Skippy & Het Geheim van de Gestolen Papyrusrol

---

### Emulate CD Drive

Some games require a CD to be present:

1. Extract the ISO/ZIP to `/home/deck/Games/Games/`.
2. Open **Protontricks**.
3. Select the game in Steam.
4. Choose "Use the default wineprefix".
5. Run **WineCfg**.
6. Go to the "Drives" tab.
7. Add a drive letter (e.g., `E:`) and point it to the extracted ISO folder.

**Games needing this:**  

- Miel Monteur Verkent de Ruimte

---

### Games That Don't Need Installation

Some games can be played by simply extracting and adding the executable:

1. Extract the ISO/ZIP directly to `/home/deck/Games/Games/`.
2. Add the game's executable as a non-Steam game.
3. Enable Proton Experimental compatibility.

**Games:**  

- Boeboeks - Tocht naar Opa Kakadoris  
- Skippy & Het Geheim van de Gestolen Papyrusrol

---

## Special Installation Steps for Specific Games

### Miel Monteur - Recht Door Zee

This game requires installation via Lutris:

1. **Install with Lutris**  
    Use the `miel-monteur-recht-door-zee.yaml` file from this repo in Lutris & choose "install using yaml file" when adding a game.
    During Setup, when prompted for the installation destination, select:  

    ```dos
    Z:\home\deck\Games\Games\Miel Monteur - Recht Door Zee
    ```

2. **Add Executable to Steam**  
    After installation, add `Mullebat.exe` (found in the install folder) as a non-Steam game in Steam.  
    Enable **Proton Experimental** compatibility.

3. **Configure with Protontricks**  
    - Enable virtual desktop as described above.
    - Add the ISO as an `E:` drive in WineCfg as described above.

---

### Miel Monteur - Huis op Stelten

This game requires specific installation steps in Steam since it does not like to be installed anywhere else but the `C:\` drive.

1. **Extract ISO**
    Extract the ISO (mielmonteur4) to

    ```bash
    /home/deck/Games/Games/Miel Monteur - Huis op Stelten
    ```

2. **Adding Game to Steam**
    Open Steam (in desktop mode), go to Library, click "Add a Game" and "Add a Non-Steam Game". Click on Browse and locate `MielHuizen.exe` in the folder where you extracted the iso. Also add Proton experimental compatibility to the non-steam game.

3. **Install the Game**
    Launch the non-Steam game, click on "Speel" and go through installation process of Miel Monteur & Quicktime. Leave the destination paths to default (`C:\...`).

4. **Configure with Protontricks**  
    - Enable virtual desktop for 800x600 display as described above.
    - Add the ISO as an `E:` drive in WineCfg as described above.
