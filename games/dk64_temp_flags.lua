temporary_flags = {
	ntsc_u = {
		{byte=0x0, bit=0, flagName="Japes: Diddy Moaning (Switch) Text Cleared", type="FTT", map=7},
		{byte=0x0, bit=7, flagName="Aztec: Llama Text Cleared", type="FTT", map=38},

		{byte=0x2, bit=2, flagName="Factory: Car Race FT Intro", type="Cutscene", map=27},

		{byte=0x6, bit=0, flagName="Caves: Ice Tomato Game Active", type="Minigame", map=98}, 

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
		-- 0xA, 5 set on entering any K Rool Phase

		{byte=0xB, bit=0, flagName="K. Rool: Tiny Phase Intro", type="Cutscene", map=206},
		{byte=0xB, bit=5, flagName="K. Rool: DK Phase Intro", type="Cutscene", map=203},

		{byte=0xC, bit=5, flagName="Caves: Beetle FT Long Intro", type="Cutscene", map=82},
		{byte=0xC, bit=6, flagName="Aztec: Beetle FT Long Intro", type="Cutscene", map=14},
		{byte=0xC, bit=7, flagName="Aztec: Dogadon Long Intro", type="Cutscene", map=197},

		{byte=0xD, bit=0, flagName="Japes: Army Dillo Long Intro", type="Cutscene", map=8},
		{byte=0xD, bit=1, flagName="Fungi: Dogadon Long Intro", type="Cutscene", map=83},
		{byte=0xD, bit=2, flagName="Factory: Mad Jack Long Intro", type="Cutscene", map=154},
		{byte=0xD, bit=3, flagName="Galleon: Puftoss Long Intro", type="Cutscene", map=111},
		{byte=0xD, bit=4, flagName="Castle: Kut Out Long Intro", type="Cutscene", map=199},
		{byte=0xD, bit=5, flagName="Caves: Army Dillo Long Intro", type="Cutscene", map=196},
	},
	pal = {
		{byte=0x0, bit=7, flagName="Aztec: Llama Text Cleared", type="FTT", map=38},
		
		{byte=0x2, bit=0, flagName="Factory: Arcade GB Spawn Pending", type="Physical", map=2},
		{byte=0x2, bit=1, flagName="Factory: Nintendo Coin Spawn Pending", type="Physical", map=2},
		{byte=0x2, bit=2, flagName="Factory: Car Race FT Intro", type="Cutscene", map=27},
		{byte=0x2, bit=4, flagName="Factory: Arcade Lever Pulled", type="Minigame", map=98},
		
		
		{byte=0x6, bit=1, flagName="Caves: Ice Tomato Game Active", type="Minigame", map=98}, 
		-- Somewhere in section 0x2,2 > 0x6,1 has an additional temp flag compared to US
		
		{byte=0x7, bit=1, flagName="Castle: Car Race FT Intro", type="Cutscene", map=185},
		{byte=0x7, bit=4, flagName="Helm: Roman Numeral Doors Open", type="Physical", map=17},
		
		{byte=0x9, bit=2, flagName="Helm: Tiny Grate Punched", type="Physical", map=17},
		
		{byte=0xB, bit=6, flagName="K. Rool: DK Phase Intro", type="Cutscene", map=203},
		
		{byte=0xD, bit=3, flagName="Factory: Mad Jack Long Intro", type="Cutscene", map=154},
	},
	ntsc_j = {
		{byte=0xD, bit=3, flagName="Factory: Mad Jack Long Intro", type="Cutscene", map=154},
	},
	kiosk = {
	},
};