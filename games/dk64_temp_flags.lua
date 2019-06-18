temporary_flags = {
	ntsc_u = {
		{byte=0xB0, bit=0, flagName="Japes: Diddy Moaning (Switch) Text Cleared", type="FTT", map=7},
		{byte=0xB0, bit=7, flagName="Aztec: Llama Text Cleared", type="FTT", map=38},

		{byte=0xB2, bit=2, flagName="Factory: Car Race FT Intro", type="Cutscene", map=27},

		{byte=0xB7, bit=0, flagName="Castle: Car Race FT Intro", type="Cutscene", map=185},
		{byte=0xB7, bit=3, flagName="Helm: Roman Numeral Doors Open", type="Physical", map=17},
		{byte=0xB7, bit=4, flagName="Helm: DK BBlast Barrel complete", type="Progress", map=17},
		{byte=0xB7, bit=4, flagName="Helm: Chunky PPunch Barrel complete", type="Progress", map=17},
		{byte=0xB7, bit=5, flagName="Helm: Diddy Kremling Barrel complete", type="Progress", map=17},
		{byte=0xB7, bit=6, flagName="Helm: Tiny PTT Barrel complete", type="Progress", map=17},

		{byte=0xB8, bit=0, flagName="Helm: Lanky Maze Barrel complete", type="Progress", map=17},
		{byte=0xB8, bit=1, flagName="Helm: DK Rambi Barrel complete", type="Progress", map=17},
		{byte=0xB8, bit=2, flagName="Helm: Diddy Cage Barrel complete", type="Progress", map=17},
		{byte=0xB8, bit=3, flagName="Helm: Tiny Mushroom Barrel complete", type="Progress", map=17},
		{byte=0xB8, bit=4, flagName="Helm: Chunky Gun Barrel complete", type="Progress", map=17},
		{byte=0xB8, bit=5, flagName="Helm: Lanky Gun Barrel complete", type="Progress", map=17},
		{byte=0xB8, bit=6, flagName="Helm: DK Grate Punched", type="Progress", map=17},
		{byte=0xB8, bit=7, flagName="Helm: Chunky Grate Punched", type="Progress", map=17},

		{byte=0xB9, bit=0, flagName="Helm: Lanky Grate Punched", type="Physical", map=17},
		{byte=0xB9, bit=1, flagName="Helm: Tiny Grate Punched", type="Physical", map=17},
		-- 0xB9, 2 > Diddy Grate Punched? (Beta Element?)
		{byte=0xB9, bit=3, flagName="Helm: DK Room Shut Down", type="Progress", map=17},
		{byte=0xB9, bit=4, flagName="Helm: Chunky Room Shut Down", type="Progress", map=17},
		{byte=0xB9, bit=5, flagName="Helm: Tiny Room Shut Down", type="Progress", map=17},
		{byte=0xB9, bit=6, flagName="Helm: Lanky Room Shut Down", type="Progress", map=17},
		{byte=0xB9, bit=7, flagName="Helm: Diddy Room Shut Down", type="Progress", map=17},

		-- 0xBA, 0 set on Helm Completion, cleared when trying to exit Diddy Room
		-- 0xBA, 5 set on entering any K Rool Phase

		{byte=0xBB, bit=0, flagName="K. Rool: Tiny Phase Intro", type="Cutscene", map=206},
		{byte=0xBB, bit=5, flagName="K. Rool: DK Phase Intro", type="Cutscene", map=203},

		{byte=0xBC, bit=5, flagName="Caves: Beetle FT Long Intro", type="Cutscene", map=82},
		{byte=0xBC, bit=6, flagName="Aztec: Beetle FT Long Intro", type="Cutscene", map=14},
		{byte=0xBC, bit=7, flagName="Aztec: Dogadon Long Intro", type="Cutscene", map=197},

		{byte=0xBD, bit=0, flagName="Japes: Army Dillo Long Intro", type="Cutscene", map=8},
		{byte=0xBD, bit=1, flagName="Fungi: Dogadon Long Intro", type="Cutscene", map=83},
		{byte=0xBD, bit=2, flagName="Factory: Mad Jack Long Intro", type="Cutscene", map=154},
		{byte=0xBD, bit=3, flagName="Galleon: Puftoss Long Intro", type="Cutscene", map=111},
		{byte=0xBD, bit=4, flagName="Castle: Kut Out Long Intro", type="Cutscene", map=199},
		{byte=0xBD, bit=5, flagName="Caves: Army Dillo Long Intro", type="Cutscene", map=196},
	},
	pal = {
		{byte=0xB0, bit=7, flagName="Aztec: Llama Text Cleared", type="FTT", map=38},
		
		{byte=0xB2, bit=2, flagName="Factory: Car Race FT Intro", type="Cutscene", map=27},
		
		-- Somewhere in section 0xB2,2 > 0xB7,1 has an additional temp flag compared to US
		
		{byte=0xB7, bit=1, flagName="Castle: Car Race FT Intro", type="Cutscene", map=185},
		{byte=0xB7, bit=4, flagName="Helm: Roman Numeral Doors Open", type="Physical", map=17},
		
		{byte=0xB9, bit=2, flagName="Helm: Tiny Grate Punched", type="Physical", map=17},
		
		{byte=0xBB, bit=6, flagName="K. Rool: DK Phase Intro", type="Cutscene", map=203},
		
		{byte=0xBD, bit=3, flagName="Factory: Mad Jack Long Intro", type="Cutscene", map=154},
	},
	ntsc_j = {
		{byte=0xBD, bit=3, flagName="Factory: Mad Jack Long Intro", type="Cutscene", map=154},
	},
	kiosk = {
	},
};