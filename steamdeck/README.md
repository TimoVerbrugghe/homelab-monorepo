# Installing Older PC Games on SteamOS/Steam Deck

This guide was written to explain how to install some specific older PC games that I have on the Steam Deck using SteamOS.

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
