;************************************
; Template
;************************************
.org 	0x805FC164 // retroben's hook but up a few functions
J 		Start2

.org 	0x805fe8f8 // write over currentmap = nextmap
JAL		Start

.org 	0x8000DE88 // In the Expansion Pak pic, TODO: Better place to put this
.include "DK64Library.s"

Start:
ADDIU	sp, sp, -0x28
SW		t0, 0xC(sp)
SW		ra, 0x10(sp)
SW		t1, 0x14(sp)
SW		t2, 0x18(sp)
SW		t3, 0x1C(sp)
SW		t4, 0x20(sp)
SW		t5, 0x24(sp)
SW		t6, 0x28(sp)

;get level ptr from krushainstrument
;increment level ptr
;put map code in t4 and store word in a1 (set next map)
LA		t0, @KrushaInstrument
LW		t4, 0x0(t0)
ADDI	t2, t4, 0x1			;t2=index on table +1
LB		t4, 0x0(t4)			;t1=map code
SW      t4, 0x0(a1)			;a1 -> needs final map code
SW		t2, 0x0(t0)			;put new ptr in KrushaInstrument

Return:
LW		t0, 0xC(sp)
LW		ra, 0x10(sp)
LW		t1, 0x14(sp)
LW		t2, 0x18(sp)
LW		t3, 0x1C(sp)
LW		t4, 0x20(sp)
LW		t5, 0x24(sp)
LW		t6, 0x28(sp)
ADDIU	sp, sp, 0x28
J		0x805fe8fc
NOP

//start second hook
Start2:

// Run the code we replaced
JAL     0x805FC2B0
NOP

;load min map code and min text offset, if 0
LA		t0, @TinyHelmTSB
LH		t1, 0x00(t0)
BEQZ	t1, SetInitialParams
NOP

J		Return2
NOP

Return2:
J       0x805FC15C // retroben's hook but up a few functions
NOP

SetInitialParams:
LA		t2, @KrushaInstrument	;KrushaInstrument = map code pointer
LA		t1, MapCodes
SW		t1, 0x0(t2)
LI		t1, 0x01
SB		t1, 0x807FCA9F 
SB		t1, 0x807FCAA1
J		Return2
NOP

;************************************
; ADDITIONAL VARS
;************************************

.align
MemoryViewerText:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0"

.align
FormatString:
.asciiz "SEED: %s"

.align
MapCodes:
Special:
.byte	0x00;		"Test Map", -- 0
.byte	0x02;		"DK Arcade",2
.byte	0x09;		"Jetpac",9
.byte	0x0F;		"Snide's H.Q.",
.byte	0x1C;		"Hideout Helm (Level Intros, Game Over)",
.byte	0x22;		"DK Isles Overworld",
.byte	0x28;		"Nintendo Logo", -- 40;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0x2A;		"Troff 'n' Scoff", -- 42
.byte	0x4D;		"DK Rap",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0x50;		"Main Menu", -- 80
.byte	0x51;		"Title Screen (Not For Resale Version)",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0x61;		"K. Lumsy",
.byte	0x6B;		"Kong Battle: Battle Arena",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0x6D;		"Kong Battle: Arena 1",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0x98;		"Hideout Helm (Intro Story)",
.byte	0x99;		"DK Isles (DK Theatre)",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0xAB;		"DK's House",
.byte	0xAC;		"Rock (Intro Story)",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0xB0;		"Training Grounds",
.byte	0xB8;		"Enguarde Arena",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0xBD;		"Fairy Island",
.byte	0xBE;		"Kong Battle: Arena 2", -- 190;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0xBF;		"Rambi Arena",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0xC0;		"Kong Battle: Arena 3",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0xC3;		"DK Isles: Snide's Room",
.byte	0xC6;		"Training Grounds (End Sequence)",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0xCB;		"K. Rool Fight: DK Phase",
.byte	0xCC;		"K. Rool Fight: Diddy Phase",
.byte	0xCD;		"K. Rool Fight: Lanky Phase",
.byte	0xCE;		"K. Rool Fight: Tiny Phase",
.byte	0xCF;		"K. Rool Fight: Chunky Phase",
.byte	0xD0;		"Bloopers Ending",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0xD5;		"K. Lumsy Ending",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0xD6;		"K. Rool's Shoe",;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.byte	0xD7;		"K. Rool's Arena", -- 215;;;;;;;;;;;;;;;;;;;;;;;;;
LevelLobbies:
.byte	0xA9;		"Jungle Japes Lobby",
.byte	0xAD;		"Angry Aztec Lobby",
.byte	0xAF;		"Frantic Factory Lobby",
.byte	0xAE;		"Gloomy Galleon Lobby",
.byte	0xB2;		"Fungi Forest Lobby",
.byte	0xC2;		"Crystal Caves Lobby",
.byte	0xC1;		"Creepy Castle Lobby",
.byte	0xAA;		"Hideout Helm Lobby", -- 170
MainLevels:
.byte	0x07;		"Jungle Japes",7
.byte	0x26;		"Angry Aztec",
.byte	0x1A;		"Frantic Factory",
.byte	0x1E;		"Gloomy Galleon", -- 30
.byte	0x30;		"Fungi Forest",
.byte	0x48;		"Crystal Caves",
.byte	0x57;		"Creepy Castle",
.byte	0x11;		"Hideout Helm",
Bosses:
.byte	0x08;		"Jungle Japes: Army Dillo",8
.byte	0xC5;		"Angry Aztec: Dogadon",
.byte	0x9A;		"Frantic Factory: Mad Jack",
.byte	0x6F;		"Gloomy Galleon: Pufftoss",
.byte	0x53;		"Fungi Forest: Dogadon",
.byte	0xC4;		"Crystal Caves: Army Dillo",
.byte	0xC7;		"Creepy Castle: King Kut Out",
Shops:
.byte	0x01;		"Funky's Store",1
.byte	0x05;		"Cranky's Lab",5
.byte	0x19;		"Candy's Music Shop",
Crowns:
.byte	0x9B;		"Battle Arena: Arena Ambush!",
.byte	0x9C;		"Battle Arena: More Kritter Karnage!",
.byte	0x9D;		"Battle Arena: Forest Fracas!",
.byte	0x9E;		"Battle Arena: Bish Bash Brawl!",
.byte	0x9F;		"Battle Arena: Kamikaze Kremlings!",
.byte	0xA0;		"Battle Arena: Plinth Panic!", -- 160
.byte	0xA1;		"Battle Arena: Pinnacle Palaver!",
.byte	0xA2;		"Battle Arena: Shockwave Showdown!",
.byte	0x35;		"Battle Arena: Beaver Brawl!",
.byte	0x49;		"Battle Arena: Kritter Karnage!",
SubAreas:
.byte	0x04;		"Jungle Japes: Mountain",4
.byte	0x06;		"Jungle Japes: Minecart",6
.byte	0x0C;		"Jungle Japes: Shell", C
.byte	0x0D;		"Jungle Japes: Lanky's Cave", D
.byte	0x21;		"Jungle Japes: Chunky's Cave",
.byte	0x25;		"Jungle Japes: Barrel Blast",
;aztec
.byte	0x0E;		"Angry Aztec: Beetle Race", 
.byte	0x10;		"Angry Aztec: Tiny's Temple",
.byte	0x13;		"Angry Aztec: Five Door Temple (DK)",
.byte	0x14;		"Angry Aztec: Llama Temple", -- 20
.byte	0x15;		"Angry Aztec: Five Door Temple (Diddy)",
.byte	0x16;		"Angry Aztec: Five Door Temple (Tiny)",
.byte	0x17;		"Angry Aztec: Five Door Temple (Lanky)",
.byte	0x18;		"Angry Aztec: Five Door Temple (Chunky)",
.byte	0x29;		"Angry Aztec: Barrel Blast",
;factory
.byte	0x1B;		"Frantic Factory: Car Race",
.byte	0x1D;		"Frantic Factory: Power Shed",
.byte	0x24;		"Frantic Factory: Crusher Room",
.byte	0x6E;		"Frantic Factory: Barrel Blast", -- 110
;galleon
.byte	0x1F;		"Gloomy Galleon: K. Rool's Ship",
.byte	0x27;		"Gloomy Galleon: Seal Race",
.byte	0x2B;		"Gloomy Galleon: Shipwreck (Diddy, Lanky, Chunky)",
.byte	0x2C;		"Gloomy Galleon: Treasure Chest",
.byte	0x2D;		"Gloomy Galleon: Mermaid",
.byte	0x2E;		"Gloomy Galleon: Shipwreck (DK, Tiny)",
.byte	0x2F;		"Gloomy Galleon: Shipwreck (Lanky, Tiny)",
.byte	0x31;		"Gloomy Galleon: Lighthouse",
.byte	0x33;		"Gloomy Galleon: Mechanical Fish",
.byte	0x36;		"Gloomy Galleon: Barrel Blast",
.byte	0xB3;		"Gloomy Galleon: Submarine",
;fungi
.byte	0x34;		"Fungi Forest: Ant Hill",
.byte	0x37;		"Fungi Forest: Minecart",
.byte	0x38;		"Fungi Forest: Diddy's Barn",
.byte	0x39;		"Fungi Forest: Diddy's Attic",
.byte	0x3A;		"Fungi Forest: Lanky's Attic",
.byte	0x3B;		"Fungi Forest: DK's Barn",
.byte	0x3C;		"Fungi Forest: Spider", -- 60
.byte	0x3D;		"Fungi Forest: Front Part of Mill",
.byte	0x3E;		"Fungi Forest: Rear Part of Mill",
.byte	0x3F;		"Fungi Forest: Mushroom Puzzle",
.byte	0x40;		"Fungi Forest: Giant Mushroom",
.byte	0x46;		"Fungi Forest: Mushroom Leap", -- 70
.byte	0x47;		"Fungi Forest: Shooting Game",
.byte	0xBC;		"Fungi Forest: Barrel Blast",
;caves
.byte	0x52;		"Crystal Caves: Beetle Race",
.byte	0x54;		"Crystal Caves: Igloo (Tiny)",
.byte	0x55;		"Crystal Caves: Igloo (Lanky)",
.byte	0x56;		"Crystal Caves: Igloo (DK)",
.byte	0x59;		"Crystal Caves: Rotating Room",
.byte	0x5A;		"Crystal Caves: Shack (Chunky)", -- 90
.byte	0x5B;		"Crystal Caves: Shack (DK)",
.byte	0x5C;		"Crystal Caves: Shack (Diddy, middle part)",
.byte	0x5D;		"Crystal Caves: Shack (Tiny)",
.byte	0x5E;		"Crystal Caves: Lanky's Hut",
.byte	0x5F;		"Crystal Caves: Igloo (Chunky)",
.byte	0x62;		"Crystal Caves: Ice Castle",
.byte	0x64;		"Crystal Caves: Igloo (Diddy)", -- 100
.byte	0xBA;		"Crystal Caves: Barrel Blast",
.byte	0xC8;		"Crystal Caves: Shack (Diddy, upper part)", -- 200
;castle
.byte	0x58;		"Creepy Castle: Ballroom",
.byte	0x69;		"Creepy Castle: Tower",
.byte	0x6A;		"Creepy Castle: Minecart",
.byte	0x6C;		"Creepy Castle: Crypt (Lanky, Tiny)",
.byte	0x70;		"Creepy Castle: Crypt (DK, Diddy, Chunky)",
.byte	0x71;		"Creepy Castle: Museum",
.byte	0x72;		"Creepy Castle: Library",
.byte	0x97;		"Creepy Castle: Dungeon",
.byte	0xA3;		"Creepy Castle: Basement",
.byte	0xA4;		"Creepy Castle: Tree",
.byte	0xA6;		"Creepy Castle: Chunky's Toolshed",
.byte	0xA7;		"Creepy Castle: Trash Can",
.byte	0xA8;		"Creepy Castle: Greenhouse",
.byte	0xB9;		"Creepy Castle: Car Race",
.byte	0xBB;		"Creepy Castle: Barrel Blast",
.byte	0xB7;		"Creepy Castle: Crypt",
;bonus barrels
.byte	0x03;		"K. Rool Barrel: Lanky's Maze",3
.byte	0x0A;		"Kremling Kosh! (very easy)", -- A
.byte	0x0B;		"Stealthy Snoop! (normal, no logo)", B
.byte	0x12;		"Teetering Turtle Trouble! (very easy)",
.byte	0x20;		"Batty Barrel Bandit! (easy)",
.byte	0x23;		"K. Rool Barrel: DK's Target Game",
.byte	0x32;		"K. Rool Barrel: Tiny's Mushroom Game", -- 50
.byte	0x41;		"Stealthy Snoop! (normal)",
.byte	0x42;		"Mad Maze Maul! (hard)",
.byte	0x43;		"Stash Snatch! (normal)",
.byte	0x44;		"Mad Maze Maul! (easy)",
.byte	0x45;		"Mad Maze Maul! (normal)", -- 69
.byte	0x4A;		"Stash Snatch! (easy)",
.byte	0x4B;		"Stash Snatch! (hard)",
.byte	0x4D;		"Minecart Mayhem! (easy)", -- 77
.byte	0x60;		"Splish-Splash Salvage! (normal)",
.byte	0x63;		"Speedy Swing Sortie! (easy)",
.byte	0x65;		"Krazy Kong Klamour! (easy)",
.byte	0x66;		"Big Bug Bash! (very easy)",
.byte	0x67;		"Searchlight Seek! (very easy)",
.byte	0x68;		"Beaver Bother! (easy)",
.byte	0x4E;		"Busy Barrel Barrage! (easy)",
.byte	0x4F;		"Busy Barrel Barrage! (normal)",
.byte	0x73;		"Kremling Kosh! (easy)",
.byte	0x74;		"Kremling Kosh! (normal)",
.byte	0x75;		"Kremling Kosh! (hard)",
.byte	0x76;		"Teetering Turtle Trouble! (easy)",
.byte	0x77;		"Teetering Turtle Trouble! (normal)",
.byte	0x78;		"Teetering Turtle Trouble! (hard)", -- 120
.byte	0x79;		"Batty Barrel Bandit! (easy)",
.byte	0x7A;		"Batty Barrel Bandit! (normal)",
.byte	0x7B;		"Batty Barrel Bandit! (hard)",
.byte	0x7C;		"Mad Maze Maul! (insane)",
.byte	0x7D;		"Stash Snatch! (insane)",
.byte	0x7E;		"Stealthy Snoop! (very easy)",
.byte	0x7F;		"Stealthy Snoop! (easy)",
.byte	0x80;		"Stealthy Snoop! (hard)",
.byte	0x81;		"Minecart Mayhem! (normal)",
.byte	0x82;		"Minecart Mayhem! (hard)", -- 130
.byte	0x83;		"Busy Barrel Barrage! (hard)",
.byte	0x84;		"Splish-Splash Salvage! (hard)",
.byte	0x85;		"Splish-Splash Salvage! (easy)",
.byte	0x86;		"Speedy Swing Sortie! (normal)",
.byte	0x87;		"Speedy Swing Sortie! (hard)",
.byte	0x88;		"Beaver Bother! (normal)",
.byte	0x89;		"Beaver Bother! (hard)",
.byte	0x8A;		"Searchlight Seek! (easy)",
.byte	0x8B;		"Searchlight Seek! (normal)",
.byte	0x8C;		"Searchlight Seek! (hard)", -- 140
.byte	0x8D;		"Krazy Kong Klamour! (normal)",
.byte	0x8E;		"Krazy Kong Klamour! (hard)",
.byte	0x8F;		"Krazy Kong Klamour! (insane)",
.byte	0x90;		"Peril Path Panic! (very easy)",
.byte	0x91;		"Peril Path Panic! (easy)",
.byte	0x92;		"Peril Path Panic! (normal)",
.byte	0x93;		"Peril Path Panic! (hard)",
.byte	0x94;		"Big Bug Bash! (easy)",
.byte	0x95;		"Big Bug Bash! (normal)",
.byte	0x96;		"Big Bug Bash! (hard)", -- 150
.byte	0xA5;		"K. Rool Barrel: Diddy's Kremling Game",
.byte	0xB1;		"Dive Barrel",
.byte	0xB4;		"Orange Barrel", -- 180
.byte	0xB5;		"Barrel Barrel",
.byte	0xB6;		"Vine Barrel",
.byte	0xC9;		"K. Rool Barrel: Diddy's Rocketbarrel Game",
.byte	0xCA;		"K. Rool Barrel: Lanky's Shooting Game",
.byte	0xD1;		"K. Rool Barrel: Chunky's Hidden Kremling Game",
.byte	0xD2;		"K. Rool Barrel: Tiny's Pony Tail Twirl Game", -- 210
.byte	0xD3;		"K. Rool Barrel: Chunky's Shooting Game",
.byte	0xD4;		"K. Rool Barrel: DK's Rambi Game",

.align
MaxMemoryViewerIndex:
.byte 0x3

.align
MinMap:
.byte 0

.align
MaxMap:
.byte 0xD7