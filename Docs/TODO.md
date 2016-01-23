#Official ScriptHawk TODO list
##High Priority
- General: Base game detection on ROM hash rather than name
- General: Rework input/keybinds, multiple profiles like wasd/arrow keys
- General: 2D game support
- General: UI framework cleanup, reduce number of parameters passed to Game.initUI(), probably just pass in a key->value table
- General: Move from x, y, z variables to position/rotation/velocity etc. tables with x, y, z indexes
- Rayman 2 rotation stuff
- Toy story 2 stuff
- DK64: Finish flag documentation
	- Complete documentation for US
	- Figure out how the 101% credits are triggered
	- Start documentation for other versions
- DK64: Neverslip enhancements, can't roll/kick on slopes
- DK64: Fix dpad for boats/cars/fly swatter etc
- DK64: Integrate Grab Objects.lua
- DK64: Finish integrating Loader.lua
	- Just needs a UI, it can currently be called via the Lua console
- BK: Integrate Level Object Analyser.lua
- BT: Take me there support for JP
- BT: Jinjo Manip memory analysis
	- Help finish the table [here](https://docs.google.com/spreadsheets/d/1QLn9yh7ZS9dT-lMymj_98mKmnEb5OLqz_QKkEhrVzyM/pub?gid=0)

##Low priority, recurring, or waiting:
- Port Tetris Attack bot to Pokémon Puzzle League (once it boots in m64p & BizHawk ofc)
	- [Info here](https://github.com/mupen64plus/mupen64plus-user-issues/issues/567)
- Keep [LIPS](https://github.com/notwa/lips) up to date
- Support both BizHawk and m64p
	- [Info here](https://github.com/notwa/mm/commit/90d30e218f3128fb130e54bd8662527bdd73f40f)
	- Squish remaining calls to bizstring library

#Game support wishlist:
- Conker's Bad Fur Day
- Gex: Enter the Gecko
- Gex 3: Deep Cover Gecko
- Wave Race 64
- THPS 1/2/3
- Mickey's Speedway USA
- Space Station Silicon Valley
- Pokémon Snap
- Doubutsu no Mori (Animal Crossing)
- Monster Truck Madness 64