# ScriptHawk
A collection of Lua scripts and RAM watches for [BizHawk](https://github.com/TASVideos/BizHawk) providing many tools to assist with Glitch Hunting and [TASing](http://tasvideos.org). ScriptHawk's Modular API allows new games to be supported easily.

## How to use
### Setup
1. Set up [BizHawk](https://github.com/TASVideos/BizHawk), the latest version is recommended
2. [Clone this repository](https://help.github.com/articles/cloning-a-repository/) or download and extract a [zipped copy](https://github.com/Isotarge/ScriptHawk/archive/master.zip)
3. Open BizHawk and your (supported) game of choice
4. Click Tools -> Lua Console
5. Open ScriptHawk.lua


- If you're experiencing poor performance in BizHawk 2.1.0 or later, try switching Lua cores to "LuaInterface + Lua" in the Config -> Customize -> Advanced menu
- BizHawk versions 1.13.0, 1.13.1, 2.0.0, and 2.0.1 do not work with ScriptHawk due to a [bug](https://github.com/TASVideos/BizHawk/issues/867) that was fixed in 2.1.0
- BizHawk versions prior to 1.11.5 are not supported by ScriptHawk

### Basic functionality
- Player position, rotation and speed will be displayed on screen
- Press L to levitate and use the D-Pad to move quickly around the map
- Press the E key to levitate and use WASD keys to move quickly around the map
- Press / to reset max velocity, odometer etc.

### Advanced functionality
- The telemetry system records everything shown in ScriptHawk's OSD to the Lua console in CSV format
- Type angleCalc.open() in the Lua console to open a calculator for the angle between 2 points in game, written by [The8bitbeast](https://twitter.com/the8bitbeast)
- Type modifyOSD() in the Lua console to open a dialog to toggle OSD entries on and off, written by [Tom Ballaam](https://twitter.com/tjballaam)
- Type lock_y = true in the Lua console to freeze the player's Y position, lock_y = false to disable
- Type loadASMPatch() in the Lua console to load a MIPS R4300i assembly patch for any N64 game, huge thanks to [notwa/lips](https://github.com/notwa/lips)

### Writing your own ScriptHawk module
1. Implement the API detailed in [Docs/Design.txt](Docs/Design.txt), a template is provided at [games/blank.lua](games/blank.lua)
2. Your module should reside in the games/ subdirectory
3. Add detection for your game to ScriptHawk.lua
4. Submit a pull request to this repository, or contact [Isotarge](https://twitter.com/Isotarge)

## Supported Games
### Donkey Kong 64
- All known versions supported
- [Object analysis tools](Docs/Object%20Analysis%20Tools.txt): List, Examine, Grab, Focus, Encircle, Zip
- Documentation for over 95% of permanent flags in USA save files
- Realtime feedback for flags being set/cleared
- Mad Jack minimap
- Automatic [ISG](http://dk64.wikia.com/wiki/Intro_Story_Glitch) timer

![Donkey Kong 64 Support](Images/Promo/dk64.png)

![Donkey Kong 64 Support](Images/Promo/dk64_ui.png)

### Banjo-Kazooie
- All known versions supported
- [Object tracking overlay](https://www.youtube.com/watch?v=m42wiHEdEbU), written by [Mittenz](https://twitter.com/mittenzhugg)
- [Object analysis tools](Docs/Object%20Analysis%20Tools.txt): List, Examine, Grab, Encircle, Zip, Despawn
- Spawn objects
- Documentation for the majority of flags
- Realtime feedback for flags being set/cleared

![Banjo-Kazooie Support](Images/Promo/bk_ui.png)

### Banjo-Tooie
- All known versions supported
- [Object analysis tools](Docs/Object%20Analysis%20Tools.txt): List, Encircle, Zip
- Documentation for over 60% of permanent flags in USA save files
- Realtime feedback for flags being set/cleared

### Conker's Bad Fur Day
- All known versions supported

### Crash Bandicoot
- All known versions supported

### Crash Bandicoot 2: Cortex Strikes Back
- All known versions supported

### Crash Bandicoot 3: Warped
- All known versions supported

### Diddy Kong Racing
- All known versions supported
- [Object analysis tools](Docs/Object%20Analysis%20Tools.txt): List, Examine, Encircle, Zip
- Autotapper, written by [Faschz](https://twitter.com/Faschz) with various improvements

![DKR Support](Images/Promo/dkr_ui.png)

### Space Station Silicon Valley
- All N64 versions supported

### Super Mario 64
- All known versions supported
- [Object analysis tools](Docs/Object%20Analysis%20Tools.txt): List, Examine, Zip

### Super Smash Bros.
- All known versions supported

![Smash 64 Support](Images/Promo/smash64.png)

![Smash 64 Support](Images/Promo/smash64_ui.png)

### Toy Story 2: Buzz Lightyear to the Rescue
- Europe (N64)
- France (N64)
- German 1.0 and 1.1 (N64)
- USA (N64)

## Other Supported Games
- Alex Kidd in Miracle World (SMS)
- Alex Kidd in Shinobi World (SMS)
- Balloon Fight (NES)
- Drill Dozer (GBA)
- Earthworm Jim 3D (N64)
- Golden Axe Warrior (SMS)
- Golvellius (SMS)
- Impossible Mission (SMS)
- Lord of the Sword (SMS)
- Mercs (SMS)
- Metroid (NES)
- Penguin Land (SMS)
- Psycho Fox (SMS)
- Rats! (GBC)
- Sonic The Hedgehog (SMS/GG)
- Taz-Mania (SMS)
- The Ninja (SMS)
- Ty the Tasmanian Tiger 2: Bush Rescue (GBA)
- Tyrants - Fight Through Time (Mega Lo Mania) (Genesis)
- Wonder Boy (SMS/GG)
- Wonder Boy III: The Dragon's Trap (SMS)
- Wonder Boy in Monster World (SMS)

## Partially Supported Games
- Elmo's Number Journey (N64 only)
- Elmo's Letter Adventure (N64 only)
- Legend of Galahad (Genesis)
- Phantasy Star (SMS)
- Rayman 2 (N64 only)
- San Francisco Rush 2049 (N64 only)
- Zelda 64 (OoT/MM)

### Gran Turismo 2
- All simulation mode discs supported
- Arcade mode is not currently supported
- Autopilot
- Import & Export cars from the game in a shareable format

## Other Included Scripts
- [Tetris Attack](Tetris%20Attack%20Bot.lua) bot, plays the game quite well using a simple sorting algorithm
- [Mr. Driller 2](Beta/Drillbot.lua) bot
- [remove_klump.lua](Beta/remove_klump.lua), [code golf](https://en.wikipedia.org/wiki/Code_golf) that removes Klumps from DK64 USA version
- Dega .MMV reader

## Other Notable Projects
- Banjo-Kazooie [MittenzHugg/Mr.Patcher](https://github.com/MittenzHugg/Mr.Patcher)
- Banjo-Kazooie [MittenzHugg/Banjo-KazooC](https://github.com/MittenzHugg/Banjo-KazooC)
- Banjo-Kazooie [MittenzHugg/Banjo-Kazooie-Turbo-Talon-Trainer](https://github.com/MittenzHugg/Banjo-Kazooie-Turbo-Talon-Trainer)
- GoldenEye [Wyst3r/GoldenEye](https://bitbucket.org/Wyst3r/bizhawklua)
- Mario Kart 64 [weatherton/BizHawkMarioKart64](https://github.com/weatherton/BizHawkMarioKart64)
- Super Mario 64 [SM64-STROOP/STROOP](https://github.com/SM64-STROOP/STROOP)
- Super Mario World [rodamaral/smw-tas](https://github.com/rodamaral/smw-tas)
- Zelda 64 [notwa/mm](https://github.com/notwa/mm/tree/master/Lua)
- Zelda 64 [RainingChain/Z64LuaHooks](https://github.com/RainingChain/Z64LuaHooks)
- Zelda 64 [mattpilla/Majora-s-Mask-Lua-Scripts](https://github.com/mattpilla/Majora-s-Mask-Lua-Scripts)
- Zelda 64 [glankk/gz](https://github.com/glankk/gz)