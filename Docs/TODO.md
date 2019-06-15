# ScriptHawk TODO list
## General
- Better High DPI support
	- Editing ScriptHawk.UI.button_height does a [decent job](https://twitter.com/Isotarge/status/963992829746855937), but it's not perfect
- Blank template that's more lightweight
- Allow modules to save extra settings via UserPreferences system
- Save and Load ScriptHawk settings using UserPreferences system
	- Joypad/Keyboard binds for D-Pad and L Button
	- Rounding precision
	- Rotation units
	- Mode? Arguable
	- Warnings/UITest?
- Bulk support SMS games with new hitbox API
- UI to load ASM patches, can currently only be done by calling loadASMPatch(filename, suppressprint) in the lua console

## Specific Modules
- Balloon Fight:
	- Mine the [disassembly](https://github.com/LuigiBlood/balloonfight_dis) for info
- DK64:
	- Finish flag documentation
	- Increase identifyMemory() coverage
		- Document the HUD object, perfect byte sized project for a quick context switch into and out of
	- ASM hook for other regions
- Land of Illusion:
	- Game Gear support
	- Make Mickey draggable (Y works, X doesn't)
	- Draw slopes as triangles in collision viewer
- Phantasy Star (SMS)
	- Mine the [disassembly](https://github.com/lory90/ps1disasm) for info
- Rats! (GBC)
	- Hitboxes, we've got object positions just need camera data/screen size etc
- Sonic 1 (SMS/GG)
	- Mine the [disassembly](https://github.com/Kroc/Sonic1-Z80-ASM) for info

## Low priority, recurring, or waiting:
- Object Analysis Tools:
	- Find a decent object/struct format that has a good balance between documentation, useability, flexibility, and speed
		- Metatable?
		- Standardize the type names and getters between BK & SM64
- Port Tetris Attack bot to other Puzzle League games
	- [List of Games](http://www.speedrun.com/puzzle_league)
	- [Pokémon Puzzle League Info here](https://github.com/mupen64plus/mupen64plus-user-issues/issues/567)
- Keep [lips](https://github.com/notwa/lips) up to date
- Experiment with APIHawk
- Support MAME?
- Support both BizHawk and m64p?
	- [Info here](https://github.com/notwa/mm/commit/90d30e218f3128fb130e54bd8662527bdd73f40f)