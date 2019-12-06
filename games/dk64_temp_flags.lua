temporary_flags = {
	ntsc_u = {
		{byte=0x0, bit=0, flagName="Japes: Caged Diddy Text Cleared", type="FTT", map=7},
		{byte=0x0, bit=6, flagName="Aztec: Caged Lanky Text Cleared", type="FTT", map=20},
		{byte=0x0, bit=7, flagName="Aztec: Caged Llama Text Cleared", type="FTT", map=38},

		{byte=0x1, bit=0, flagName="Aztec: Caged Tiny Text Cleared", type="FTT", map=16},
		{byte=0x1, bit=7, flagName="Factory: Caged Chunky Text Cleared", type="FTT", map=26},

		{byte=0x2, bit=0, flagName="Factory: Arcade GB Spawn Pending", type="Physical", map=2},
		{byte=0x2, bit=1, flagName="Factory: Nintendo Coin Spawn Pending", type="Physical", map=2},
		{byte=0x2, bit=2, flagName="Factory: Car Race FT Intro", type="Cutscene", map=27},
		
		{byte=0x3, bit=0, flagName="Factory: Dartboard Minigame Beaten", type="Physical", map=26},
		{byte=0x3, bit=6, flagName="Galleon: Mermaid FT Cutscene", type="Cutscene", map=45},
		{byte=0x3, bit=7, flagName="Galleon: All Pearls Collected", type="Progress", map=44},

		{byte=0x4, bit=1, flagName="Fungi: Beanstalk No-Bean Text Cleared", type="FTT", map=48},
		{byte=0x4, bit=2, flagName="Fungi: Bean", type="Progress", map=52},

		{byte=0x5, bit=0, flagName="Fungi: BBlast GB Spawn Pending", type="Progress", map=188},
		{byte=0x5, bit=1, flagName="Fungi: Apple Danger Cutscene watched", type="Cutscene", map=48},
		{byte=0x5, bit=2, flagName="Fungi: Apple Saved Cutscene watched", type="Cutscene", map=48},

		{byte=0x6, bit=0, flagName="Caves: Ice Tomato Board Active", type="Minigame", map=98}, 
		{byte=0x6, bit=1, flagName="Caves: 1DC GB Raised Cutscene watched", type="Cutscene", map=94}, 
		{byte=0x6, bit=2, flagName="Caves: BBlast GB Spawn Pending", type="Progress", map=186}, 

		{byte=0x7, bit=0, flagName="Castle: Car Race FT Intro", type="Cutscene", map=185},
		{byte=0x7, bit=3, flagName="Helm: Roman Numeral Doors Open", type="Physical", map=17},
		{byte=0x7, bit=4, flagName="Helm: DK BBlast Barrel complete", type="Progress", map=17},
		{byte=0x7, bit=4, flagName="Helm: Chunky PPunch Barrel complete", type="Progress", map=17},
		{byte=0x7, bit=5, flagName="Helm: Diddy Kremling Barrel complete", type="Progress", map=17},
		{byte=0x7, bit=6, flagName="Helm: Tiny PTT Barrel complete", type="Progress", map=17},

		{byte=0x8, bit=0, flagName="Helm: Lanky Maze Barrel complete", type="Progress", map=17},
		{byte=0x8, bit=1, flagName="Helm: DK Rambi Barrel complete", type="Progress", map=17},
		{byte=0x8, bit=2, flagName="Helm: Diddy Cage Barrel complete", type="Progress", map=17},
		{byte=0x8, bit=3, flagName="Helm: Tiny Mushroom Barrel complete", type="Progress", map=17},
		{byte=0x8, bit=4, flagName="Helm: Chunky Gun Barrel complete", type="Progress", map=17},
		{byte=0x8, bit=5, flagName="Helm: Lanky Gun Barrel complete", type="Progress", map=17},
		{byte=0x8, bit=6, flagName="Helm: DK Grate Punched", type="Progress", map=17},
		{byte=0x8, bit=7, flagName="Helm: Chunky Grate Punched", type="Progress", map=17},

		{byte=0x9, bit=0, flagName="Helm: Lanky Grate Punched", type="Physical", map=17},
		{byte=0x9, bit=1, flagName="Helm: Tiny Grate Punched", type="Physical", map=17},
		-- 0x9, 2 > Diddy Grate Punched? (Beta Element?)
		{byte=0x9, bit=3, flagName="Helm: DK Room Shut Down", type="Progress", map=17},
		{byte=0x9, bit=4, flagName="Helm: Chunky Room Shut Down", type="Progress", map=17},
		{byte=0x9, bit=5, flagName="Helm: Tiny Room Shut Down", type="Progress", map=17},
		{byte=0x9, bit=6, flagName="Helm: Lanky Room Shut Down", type="Progress", map=17},
		{byte=0x9, bit=7, flagName="Helm: Diddy Room Shut Down", type="Progress", map=17},

		-- 0xA, 0 set on Helm Completion, cleared when trying to exit Diddy Room
		{byte=0xA, bit=1, flagName="K. Rool: Tiny Phase Toe 1 Complete", type="Progress", map=214},
		{byte=0xA, bit=2, flagName="K. Rool: Tiny Phase Toe 2 Complete", type="Progress", map=214},
		{byte=0xA, bit=3, flagName="K. Rool: Tiny Phase Toe 3 Complete", type="Progress", map=214},
		{byte=0xA, bit=4, flagName="K. Rool: Tiny Phase Toe 4 Complete", type="Progress", map=214},
		-- 0xA, 5 - Set on entering any K Rool Phase, Cleared on K Rool Victorious
		-- 0xA, 6 - Diddy Phase long beta cutscene? Set on first entrance, no noticeable differences
		-- 0xA, 7 - Lanky Phase long beta cutscene? Set on first entrance, no noticeable differences

		{byte=0xB, bit=0, flagName="K. Rool: Tiny Phase Intro", type="Cutscene", map=206},
		-- 0xB, 1 - Chunky Phase long beta cutscene? Set on first entrance, no noticeable differences
		{byte=0xB, bit=2, flagName="K. Rool: Phase Timeout", type="Trigger", nomap=true},
		{byte=0xB, bit=3, flagName="K. Rool: Cranky cutscene watched", type="Cutscene", map=215},
		{byte=0xB, bit=4, flagName="K. Rool: Reset Tiny Phase Progress Flags and Round Counter", type="Trigger", nomap=true},
		{byte=0xB, bit=5, flagName="K. Rool: DK Phase Intro", type="Cutscene", map=203},
		{byte=0xB, bit=7, flagName="K. Rool: Gorilla Gone Cutscene watched", type="Cutscene", map=207},
		
		{byte=0xC, bit=0, flagName="Isles: Sprint GB Cutscene watched", type="Cutscene", map=97},
		{byte=0xC, bit=1, flagName="Global: Jetpac Active", type="Minigame", map=5},
		{byte=0xC, bit=2, flagName="Global: Rareware Coin Spawn Pending", type="Physical", map=9},
		{byte=0xC, bit=3, flagName="Factory: Arcade Active", type="Minigame", map=26},
		{byte=0xC, bit=4, flagName="Global: Training Barrel Spawn Pending", type="Progress", map=5},
		{byte=0xC, bit=5, flagName="Caves: Beetle FT Long Intro", type="Cutscene", map=82},
		{byte=0xC, bit=6, flagName="Aztec: Beetle FT Long Intro", type="Cutscene", map=14},
		{byte=0xC, bit=7, flagName="Aztec: Dogadon Long Intro", type="Cutscene", map=197},

		{byte=0xD, bit=0, flagName="Japes: Army Dillo Long Intro", type="Cutscene", map=8},
		{byte=0xD, bit=1, flagName="Fungi: Dogadon Long Intro", type="Cutscene", map=83},
		{byte=0xD, bit=2, flagName="Factory: Mad Jack Long Intro", type="Cutscene", map=154},
		{byte=0xD, bit=3, flagName="Galleon: Puftoss Long Intro", type="Cutscene", map=111},
		{byte=0xD, bit=4, flagName="Castle: Kut Out Long Intro", type="Cutscene", map=199},
		{byte=0xD, bit=5, flagName="Caves: Army Dillo Long Intro", type="Cutscene", map=196},
		{byte=0xD, bit=6, flagName="Global: Unused Ice Key Text Cutscene Pending", type="Trigger",nomap=true}, -- https://www.youtube.com/watch?v=TxMGt4EZJYE&feature=youtu.be
	},
	pal = {
		{byte=0x0, bit=7, flagName="Aztec: Llama Text Cleared", type="FTT", map=38},
		
		{byte=0x2, bit=0, flagName="Factory: Arcade GB Spawn Pending", type="Physical", map=2},
		{byte=0x2, bit=1, flagName="Factory: Nintendo Coin Spawn Pending", type="Physical", map=2},
		{byte=0x2, bit=2, flagName="Factory: Car Race FT Intro", type="Cutscene", map=27},
		{byte=0x2, bit=4, flagName="Factory: Arcade Lever Pulled", type="Minigame", map=98},
		
		{byte=0x3, bit=0, flagName="Factory: Dartboard Minigame Beaten", type="Physical", map=26},
		-- Somewhere in section 0x3,1 > 0x3, 6 has an additional temp flag compared to US
		{byte=0x3, bit=7, flagName="Galleon: Mermaid FT Cutscene", type="Cutscene", map=45},
		
		{byte=0x4, bit=0, flagName="Galleon: All Pearls Collected", type="Progress", map=44},
		
		{byte=0x6, bit=1, flagName="Caves: Ice Tomato Game Active", type="Minigame", map=98},
		
		{byte=0x7, bit=1, flagName="Castle: Car Race FT Intro", type="Cutscene", map=185},
		{byte=0x7, bit=4, flagName="Helm: Roman Numeral Doors Open", type="Physical", map=17},
		
		{byte=0x9, bit=2, flagName="Helm: Tiny Grate Punched", type="Physical", map=17},
		
		{byte=0xB, bit=6, flagName="K. Rool: DK Phase Intro", type="Cutscene", map=203},
		
		{byte=0xD, bit=3, flagName="Factory: Mad Jack Long Intro", type="Cutscene", map=154},
		{byte=0xD, bit=7, flagName="Global: Unused Ice Key Text Cutscene Pending", type="Progress",nomap=true},
	},
	ntsc_j = { -- Likely same as PAL
		{byte=0x4, bit=0, flagName="Galleon: All Pearls Collected", type="Progress", map=44},
		
		{byte=0xD, bit=3, flagName="Factory: Mad Jack Long Intro", type="Cutscene", map=154},
	},
	kiosk = {
	},
};