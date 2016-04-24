#Official ScriptHawk TODO list
##High Priority
- General: Rework input/keybinds, multiple profiles like wasd/arrow keys
- General: 2D game support
- General: Move from x, y, z variables to position/rotation/velocity etc. tables with x, y, z indexes
- General: UI to load ASM patches, can currently only be done by calling loadASMPatch(filename, suppressprint) in the lua console
- Rayman 2: Find player object pointer
- DPAD Fixes for:
	- DK64 (Fly Swatter)
- DK64: Finish flag documentation
	- Complete documentation for US
	- Figure out how the 101% credits are triggered
	- Start documentation for other versions
- DK64: Exception when gui.cleargraphics() is called on first frame (by MJ minimap)
- DK64: Finish integrating the Object Analysis tools
	- Move to SM64.lua's struct format for object model 1 and model 2
- BK: Integrate Level Object Analyser.lua
- BK: Integrate flags (and many other finds) from Bitalive's research https://docs.google.com/document/d/1Gek6Bkfcy1RHSDTBa3L3fEzJhaWROX3hfcmOrcekTV0/edit
- BT: ScriptHawk tracks the wrong object in certain circumstances
	- Asked for Mumbo's help but still in Skull
	- Split up pads
	- Clockwork Kazooie eggs
- BT: Jinjo Manip memory analysis
	- Help finish the table [here](https://docs.google.com/spreadsheets/d/1QLn9yh7ZS9dT-lMymj_98mKmnEb5OLqz_QKkEhrVzyM/pub?gid=0)

##Low priority, recurring, or waiting:
- General: Detailed watch toggle (checkbox maybe)
	- "Verbosity level" for object viewer scripts, include as a struct field flag
- DK64: Neverslip enhancements, can't roll/kick on slopes
- Port Tetris Attack bot to other Puzzle League games
	- [List of Games](http://www.speedrun.com/puzzle_league)
	- [Pokémon Puzzle League Info here](https://github.com/mupen64plus/mupen64plus-user-issues/issues/567)
- Keep [LIPS](https://github.com/notwa/lips) up to date
- Support both BizHawk and m64p
	- [Info here](https://github.com/notwa/mm/commit/90d30e218f3128fb130e54bd8662527bdd73f40f)
	- Squish remaining calls to bizstring library
- BK: ASM hook for other regions
- DK64: ASM hook for other regions

#Game support wishlist:
- Gex: Enter the Gecko
- Gex 3: Deep Cover Gecko
- Wave Race 64
- THPS 1/2/3
- Mickey's Speedway USA
- Mischief Makers
- Space Station Silicon Valley
- Pokémon Snap
- Doubutsu no Mori (Animal Crossing)
- Monster Truck Madness 64