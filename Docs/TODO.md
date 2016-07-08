#ScriptHawk TODO list
##High Priority
- General: Rework input/keybinds, multiple profiles like wasd/arrow keys
- General: 2D game support
	- Integrate SMS object viewers into ScriptHawk.lua
		- Currently they share a lot of code that would work well as a game module
		- I think it'd be fun to bulk support SMS games since the object layout is so simple :P
	- Move from x, y, z variables to position/rotation/velocity etc. tables with x, y, z indexes
- General: UI to load ASM patches, can currently only be done by calling loadASMPatch(filename, suppressprint) in the lua console
- D-Pad Fixes for:
	- DK64 (Fly Swatter)
- DK64: Find menu cutscene flags
- DK64: Finish flag documentation
	- Figure out how to reliably find flag block on any frame
		- The current method reads the pointer from what I assume is the stack and this doesn't work on lag frames
		- There are other pointers to the flag block (in non-global space?), these might be a clue
	- Implement framework to detect when flags are set/cleared & print to console
- DK64: Exception when gui.cleargraphics() is called on first frame (by MJ minimap)
- BK: Integrate flags (and many other finds) from Bitalive's research https://docs.google.com/document/d/1Gek6Bkfcy1RHSDTBa3L3fEzJhaWROX3hfcmOrcekTV0/edit

##Low priority, recurring, or waiting:
- Object Analysis Tools:
	- Find a decent object/struct format that has a good balance between documentation, useability, flexibility and speed
		- Metatable?
		- Standardize the type names and getters between BK & SM64
- General: Detailed watch toggle (checkbox maybe)
	- "Verbosity level" for object viewer scripts, include as a struct field flag
- Port Tetris Attack bot to other Puzzle League games
	- [List of Games](http://www.speedrun.com/puzzle_league)
	- [Pokémon Puzzle League Info here](https://github.com/mupen64plus/mupen64plus-user-issues/issues/567)
- Keep [lips](https://github.com/notwa/lips) up to date
- Support both BizHawk and m64p
	- [Info here](https://github.com/notwa/mm/commit/90d30e218f3128fb130e54bd8662527bdd73f40f)
	- Squish remaining calls to bizstring library
		- Ledge Clip.lua
		- Wonder Boy III RNG Watch.lua
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