#ScriptHawk
A collection of Lua scripts and RAM watches for [BizHawk](https://github.com/TASVideos/BizHawk) providing many tools to assist with Glitch Hunting and TASing. ScriptHawk's Modular API allows new games to be supported easily.

##How to use
###Setup
1. Set up [BizHawk](https://github.com/TASVideos/BizHawk) and run the prerequisite installer, the latest version is always recommended
2. [Clone the repository](https://help.github.com/articles/cloning-a-repository/) into a ScriptHawk folder inside the Lua folder that comes with BizHawk
3. Open BizHawk and your game of choice
4. Click Tools -> Lua Console
5. Open ScriptHawk.lua

###Basic functionality
- Player position, rotation and speed will be displayed on screen
- Use L to levitate and the D-Pad to move quickly around the map

###Writing your own ScriptHawk module
1. Implement the API detailed in Docs/Design.txt, a template is provided at games/blank.lua
2. Your module should reside in the games/ subdirectory
3. Add detection for your game to ScriptHawk.lua
4. Submit a pull request to this repository, or contact [@Isotarge](https://twitter.com/Isotarge)

##Supported Games
###Donkey Kong 64
- Europe
- Japan
- Kiosk Demo
- USA

###Banjo-Kazooie
- Europe
- Japan
- USA 1.0 and 1.1

###Banjo-Tooie
- Australia
- Europe
- Japan
- USA

###Conker's Bad Fur Day
- Europe
- USA

###Diddy Kong Racing
- Europe 1.0 and 1.1
- Japan
- USA 1.0 and 1.1

###Super Mario 64
- Europe
- Japan 1.0 and Shindou Edition
- USA

###The Legend of Zelda: Majora's Mask
- Europe 1.0 and 1.1
- Japan 1.0 and 1.1
- USA 1.0

###The Legend of Zelda: Ocarina of Time
- Europe 1.0, 1.1 and Master Quest
- Japan 1.0, 1.1 and 1.2
- USA 1.0, 1.1 and 1.2

###Toy Story 2: Buzz Lightyear to the Rescue
- Europe (N64)
- France (N64)
- German 1.0 and 1.1 (N64)
- USA (N64)

###Regarding Zelda
While ScriptHawk does have basic support for OoT and MM there are people who are much more dedicated to these games than I will ever be. Check out the great work at the following GitHub repos for more comprehensive support:  
- [notwa/mm](https://github.com/notwa/mm/tree/master/Lua)  
- [RainingChain/Z64LuaHooks](https://github.com/RainingChain/Z64LuaHooks)  

##Partially Supported Games
- Elmo's Number Journey (N64 only)
- Elmo's Letter Adventure (N64 only)
- Rayman 2 (N64 USA only)

##Support me
If you like my work, consider donating [here](https://streamtip.com/t/isotarge)