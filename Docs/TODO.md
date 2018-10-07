# ScriptHawk TODO list
## High Priority
- Save and Load settings from a config file on disk
	- Joypad/Keyboard binds for D-Pad and L Button
	- Rounding precision
	- Rotation units
	- Mode? Arguable
	- Verbosity/Debug mode?
- Bulk support SMS games with new hitbox API
- General: UI to load ASM patches, can currently only be done by calling loadASMPatch(filename, suppressprint) in the lua console
- DK64:
	- Find menu cutscene nonsense
	- Finish flag documentation
	- The endgame here is identifying everything on the heap until there are no unknown allocated blocks left. We have a fairly decent picture of what’s on the heap currently but the documentation is scattered throughout various ScriptHawk functions so there’s no all-in-one automated method of identifying arbitrary blocks. I could implement a function that you could pass a block pointer and it'll try and identify what the block is/does by searching through known pointer lists of various object types etc. I don't have much free time at the moment but I'll put it on my todo list for when things settle down.

## Low priority, recurring, or waiting:
- Object Analysis Tools:
	- Find a decent object/struct format that has a good balance between documentation, useability, flexibility, and speed
		- Metatable?
		- Standardize the type names and getters between BK & SM64
- Port Tetris Attack bot to other Puzzle League games
	- [List of Games](http://www.speedrun.com/puzzle_league)
	- [Pokémon Puzzle League Info here](https://github.com/mupen64plus/mupen64plus-user-issues/issues/567)
- Keep [lips](https://github.com/notwa/lips) up to date
- Support both BizHawk and m64p?
	- [Info here](https://github.com/notwa/mm/commit/90d30e218f3128fb130e54bd8662527bdd73f40f)
	- Squish remaining calls to bizstring library
		- Wonder Boy III RNG Watch.lua
- DK64: ASM hook for other regions