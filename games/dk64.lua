if type(ScriptHawk) ~= "table" then
	print("This script is not designed to run by itself");
	print("Please run ScriptHawk.lua from the parent directory instead");
	print("Thanks for using ScriptHawk :)");
	return;
end

crumbling = false;
displacement_detection = false;
enable_phase = false; -- To enable the phase glitches on Europe and Japan set this to true
encircle_enabled = false;
fix_chunk_deload = false;
force_gb_load = false;
force_tbs = false;
hide_non_scripted = false;
never_slip = false;
object_model1_filter = nil; -- String, see obj_model1.actor_types
object_model2_filter = nil; -- String, see obj_model2.object_types
paper_mode = false;
rat_enabled = false; -- Randomize Animation Timers

-- TODO: Need to put some grab script state up here because encircle uses it before they would normally be defined
-- This can probably be fixed with a clever reshuffle of grab script state/functions
local object_index = 1;
local object_pointers = {}; -- TODO: I'd love to get rid of this eventually, replace with some kind of getObjectPointers() system
local radius = 100;
local grab_script_modes = {
	{"Disabled","Disabled"},
	{"List (Object Model 1)","Object Model 1", subtype = "List"},
	{"Examine (Object Model 1)","Object Model 1", subtype = "Examine"},
	{"List (Object Model 2)","Object Model 2", subtype = "List"},
	{"Examine (Object Model 2)","Object Model 2", subtype = "Examine"},
	{"List (Loading Zones)","Loading Zones", subtype = "List"},
	{"Examine (Loading Zones)","Loading Zones", subtype = "Examine"},
	{"List (Arcade Objects)","Arcade Objects", subtype = "List"},
	{"Examine (Arcade Objects)","Arcade Objects", subtype = "Examine"},
	{"Chunks","Chunks"},
	{"Exits","Exits"},
	{"List (Spawners)","Spawners", subtype = "List"},
	{"Examine (Spawners)","Spawners", subtype = "Examine"},
};
local grab_script_mode_index = 1;
local grab_script_mode = grab_script_modes[grab_script_mode_index][1];

local function getListOfAnalysisSlideTypes()
	analysis_slide_types = {};
	for i = 1, #grab_script_modes do
		local analysis_stored = false;
		if #analysis_slide_types > 0 then
			for j = 1, #analysis_slide_types do
				if analysis_slide_types[j] == grab_script_modes[i][2] then
					analysis_stored = true;
				end
			end
			if not analysis_stored then
				table.insert(analysis_slide_types, grab_script_modes[i][2]);
			end
		else
			table.insert(analysis_slide_types, grab_script_modes[i][2]);
		end
	end
end

local function getListOfAnalysisSlideSubtypes()
	analysis_slide_subtypes = {};
	for i = 1, #grab_script_modes do
		local analysis_sub_stored = false;
		if #analysis_slide_subtypes > 0 then
			for j = 1, #analysis_slide_subtypes do
				if analysis_slide_subtypes[j] == grab_script_modes[i].subtype then
					analysis_sub_stored = true;
				end
			end
			if not analysis_sub_stored then
				table.insert(analysis_slide_subtypes, grab_script_modes[i].subtype);
			end
		else
			table.insert(analysis_slide_subtypes, grab_script_modes[i].subtype);
		end
	end
end

local function turnFilterBoxIntoFilter()
	local filter_box_text = forms.gettext(ScriptHawk.UI.form_controls["Analysis Filter Textbox"]);
	local filter_value = nil;
	if filter_box_text == "" or filter_box_text == nil then
		filter_value = nil;
	else
		filter_value = filter_box_text;
	end
	if grab_script_modes[grab_script_mode_index][2] == "Object Model 1" then
		object_model1_filter = filter_value;
	end
	if grab_script_modes[grab_script_mode_index][2] == "Object Model 2" then
		object_model2_filter = filter_value;
	end
end

getListOfAnalysisSlideTypes();
getListOfAnalysisSlideSubtypes();
analysis_slide_type_index = 1;
analysis_slide_type = analysis_slide_types[analysis_slide_type_index];
analysis_slide_subtype_index = 1;
analysis_slide_subtype = analysis_slide_subtypes[analysis_slide_subtype_index];

--[[
local function switch_grab_script_mode()
	grab_script_mode_index = grab_script_mode_index + 1;
	if grab_script_mode_index > #grab_script_modes then
		grab_script_mode_index = 1;
	end
	grab_script_mode = grab_script_modes[grab_script_mode_index][1];
	analysis_slide_type = grab_script_modes[grab_script_mode_index][2];
	for i = 1, #analysis_slide_types do
		if analysis_slide_types[i] == analysis_slide_type then
			analysis_slide_type_index = i;
		end
	end
	if grab_script_modes[grab_script_mode_index].subtype == nil then
		analysis_slide_subtype = grab_script_modes[grab_script_mode_index].subtype;
	else
		analysis_slide_subtype = analysis_slide_subtypes[1];
	end
	for i = 1, #analysis_slide_subtypes do
		if analysis_slide_subtypes[i] == analysis_slide_subtype then
			analysis_slide_subtype_index = i;
		end
	end
end
]]--

local function increase_analysis_slide_type()
	analysis_slide_type_index = analysis_slide_type_index + 1;
	if analysis_slide_type_index > #analysis_slide_types then
		analysis_slide_type_index = 1;
	end
	analysis_slide_type = analysis_slide_types[analysis_slide_type_index];
end

local function increase_analysis_slide_subtype()
	analysis_slide_subtype_index = analysis_slide_subtype_index + 1;
	if analysis_slide_subtype_index > #analysis_slide_subtypes then
		analysis_slide_subtype_index = 1;
	end
	analysis_slide_subtype = analysis_slide_subtypes[analysis_slide_subtype_index];
end

local function decrease_analysis_slide_type()
	analysis_slide_type_index = analysis_slide_type_index - 1;
	if analysis_slide_type_index < 1 then
		analysis_slide_type_index = #analysis_slide_types;
	end
	analysis_slide_type = analysis_slide_types[analysis_slide_type_index];
end

local function decrease_analysis_slide_subtype()
	analysis_slide_subtype_index = analysis_slide_subtype_index - 1;
	if analysis_slide_subtype_index < 1 then
		analysis_slide_subtype_index = #analysis_slide_subtypes;
	end
	analysis_slide_subtype = analysis_slide_subtypes[analysis_slide_subtype_index];
end

function grab_script_mode_from_inputs()
	local all_acceptable_script_modes = {};
	for i = 1, #grab_script_modes do
		if grab_script_modes[i][2] == analysis_slide_type then
			table.insert(all_acceptable_script_modes, i);
		end
	end
	local acceptable_subtype_found = false;
	if #all_acceptable_script_modes > 0 then
		for i = 1, #all_acceptable_script_modes do
			if grab_script_modes[all_acceptable_script_modes[i]].subtype ~= nil then
				if grab_script_modes[all_acceptable_script_modes[i]].subtype == analysis_slide_subtype then
					acceptable_subtype_found = true;
					correct_subtype = i;
				end
			end
		end
	end
	if not acceptable_subtype_found then
		all_acceptable_script_modes = {all_acceptable_script_modes[1]};
	else
		all_acceptable_script_modes = {all_acceptable_script_modes[correct_subtype]};
	end
	grab_script_mode_index = all_acceptable_script_modes[1];
	grab_script_mode = grab_script_modes[grab_script_mode_index][1];
end

-------------------------
-- DK64 specific state --
-------------------------

-- TODO: Investigate texture pointer block at 0x7FA8A0 (USA)
	-- 2 pointers
	-- 1 u32_be
local Game = {
	RAMWatch = {},
	squish_memory_table = true,
	Memory = { -- 1 USA, 2 Europe, 3 Japan, 4 Kiosk
		jetpac_object_base = {0x02EC68, 0x021D18, 0x021C78, nil},
		jetpac_enemy_base = {0x02F09C, 0x02214C, 0x0220AC, nil},
		jetpac_level = {0x02EC4F, 0x21CFF, 0x021C5F, nil},
		jetman_position_x = {0x02F050, 0x022100, 0x022060, nil},
		jetman_position_y = {0x02F054, 0x022104, 0x022064, nil},
		jetman_velocity_x = {0x02F058, 0x022108, 0x022068, nil},
		jetman_velocity_y = {0x02F05C, 0x02210C, 0x02206C, nil},
		arcade_object_base = {0x04BCD0, 0x03EC30, 0x03EA60, nil},
		arcade_level = {0x04C723, 0x03F683, 0x03F4B3, nil},
		arcade_reload = {0x04C724, 0x03F684, 0x03F4B4, nil},
		RNG = {0x746A40, 0x7411A0, 0x746300, 0x6F36E0},
		mode = {0x755318, 0x74FB98, 0x7553D8, 0x6FFE6C}, -- See Game.modes for values
		current_map = {0x76A0A8, 0x764BC8, 0x76A298, 0x72CDE4}, -- See Game.maps for values
		current_exit = {0x76A0AC, 0x764BCC, 0x76A29C, 0x72CDE8}, -- u32_be
		exit_array_pointer = {0x7FC900, 0x7FC840, 0x7FCD90, 0x7B6520}, -- Pointer
		number_of_exits = {0x7FC904, 0x7FC844, 0x7FCD94, 0x7B6524}, -- Byte
		level_index_mapping = {0x7445E0, 0x73ED30, 0x743EA0, 0x6F1D10},
		in_submap = {0x76A160, 0x764C80, 0x76A350, nil},
		parent_map = {0x76A172, 0x764C92, 0x76A362, nil},
		parent_exit = {0x76A174, 0x764C94, 0x76A364, nil},
		lag_boost = {0x744478, 0x73EBC8, 0x743D38, 0x6F1C70},
		destination_map = {0x7444E4, 0x73EC34, 0x743DA4, 0x6F1CC4}, -- See Game.maps for values
		destination_exit = {0x7444E8, 0x73EC38, 0x743DA8, 0x6F1CC8},
		-- 1000 0000 - ????
		-- 0100 0000 - ????
		-- 0010 0000 - ????
		-- 0001 0000 - In Cutscene
		-- 0000 1000 - Always Set?
		-- 0000 0100 - ????
		-- 0000 0010 - ????
		-- 0000 0001 - Reload Map
		map_state = {0x76A0B1, 0x764BD1, 0x76A2A1, 0x72CDED}, -- byte, bitfield -- TODO: Document remaining values
		-- 0 = Fade (Level FT Entry w/out Story Skip [Probably Wrong Cutscene fade type])
		-- 1 = DK Transition
		-- 2 = Fade (Normal Level Entry / FT Entry with Story Skip)
		-- 3 = Unused (Shrinking rectangle)
		loading_zone_transition_type = {0x76AEE0, 0x765A00, 0x76B0D0, 0x72D110}, -- byte
		loazing_zone_transition_speed = {0x7FD88C, 0x7FD7CC, 0x7FDD1C, 0x7B708C}, -- Float
		loading_zone_array_size = {0x7FDCB0, 0x7FDBF0, 0x7FE140, 0x7B7410}, -- u16_be
		loading_zone_array = {0x7FDCB4, 0x7FDBF4, 0x7FE144, 0x7B7414},
		file = {0x7467C8, 0x740F18, 0x746088, nil},
		character = {0x74E77C, 0x748EDC, 0x74E05C, 0x6F9EB8},
		character_change_pointer = {0x7FC924, 0x7FC864, 0x7FCDB4, 0x7B6564},
		character_change_offset_player_actor = {0x36F, 0x36F, 0x36F, 0x333},
		character_change_offset_mystery_object = {0x29C, 0x29C, 0x29C, 0x29C},
		character_change_value_mystery_object = {0x3B, 0x3C, 0x3C, 0x2E},
		object_spawn_table = {0x74E8B0, 0x749010, 0x74E1D0, 0x6F9F80},
		enemy_drop_table = {0x750400, 0x74AB20, 0x74FCE0, 0x6FB630},
		cutscene_model_table = {0x75570C, 0x74FF8C, 0x7557CC, 0x7001F0},
		flag_mapping = {0x755A20, 0x7502B0, 0x755AF0, 0x7003D0},
		enemy_table = {0x75EB80, 0x759690, 0x75ED40, 0x70A460},
		num_enemy_types = {0x70, 0x70, 0x70, 0x66},
		enemy_type_size = {0x18, 0x18, 0x18, 0x1C},
		-- 1000 0000 - ????
		-- 0100 0000 - Pause Cancel
		-- 0010 0000 - Show Model 2 Objects
		-- 0001 0000 - Tag Barrel Void
		-- 0000 1000 - ????
		-- 0000 0100 - ????
		-- 0000 0010 - Freeze Actors (Pause Menu)
		-- 0000 0001 - Pausing
		tb_void_byte = {0x7FBB63, 0x7FBA83, 0x7FBFD3, 0x7B5B13}, -- byte, bitfield -- TODO: Document remaining values
		player_pointer = {0x7FBB4C, 0x7FBA6C, 0x7FBFBC, 0x7B5AFC},
		camera_pointer = {0x7FB968, 0x7FB888, 0x7FBDD8, 0x7B5918},
		actor_pointer_array = {0x7FBFF0, 0x7FBF10, 0x7FC460, 0x7B5E58},
		actor_count = {0x7FC3F0, 0x7FC310, 0x7FC860, 0x7B6258},
		heap_pointer = {0x7F0990, 0x7F08B0, 0x7F0E00, 0x7A12C0},
		heap_end = {0x561FA0, 0x55AFA0, 0x55F7A0, 0x4D7DB0},
		texture_list_pointer = {0x7F09DC, 0x7F08FC, 0x7F0E4C, 0x7A130C},
		model2_dl_rom_map_object_pointer = {0x7F9538, 0x7F9458, 0x7F99A8, 0x7B49F4},
		texture_rom_map_object_pointer = {0x7F9544, 0x7F9464, 0x7F99B4, 0x7B4A00},
		ffa_texture_rom_map_object_pointer = {0x7F9560, 0x7F9480, 0x7F99D0, 0x7B4A1C},
		texture_rom_map_object_pointer_2 = {0x7F958C, 0x7F94AC, 0x7F99FC, 0x7B4A48},
		model2_dl_index_object_pointer = {0x7F95B8, 0x7F94D8, 0x7F9A28, 0x7B4A74},
		texture_index_object_pointer = {0x7F95C4, 0x7F94E4, 0x7F9A34, 0x7B4A80},
		ffa_texture_index_object_pointer = {0x7F95E0, 0x7F9500, 0x7F9A50, 0x7B4A9C},
		texture_index_object_pointer_2 = {0x7F960C, 0x7F952C, 0x7F9A7C, 0x7B4AC8},
		weather_particle_array_pointer = {0x7FD9E4, 0x7FD924, 0x7FDE74, 0x7B71C4},
		hud_pointer = {0x754280, 0x74E9E0, 0x753B70, 0x6FF080},
		shared_collectables = {0x7FCC40, 0x7FCB80, 0x7FD0D0, 0x7B6752},
		kong_base = {0x7FC950, 0x7FC890, 0x7FCDE0, 0x7B6590},
		kong_size = {0x5E, 0x5E, 0x5E, 0x5A},
		framebuffer_pointer = {0x744470, 0x73EBC0, 0x743D30, 0x72CDA0},
		eeprom_copy_base = {0x7ECEA8, 0x7ECDC8, 0x7ED318, nil},
		menu_flags = {0x7ED558, 0x7ED478, 0x7ED9C8, nil},
		eeprom_file_mapping = {0x7EDEA8, 0x7EDDC8, 0x7EE318, nil},
		security_byte = {0x7552E0, 0x74FB60, 0x7553A0, nil}, -- As far as I am aware this function is not present in the Kiosk version
		security_message = {0x75E5DC, 0x7590F0, 0x75E790, nil}, -- As far as I am aware this function is not present in the Kiosk version
		DKTV_pointer = {0x7550C0, 0x74F940, 0x755180, 0x709DA0},
		buttons_enabled_bitfield = {0x755308, 0x74FB88, 0x7553C8, 0x6FFE5C},
		joystick_enabled_x = {0x75530C, 0x74FB8C, 0x7553CC, 0x6FFE60},
		joystick_enabled_y = {0x755310, 0x74FB90, 0x7553D0, 0x6FFE64},
		bone_displacement_cop0_write = {0x61963C, 0x6128EC, 0x6170AC, 0x5AFB1C},
		frames_lag = {0x76AF10, 0x765A30, 0x76B100, 0x72D140}, -- TODO: Kiosk only works for minecart?
		frames_real = {0x7F0560, 0x7F0480, 0x7F09D0, nil}, -- TODO: Make sure freezing these stalls the main thread -- TODO: Kiosk
		isg_active = {0x755070, 0x74F8F0, 0x755130, nil},
		isg_timestamp = {0x7F5CE0, 0x7F5C00, 0x7F6150, nil},
		isg_previous_fadeout = {0x7F5D14, 0x7F5C34, 0x7F6184, nil},
		timestamp = {0x14FE0, 0x155C0, 0x15300, 0x72F880},
		cutscene_will_play_next_map = {0x75533B, 0x74FBBB, 0x7553FB, nil}, -- byte
		cutscene_to_play_next_map = {0x75533E, 0x74FBBE, 0x7553FE, nil}, -- 2-byte
		cutscene_active = {0x7444EC, 0x73EC3C, 0x743DAC, 0x6F1CCC},
		cutscene_timer = {0x7476F0, 0x741E50, 0x746FB0, 0x6F4460},
		cutscene = {0x7476F4, 0x741E54, 0x746FB4, 0x6F4464},
		cutscene_type = {0x7476FC, 0x741E5C, 0x746FBC, 0x6F446C},
		cutscene_type_map = {0x7F5B10, 0x7F5A30, 0x7F5F80, 0x7A1C00},
		cutscene_type_kong = {0x7F5BF0, 0x7F5B10, 0x7F6060, 0x7A1CE0},
		number_of_cutscenes = {0x7F5BDC, 0x7F5AFC, 0x7F604C, 0x7A1CCC},
		obj_model2_array_pointer = {0x7F6000, 0x7F5F20, 0x7F6470, 0x7A20B0}, -- 0x6F4470 has something to do with obj model 2 on Kiosk, not sure what yet
		obj_model2_array_count = {0x7F6004, 0x7F5F24, 0x7F6474, 0x7B17B8},
		obj_model2_setup_pointer = {0x7F6010, 0x7F5F30, 0x7F6480, 0x7B17C4},
		obj_model2_timer = {0x76A064, 0x764B84, 0x76A254, 0x72CDAC},
		obj_model2_collision_linked_list_pointer = {0x754244, 0x74E9A4, 0x753B34, 0x6FF054},
		map_block_pointer = {0x7F5DE0, 0x7F5D00, 0x7F6250, 0x7A1E90},
		map_vertex_pointer = {0x7F5DE8, 0x7F5D08, 0x7F6258, 0x7A1E98},
		map_displaylist_pointer = {0x7F5DEC, 0x7F5D0C, 0x7F625C, 0x7A1E9C},
		map_wall_pointer = {0x7FB534, 0x7FB454, 0x7FB9A4, 0x7B54E8},
		map_floor_pointer = {0x7F9514, 0x7F9434, 0x7F9984, 0x7B49D4},
		water_surface_list = {0x7F93C0, 0x7F92E0, 0x7F9830, 0x7B48A0},
		chunk_array_pointer = {0x7F6C18, 0x7F6B38, 0x7F7088, 0x7B20F8},
		num_enemies = {0x7FDC88, 0x7FDBC8, 0x7FE118, 0x7B73D8},
		enemy_respawn_object = {0x7FDC8C, 0x7FDBCC, 0x7FE11C, 0x7B73DC},
		os_code_start = {0x400, 0x400, 0x400, nil}, -- TODO: Kiosk
		os_code_size = {0xD8A8, 0xDAB8, 0xDB18, nil},
		game_code_start = {0x5FB300, 0x5F4300, 0x5F8B00, 0x590000},
		game_code_size = {0x149160, 0x14A8B0, 0x14B220, nil},
		game_constants_start = {0x744460, 0x73EBB0, 0x743D20, nil},
		game_constants_size = {0x1CBF0, 0x1CFC0, 0x1D520, nil},
	},
	modes = {
		[0] = "Nintendo Logo",
		[1] = "Opening Cutscene",
		[2] = "DK Rap",
		[3] = "DK TV",
		-- 4 is unknown
		[5] = "Main Menu",
		[6] = "Adventure",
		[7] = "Quit Game",
		-- 8 is unknown
		[9] = "Game Over",
		[10] = "End Sequence",
		[11] = "DK Theatre",
		[12] = "Mystery Menu Minigame",
		[13] = "Snide's Bonus Game",
		[14] = "End Sequence (DK Theatre)",
	},
	maps = {
		"Test Map", -- 0
		"Funky's Store",
		"DK Arcade",
		"K. Rool Barrel: Lanky's Maze",
		"Jungle Japes: Mountain",
		"Cranky's Lab",
		"Jungle Japes: Minecart",
		"Jungle Japes",
		"Jungle Japes: Army Dillo",
		"Jetpac",
		"Kremling Kosh! (very easy)", -- 10
		"Stealthy Snoop! (normal, no logo)",
		"Jungle Japes: Shell",
		"Jungle Japes: Lanky's Cave",
		"Angry Aztec: Beetle Race",
		"Snide's H.Q.",
		"Angry Aztec: Tiny's Temple",
		"Hideout Helm",
		"Teetering Turtle Trouble! (very easy)",
		"Angry Aztec: Five Door Temple (DK)",
		"Angry Aztec: Llama Temple", -- 20
		"Angry Aztec: Five Door Temple (Diddy)",
		"Angry Aztec: Five Door Temple (Tiny)",
		"Angry Aztec: Five Door Temple (Lanky)",
		"Angry Aztec: Five Door Temple (Chunky)",
		"Candy's Music Shop",
		"Frantic Factory",
		"Frantic Factory: Car Race",
		"Hideout Helm (Level Intros, Game Over)",
		"Frantic Factory: Power Shed",
		"Gloomy Galleon", -- 30
		"Gloomy Galleon: K. Rool's Ship",
		"Batty Barrel Bandit! (easy)",
		"Jungle Japes: Chunky's Cave",
		"DK Isles Overworld",
		"K. Rool Barrel: DK's Target Game",
		"Frantic Factory: Crusher Room",
		"Jungle Japes: Barrel Blast",
		"Angry Aztec",
		"Gloomy Galleon: Seal Race",
		"Nintendo Logo", -- 40
		"Angry Aztec: Barrel Blast",
		"Troff 'n' Scoff", -- 42
		"Gloomy Galleon: Shipwreck (Diddy, Lanky, Chunky)",
		"Gloomy Galleon: Treasure Chest",
		"Gloomy Galleon: Mermaid",
		"Gloomy Galleon: Shipwreck (DK, Tiny)",
		"Gloomy Galleon: Shipwreck (Lanky, Tiny)",
		"Fungi Forest",
		"Gloomy Galleon: Lighthouse",
		"K. Rool Barrel: Tiny's Mushroom Game", -- 50
		"Gloomy Galleon: Mechanical Fish",
		"Fungi Forest: Ant Hill",
		"Battle Arena: Beaver Brawl!",
		"Gloomy Galleon: Barrel Blast",
		"Fungi Forest: Minecart",
		"Fungi Forest: Diddy's Barn",
		"Fungi Forest: Diddy's Attic",
		"Fungi Forest: Lanky's Attic",
		"Fungi Forest: DK's Barn",
		"Fungi Forest: Spider", -- 60
		"Fungi Forest: Front Part of Mill",
		"Fungi Forest: Rear Part of Mill",
		"Fungi Forest: Mushroom Puzzle",
		"Fungi Forest: Giant Mushroom",
		"Stealthy Snoop! (normal)",
		"Mad Maze Maul! (hard)",
		"Stash Snatch! (normal)",
		"Mad Maze Maul! (easy)",
		"Mad Maze Maul! (normal)", -- 69
		"Fungi Forest: Mushroom Leap", -- 70
		"Fungi Forest: Shooting Game",
		"Crystal Caves",
		"Battle Arena: Kritter Karnage!",
		"Stash Snatch! (easy)",
		"Stash Snatch! (hard)",
		"DK Rap",
		"Minecart Mayhem! (easy)", -- 77
		"Busy Barrel Barrage! (easy)",
		"Busy Barrel Barrage! (normal)",
		"Main Menu", -- 80
		"Title Screen (Not For Resale Version)",
		"Crystal Caves: Beetle Race",
		"Fungi Forest: Dogadon",
		"Crystal Caves: Igloo (Tiny)",
		"Crystal Caves: Igloo (Lanky)",
		"Crystal Caves: Igloo (DK)",
		"Creepy Castle",
		"Creepy Castle: Ballroom",
		"Crystal Caves: Rotating Room",
		"Crystal Caves: Shack (Chunky)", -- 90
		"Crystal Caves: Shack (DK)",
		"Crystal Caves: Shack (Diddy, middle part)",
		"Crystal Caves: Shack (Tiny)",
		"Crystal Caves: Lanky's Hut",
		"Crystal Caves: Igloo (Chunky)",
		"Splish-Splash Salvage! (normal)",
		"K. Lumsy",
		"Crystal Caves: Ice Castle",
		"Speedy Swing Sortie! (easy)",
		"Crystal Caves: Igloo (Diddy)", -- 100
		"Krazy Kong Klamour! (easy)",
		"Big Bug Bash! (very easy)",
		"Searchlight Seek! (very easy)",
		"Beaver Bother! (easy)",
		"Creepy Castle: Tower",
		"Creepy Castle: Minecart",
		"Kong Battle: Battle Arena",
		"Creepy Castle: Crypt (Lanky, Tiny)",
		"Kong Battle: Arena 1",
		"Frantic Factory: Barrel Blast", -- 110
		"Gloomy Galleon: Pufftoss",
		"Creepy Castle: Crypt (DK, Diddy, Chunky)",
		"Creepy Castle: Museum",
		"Creepy Castle: Library",
		"Kremling Kosh! (easy)",
		"Kremling Kosh! (normal)",
		"Kremling Kosh! (hard)",
		"Teetering Turtle Trouble! (easy)",
		"Teetering Turtle Trouble! (normal)",
		"Teetering Turtle Trouble! (hard)", -- 120
		"Batty Barrel Bandit! (easy)",
		"Batty Barrel Bandit! (normal)",
		"Batty Barrel Bandit! (hard)",
		"Mad Maze Maul! (insane)",
		"Stash Snatch! (insane)",
		"Stealthy Snoop! (very easy)",
		"Stealthy Snoop! (easy)",
		"Stealthy Snoop! (hard)",
		"Minecart Mayhem! (normal)",
		"Minecart Mayhem! (hard)", -- 130
		"Busy Barrel Barrage! (hard)",
		"Splish-Splash Salvage! (hard)",
		"Splish-Splash Salvage! (easy)",
		"Speedy Swing Sortie! (normal)",
		"Speedy Swing Sortie! (hard)",
		"Beaver Bother! (normal)",
		"Beaver Bother! (hard)",
		"Searchlight Seek! (easy)",
		"Searchlight Seek! (normal)",
		"Searchlight Seek! (hard)", -- 140
		"Krazy Kong Klamour! (normal)",
		"Krazy Kong Klamour! (hard)",
		"Krazy Kong Klamour! (insane)",
		"Peril Path Panic! (very easy)",
		"Peril Path Panic! (easy)",
		"Peril Path Panic! (normal)",
		"Peril Path Panic! (hard)",
		"Big Bug Bash! (easy)",
		"Big Bug Bash! (normal)",
		"Big Bug Bash! (hard)", -- 150
		"Creepy Castle: Dungeon",
		"Hideout Helm (Intro Story)",
		"DK Isles (DK Theatre)",
		"Frantic Factory: Mad Jack",
		"Battle Arena: Arena Ambush!",
		"Battle Arena: More Kritter Karnage!",
		"Battle Arena: Forest Fracas!",
		"Battle Arena: Bish Bash Brawl!",
		"Battle Arena: Kamikaze Kremlings!",
		"Battle Arena: Plinth Panic!", -- 160
		"Battle Arena: Pinnacle Palaver!",
		"Battle Arena: Shockwave Showdown!",
		"Creepy Castle: Basement",
		"Creepy Castle: Tree",
		"K. Rool Barrel: Diddy's Kremling Game",
		"Creepy Castle: Chunky's Toolshed",
		"Creepy Castle: Trash Can",
		"Creepy Castle: Greenhouse",
		"Jungle Japes Lobby",
		"Hideout Helm Lobby", -- 170
		"DK's House",
		"Rock (Intro Story)",
		"Angry Aztec Lobby",
		"Gloomy Galleon Lobby",
		"Frantic Factory Lobby",
		"Training Grounds",
		"Dive Barrel",
		"Fungi Forest Lobby",
		"Gloomy Galleon: Submarine",
		"Orange Barrel", -- 180
		"Barrel Barrel",
		"Vine Barrel",
		"Creepy Castle: Crypt",
		"Enguarde Arena",
		"Creepy Castle: Car Race",
		"Crystal Caves: Barrel Blast",
		"Creepy Castle: Barrel Blast",
		"Fungi Forest: Barrel Blast",
		"Fairy Island",
		"Kong Battle: Arena 2", -- 190
		"Rambi Arena",
		"Kong Battle: Arena 3",
		"Creepy Castle Lobby",
		"Crystal Caves Lobby",
		"DK Isles: Snide's Room",
		"Crystal Caves: Army Dillo",
		"Angry Aztec: Dogadon",
		"Training Grounds (End Sequence)",
		"Creepy Castle: King Kut Out",
		"Crystal Caves: Shack (Diddy, upper part)", -- 200
		"K. Rool Barrel: Diddy's Rocketbarrel Game",
		"K. Rool Barrel: Lanky's Shooting Game",
		"K. Rool Fight: DK Phase",
		"K. Rool Fight: Diddy Phase",
		"K. Rool Fight: Lanky Phase",
		"K. Rool Fight: Tiny Phase",
		"K. Rool Fight: Chunky Phase",
		"Bloopers Ending",
		"K. Rool Barrel: Chunky's Hidden Kremling Game",
		"K. Rool Barrel: Tiny's Pony Tail Twirl Game", -- 210
		"K. Rool Barrel: Chunky's Shooting Game",
		"K. Rool Barrel: DK's Rambi Game",
		"K. Lumsy Ending",
		"K. Rool's Shoe",
		"K. Rool's Arena", -- 215
	},
	speedy_speeds = { .001, .01, .1, 1, 5, 10, 15, 20, 35, 50, 100, 250, 500, 1000 },
	speedy_index = 8,
	rot_speed = 10,
	max_rot_units = 4096,
	form_height = 14,
};

function Game.getCurrentMode()
	local modeValue = mainmemory.readbyte(Game.Memory.mode);
	if Game.modes[modeValue] ~= nil then
		return Game.modes[modeValue];
	end
	return "Unknown "..modeValue;
end

-- Don't trust anything on the heap if this is true
function Game.isLoading()
	return mainmemory.read_u32_be(Game.Memory.obj_model2_timer) == 0;
end

function Game.getCutsceneIndex()
	return mainmemory.read_u16_be(Game.Memory.cutscene);
end

function Game.getNumberOfCutscenes()
	return mainmemory.read_u16_be(Game.Memory.number_of_cutscenes);
end

function Game.getCutsceneOSD()
	if mainmemory.readbyte(Game.Memory.cutscene_active) == 0 then
		return "None";
	end
	local numberOfCutscenes = Game.getNumberOfCutscenes() - 1;
	if numberOfCutscenes == -1 then
		numberOfCutscenes = "None";
	end
	local cutsceneType = dereferencePointer(Game.Memory.cutscene_type);
	local cutsceneTime = mainmemory.read_u16_be(Game.Memory.cutscene_timer);
	if cutsceneType == Game.Memory.cutscene_type_kong then
		return Game.getCutsceneIndex().." (Global ["..cutsceneTime.."])";
	elseif cutsceneType == Game.Memory.cutscene_type_map then
		return Game.getCutsceneIndex().."/"..numberOfCutscenes.." (Map ["..cutsceneTime.."])";
	else
		return Game.getCutsceneIndex().." (Unknown Type: "..toHexString(cutsceneType).." ["..cutsceneTime.."])";
	end
end

local flag_array = {};
local flag_names = {};
local flags_by_map = {};
local previousCameraState = "Unknown";
local map_value = 0;

------------------
-- Subgame maps --
------------------

local arcade_map = 2;
local jetpac_map = 9;

local arcade_object = {
	x_position = 0x00, -- Float
	y_position = 0x04, -- Float
	x_velocity = 0x08, -- Float
	y_velocity = 0x0C, -- Float
	object_type = 0x18,
	movement = 0x19,
	size = 0x20,
	count = 61, -- TODO: Figure out actual value
	hitbox = {
		width = 16,
		height = 16,
		x_offset = 0,
		y_offset = 0,
	},
	object_name = {
		[1] = "Barrel", -- 25m
		[2] = "Flame Enemy",
		[3] = "Spring", -- 75m
		[4] = "Pie", -- 50m
		[5] = "Points Bonus", -- Umbrella, Handbag etc.
		[6] = "Hammer",
		[7] = "Particles", -- Hammer
		[8] = "DK (How High)",
		-- [9]
		[10] = "Barrel (Stack)", -- 25m, near DK
		[11] = "Rivet", -- 100m
		[12] = "Moving Ladder", -- 50m
		[13] = "Jumpman",
		[14] = "Bonus", -- OSD
		[15] = "Particles", -- 100m Completion
		[16] = "Oil Drum", -- 25m
		[17] = "Elevator Crank", -- 75m
		[18] = "Pulley", -- 50m
		[19] = "Flames", -- Oil Drum (25m)
		[20] = "Points Text", -- Text (Eg. 100)
		[21] = "DK (Title)",
		[22] = "DK (25m)",
		[23] = "DK (100m)",
		[24] = "DK (75m)",
		[25] = "DK (50m)",
		[26] = "Pauline (Bottom)",
		[27] = "Pauline (Top)",
		-- [28]
		[29] = "Text", -- 'Help!' from Pauline
		-- [30]
	},
};

local function getArcadeObjectNameOSD(objectType)
	if arcade_object.object_name[objectType] ~= nil then
		return arcade_object.object_name[objectType];
	end
	return 'Unknown';
end

function Game.getJumpman()
	for i = 0, arcade_object.count - 1 do
		local objectBase = Game.Memory.arcade_object_base + (i * arcade_object.size);
		if mainmemory.readbyte(objectBase + arcade_object.object_type) == 0x0D then
			return objectBase;
		end
	end
end

local arcadeXMultiplier = 1;
local arcadeYMultiplier = 0.9;

local jetpacHitboxXOffset = 26;
local jetpacHitboxYOffset = 18;

local mouseClickedLastFrame = false;
local startDragPosition = {0, 0};
local draggedObjects = {};

local function arcadeObjectBaseToDraggableObject(objectBase)
	local draggableObject = {
		objectBase = objectBase,
		xPositionAddress = objectBase + arcade_object.x_position,
		yPositionAddress = objectBase + arcade_object.y_position,
		xPosition = mainmemory.readfloat(objectBase + arcade_object.x_position, true),
		yPosition = mainmemory.readfloat(objectBase + arcade_object.y_position, true),
	};

	local hbWidth = mainmemory.readbyte(objectBase + 0x1E);
	local hbHeight = mainmemory.readbyte(objectBase + 0x1F);

	draggableObject.leftX = (draggableObject.xPosition + arcade_object.hitbox.x_offset) * arcadeXMultiplier;
	draggableObject.rightX = draggableObject.leftX + hbWidth;
	draggableObject.topY = (draggableObject.yPosition + arcade_object.hitbox.y_offset) * arcadeYMultiplier;
	draggableObject.bottomY = draggableObject.topY + hbHeight;

	return draggableObject;
end

local function jetpacObjectBaseToDraggableObject(objectBase)
	local draggableObject = {
		objectBase = objectBase,
		xPositionAddress = objectBase + 0x00,
		yPositionAddress = objectBase + 0x04,
		xPosition = mainmemory.readfloat(objectBase + 0x00, true),
		yPosition = mainmemory.readfloat(objectBase + 0x04, true),
	};

	draggableObject.leftX = (draggableObject.xPosition + jetpacHitboxXOffset) * 1;
	draggableObject.rightX = draggableObject.leftX + 16;
	draggableObject.topY = (draggableObject.yPosition + jetpacHitboxYOffset) * 1;
	draggableObject.bottomY = draggableObject.topY + 16;

	return draggableObject;
end

local function drawSubGameHitboxes()
	if Game.version == 4 then
		return;
	end

	local startDrag = false;
	local dragging = false;
	local draggableObjects = {};
	local dragTransform = {0, 0};
	local mouse = input.getmouse();

	if mouse.Left then
		if not mouseClickedLastFrame then
			startDrag = true;
			startDragPosition = {mouse.X, mouse.Y};
		end
		mouseClickedLastFrame = true;
		dragging = true;
		dragTransform = {mouse.X - startDragPosition[1], mouse.Y - startDragPosition[2]};
	else
		draggedObjects = {};
		mouseClickedLastFrame = false;
		dragging = false;
	end

	if map_value == arcade_map then
		for i = 0, arcade_object.count - 1 do
			local objectBase = Game.Memory.arcade_object_base + (i * arcade_object.size);
			table.insert(draggableObjects, arcadeObjectBaseToDraggableObject(objectBase));
		end
	end

	if map_value == jetpac_map then
		-- Objects
		for i = 0, 4 do
			local objectBase = Game.Memory.jetpac_object_base + i * 0x4C;
			if i == 4 then
				objectBase = objectBase + 4;
			end
			table.insert(draggableObjects, jetpacObjectBaseToDraggableObject(objectBase));
		end
		-- Enemies
		for i = 0, 9 do
			local objectBase = Game.Memory.jetpac_enemy_base + i * 0x50;
			table.insert(draggableObjects, jetpacObjectBaseToDraggableObject(objectBase));
		end
		-- Player
		table.insert(draggableObjects, jetpacObjectBaseToDraggableObject(Game.Memory.jetman_position_x));
	end

	for i = 1, #draggableObjects do
		--local objectBase = draggableObjects[i].objectBase;
		local xPosition = draggableObjects[i].xPosition;
		local yPosition = draggableObjects[i].yPosition;
		local leftX = draggableObjects[i].leftX;
		local rightX = draggableObjects[i].rightX;
		local topY = draggableObjects[i].topY;
		local bottomY = draggableObjects[i].bottomY;
		if dragging then
			for d = 1, #draggedObjects do
				if draggedObjects[d][1] == i then
					xPosition = draggedObjects[d][2] + dragTransform[1];
					yPosition = draggedObjects[d][3] + dragTransform[2];
					mainmemory.writefloat(draggableObjects[i].xPositionAddress, xPosition, true);
					mainmemory.writefloat(draggableObjects[i].yPositionAddress, yPosition, true);
					break;
				end
			end
		end
		gui.drawBox(leftX, topY, rightX, bottomY, colors.white);
		if (mouse.X >= leftX and mouse.X <= rightX) and (mouse.Y >= topY and mouse.Y <= bottomY) then
			if startDrag then
				table.insert(draggedObjects, {i, xPosition, yPosition});
				--console.log("starting drag for object "..i);
			end
		end
	end

	-- Draw mouse
	--gui.drawPixel(mouse.X, mouse.Y, colors.white);
	gui.drawImage("beta/cursor.png", mouse.X, mouse.Y - 4);
end

local function getSubgameLevel()
	if map_value == arcade_map then
		local arcade_level = mainmemory.readbyte(Game.Memory.arcade_level);
		local arcade_level_osd = ((math.fmod(arcade_level, 3) + 1) * 25).."m ("..math.floor(arcade_level / 4)..")";
		return arcade_level_osd;
	elseif map_value == jetpac_map then
		local jetpac_level = mainmemory.readbyte(Game.Memory.jetpac_level);
		return jetpac_level;
	end
	return 0;
end

-- TODO: Hook these up to UI somehow?
function arcadeTakeMeThere(level)
	local level_value = 0;
	if map_value == arcade_map then
		if level == "25m" then
			level_value = 0;
		elseif level == "50m" then
			level_value = 1;
		elseif level == "75m" then
			level_value = 2;
		elseif level == "100m" then
			level_value = 3;
		end

		if level == "25m" or level == "50m" or level == "75m" or level == "100m" then
			mainmemory.writebyte(Game.Memory.arcade_level, level_value);
			mainmemory.writebyte(Game.Memory.arcade_reload, 2);
		end
	end
end

-- TODO: Hook these up to UI somehow?
function jetpacTakeMeThere(level)
	if map_value == jetpac_map then
		mainmemory.writebyte(Game.Memory.jetpac_level, level);
	end
end

-----------------
-- Other state --
-----------------

--local eeprom_size = 0x800;
local eeprom_slot_size = 0x1AC;
local eep_checksum = {
	{ address = 0x1A8, value = 0 }, -- Save Slot 1
	{ address = 0x354, value = 0 }, -- Save Slot 2
	{ address = 0x500, value = 0 }, -- Save Slot 3
	{ address = 0x6AC, value = 0 }, -- Save Slot 4
	{ address = 0x6EC, value = 0 }, -- Global flags
};

----------------------------------
-- Refill Consumables           --
-- Based on research by Exchord --
----------------------------------

-- Maximum values
local max_coins          = 50;
local max_crystals       = 20; local ticks_per_crystal = 150; -- 125 for European version
local max_film           = 10;
local max_oranges        = 20;
local max_musical_energy = 10;

local max_blueprints = 40;
local max_cb = 3513; -- 3500 in levels, 10 in test room balloon, 2 out of bounds in Japes, 1 out of bounds in Galleon
local max_crowns = 10;
local max_fairies = 20;
local max_gb = 201;
local max_medals = 40;
local max_warps = (5 * 2 * 8) + 4 + 2 + 2 + 6;

-- Relative to shared_collectables
local standard_ammo = 0; -- u16_be
local homing_ammo   = 2; -- u16_be
local oranges       = 4; -- u16_be
local crystals      = 6; -- u16_be, 150 ticks per crystal or 125 in European version
local film          = 8; -- u16_be
local health        = 11; -- s8 -- 12 on Kiosk, handled in Game.detectVersion()
local melons        = 12; -- u8? -- 13 on Kiosk, handled in Game.detectVersion()

-- Kong index
local DK     = 0;
local Diddy  = 1;
local Lanky  = 2;
local Tiny   = 3;
local Chunky = 4;
local Krusha = 5;

-- Relative to Kong base
local moves      = 0; -- u8
local sim_slam   = 1; -- u8
local weapon     = 2; -- byte, bitfield, xxxxxshw
local ammo_belt  = 3; -- u8, see Game.getMaxStandardAmmo() for formula
local instrument = 4; -- byte, bitfield, xxxx321i
local coins      = 6; -- u16_be
local lives      = 8; -- u16_be This is used as instrument ammo in single player
local CB_Base    = 10; -- u16_be array
local TS_CB_Base = CB_Base + (14 * 2); -- u16_be array
local GB_Base    = TS_CB_Base + (14 * 2); -- u16_be array

-- For CB, T&S CB, GB
-- Different on Kiosk, handled in Game.detectVersion()
local levelIndexes = {
	[0x00] = "Japes",
	[0x01] = "Aztec",
	[0x02] = "Factory",
	[0x03] = "Galleon",
	[0x04] = "Fungi",
	[0x05] = "Caves",
	[0x06] = "Castle",
	[0x07] = "Isles",
	[0x08] = "Helm",
	[0x09] = "Bonus", -- Submap
	[0x0A] = "Multiplayer",
	[0x0B] = "Story",
	[0x0C] = "Test",
	[0x0D] = "Shared", -- Submap
};

function Game.getMaxStandardAmmo()
	local kong = Game.getCharacter();
	local ammoBelt = mainmemory.readbyte(Game.Memory.kong_base + (kong * Game.Memory.kong_size) + ammo_belt);
	return ((2 ^ ammoBelt) * 100) / 2;
end
Game.getMaxHomingAmmo = Game.getMaxStandardAmmo;

----------------------------------
-- Object Model 1 Documentation --
----------------------------------

-- Relative to objects found in the heap (and similar linked lists)
local heap = {
	previous_object = -0x10, -- Pointer
	object_size = -0x0C, -- u32_be
	next_free_block = -0x08, -- Pointer
	prev_free_block = -0x04, -- Pointer
};

-- Theoretical max is 255 actors, but the game crashes well before that limit
local function getObjectModel1Count()
	return math.min(255, mainmemory.read_u16_be(Game.Memory.actor_count));
end

-- Relative to Model 1 Objects
obj_model1 = {
	model_pointer = 0x00,
	model = { -- Relative to model_pointer
		num_bones = 0x20,
	},
	rendering_parameters_pointer = 0x04,
	rendering_parameters = { -- Relative to rendering_parameters_pointer
		bone_array_1 = 0x14, -- Pointer: Used for camera, updating bone positions
		bone_array_2 = 0x18, -- Pointer: Used for camera, updating bone positions
		scale_x = 0x34, -- 32 bit float big endian
		scale_y = 0x38, -- 32 bit float big endian
		scale_z = 0x3C, -- 32 bit float big endian
		anim_timer1 = 0x94, -- 32 bit float big endian
		anim_timer2 = 0x98, -- 32 bit float big endian
		anim_timer3 = 0x104, -- 32 bit float big endian
		anim_timer4 = 0x108, -- 32 bit float big endian
	},
	current_bone_array_pointer = 0x08,
	actor_type = 0x5A, -- u16 be
	actor_types = { -- These are different on Kiosk
		[2] = "DK",
		[3] = "Diddy",
		[4] = "Lanky",
		[5] = "Tiny",
		[6] = "Chunky",
		[7] = "Krusha",
		[8] = "Rambi",
		[9] = "Enguarde",
		--[10] = "Unknown", -- Always loaded -- TODO: Figure out what actors 10-15 do
		--[11] = "Unknown", -- Always loaded -- What is this?
		[12] = "Loading Zone Controller", -- Always loaded
		[13] = "Object Model 2 Controller", -- Always loaded
		--[14] = "Unknown", -- Always loaded -- What is this?
		--[15] = "Unknown", -- Always loaded -- What is this?
		[17] = "Cannon Barrel",
		[18] = "Rambi Crate",
		[19] = "Barrel (Diddy 5DI)",
		[20] = "Camera Focus Point", -- Exists during some cutscenes
		[21] = "Pushable Box",
		[22] = "Barrel Spawner", -- Normal barrel on a star pad, unused?
		[23] = "Cannon",
		[25] = "Hunky Chunky Barrel",
		[26] = "TNT Barrel",
		[27] = "TNT Barrel Spawner", -- Army Dillo
		[28] = "Bonus Barrel",
		[29] = "Minecart",
		[30] = "Fireball", -- Boss fights
		[31] = "Bridge (Castle)",
		[32] = "Swinging Light",
		[33] = "Vine", -- Brown
		[34] = "Kremling Kosh Controller",
		[35] = "Melon (Projectile)",
		[36] = "Peanut",
		[37] = "Rocketbarrel", -- On Kong
		[38] = "Pineapple",
		[39] = "Large Brown Bridge", -- Unused?
		[40] = "Mini Monkey Barrel",
		[41] = "Orange",
		[42] = "Grape",
		[43] = "Feather",
		[44] = "Laser", -- Projectile
		[45] = "Golden Banana", -- Vulture, bonus barrels (US code 0x6818EE), probably some other places
		[46] = "Barrel Gun", -- Teetering Turtle Trouble
		[47] = "Watermelon Slice",
		[48] = "Coconut",
		[49] = "Rocketbarrel", -- The Barrel
		[50] = "Lime",
		[51] = "Ammo Crate", -- Dropped by Red Klaptrap
		[52] = "Orange Pickup", -- Dropped by Klump & Purple Klaptrap
		[53] = "Banana Coin", -- Dropped by "Diddy", otherwise unused?
		[54] = "DK Coin", -- Minecart
		[55] = "Small Explosion", -- Seasick Chunky
		[56] = "Orangstand Sprint Barrel",
		[57] = "Strong Kong Barrel",
		[58] = "Swinging Light",
		[59] = "Fireball", -- Mad Jack etc.
		[60] = "Bananaporter",
		[61] = "Boulder",
		[62] = "Minecart", -- DK?
		[63] = "Vase (O)",
		[64] = "Vase (:)",
		[65] = "Vase (Triangle)",
		[66] = "Vase (+)",
		[67] = "Cannon Ball",
		-- [68] = "Unknown",
		[69] = "Vine", -- Green
		[70] = "Counter", -- Unused?
		[71] = "Kremling (Red)", -- Lanky's Keyboard Game in R&D
		[72] = "Boss Key",
		[73] = "Cannon", -- Galleon Minigame
		[74] = "Cannon Ball", -- Galleon Minigame Projectile
		[75] = "Blueprint (Diddy)",
		[76] = "Blueprint (Chunky)",
		[77] = "Blueprint (Lanky)",
		[78] = "Blueprint (DK)",
		[79] = "Blueprint (Tiny)",
		[80] = "Minecart", -- Chunky?
		[81] = "Fire Spawner? (Dogadon)", -- TODO: Verify
		[82] = "Boulder Debris", -- Minecart
		[83] = "Spider Web", -- Fungi miniBoss
		[84] = "Steel Keg Spawner",
		[85] = "Steel Keg",
		[86] = "Crown",
		[87] = "Minecart", -- BONUS
		-- [88] = "Unknown",
		[89] = "Fire", -- Unused?
		[90] = "Ice Wall?",
		[91] = "Balloon (Diddy)",
		[92] = "Stalactite",
		[93] = "Rock Debris", -- Rotating, Unused?
		[94] = "Car", -- Unused?
		[95] = "Pause Menu",
		[96] = "Hunky Chunky Barrel (Dogadon)",
		[97] = "TNT Barrel Spawner (Dogadon)",
		[98] = "Tag Barrel",
		[99] = "Fireball", -- Get Out
		[100] = "1 Pad (Diddy 5DI)",
		[101] = "2 Pad (Diddy 5DI)",
		[102] = "3 Pad (Diddy 5DI)",
		[103] = "4 Pad (Diddy 5DI)",
		[104] = "5 Pad (Diddy 5DI)",
		[105] = "6 Pad (Diddy 5DI)",
		[106] = "Kong Reflection",
		[107] = "Bonus Barrel (Hideout Helm)",
		-- [108] = "Unknown",
		[109] = "Race Checkpoint",
		[110] = "CB Bunch", -- Unused? Doesn't seem to work, these are normally model 2
		[111] = "Balloon (Chunky)",
		[112] = "Balloon (Tiny)",
		[113] = "Balloon (Lanky)",
		[114] = "Balloon (DK)",
		[115] = "K. Lumsy's Cage", -- TODO: Also rabbit race finish line?
		[116] = "Chain",
		[117] = "Beanstalk",
		[118] = "Yellow ?", -- Unused?
		[119] = "CB Single (Blue)", -- Unused? Doesn't seem to work, these are normally model 2
		[120] = "CB Single (Yellow)", -- Unused? Doesn't seem to work, these are normally model 2
		[121] = "Crystal Coconut", -- Unused? Doesn't seem to work, these are normally model 2
		[122] = "DK Coin", -- Multiplayer
		[123] = "Kong Mirror", -- Creepy Castle Museum
		[124] = "Barrel Gun", -- Peril Path Panic
		[125] = "Barrel Gun", -- Krazy Kong Klamour
		[126] = "Fly Swatter",
		[127] = "Searchlight", -- Searchlight Seek
		[128] = "Headphones",
		[129] = "Enguarde Crate",
		[130] = "Apple", -- Fungi
		[131] = "Worm", -- Fungi
		[132] = "Enguarde Crate (Unused?)",
		[133] = "Barrel",
		[134] = "Training Barrel",
		[135] = "Boombox", -- Treehouse
		[136] = "Tag Barrel",
		[137] = "Tag Barrel", -- Troff'n'Scoff
		[138] = "B. Locker",
		[139] = "Rainbow Coin Patch",
		[140] = "Rainbow Coin",
		-- [141] = "Unknown",
		-- [142] = "Unknown",
		-- [143] = "Unknown",
		-- [144] = "Unknown",
		[145] = "Cannon (Seasick Chunky)", -- Internal name "Puffer cannon"
		-- [146] = "Unknown",
		[147] = "Balloon (Unused - K. Rool)", -- Internal Name: K. Rool Banana Balloon, unsure of purpose. Can only be popped by Lanky
		[148] = "Rope", -- K. Rool's Arena
		[149] = "Banana Barrel", -- Lanky Phase
		[150] = "Banana Barrel Spawner", -- Lanky Phase, internal name "Skin barrel generator"
		-- [151] = "Unknown",
		-- [152] = "Unknown",
		-- [153] = "Unknown",
		-- [154] = "Unknown",
		-- [155] = "Unknown",
		[156] = "Wrinkly",
		-- [157] = "Unknown",
		-- [158] = "Unknown",
		-- [159] = "Unknown",
		-- [160] = "Unknown",
		-- [161] = "Unknown",
		-- [162] = "Unknown",
		[163] = "Banana Fairy (BFI)",
		[164] = "Ice Tomato",
		[165] = "Tag Barrel (King Kut Out)",
		[166] = "King Kut Out Part",
		[167] = "Cannon",
		-- [168] = "Unknown",
		[169] = "Pufftup", -- Pufftoss Fight
		[170] = "Damage Source", -- K. Rool's Glove
		[171] = "Orange", -- Krusha's Gun
		[173] = "Cutscene Controller",
		-- [174] = "Unknown",
		[175] = "Kaboom",
		[176] = "Timer",
		[177] = "Timer Controller", -- Pufftoss Fight & Fac Beaver Bother Spawn Timer
		[178] = "Beaver", -- Blue
		[179] = "Shockwave (Mad Jack)",
		[180] = "Krash", -- Minecart Club Guy
		[181] = "Book", -- Castle Library
		[182] = "Klobber",
		[183] = "Zinger",
		[184] = "Snide",
		[185] = "Army Dillo",
		[186] = "Kremling", -- Kremling Kosh
		[187] = "Klump",
		[188] = "Camera",
		[189] = "Cranky",
		[190] = "Funky",
		[191] = "Candy",
		[192] = "Beetle", -- Race
		[193] = "Mermaid",
		[194] = "Vulture",
		[195] = "Squawks",
		[196] = "Cutscene DK",
		[197] = "Cutscene Diddy",
		[198] = "Cutscene Lanky",
		[199] = "Cutscene Tiny",
		[200] = "Cutscene Chunky",
		[201] = "Llama",
		[202] = "Fairy Picture",
		[203] = "Padlock (T&S)",
		[204] = "Mad Jack",
		[205] = "Klaptrap", -- Green
		[206] = "Zinger",
		[207] = "Vulture (Race)",
		[208] = "Klaptrap (Purple)",
		[209] = "Klaptrap (Red)",
		[210] = "GETOUT Controller",
		[211] = "Klaptrap (Skeleton)",
		[212] = "Beaver (Gold)",
		[213] = "Fire Column Spawner", -- Japes Minecart
		[214] = "Minecart (TNT)", -- Minecart Mayhem
		[215] = "Minecart (TNT)",
		[216] = "Pufftoss",
		-- [217] = "Unknown",
		[218] = "Handle",
		[219] = "Slot",
		[220] = "Cannon (Seasick Chunky)",
		[221] = "Light Piece", -- Lanky Phase
		[222] = "Banana Peel", -- Lanky Phase
		[223] = "Fireball Spawner", -- Factory Crusher Room
		[224] = "Mushroom Man",
		-- [225] = "Unknown",
		[226] = "Troff",
		[227] = "K. Rool's Foot", -- Including leftmost toe
		[228] = "Bad Hit Detection Man",
		[229] = "K. Rool's Toe", -- Rightmost 3 toes
		[230] = "Ruler",
		[231] = "Toy Box",
		[232] = "Text Overlay",
		[233] = "Squawks",
		[234] = "Scoff",
		[235] = "Robo-Kremling",
		[236] = "Dogadon",
		-- [237] = "Unknown",
		[238] = "Kremling",
		[239] = "Bongos",
		[240] = "Spotlight Fish",
		[241] = "Kasplat (DK)",
		[242] = "Kasplat (Diddy)",
		[243] = "Kasplat (Lanky)",
		[244] = "Kasplat (Tiny)",
		[245] = "Kasplat (Chunky)",
		[246] = "Mechanical Fish",
		[247] = "Seal",
		[248] = "Banana Fairy",
		[249] = "Squawks with spotlight",
		[250] = "Owl",
		[251] = "Spider miniBoss",
		[252] = "Rabbit", -- Fungi
		[253] = "Nintendo Logo",
		[254] = "Cutscene Object", -- For objects animated by Cutscenes
		[255] = "Shockwave",
		[256] = "Minigame Controller",
		[257] = "Fire Breath Spawner", -- Aztec Beetle Race
		[258] = "Shockwave", -- Boss
		[259] = "Guard", -- Stealthy Snoop
		[260] = "Text Overlay", -- K. Rool fight
		[261] = "Robo-Zinger",
		[262] = "Krossbones",
		[263] = "Fire Shockwave (Dogadon)",
		[264] = "Squawks",
		[265] = "Light beam", -- Boss fights etc
		[266] = "DK Rap Controller", -- Handles the lyrics etc
		[267] = "Shuri",
		[268] = "Gimpfish",
		[269] = "Mr. Dice",
		[270] = "Sir Domino",
		[271] = "Mr. Dice",
		[272] = "Rabbit",
		[273] = "Fireball (With Glasses)", -- From Chunky 5DI
		-- [274] = "Unknown",
		[275] = "K. Lumsy",
		[276] = "Spiderling",
		[277] = "Squawks",
		[278] = "Projectile", -- Spider miniBoss
		-- [279] = "Unknown",
		[280] = "Spider Silk String", -- Spider miniBoss
		[281] = "K. Rool (DK Phase)",
		[282] = "Retexturing Controller", -- Beaver Bother
		[283] = "Skeleton Head",
		-- [284] = "Unknown",
		[285] = "Bat",
		[286] = "Giant Clam",
		-- [287] = "Unknown",
		[288] = "Tomato", -- Fungi
		[289] = "Kritter-in-a-Sheet",
		[290] = "Pufftup",
		[291] = "Kosha",
		[292] = "K. Rool (Diddy Phase)",
		[293] = "K. Rool (Lanky Phase)",
		[294] = "K. Rool (Tiny Phase)",
		[295] = "K. Rool (Chunky Phase)",
		-- [296] = "Unknown",
		[297] = "Battle Crown Controller",
		-- [298] = "Unknown",
		-- [299] = "Unknown",
		[299] = "Textbox",
		[300] = "Snake", -- Teetering Turtle Trouble
		[301] = "Turtle", -- Teetering Turtle Trouble
		[302] = "Toy Car", -- Player in the Factory Toy Car Race
		[303] = "Toy Car",
		[304] = "Camera", -- Factory Toy Car Race
		[305] = "Missile", -- Car Race
		-- [306] = "Unknown",
		-- [307] = "Unknown",
		[308] = "Seal",
		[309] = "Kong Logo (Instrument)", -- DK for DK, Star for Diddy, DK for Lanky, Flower for Tiny, DK for Chunky
		[310] = "Spotlight", -- Tag barrel, instrument etc.
		[311] = "Race Checkpoint", -- Seal race & Castle car race
		[312] = "Minecart (TNT)",
		[313] = "Idle Particle",
		[314] = "Rareware Logo",
		-- [315] = "Unknown",
		[316] = "Kong (Tag Barrel)",
		[317] = "Locked Kong (Tag Barrel)",
		-- [318] = "Unknown",
		[319] = "Propeller (Boat)",
		[320] = "Potion", -- Cranky Purchase
		[321] = "Fairy (Refill)", -- Refill Fairy
		[322] = "Car", -- Car Race
		[323] = "Enemy Car", -- Car Race, aka George
		[324] = "Text Overlay Controller", -- Candy's
		[325] = "Shockwave", -- Simian Slam
		[326] = "Main Menu Controller",
		[327] = "Kong", -- Krazy Kong Klamour
		[328] = "Klaptrap", -- Peril Path Panic
		[329] = "Fairy", -- Peril Path Panic
		[330] = "Bug", -- Big Bug Bash
		[331] = "Klaptrap", -- Searchlight Seek
		[332] = "Big Bug Bash Controller?", -- TODO: Fly swatter?
		[333] = "Barrel (Main Menu)",
		[334] = "Padlock (K. Lumsy)",
		[335] = "Snide's Menu",
		[336] = "Training Barrel Controller",
		[337] = "Multiplayer Model (Main Menu)",
		[338] = "End Sequence Controller",
		[339] = "Arena Controller", -- Rambi/Enguarde
		[340] = "Bug", -- Trash Can
		[342] = "Try Again Dialog",
		[343] = "Pause Menu", -- Mystery menu bosses
	},
	interactable = 0x5C, -- u16 be, bitfield
	-- 0000 0010 = Block playing instrument
	object_properties_bitfield_1 = 0x60, -- TODO: Document & rename this, probably lump into a u32_be bitfield
	-- 0001 0000 = collides with terrain
	-- 0000 0100 = visible
	-- 0000 0001 = in water
	visibility = 0x63, -- Byte (bitfield) TODO: Fully document & rename this, probably lump into a u32_be bitfield
	specular_highlight = 0x6D, -- TODO: uh
	shadow_width = 0x6E, -- u8
	shadow_height = 0x6F, -- u8
	x_pos = 0x7C, -- 32 bit float big endian
	y_pos = 0x80, -- 32 bit float big endian
	z_pos = 0x84, -- 32 bit float big endian
	floor = 0xA4, -- 32 bit float big endian
	distance_from_floor = 0xB4, -- 32 bit float big endian
	velocity = 0xB8, -- 32 bit float big endian
	--acceleration = 0xBC, -- TODO: Seems wrong
	y_velocity = 0xC0, -- 32 bit float big endian
	y_acceleration = 0xC4, -- 32 bit float big endian
	terminal_velocity = 0xC8, -- 32 bit float big endian
	light_thing = 0xCC, -- Values 0x00->0x14
	x_rot = 0xE4, -- u16_be
	y_rot = 0xE6, -- u16_be
	z_rot = 0xE8, -- u16_be
	locked_to_pad = 0x110, -- TODO: What datatype is this? code says byte but I'd think it'd be a pointer
	chunk = 0x12C, -- u16_be
	health = 0x134, -- s16_be
	takes_enemy_damage = 0x13B, -- TODO: put into examine method and double check datatype
	collision_queue_pointer = 0x13C,
	ledge_info_pointer = 0x140, -- TODO: I don't quite know what to call this, it has 2 pointers to the bone arrays used for tree grab, telegrab, oranges & bullets
	ledge_info = {
		last_x = 0x1C, -- 32 bit float big endian
		last_z = 0x20, -- 32 bit float big endian
		is_locked = 0x21, -- Byte, setting this > 0 will send the player to last_x, player Y, last_z
		bone_array_1_pointer = 0x74, -- Pointer: Used for enemy eye position, bullets & oranges, telegrabs & tree warps
		bone_array_2_pointer = 0x78, -- Pointer: Used for enemy eye position, bullets & oranges, telegrabs & tree warps
	},
	noclip_byte = 0x144, -- Byte? Bitfield?
	hand_state = 0x147, -- Bitfield
	control_state_byte = 0x154,
	control_states = {
		[0x01] = "Idle", -- Enemy
		[0x02] = "First person camera",
		[0x03] = "First person camera", -- Water
		[0x04] = "Fairy Camera",
		[0x05] = "Fairy Camera", -- Water
		[0x06] = "Locked", -- Inside bonus barrel
		[0x07] = "Minecart (Idle)",
		[0x08] = "Minecart (Crouch)",
		[0x09] = "Minecart (Jump)",
		[0x0A] = "Minecart (Left)",
		[0x0B] = "Minecart (Right)",
		[0x0C] = "Idle",
		[0x0D] = "Walking",
		[0x0E] = "Skidding",
		[0x0F] = "Sliding", -- Beetle Race
		[0x10] = "Sliding (Left)", -- Beetle Race
		[0x11] = "Sliding (Right)", -- Beetle Race
		[0x12] = "Sliding (Forward)", -- Beetle Race
		[0x13] = "Sliding (Back)", -- Beetle Race
		[0x14] = "Jumping", -- Beetle Race
		[0x15] = "Slipping",
		[0x16] = "Slipping", -- DK Slope in Helm
		[0x17] = "Jumping",
		[0x18] = "Baboon Blast Pad",
		[0x19] = "Bouncing", -- Mushroom
		[0x1A] = "Double Jump", -- Diddy
		[0x1B] = "Simian Spring",
		[0x1C] = "Simian Slam",
		[0x1D] = "Long Jumping",
		[0x1E] = "Falling",
		[0x1F] = "Falling", -- Gun
		[0x20] = "Falling/Splat",
		[0x21] = "Falling", -- Beetle Race
		[0x22] = "Pony Tail Twirl",
		[0x23] = "Attacking", -- Enemy
		[0x24] = "Primate Punch", -- TODO: Is this used anywhere else?
		[0x25] = "Attacking", -- Enemy
		[0x26] = "Ground Attack",
		[0x27] = "Attacking", -- Enemy
		[0x28] = "Ground Attack (Final)",
		[0x29] = "Moving Ground Attack",
		[0x2A] = "Aerial Attack",
		[0x2B] = "Rolling",
		[0x2C] = "Throwing Orange",
		[0x2D] = "Shockwave",
		[0x2E] = "Chimpy Charge",
		[0x2F] = "Charging", -- Rambi
		[0x30] = "Bouncing",
		[0x31] = "Damaged",
		[0x32] = "Stunlocked", -- Kasplat
		[0x33] = "Damaged", -- Mad Jack Wrong Switch
		-- [0x34] = "Unknown 0x34",
		[0x35] = "Damaged", -- Klump knockback
		[0x36] = "Death",
		[0x37] = "Damaged", -- Underwater
		[0x38] = "Damaged", -- Vehicle (Boat?)
		[0x39] = "Shrinking",
		[0x3B] = "Death", -- Dogadon Lava
		[0x3C] = "Crouching",
		[0x3D] = "Uncrouching",
		[0x3E] = "Backflip",
		[0x3F] = "Entering Orangstand",
		[0x40] = "Orangstand",
		[0x41] = "Jumping", -- Orangstand
		[0x42] = "Barrel", -- Tag Barrel, Bonus Barrel, Mini Monkey Barrel
		[0x43] = "Barrel", -- Underwater
		[0x44] = "Baboon Blast Shot",
		[0x45] = "Cannon Shot",
		[0x46] = "Pushing Object", -- Unused
		[0x47] = "Picking up Object",
		[0x48] = "Idle", -- Carrying Object
		[0x49] = "Walking", -- Carrying Object
		[0x4A] = "Dropping Object",
		[0x4B] = "Throwing Object",
		[0x4C] = "Jumping", -- Carrying Object
		[0x4D] = "Throwing Object", -- In Air
		[0x4E] = "Surface Swimming",
		[0x4F] = "Underwater",
		[0x50] = "Leaving Water",
		[0x51] = "Jumping", -- Out of water
		[0x52] = "Bananaporter",
		[0x53] = "Monkeyport",
		[0x54] = "Bananaporter", -- Multiplayer
		-- [0x55] = "Unknown 0x55",
		[0x56] = "Locked", -- Funky's & Candy's store
		[0x57] = "Swinging on Vine",
		[0x58] = "Leaving Vine",
		[0x59] = "Climbing Tree",
		[0x5A] = "Leaving Tree",
		[0x5B] = "Grabbed Ledge",
		[0x5C] = "Pulling up on Ledge",
		[0x5D] = "Idle", -- With gun
		[0x5E] = "Walking", -- With gun
		[0x5F] = "Putting away gun",
		[0x60] = "Pulling out gun",
		[0x61] = "Jumping", -- With gun
		[0x62] = "Aiming Gun",
		[0x63] = "Rocketbarrel",
		[0x64] = "Taking Photo",
		[0x65] = "Taking Photo", -- Underwater
		[0x66] = "Damaged", -- Exploding TNT Barrels
		[0x67] = "Instrument",
		-- [0x68] = "Unknown 0x68",
		[0x69] = "Car", -- Race
		[0x6A] = "Learning Gun",
		[0x6B] = "Locked", -- Bonus barrel
		[0x6C] = "Feeding T&S",
		[0x6D] = "Boat",
		[0x6E] = "Baboon Balloon",
		[0x6F] = "Updraft", -- Castle tower
		[0x70] = "GB Dance",
		[0x71] = "Key Dance",
		[0x72] = "Crown Dance",
		[0x73] = "Loss Dance",
		[0x74] = "Victory Dance",
		[0x75] = "Vehicle", -- Castle Car Race
		[0x76] = "Entering Battle Crown",
		[0x77] = "Locked", -- Tons of cutscenes use this
		[0x78] = "Gorilla Grab",
		[0x79] = "Learning Move",
		[0x7A] = "Locked", -- Car race loss, possibly elsewhere
		[0x7B] = "Locked", -- Beetle Race loss, falling animation on ground
		[0x7C] = "Trapped", -- Spider miniBoss
		[0x7D] = "Klaptrap Kong", -- Beaver Bother
		[0x7E] = "Surface Swimming", -- Enguarde
		[0x7F] = "Underwater", -- Enguarde
		[0x80] = "Attacking", -- Enguarde, surface
		[0x81] = "Attacking", -- Enguarde
		[0x82] = "Leaving Water", -- Enguarde
		[0x83] = "Fairy Refill",
		--[0x84] = "Unknown 0x84", -- Screen fades to black function at 806F007C sets it, pointer to that function in jump table at 80752DDC (near portal enter/exit functions)
		[0x85] = "Main Menu",
		[0x86] = "Entering Main Menu",
		[0x87] = "Entering Portal",
		[0x88] = "Exiting Portal",
	},
	control_state_progress = 0x155, -- Byte, describes how far through the action the actor is, for example simian slam is only active once this byte hits 0x04
	texture_renderer_pointer = 0x158, -- Pointer
	texture_renderer = {
		texture_index = 0x0C, -- u16_be
		--unknown_float = 0x10, -- Float -- TODO: What is this?
		--unknown_float = 0x14, -- Float -- TODO: What is this?
		next_renderer = 0x24, -- Pointer
	},
	shade_byte = 0x16D,
	destination_map = 0x17E, -- u16_be, bonus barrels etc
	player = {
		animation_type = 0x181, -- Seems to be the same value as control_states
		stored_y_rotation = 0x18A, -- Angle post tag barrel?
		velocity_uncrouch_aerial = 0x1A4, -- TODO: What is this?
		misc_acceleration_float = 0x1AC, -- TODO: What is this?
		horizontal_acceleration = 0x1B0, -- Set to a negative number to go fast
		misc_acceleration_float_2 = 0x1B4, -- TODO: What is this?
		misc_acceleration_float_3 = 0x1B8, -- TODO: What is this?
		velocity_ground = 0x1C0, -- TODO: What is this?
		vehicle_actor_pointer = 0x208, -- u32 be
		slope_timer = 0x243,
		shockwave_charge_timer = 0x248, -- s16 be
		shockwave_recovery_timer = 0x24A, -- byte
		animation = 0x29E, -- u16 be
		grabbed_vine_pointer = 0x2B0, -- u32 be
		grab_pointer = 0x32C, -- u32 be
		scale = {
			0x344, 0x348, 0x34C, 0x350, 0x354 -- 0x344 and 0x348 seem to be a target, the rest must be current value for each axis
		},
		fairy_active = 0x36C, -- TODO: Find a pointer for the actor the camera is focusing on
		effect_byte = 0x372, -- Bitfield, TODO: Document bits
		effect_byte_2 = 0x373, -- Bitfield
			-- 1000 0000 = Inverted Controls (Spider Boss)
			-- 0100 0000 = Translucent & Sparkles (Strong Kong)
			-- 0010 0000 = Puts player in orangstand????
			-- 0001 0000 = Damage flashes
	},
	animations = { -- TODO: These are probably different on Kiosk and maybe different on PAL/J
		[0x00] = "Idle (DK, Normal)",
		[0x01] = "Walking (DK)",
		[0x02] = "Creeping (DK)",
		[0x03] = "Running (DK)",
		[0x04] = "Idle (DK, Looking Around)",
		[0x05] = "Idle (DK, Fly)",
		-- [0x06] = "",
		-- [0x07] = "",
		-- [0x08] = "",
		[0x09] = "Skidding (DK)", -- Also applies to Skid Jumps
		-- [0x0A] = "",
		-- [0x0B] = "",
		-- [0x0C] = "",
		-- [0x0D] = "",
		-- [0x0E] = "",
		[0x0F] = "Locked (DK, Listening)", -- Squawks
		[0x10] = "Slipping Forward (DK)",
		[0x11] = "Slipping Backward (DK)",
		[0x12] = "Damage Knockback (DK)",
		[0x13] = "Death (DK)",
		-- [0x14] = "",
		-- [0x15] = "",
		-- [0x16] = "",
		[0x17] = "Jumping (DK)",
		[0x18] = "Long Jump (DK)",
		[0x19] = "Simian Slam (DK)",
		[0x1A] = "Starting Simian Slam (DK)",
		-- [0x1B] = "",
		-- [0x1C] = "",
		[0x1D] = "Falling (DK, Splat Incoming)",
		[0x1E] = "Splat (DK)",
		[0x1F] = "Super Simian Slam (DK)",
		[0x20] = "Super Duper Simian Slam (DK)",
		-- [0x21] = "",
		[0x22] = "Walking (DK, Holding Object)",
		[0x23] = "Idle (DK, Holding Object)", -- Also used on main menu
		[0x24] = "Throwing Object (DK)", -- Also used on main menu
		[0x25] = "Jumping (DK, Holding Object)", -- Also used on main menu
		[0x26] = "Picking Up Object (DK)",
		[0x27] = "Dropping Object (DK)",
		[0x28] = "Crouch Transition (DK)",
		[0x29] = "Backflip (DK)",
		[0x2A] = "Crouching (DK)",
		[0x2B] = "Crouch Turning (DK)", -- Z & Direction
		[0x2C] = "Paddling (DK)", -- Water
		[0x2D] = "Dolphin Kicking (DK)", -- Water
		[0x2E] = "Breast Stroke (DK)", -- Water
		[0x2F] = "Idle (DK, Water)",
		[0x30] = "Grabbed Ledge (DK, Moving Left)",
		[0x31] = "Grabbed Ledge (DK, Moving Right)",
		[0x32] = "Grabbed Ledge (DK)",
		[0x33] = "Grabbed Ledge (DK, Almost Falling)",
		[0x34] = "Pulling up on ledge (DK)",
		-- [0x35] = "",
		-- [0x36] = "",
		-- [0x37] = "",
		-- [0x38] = "",
		-- [0x39] = "",
		[0x3A] = "On Tree (DK, Almost Falling)",
		[0x3B] = "On Tree (DK, Normal)",
		[0x3C] = "On Tree (DK, Climbing Up)",
		[0x3D] = "On Tree (DK, Climbing Down)",
		[0x3E] = "Ground Attack (DK, Slap Left)",
		-- [0x3F] = "",
		[0x40] = "Ground Attack (DK, Slap Right)",
		-- [0x41] = "",
		[0x42] = "Ground Attack (DK, Slap Ground)",
		-- [0x43] = "",
		[0x44] = "Moving Ground Attack (DK)",
		-- [0x45] = "",
		[0x46] = "Aerial Attack (DK)",
		[0x47] = "Rolling (DK)",
		[0x48] = "Throwing Orange (DK)",
		[0x49] = "Shockwave (DK)",
		[0x4A] = "Walking (DK, Gun)",
		[0x4B] = "Shooting (DK)",
		[0x4C] = "Running (DK, Gun)",
		[0x4D] = "Holding Gun (DK)",
		[0x4E] = "Looking Around (DK, Gun)",
		[0x4F] = "Creeping (DK, Gun)",
		[0x50] = "Jumping (DK, Gun)",
		[0x51] = "Acquiring/Putting Away Gun (DK)",
		[0x52] = "Aiming Gun Transition (DK)",
		-- [0x53] = "",
		[0x54] = "Instrument (DK)",
		[0x55] = "Instrument Start (DK)",
		[0x56] = "Instrument End (DK)",
		-- [0x57] = "",
		-- [0x58] = "",
		-- [0x59] = "",
		-- [0x5A] = "",
		-- [0x5B] = "",
		-- [0x5C] = "",
		-- [0x5D] = "",
		-- [0x5E] = "",
		-- [0x5F] = "",
		-- [0x60] = "",
		[0x61] = "Scaring off Kremling (Right) (DK)", -- Main menu
		[0x62] = "Scaring off Kremling (Left) (DK)", -- Main menu
		-- [0x63] = "",
		-- [0x64] = "",
		[0x65] = "Leg Shake (DK)", -- Main menu
		[0x66] = "Looking at activity in front (DK)", -- Main menu
		[0x67] = "Scared of night time (DK)", -- Main menu
		[0x68] = "Trying to spot activity behind back (DK)", -- Main menu
		-- [0x69] = "",
		-- [0x6A] = "",
		-- [0x6B] = "",
		-- [0x6C] = "",
		-- [0x6D] = "",
		-- [0x6E] = "",
		-- [0x6F] = "",
		[0x70] = "Idle (Diddy, Looking Around)",
		[0x71] = "Idle (Diddy)",
		[0x72] = "Creeping (Diddy)",
		[0x73] = "Walking (Diddy)",
		[0x74] = "Running (Diddy)",
		[0x75] = "Skidding (Diddy)",
		[0x76] = "Idle (Diddy, Orange)",
		-- [0x77] = "",
		-- [0x78] = "",
		-- [0x79] = "",
		-- [0x7A] = "",
		-- [0x7B] = "",
		-- [0x7C] = "",
		[0x7D] = "Slipping Forward (Diddy/Rambi)",
		[0x7E] = "Slipping Backward (Diddy/Rambi)",
		[0x7F] = "Damage Knockback (Diddy)",
		[0x80] = "Death (Diddy)",
		-- [0x81] = "",
		-- [0x82] = "",
		-- [0x83] = "",
		[0x84] = "Damage Knockback (Diddy, Tail Spring)", -- Kosha
		[0x85] = "Jump (Diddy)",
		[0x86] = "Double Jump (Diddy)",
		-- [0x87] = "",
		-- [0x88] = "",
		-- [0x89] = "",
		[0x8A] = "Simian Slam (Diddy)", -- Also super
		-- [0x8B] = "",
		[0x8C] = "Simian Slam (Diddy, End)",
		[0x8D] = "Long Jump (Diddy)",
		[0x8E] = "Falling (Diddy, Splat Incoming)",
		[0x8F] = "Splat (Diddy)",
		[0x90] = "Super Simian Slam (Diddy, End)",
		[0x91] = "Super Duper Simian Slam (Diddy)",
		[0x92] = "Super Duper Simian Slam (Diddy, End)",
		[0x93] = "Tag Barrel",
		-- [0x94] = "",
		-- [0x95] = "",
		-- [0x96] = "",
		-- [0x97] = "",
		-- [0x98] = "",
		[0x99] = "Crouch Transition (Diddy)",
		[0x9A] = "Crouching (Diddy)",
		[0x9B] = "Backflip (Diddy)",
		[0x9C] = "Crouch Turning (Diddy)",
		[0x9D] = "Idle (Diddy, Water)",
		[0x9E] = "Dolphin Kicking (Diddy)",
		[0x9F] = "Breast Stroke (DK)",
		[0xA0] = "Paddling (Diddy)",
		[0xA1] = "Grabbed Ledge (Diddy, Moving Feet)",
		[0xA2] = "Grabbed Ledge (Diddy, Moving Left)",
		[0xA3] = "Grabbed Ledge (Diddy, Moving Right)",
		[0xA4] = "Grabbed Ledge (Diddy)",
		[0xA5] = "Pulling up on ledge (Diddy)",
		-- [0xA6] = "",
		-- [0xA7] = "",
		-- [0xA8] = "",
		-- [0xA9] = "",
		[0xAA] = "On Tree (Diddy, Normal)",
		[0xAB] = "On Tree (Diddy, Climbing Up)",
		[0xAC] = "On Tree (Diddy, Climbing Down)",
		[0xAD] = "On Tree (Diddy, Almost Falling)",
		-- [0xAE] = "",
		-- [0xAF] = "",
		-- [0xB0] = "",
		[0xB1] = "Bananaporter", -- All Kongs
		[0xB2] = "Ground Attack (Diddy, Left)",
		-- [0xB3] = "",
		[0xB4] = "Ground Attack (Diddy, Right)",
		-- [0xB5] = "",
		[0xB6] = "Ground Attack (Diddy, Final)",
		[0xB7] = "Morving Ground Attack (Diddy)",
		[0xB8] = "Aerial Attack (Diddy)",
		[0xB9] = "Throwing Orange (Diddy)",
		[0xBA] = "Shockwave (Diddy)",
		[0xBB] = "Chimpy Charge",
		[0xBC] = "Knockback (Chimpy Charge)",
		[0xBD] = "Slowdown (Chimpy Charge)",
		[0xBE] = "Walking (Diddy, Gun)",
		[0xBF] = "Idle (Diddy, Gun)",
		[0xC0] = "Idle (Diddy, Gun, Looking Around)",
		[0xC1] = "Acquiring/Putting Away Gun (Diddy)",
		[0xC2] = "Creeping (Diddy, Gun)",
		[0xC3] = "Aiming/Shooting Gun (Diddy)",
		[0xC4] = "Aiming/Shooting Gun (Diddy)",
		[0xC5] = "Walking (Diddy, Gun)",
		[0xC6] = "Jumping (Diddy, Gun)",
		[0xC7] = "Instrument (Diddy)",
		[0xC8] = "Instrument (Diddy, Transition)",
		-- [0xC9] = "",
		-- [0xCA] = "",
		-- [0xCB] = "",
		-- [0xCC] = "",
		-- [0xCD] = "",
		-- [0xCE] = "",
		-- [0xCF] = "",
		-- [0xD0] = "",
		-- [0xD1] = "",
		-- [0xD2] = "",
		[0xD3] = "Idle (Diddy, Listening)",
		[0xD4] = "Idle (Diddy, Listening)", -- Hands on head
		[0xD5] = "Idle (Diddy, Listening)", -- Transition
		-- [0xD6] = "",
		-- [0xD7] = "",
		-- [0xD8] = "",
		-- [0xD9] = "",
		-- [0xDA] = "",
		-- [0xDB] = "",
		-- [0xDC] = "",
		-- [0xDD] = "",
		-- [0xDE] = "",
		-- [0xDF] = "",
		[0xE0] = "Creeping (Lanky)",
		[0xE1] = "Running (Lanky)",
		[0xE2] = "Idle (Lanky)",
		[0xE3] = "Idle (Lanky, Looking Around)",
		[0xE4] = "Idle (Lanky, Side to Side)",
		[0xE5] = "Walking (Lanky)",
		-- [0xE6] = "",
		-- [0xE7] = "",
		-- [0xE8] = "",
		[0xE9] = "Skidding (Lanky)",
		[0xEA] = "Idle (Lanky, Oranges)",
		-- [0xEB] = "",
		-- [0xEC] = "",
		-- [0xED] = "",
		[0xEE] = "Death (Lanky)",
		-- [0xEF] = "",
		-- [0xF0] = "",
		-- [0xF1] = "",
		[0xF2] = "Damage Knockback (Lanky, Spring Back Up)", -- Kosha
		[0xF3] = "Jumping (Lanky)",
		[0xF4] = "Starting Simian Slam (Lanky)",
		[0xF5] = "Simian Slam (Lanky, End)",
		-- [0xF6] = "",
		[0xF7] = "Long Jump (Lanky)",
		[0xF8] = "Falling (Lanky, Splat Incoming)",
		[0xF9] = "Splat (Lanky)",
		[0xFA] = "Super Simian Slam (Lanky, End)",
		[0xFB] = "Super Duper Simian Slam (Lanky)",
		[0xFC] = "Super Duper Simian Slam (Lanky, End)",
		[0xFD] = "Idle (Lanky, Holding Object)",
		[0xFE] = "Jumping (Lanky, Holding Object)",
		[0xFF] = "Picking Up/Dropping Object (Lanky)",
		[0x100] = "Throwing Object (Lanky)",
		[0x101] = "Walking (Lanky, Holding Object)",
		[0x102] = "Crouch Transition (Lanky)",
		[0x103] = "Crouching (Lanky)",
		[0x104] = "Entering Orangstand (Lanky)",
		[0x105] = "Idle (Lanky, Orangstand)",
		[0x106] = "Walking (Lanky, Orangstand)",
		-- [0x107] = "",
		[0x108] = "Backflip (Lanky)",
		[0x109] = "Jumping (Lanky, Orangstand)",
		[0x10A] = "Crouch Turning (Lanky)", -- Z & Direction
		[0x10B] = "Breast Stroke (Lanky)", -- Water
		[0x10C] = "Dolphin Kicking (Lanky)", -- Water
		[0x10D] = "Paddling (Lanky)",
		[0x10E] = "Idle (Lanky, Water)",
		[0x10F] = "Idle (Lanky, Underwater)",
		[0x110] = "Pulling up on ledge (Lanky)",
		[0x111] = "Grabbed Ledge (Lanky, Moving Right)",
		[0x112] = "Grabbed Ledge (Lanky, Moving Left)",
		[0x113] = "Grabbed Ledge (Lanky)",
		[0x114] = "On Tree (Lanky, Climbing Up)",
		[0x115] = "On Tree (Lanky, Climbing Down)",
		[0x116] = "On Tree (Lanky, Normal)",
		[0x117] = "On Tree (Lanky, Almost Falling)",
		-- [0x118] = "",
		-- [0x119] = "",
		-- [0x11A] = "",
		-- [0x11B] = "",
		-- [0x11C] = "",
		-- [0x11D] = "",
		[0x11E] = "Combo Attack (Lanky, Right)",
		[0x11F] = "Combo Attack (Lanky, Left)",
		[0x120] = "Combo Attack (Lanky, Final)",
		[0x121] = "Moving Ground Attack (Lanky)",
		[0x122] = "Aerial Attack (Lanky)",
		[0x123] = "Throwing Orange (Lanky)",
		[0x124] = "Shockwave (Lanky)",
		[0x125] = "Shooting Gun (Lanky)",
		[0x126] = "Aiming/Shooting Gun (Lanky, Pivoting)",
		[0x127] = "Walking (Lanky, Gun)",
		[0x128] = "Aiming/Shooting Gun (Lanky)",
		[0x129] = "Acquiring/Putting Away Gun (Lanky)",
		[0x12A] = "Idle (Lanky, Gun, Looking Around)",
		[0x12B] = "Idle (Lanky, Gun, Looking Around)",
		[0x12C] = "Creeping (Lanky, Gun)",
		[0x12D] = "Running (Lanky, Gun)",
		[0x12E] = "Jumping (Lanky, Gun)",
		[0x12F] = "Instrument (Lanky)",
		[0x130] = "Instrument (Lanky, End)",
		[0x131] = "Instrument (Lanky, Start)",
		-- [0x132] = "",
		-- [0x133] = "",
		-- [0x134] = "",
		-- [0x135] = "",
		-- [0x136] = "",
		-- [0x137] = "",
		[0x138] = "Idle (Lanky, Listening)", -- Transition
		[0x139] = "Idle (Lanky, Listening)",
		[0x13A] = "Idle (Lanky, Listening)", -- Hand at mouth
		-- [0x13B] = "",
		-- [0x13C] = "",
		-- [0x13D] = "",
		-- [0x13E] = "",
		-- [0x13F] = "",
		-- [0x140] = "",
		-- [0x141] = "",
		-- [0x142] = "",
		-- [0x143] = "",
		-- [0x144] = "",
		-- [0x145] = "",
		-- [0x146] = "",
		[0x147] = "Slipping Forward (Lanky)",
		[0x148] = "Slipping Backward (Lanky)",
		-- [0x149] = "",
		-- [0x14A] = "",
		-- [0x14B] = "",
		-- [0x14C] = "",
		-- [0x14D] = "",
		-- [0x14E] = "",
		-- [0x14F] = "",
		-- [0x150] = "",
		[0x151] = "Walking (Tiny)",
		[0x152] = "Running (Tiny)",
		[0x153] = "Creeping (Tiny)",
		[0x154] = "Idle (Tiny)",
		[0x155] = "Idle (Tiny, Looking Around)",
		[0x156] = "Skidding (Tiny)",
		-- [0x157] = "",
		-- [0x158] = "",
		-- [0x159] = "",
		[0x15A] = "Idle (Tiny, Orange)",
		-- [0x15B] = "",
		[0x15C] = "Damage Knockback (Tiny)",
		[0x15D] = "Death (Tiny)",
		-- [0x15E] = "",
		-- [0x15F] = "",
		-- [0x160] = "",
		[0x161] = "Damage Knockback (Tiny, Jump Back Up)", -- Kosha
		-- [0x162] = "",
		[0x163] = "Jumping (Tiny)",
		[0x164] = "Long Jump (Tiny)",
		[0x165] = "Super Simian Slam (Tiny)",
		-- [0x166] = "",
		[0x167] = "Pony Tail Twirl",
		[0x168] = "Falling (Tiny, Splat Incoming)",
		[0x169] = "Splat (Tiny)",
		[0x16A] = "Super Simian Slam (Tiny, End)",
		[0x16B] = "Super Duper Simian Slam (Tiny)",
		[0x16C] = "Super Duper Simian Slam (Tiny, End)",
		-- [0x16D] = "",
		-- [0x16E] = "",
		-- [0x16F] = "",
		-- [0x170] = "",
		[0x171] = "Dropping Object (Tiny)",
		[0x172] = "Throwing Object (Tiny)",
		-- [0x173] = "",
		-- [0x174] = "",
		-- [0x175] = "",
		-- [0x176] = "",
		-- [0x177] = "",
		-- [0x178] = "",
		-- [0x179] = "",
		-- [0x17A] = "",
		-- [0x17B] = "",
		-- [0x17C] = "",
		-- [0x17D] = "",
		[0x17E] = "Slipping Forward (Tiny)",
		[0x17F] = "Slipping Backward (Tiny)",
		[0x180] = "Crouch Transition (Tiny)",
		[0x181] = "Crouching (Tiny)",
		[0x182] = "Backflip (Tiny)",
		[0x183] = "Crouch Turning (Tiny)", -- Z & Direction
		[0x184] = "Dolphin Kicking (Tiny)",
		[0x185] = "Breast Stroke (Tiny)",
		[0x186] = "Paddling (Tiny)",
		[0x187] = "Idle (Tiny, Water)",
		-- [0x188] = "",
		[0x189] = "Grabbed Ledge (Tiny, Moving Legs)",
		[0x18A] = "Grabbed Ledge (Tiny)",
		[0x18B] = "Pulling up on ledge (Tiny)",
		[0x18C] = "Grabbed Ledge (Tiny, Moving Left)",
		[0x18D] = "Grabbed Ledge (Tiny, Moving Right)",
		[0x18E] = "On Tree (Tiny, Climbing Up)",
		[0x18F] = "On Tree (Tiny, Climbing Down)",
		[0x190] = "On Tree (Tiny, Normal)",
		[0x191] = "On Tree (Tiny, Almost Falling)",
		-- [0x192] = "",
		-- [0x193] = "",
		-- [0x194] = "",
		-- [0x195] = "",
		-- [0x196] = "",
		-- [0x197] = "",
		[0x198] = "Ground Attack (Tiny, Left)",
		[0x199] = "Ground Attack (Tiny, Right)",
		[0x19A] = "Ground Attack (Tiny, Final)",
		[0x19B] = "Moving Ground Attack (Tiny)", -- B
		[0x19C] = "Aerial Attack (Tiny)",
		[0x19D] = "Moving Ground Attack (Tiny)", -- Z + B
		[0x19E] = "Throwing Orange (Tiny)",
		[0x19F] = "Shockwave (Tiny)",
		[0x1A0] = "Shockwave End (Tiny)",
		-- [0x1A1] = "",
		-- [0x1A2] = "",
		-- [0x1A3] = "",
		-- [0x1A4] = "",
		-- [0x1A5] = "",
		-- [0x1A6] = "",
		-- [0x1A7] = "",
		-- [0x1A8] = "",
		-- [0x1A9] = "",
		[0x1AA] = "Instrument (Tiny)",
		[0x1AB] = "Instrument (Tiny, Transition)",
		-- [0x1AC] = "",
		-- [0x1AD] = "",
		-- [0x1AE] = "",
		[0x1AF] = "Idle (Tiny, Listening)",
		-- [0x1B0] = "",
		-- [0x1B1] = "",
		-- [0x1B2] = "",
		-- [0x1B3] = "",
		-- [0x1B4] = "",
		-- [0x1B5] = "",
		[0x1B6] = "Idle (Chunky)",
		[0x1B7] = "Walking (Chunky/Krusha)",
		[0x1B8] = "Running (Chunky/Krusha)",
		[0x1B9] = "Creeping (Chunky/Krusha)",
		[0x1BA] = "Idle (Chunky, Beating Chest)",
		-- [0x1BB] = "",
		-- [0x1BC] = "",
		[0x1BD] = "Learning Move (Chunky)",
		-- [0x1BE] = "",
		[0x1BF] = "Skidding (Chunky/Krusha)",
		[0x1C0] = "Idle (Chunky, Butterflies)",
		-- [0x1C1] = "",
		-- [0x1C2] = "",
		-- [0x1C3] = "",
		[0x1C4] = "Damage Knockback (Chunky)",
		[0x1C5] = "Death (Chunky)",
		-- [0x1C6] = "",
		-- [0x1C7] = "",
		-- [0x1C8] = "",
		[0x1C9] = "Damage Knockback (Chunky, Jump Back Up)", -- Kosha
		-- [0x1CA] = "",
		-- [0x1CB] = "",
		[0x1CC] = "Jumping (Chunky/Krusha)", -- Krusha only on water
		[0x1CD] = "Super Duper Simian Slam (Chunky)",
		[0x1CE] = "Super Duper Simian Slam (Chunky, End)",
		[0x1CF] = "Long Jump (Chunky)",
		[0x1D0] = "Falling (Chunky, Splat Incoming)",
		[0x1D1] = "Splat (Chunky)",
		[0x1D2] = "Simian Slam (Chunky, End)",
		[0x1D3] = "Super Simian Slam (Chunky, End)",
		[0x1D4] = "Simian Slam (Chunky)",
		[0x1D5] = "Super Simian Slam (Chunky)",
		[0x1D6] = "Dolphin Kicking (Chunky)",
		[0x1D7] = "Breast Stroke (Chunky/Krusha)",
		[0x1D8] = "Idle (Chunky, Water)",
		[0x1D9] = "Paddling (Chunky)",
		[0x1DA] = "Idle (Chunky/Krusha, Underwater)",
		[0x1DB] = "Crouch Transition (Chunky)",
		[0x1DC] = "Crouching (Chunky/Krusha)",
		[0x1DD] = "Backflip (Chunky)",
		[0x1DE] = "Crouch Turning (Chunky/Krusha)",
		-- [0x1DF] = "",
		-- [0x1E0] = "",
		-- [0x1E1] = "",
		-- [0x1E2] = "",
		[0x1E3] = "On Tree (Chunky/Krusha, Almost Falling)",
		[0x1E4] = "On Tree (Chunky/Krusha, Normal)",
		[0x1E5] = "On Tree (Chunky/Krusha, Climbing Down)",
		[0x1E6] = "On Tree (Chunky/Krusha, Climbing Up)",
		-- [0x1E7] = "",
		-- [0x1E8] = "",
		[0x1E9] = "Grabbed Ledge (Chunky, Moving Right)",
		[0x1EA] = "Grabbed Ledge (Chunky, Moving Left)",
		[0x1EB] = "Pulling up on ledge (Chunky)",
		[0x1EC] = "Grabbed Ledge (Chunky, Moving Legs)",
		[0x1ED] = "Grabbed Ledge (Chunky)",
		[0x1EE] = "Picking Up Object (Chunky)",
		[0x1EF] = "Idle (Chunky, Holding Object)",
		[0x1F0] = "Walking (Chunky, Holding Object)",
		[0x1F1] = "Throwing Object (Chunky)",
		[0x1F2] = "Jumping (Chunky, Holding Object)",
		-- [0x1F3] = "",
		[0x1F4] = "Dropping Object (Chunky)",
		[0x1F5] = "Idle (Chunky/Krusha, Holding Small Object)",
		[0x1F6] = "Jumping (Chunky/Krusha, Holding Small Object)",
		[0x1F7] = "Picking Up Small Object (Chunky/Krusha)",
		-- [0x1F8] = "",
		[0x1F9] = "Walking (Chunky/Krusha, Holding Small Object)",
		[0x1FA] = "Dropping Small Object (Chunky/Krusha)",
		[0x1FB] = "Combo-Punch (Left)", -- Chunky
		[0x1FC] = "Combo-Punch (Right)", -- Chunky
		[0x1FD] = "Combo-punch (Final)", -- Chunky
		[0x1FE] = "Moving Ground Attack (Chunky)",
		[0x1FF] = "Primate Punch",
		-- [0x200] = "",
		[0x201] = "Aerial Attack (Chunky)",
		[0x202] = "Throwing Orange (Chunky)",
		[0x203] = "Shockwave (Chunky/Krusha)",
		-- [0x204] = "",
		-- [0x205] = "",
		[0x206] = "Idle (Chunky, Gun)",
		[0x207] = "Walking (Chunky, Gun)",
		[0x208] = "Running (Chunky, Gun)",
		[0x209] = "Idle (Chunky, Gun, Looking Around)",
		[0x20A] = "Acquiring/Putting Away Gun (Chunky)",
		[0x20B] = "Aiming/Shooting Gun (Chunky, Pivoting)",
		[0x20C] = "Aiming/Shooting Gun (Chunky)",
		[0x20D] = "Jumping (Chunky, Gun)",
		[0x20E] = "Creeping (Chunky, Gun)",
		[0x20F] = "Instrument (Chunky)",
		[0x210] = "Instrument Start/End (Chunky)",
		-- [0x211] = "",
		-- [0x212] = "",
		-- [0x213] = "",
		-- [0x214] = "",
		-- [0x215] = "",
		-- [0x216] = "",
		-- [0x217] = "",
		-- [0x218] = "",
		-- [0x219] = "",
		[0x21A] = "Idle (Chunky/Krusha, Listening)", -- Transition
		[0x21B] = "Idle (Chunky/Krusha, Listening)",
		[0x21C] = "Idle (Chunky/Krusha, Listening)", -- Hand on head
		-- [0x21D] = "",
		-- [0x21E] = "",
		-- [0x21F] = "",
		[0x220] = "Slipping Forward (Chunky/Krusha)",
		[0x221] = "Slipping Backward (Chunky/Krusha)",
		[0x222] = "Idle (Rambi)",
		[0x223] = "Running (Rambi)", -- Also used for creeping/walking speeds
		[0x224] = "Jumping (Rambi)",
		[0x225] = "Swimming (Rambi)", -- Covers all water states
		[0x226] = "Moving Ground Attack (Rambi)",
		[0x227] = "Charging (Rambi, Start)", -- Z + B
		[0x228] = "Charging (Rambi, Middle)", -- Z + B
		[0x229] = "Charging (Rambi, End)", -- Z + B
		[0x22A] = "Bonk (Rambi)", -- Hit something while charging
		-- [0x22B] = "",
		[0x22C] = "Swimming (Enguarde)",
		[0x22D] = "Attacking (Enguarde)",
		-- [0x22E] = "",
		-- [0x22F] = "",
		[0x230] = "Idle (Krusha)",
		[0x231] = "Idle (Krusha, Looking Around)",
		[0x232] = "Idle (Krusha, Yawning)",
		[0x233] = "Idle (Krusha, Flexing)",
		[0x234] = "Jumping (Krusha)",
		-- [0x235] = "",
		-- [0x236] = "",
		[0x237] = "Simian Slam (Krusha)", -- Also used for super and super duper
		[0x238] = "Simian Slam (Krusha, End)", -- Also used for super and super duper
		[0x239] = "Idle (Krusha, Water)",
		[0x23A] = "Paddling (Krusha)", -- Water
		[0x23B] = "Dolphin Kicking (Krusha)", -- Water
		[0x23C] = "Idle (Krusha, Gun)",
		[0x23D] = "Creeping (Krusha, Gun)",
		[0x23E] = "Walking (Krusha, Gun)",
		[0x23F] = "Running (Krusha, Gun)",
		[0x240] = "Jumping (Krusha, Gun)",
		[0x241] = "Idle (Krusha, Gun, Looking Around)",
		[0x242] = "Acquiring/Putting Away Gun (Krusha)",
		[0x243] = "Aiming/Shooting Gun (Krusha)",
		[0x244] = "Aiming/Shooting Gun (Krusha, Pivoting)",
		[0x245] = "Throwing Orange (Krusha)",
		[0x246] = "Ground Attack (Krusha, Left)",
		[0x247] = "Ground Attack (Krusha, Right)",
		[0x248] = "Aerial Attack (Krusha)",
		[0x249] = "Moving Ground Attack (Krusha)",
		[0x24A] = "Ground Attack (Krusha, Final)",
		-- [0x24B] = "",
		[0x24B] = "Rolling (Krusha)",
		[0x24C] = "Crouch Transition (Krusha)",
		-- [0x24D] = "",
		-- [0x24E] = "",
		[0x24F] = "Backflip (Krusha)",
		[0x250] = "Long Jump (Krusha)",
		[0x251] = "Death (Krusha)",
		[0xFFFF] = "Default",
	},
	camera = {
		-- TODO: Focused vehicle pointers
		-- TODO: Verify for all versions
		focused_actor_pointer = 0x178,
		focused_vehicle_pointer = 0x1BC,
		focused_vehicle_pointer_2 = 0x1C0,
		viewport_x_position = 0x1FC, -- 32 bit float big endian
		viewport_y_position = 0x200, -- 32 bit float big endian
		viewport_z_position = 0x204, -- 32 bit float big endian
		tracking_distance = 0x21C, -- 32 bit float big endian
		viewport_y_rotation = 0x22A, -- u16_be
		viewport_x_rotation = 0x230, -- 32 bit float big endian
		tracking_angle = 0x230,
		zoom_level_c_down = 0x266, -- u8
		zoom_level_current = 0x267, -- u8
		zoom_level_after_c_up = 0x268, -- u8
		state_switch_timer_1 = 0x269,
		state_switch_timer_2 = 0x26E,
		state_type = 0x26B,
		state_values = {
			[1] = "Normal",
			[2] = "Locked",
			[3] = "First Person",
			[4] = "Vehicle",
			[5] = "Water",
			[9] = "Tag Barrel",
			[11] = "Fairy",
			[12] = "Vine", -- Swinging
			[13] = "Aiming", -- Gun, third person
		},
	},
	tag_barrel = {
		scroll_timer = 0x17D,
		current_index = 0x17E,
		previous_index = 0x17F,
		DK_actor_pointer = 0x180,
		Diddy_actor_pointer = 0x184,
		Lanky_actor_pointer = 0x188,
		Tiny_actor_pointer = 0x18C,
		Chunky_actor_pointer = 0x190,
		y_oscillation_point = 0x19C,
		kickout_timer = 0x1B4, -- Kicks the player out of the tag barrel at >= 9000
	},
	text_overlay = {
		text_shown = 0x1EE, -- u16 be
	},
	kosh_kontroller = {
		slot_location = 0x1A2,
		melons_remaining = 0x1A3,
		slot_pointer_base = 0x1A8,
	},
	main_menu_controller = {
		menu_screen = 0x18A,
		menu_position = 0x18F,
	},
	bug = { -- Big Bug Bash -- TODO: These possibly apply to other AI objects
		current_direction = 0x180, -- Float
		ticks_til_direction_change = 0x184, -- u32_be
	},
	orange = {
		bounce_counter = 0x17C,
	},
	mad_jack = { -- TODO: Some of these might be wrong... hmm..
		ticks_until_next_action = {0x1AD, 0x1A5, 0x1A5, nil},
		phase =                   {0x1D4, 0x1DC, 0x1DC, nil},
		actions_remaining =       {0x1D8, 0x1E0, 0x1E0, nil},
		action_type =             {0x1D9, 0x1E1, 0x1E1, nil},
		current_position =        {0x1E0, 0x1E8, 0x1E8, nil},
		next_position =           {0x1E1, 0x1E9, 0x1E9, nil},
		white_switch_position =   {0x1E4, 0x1EC, 0x1EC, nil},
		blue_switch_position =    {0x1E5, 0x1ED, 0x1ED, nil},
	};
};

local function getActorNameFromBehavior(actorBehavior)
	return obj_model1.actor_types[actorBehavior] or actorBehavior;
end

local function getActorName(pointer)
	if isRDRAM(pointer) then
		local actorBehavior = mainmemory.read_u16_be(pointer + obj_model1.actor_type);
		return getActorNameFromBehavior(actorBehavior);
	end
	return "Unknown";
end

local function isKong(actorType)
	return actorType >= 2 and actorType <= 6;
end

local function getExamineDataModelOne(pointer)
	local examine_data = {};

	if not isRDRAM(pointer) then
		return examine_data;
	end

	local modelPointer = dereferencePointer(pointer + obj_model1.model_pointer);
	local renderingParametersPointer = dereferencePointer(pointer + obj_model1.rendering_parameters_pointer);
	local boneArrayPointer = dereferencePointer(pointer + obj_model1.current_bone_array_pointer);
	local hasModel = isRDRAM(modelPointer) or isRDRAM(renderingParametersPointer) or isRDRAM(boneArrayPointer);

	local xPos = mainmemory.readfloat(pointer + obj_model1.x_pos, true);
	local yPos = mainmemory.readfloat(pointer + obj_model1.y_pos, true);
	local zPos = mainmemory.readfloat(pointer + obj_model1.z_pos, true);
	local hasPosition = hasModel or xPos ~= 0 or yPos ~= 0 or zPos ~= 0;

	table.insert(examine_data, { "Actor base", toHexString(pointer, 6) });
	table.insert(examine_data, { "Actor size", toHexString(mainmemory.read_u32_be(pointer + heap.object_size)) });
	local currentActorTypeNumeric = mainmemory.read_u16_be(pointer + obj_model1.actor_type);
	local currentActorType = getActorName(pointer); -- Needed for detecting special fields
	table.insert(examine_data, { "Actor type", currentActorType });
	table.insert(examine_data, { "Separator", 1 });

	if hasModel then
		table.insert(examine_data, { "Model", toHexString(modelPointer, 6) });
		table.insert(examine_data, { "Rendering Params", toHexString(renderingParametersPointer, 6) });
		table.insert(examine_data, { "Texture Renderer", toHexString(dereferencePointer(pointer + obj_model1.texture_renderer_pointer) or 0)});
		table.insert(examine_data, { "Separator", 1 });
		table.insert(examine_data, { "Bone Array 1", Game.getBoneArray1PrettyPrint(pointer) });
		table.insert(examine_data, { "Stored X1", Game.getStoredX1(pointer) });
		table.insert(examine_data, { "Stored Y1", Game.getStoredY1(pointer) });
		table.insert(examine_data, { "Stored Z1", Game.getStoredZ1(pointer) });
		table.insert(examine_data, { "Separator", 1 });
		table.insert(examine_data, { "Bone Array 2", Game.getBoneArray2PrettyPrint(pointer) });
		table.insert(examine_data, { "Stored X2", Game.getStoredX2(pointer) });
		table.insert(examine_data, { "Stored Y2", Game.getStoredY2(pointer) });
		table.insert(examine_data, { "Stored Z2", Game.getStoredZ2(pointer) });
		table.insert(examine_data, { "Separator", 1 });
	end

	if hasPosition then
		table.insert(examine_data, { "X", xPos });
		table.insert(examine_data, { "Y", yPos });
		table.insert(examine_data, { "Z", zPos });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Floor", mainmemory.readfloat(pointer + obj_model1.floor, true) });
		table.insert(examine_data, { "Distance From Floor", mainmemory.readfloat(pointer + obj_model1.distance_from_floor, true) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Rot X", ScriptHawk.UI.formatRotation(mainmemory.read_u16_be(pointer + obj_model1.x_rot)) });
		table.insert(examine_data, { "Rot Y", ScriptHawk.UI.formatRotation(mainmemory.read_u16_be(pointer + obj_model1.y_rot)) });
		table.insert(examine_data, { "Rot Z", ScriptHawk.UI.formatRotation(mainmemory.read_u16_be(pointer + obj_model1.z_rot)) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Velocity", mainmemory.readfloat(pointer + obj_model1.velocity, true) });
		table.insert(examine_data, { "Y Velocity", mainmemory.readfloat(pointer + obj_model1.y_velocity, true) });
		table.insert(examine_data, { "Y Accel", mainmemory.readfloat(pointer + obj_model1.y_acceleration, true) });
		table.insert(examine_data, { "Terminal Velocity", mainmemory.readfloat(pointer + obj_model1.terminal_velocity, true) });
		table.insert(examine_data, { "Separator", 1 });
	end

	table.insert(examine_data, { "Health", mainmemory.read_s16_be(pointer + obj_model1.health) });
	table.insert(examine_data, { "Hand state", mainmemory.readbyte(pointer + obj_model1.hand_state) });
	table.insert(examine_data, { "Noclip Byte", mainmemory.readbyte(pointer + obj_model1.noclip_byte) });
	table.insert(examine_data, { "Specular highlight", mainmemory.readbyte(pointer + obj_model1.specular_highlight) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Shadow width", mainmemory.readbyte(pointer + obj_model1.shadow_width) });
	table.insert(examine_data, { "Shadow height", mainmemory.readbyte(pointer + obj_model1.shadow_height) });
	local controlStateValue = mainmemory.readbyte(pointer + obj_model1.control_state_byte);
	if isKong(currentActorTypeNumeric) and obj_model1.control_states[controlStateValue] ~= nil then
		controlStateValue = obj_model1.control_states[controlStateValue];
	else
		controlStateValue = toHexString(controlStateValue);
	end
	table.insert(examine_data, { "Control State", controlStateValue });
	table.insert(examine_data, { "Brightness", mainmemory.readbyte(pointer + obj_model1.shade_byte) });
	table.insert(examine_data, { "Separator", 1 });

	local visibilityValue = mainmemory.readbyte(pointer + obj_model1.visibility);
	table.insert(examine_data, { "Visibility", toBinaryString(visibilityValue) });
	table.insert(examine_data, { "In water", tostring(not bit.check(visibilityValue, 0)) });
	table.insert(examine_data, { "Visible", tostring(bit.check(visibilityValue, 2)) });
	table.insert(examine_data, { "Collides with terrain", tostring(bit.check(visibilityValue, 4)) });
	table.insert(examine_data, { "Destination", Game.maps[mainmemory.read_u16_be(pointer + obj_model1.destination_map) + 1] or "Unknown"});
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Lock Method 1 Pointer", toHexString(mainmemory.read_u32_be(pointer + obj_model1.collision_queue_pointer), 8) });
	table.insert(examine_data, { "Separator", 1 });

	if isKong(currentActorTypeNumeric) then
		table.insert(examine_data, { "Shockwave Charge Timer", mainmemory.read_s16_be(pointer + obj_model1.player.shockwave_charge_timer) });
		table.insert(examine_data, { "Shockwave Recovery Timer", mainmemory.readbyte(pointer + obj_model1.player.shockwave_recovery_timer) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Vehicle Actor Pointer", toHexString(mainmemory.read_u32_be(pointer + obj_model1.player.vehicle_actor_pointer), 8) });
		table.insert(examine_data, { "Grabbed Vine Pointer", toHexString(mainmemory.read_u32_be(pointer + obj_model1.player.grabbed_vine_pointer), 8) });
		table.insert(examine_data, { "Grab pointer", toHexString(mainmemory.read_u32_be(pointer + obj_model1.player.grab_pointer), 8) });
		table.insert(examine_data, { "Fairy Active", mainmemory.readbyte(pointer + obj_model1.player.fairy_active) });
		local animationType = mainmemory.readbyte(pointer + obj_model1.player.animation_type);
		if obj_model1.control_states[animationType] ~= nil then
			animationType = obj_model1.control_states[animationType];
		end
		table.insert(examine_data, { "Animation Type", animationType });
		table.insert(examine_data, { "Separator", 1 });

		for index, offset in ipairs(obj_model1.player.scale) do
			table.insert(examine_data, { "Scale "..toHexString(offset), mainmemory.readfloat(pointer + offset, true) });
		end
		table.insert(examine_data, { "Separator", 1 });
	end

	if currentActorType == "Camera" then
		local focusedActor = dereferencePointer(pointer + obj_model1.camera.focused_actor_pointer);
		local focusedActorType = "Unknown";

		if isRDRAM(focusedActor) then
			focusedActorType = getActorName(focusedActor);
		end

		table.insert(examine_data, { "Focused Actor", toHexString(focusedActor, 6).." "..focusedActorType });
		table.insert(examine_data, { "Focused Vehicle", toHexString(mainmemory.read_u32_be(pointer + obj_model1.camera.focused_vehicle_pointer))});
		table.insert(examine_data, { "Focused Vehicle 2", toHexString(mainmemory.read_u32_be(pointer + obj_model1.camera.focused_vehicle_pointer_2))});
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Viewport X Pos", mainmemory.readfloat(pointer + obj_model1.camera.viewport_x_position, true) });
		table.insert(examine_data, { "Viewport Y Pos", mainmemory.readfloat(pointer + obj_model1.camera.viewport_y_position, true) });
		table.insert(examine_data, { "Viewport Z Pos", mainmemory.readfloat(pointer + obj_model1.camera.viewport_z_position, true) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Viewport Y Rot", ScriptHawk.UI.formatRotation(mainmemory.read_u16_be(pointer + obj_model1.camera.viewport_y_rotation)) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Tracking Distance", mainmemory.readfloat(pointer + obj_model1.camera.tracking_distance, true) });
		table.insert(examine_data, { "Tracking Angle", mainmemory.readfloat(pointer + obj_model1.camera.tracking_angle, true) });
		table.insert(examine_data, { "Separator", 1 });

		local stateType = mainmemory.readbyte(pointer + obj_model1.camera.state_type);
		if obj_model1.camera.state_values[stateType] ~= nil then
			stateType = obj_model1.camera.state_values[stateType];
		end
		table.insert(examine_data, { "Camera State Type", stateType });
		table.insert(examine_data, { "C-Down Zoom Level", mainmemory.readbyte(pointer + obj_model1.camera.zoom_level_c_down) });
		table.insert(examine_data, { "Current Zoom Level", mainmemory.readbyte(pointer + obj_model1.camera.zoom_level_current) });
		table.insert(examine_data, { "Zoom Level After C-Up", mainmemory.readbyte(pointer + obj_model1.camera.zoom_level_after_c_up) });
		table.insert(examine_data, { "Zoom Level Timer 1", mainmemory.readbyte(pointer + obj_model1.camera.state_switch_timer_1) });
		table.insert(examine_data, { "Zoom Level Timer 2", mainmemory.readbyte(pointer + obj_model1.camera.state_switch_timer_2) });
		table.insert(examine_data, { "Separator", 1 });
	end

	if currentActorType == "Tag Barrel" then
		table.insert(examine_data, { "TB scroll timer", mainmemory.readbyte(pointer + obj_model1.tag_barrel.scroll_timer) });
		table.insert(examine_data, { "TB current index", mainmemory.readbyte(pointer + obj_model1.tag_barrel.current_index) });
		table.insert(examine_data, { "TB previous index", mainmemory.readbyte(pointer + obj_model1.tag_barrel.previous_index) });
		table.insert(examine_data, { "TB kickout timer", mainmemory.read_u32_be(pointer + obj_model1.tag_barrel.kickout_timer) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Y Oscillation Point", mainmemory.readfloat(pointer + obj_model1.tag_barrel.y_oscillation_point,true) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "DK Actor Pointer", toHexString(mainmemory.read_u32_be(pointer + obj_model1.tag_barrel.DK_actor_pointer)) });
		table.insert(examine_data, { "Diddy Actor Pointer", toHexString(mainmemory.read_u32_be(pointer + obj_model1.tag_barrel.Diddy_actor_pointer)) });
		table.insert(examine_data, { "Lanky Actor Pointer", toHexString(mainmemory.read_u32_be(pointer + obj_model1.tag_barrel.Lanky_actor_pointer)) });
		table.insert(examine_data, { "Tiny Actor Pointer", toHexString(mainmemory.read_u32_be(pointer + obj_model1.tag_barrel.Tiny_actor_pointer)) });
		table.insert(examine_data, { "Chunky Actor Pointer", toHexString(mainmemory.read_u32_be(pointer + obj_model1.tag_barrel.Chunky_actor_pointer)) });
		table.insert(examine_data, { "Separator", 1 });

	elseif currentActorType == "Kremling Kosh Controller" then
		table.insert(examine_data, { "Current Slot", mainmemory.readbyte(pointer + obj_model1.kosh_kontroller.slot_location) });
		table.insert(examine_data, { "Melons Remaining", mainmemory.readbyte(pointer + obj_model1.kosh_kontroller.melons_remaining) });
		for i = 1, 8 do
			table.insert(examine_data, { "Slot "..i.." pointer", toHexString(mainmemory.read_u32_be(pointer + obj_model1.kosh_kontroller.slot_pointer_base + (i - 1) * 4), 8) });
		end
		table.insert(examine_data, { "Separator", 1 });
	elseif currentActorType == "Bug" then -- Big Bug Bash
		table.insert(examine_data, { "Current AI direction", mainmemory.readfloat(pointer + obj_model1.bug.current_direction, true) });
		table.insert(examine_data, { "Ticks til direction change", mainmemory.read_u32_be(pointer + obj_model1.bug.ticks_til_direction_change) });
		table.insert(examine_data, { "Separator", 1 });
	elseif currentActorType == "Main Menu Controller" then
		table.insert(examine_data, { "Menu Screen", mainmemory.readbyte(pointer + obj_model1.main_menu_controller.menu_screen) });
		table.insert(examine_data, { "Menu Position", mainmemory.readbyte(pointer + obj_model1.main_menu_controller.menu_position) });
		table.insert(examine_data, { "Separator", 1 });
	end

	return examine_data;
end

function Game.getPlayerObject() -- TODO: Cache this
	if Game.isLoading() then
		return;
	end
	return dereferencePointer(Game.Memory.player_pointer);
end

local function setObjectModel1Position(pointer, x, y, z)
	if isRDRAM(pointer) then
		mainmemory.writefloat(pointer + obj_model1.x_pos, x, true);
		mainmemory.writefloat(pointer + obj_model1.y_pos, y, true);
		mainmemory.writefloat(pointer + obj_model1.z_pos, z, true);
	end
end

local model_indexes = { -- Different on Kiosk, handled in Game.detectVersion()
	[0x0000] = "No Model",
	[0x0001] = "Diddy",
	[0x0002] = "Diddy (Instrument)",
	[0x0003] = "Diddy (Gun)",
	[0x0004] = "DK",
	[0x0005] = "DK",
	[0x0006] = "Lanky",
	[0x0007] = "Lanky (Instrument)",
	[0x0008] = "Lanky",
	[0x0009] = "Tiny",
	[0x000A] = "Tiny (Instrument)",
	[0x000B] = "Tiny",
	[0x000C] = "Chunky",
	[0x000D] = "Chunky (Instrument)",
	[0x000E] = "Disco Chunky",
	[0x000F] = "Chunky",
	[0x0010] = "Invisible Chunky",
	[0x0011] = "Cranky",
	[0x0012] = "Funky",
	[0x0013] = "Candy",
	[0x0014] = "Rambi",
	[0x0015] = "Snake", -- Teetering Turtles
	[0x0016] = "Turtle", -- Teetering Turtles
	[0x0017] = "Seal",
	[0x0018] = "Enguarde",
	[0x0019] = "Beaver",
	[0x001A] = "Beaver",
	[0x001B] = "Beaver",
	[0x001C] = "Zinger",
	[0x001D] = "Squawks",
	[0x001E] = "Klobber",
	[0x001F] = "Snide",
	[0x0020] = "Kaboom",
	[0x0021] = "Klaptrap (Green)",
	[0x0022] = "Klaptrap (Purple)",
	[0x0023] = "Klaptrap (Red)",
	[0x0024] = "Klaptrap (Teeth)",
	[0x0025] = "Mad Jack",
	[0x0026] = "Krash", -- Minecart Club Guy
	[0x0027] = "Troff",
	[0x0028] = "Bad Hit Detection Man",
	[0x0029] = "Sir Domino",
	[0x002A] = "Mr. Dice",
	[0x002B] = "Ruler", -- Shape puzzle enemy thing toy thing enemy
	[0x002C] = "Robo-Kremling",
	[0x002D] = "Scoff",
	[0x002E] = "Beetle",
	[0x002F] = "Klaptrap (Teeth?)",
	[0x0030] = "Nintendo Logo",
	[0x0031] = "Kremling",
	[0x0032] = "Kremling (Red)",
	[0x0033] = "Kremling",
	[0x0034] = "Mechanical Fish",
	[0x0035] = "Toy Car",
	[0x0036] = "Giant Clam",
	[0x0037] = "Kasplat",
	[0x0038] = "Army Dillo", -- With shell
	[0x0039] = "Mr. Dice",
	[0x003A] = "Klump",
	[0x003B] = "Pufftoss",
	[0x003C] = "Dogadon",
	[0x003D] = "Banana Fairy",
	[0x003E] = "Llama",
	[0x003F] = "Guard", -- Stealthy Snoop
	[0x0040] = "Robo-Zinger",
	[0x0041] = "Turntable", -- DK Rap
	[0x0042] = "Krossbones",
	[0x0043] = "Shuri",
	[0x0044] = "Gimpfish",
	[0x0045] = "K. Lumsy",
	[0x0046] = "Spider",
	[0x0047] = "Rabbit",
	[0x0048] = "Beanstalk",
	[0x0049] = "K. Rool",
	[0x004A] = "Fireball (With Glasses)", -- From Chunky 5DI
	[0x004B] = "Skeleton Head", -- DK minecart
	[0x004C] = "Skeleton Hand", -- DK minecart
	[0x004D] = "Vulture",
	[0x004E] = "Vulture",
	[0x004F] = "Bat",
	[0x0050] = "Skull", -- DK Minecart
	[0x0051] = "Tomato",
	[0x0052] = "Kritter-in-a-Sheet",
	[0x0053] = "Fly",
	[0x0054] = "Fly Swatter",
	[0x0055] = "Fly Swatter",
	[0x0056] = "Owl",
	[0x0057] = "Book", -- Cactle
	[0x0058] = "Ship's Wheel",
	[0x0059] = "Spotlight Fish", -- What the heck is his name?
	[0x005A] = "Pufftup",
	[0x005B] = "Mermaid",
	[0x005C] = "Mushroom",
	[0x005D] = "Shockwave (Mad Jack)",
	[0x005E] = "Squawks",
	[0x005F] = "Worm (apple)",
	[0x0060] = "Cuckoo Bird",
	[0x0061] = "Kosha",
	[0x0062] = "Ice Tomato",
	[0x0063] = "Army Dillo (No Shell)",
	[0x0064] = "Boombox",
	[0x0065] = "B. Locker",
	[0x0066] = "Escape Ship",
	[0x0067] = "Army Dillo's Cannon",
	[0x0068] = "K. Rool", -- Tiny Phase?
	[0x0069] = "Golden Banana",
	[0x006A] = "Shockwave",
	[0x006B] = "K. Rool's Glove",
	[0x006C] = "K. Rool's Foot",
	[0x006D] = "K. Rool's Toe",
	[0x006E] = "K. Rool's Toe",
	[0x006F] = "K. Rool's Toe",
	[0x0070] = "Microphone", -- K. Rool Fight
	[0x0071] = "Desk (K. Rool)",
	[0x0072] = "Bell",
	[0x0073] = "Clapper Board", -- Bloopers Ending
	[0x0074] = "Cannon",
	[0x0075] = "Barrel?",
	[0x0076] = "Bonus Barrel",
	[0x0077] = "Hunky Chunky Barrel",
	[0x0078] = "Mini Monkey Barrel",
	[0x0079] = "Barrel",
	[0x007A] = "Pushable Box",
	[0x007B] = "TNT Barrel Spawner",
	[0x007C] = "Cannon",
	[0x007D] = "TNT Barrel",
	[0x007E] = "Rambi Crate",
	[0x007F] = "Enguarde Crate",
	[0x0080] = "Chain", -- Diddy, Castle
	[0x0081] = "Swinging Light", -- Lobby Roof
	[0x0082] = "Minecart",
	[0x0083] = "Barrel",
	[0x0084] = "Bridge (Castle)",
	[0x0085] = "Large Brown Bridge",
	[0x0086] = "Feather",
	[0x0087] = "Laser", -- Castle Boss
	[0x0088] = "Golden Banana",
	[0x0089] = "Rocketbarrel",
	[0x008A] = "Strong Kong Barrel",
	[0x008B] = "Orangstand Sprint Barrel",
	[0x008C] = "Diddy's Jetpack",
	[0x008D] = "Photo",
	[0x008E] = "Minecart (TNT)",
	[0x008F] = "Weird glitch texture (computer screen?)",
	[0x0090] = "BBB Slot",
	[0x0091] = "BBB Slot",
	[0x0092] = "BBB Slot",
	[0x0093] = "BBB Slot",
	[0x0094] = "BBB Lever",
	[0x0095] = "Tiny's Car",
	[0x0096] = "Missile", -- Car Race
	[0x0097] = "Swinging light", -- Green
	[0x0098] = "Bananaporter Zipper",
	[0x0099] = "Boulder",
	[0x009A] = "Vase (O)",
	[0x009B] = "Vase (:)",
	[0x009C] = "Vase (Triangle)",
	[0x009D] = "Vase (+)",
	[0x009E] = "Toy Box",
	[0x009F] = "Boat",
	[0x00A0] = "Padlock",
	[0x00A1] = "Cannon Ball",
	[0x00A2] = "Vine", -- Brown
	[0x00A3] = "Vine",
	[0x00A4] = "Counter",
	[0x00A5] = "Key",
	[0x00A6] = "Bongos",
	[0x00A7] = "DK Star",
	[0x00A8] = "Spotlight",
	[0x00A9] = "Cannon (Seasick Chunky)",
	[0x00AA] = "Boulder Debris", -- K. Lumsy Cutscene
	[0x00AB] = "Spider Web",
	[0x00AC] = "Steel Keg",
	[0x00AD] = "Shockwave",
	[0x00AE] = "Shockwave",
	[0x00AF] = "Battle Crown",
	[0x00B0] = "Buoy",
	[0x00B1] = "Buoy (Green)",
	[0x00B2] = "Nothing?",
	[0x00B3] = "DK Banana Counter",
	[0x00B4] = "Diddy Banana Counter",
	[0x00B5] = "Tiny Banana Counter",
	[0x00B6] = "Lanky Banana Counter",
	[0x00B7] = "Chunky Banana Counter",
	[0x00B8] = "Shockwave (Green)",
	[0x00B9] = "Potion",
	[0x00BA] = "Missile (Army Dillo)",
	[0x00BB] = "Shockwave (Red)",
	[0x00BC] = "Ice wall?", -- in caves? Too thick? Texture on wall Army Dillo 2?
	[0x00BD] = "Rareware Logo",
	[0x00BE] = "Stalactite",
	[0x00BF] = "Rock Debris",
	[0x00C0] = "Spotlight (BONUS)",
	[0x00C1] = "Tag Barrel",
	[0x00C2] = "Castle minecart thing",
	[0x00C3] = "Lever", -- Gorilla Grab
	[0x00C4] = "K. Lumsy's Cage",
	[0x00C5] = "Freeze Attack", -- Multiplayer Battle Arena
	[0x00C6] = "1 Pad (Diddy 5DI)",
	[0x00C7] = "2 Pad (Diddy 5DI)",
	[0x00C8] = "3 Pad (Diddy 5DI)",
	[0x00C9] = "4 Pad (Diddy 5DI)",
	[0x00CA] = "5 Pad (Diddy 5DI)",
	[0x00CB] = "6 Pad (Diddy 5DI)",
	[0x00CC] = "Race Checkpoint", -- Rabbit Race
	[0x00CD] = "Padlock & Key",
	[0x00CE] = "Finish Line", -- Rabbit Race
	[0x00CF] = "Shockwave (Green)",
	[0x00D0] = "Shockwave (Blue)",
	[0x00D1] = "Shockwave (Purple)",
	[0x00D2] = "Question Mark", -- Tag Barrel
	[0x00D3] = "Flower (Instrument)",
	[0x00D4] = "DK Logo (Instrument)",
	[0x00D5] = "Golden Banana",
	[0x00D6] = "Apple",
	[0x00D7] = "Barrel",
	[0x00D8] = "Flag", -- Car Race?
	[0x00D9] = "Flag", -- Car Race?
	[0x00DA] = "Boat",
	[0x00DB] = "Krusha (Gun)",
	[0x00DC] = "King Kut Out Body",
	[0x00DD] = "King Kut Out Head",
	[0x00DE] = "King Kut Out Arm",
	[0x00DF] = "King Kut Out Arm",
	[0x00E0] = "Rainbow Coin Patch",
	[0x00E1] = "Rope", -- K. Rool Fight
	[0x00E2] = "DK Smoke Trail", -- End Sequence
	[0x00E3] = "Light (K. Rool fight)",
	[0x00E4] = "Bonus Barrel (Hideout Helm)",
	[0x00E5] = "Banana", -- Lanky phase
	[0x00E6] = "Banana Barrel", -- Lanky phase
	[0x00E7] = "Training Barrel",
	[0x00E8] = "Pirate Photo",
	[0x00E9] = "Butterfly",
	[0x00EA] = "Barrel",
	[0x00EB] = "Funky's Gun", -- K. Rool Cutscene
	[0x00EC] = "Boot", -- K. Rool Cutscene
};

local function getModelNameFromModelIndex(modelIndex)
	return model_indexes[modelIndex] or modelIndex;
end

local function getActorCollisions(actor)
	local collisionCount = 0;
	local collision = dereferencePointer(actor + obj_model1.collision_queue_pointer);
	while isRDRAM(collision) do
		collisionCount = collisionCount + 1;
		--[[
		local collisionPosition = dereferencePointer(collision + 0x10);
		if isRDRAM(collisionPosition) then
			dprint(toHexString(collisionPosition)..": "..mainmemory.readfloat(collisionPosition + 0x00, true)..", "..mainmemory.readfloat(collisionPosition + 0x04, true)..", "..mainmemory.readfloat(collisionPosition + 0x08, true))
		end
		--]]
		collision = dereferencePointer(collision + 0x14);
	end
	--print_deferred();
	return collisionCount;
end

----------------------------------
-- Object Model 2 Documentation --
----------------------------------

-- Things in object model 2
-- GBs & CBs
-- Doors in helm
-- K. Rool's chair
-- Gorilla Grab Levers
-- Bananaporters
-- DK portals
-- Trees
-- Instrument pads
-- Wrinkly doors
-- Shops (Snide's, Cranky's, Funky's, Candy's)

local obj_model2_slot_size = 0x90; -- 0x88 on Kiosk, handled in Game.detectVersion()

-- Relative to objects in model 2 array
obj_model2 = {
	x_pos = 0x00, -- Float
	y_pos = 0x04, -- Float
	z_pos = 0x08, -- Float
	hitbox_scale = 0x0C, -- Float
	model_pointer = 0x20,
	model = {
		x_pos = 0x00, -- Float
		y_pos = 0x04, -- Float
		z_pos = 0x08, -- Float
		scale = 0x0C, -- Float
		rot_x = 0x10, -- Float
		rot_y = 0x14, -- Float
		rot_z = 0x18, -- Float
	},
	behavior_type_pointer = 0x24, -- TODO: Fields for this object
	unknown_counter = 0x3A, -- u16_be
	behavior_pointer = 0x7C,
	object_type = 0x84, -- u16_be
	object_types = { -- "-" means that spawning this object crashes the game
		[0x00] = "Nothing", -- "test" internal name
		[0x01] = "Thin Flame?", -- 2D
		[0x02] = "-",
		[0x03] = "Tree", -- 2D
		[0x04] = "-",
		[0x05] = "Yellow Flowers", -- 2D
		[0x06] = "-",
		[0x07] = "-",
		[0x08] = "Xmas Holly?", -- 2D
		[0x09] = "-",
		[0x0A] = "CB Single (Diddy)",
		[0x0B] = "Large Wooden Panel", -- 2D
		[0x0C] = "Flames", -- 2D
		[0x0D] = "CB Single (DK)",
		[0x0E] = "Large Iron Bars Panel", -- 2D
		[0x0F] = "Goo Hand", -- Castle
		[0x10] = "Flame", -- 2D
		[0x11] = "Homing Ammo Crate",
		[0x12] = "Coffin Door",
		[0x13] = "Coffin Lid",
		[0x14] = "Skull", -- Castle, it has a boulder in it
		[0x15] = "Wooden Crate",
		[0x16] = "CB Single (Tiny)",
		[0x17] = "Shield", -- Castle
		[0x18] = "Metal thing",
		[0x19] = "Coffin",
		[0x1A] = "Metal Panel",
		[0x1B] = "Rock Panel",
		[0x1C] = "Banana Coin (Tiny)",
		[0x1D] = "Banana Coin (DK)",
		[0x1E] = "CB Single (Lanky)",
		[0x1F] = "CB Single (Chunky)",
		[0x20] = "Tree", -- Japes?
		[0x21] = "-",
		[0x22] = "Metal Panel",
		[0x23] = "Banana Coin (Lanky)",
		[0x24] = "Banana Coin (Diddy)",
		[0x25] = "Metal Panel",
		[0x26] = "Metal Panel Red",
		[0x27] = "Banana Coin (Chunky)",
		[0x28] = "Metal Panel Grey",
		[0x29] = "Tree", -- Japes?
		[0x2A] = "-",
		[0x2B] = "CB Bunch (DK)",
		[0x2C] = "Hammock",
		[0x2D] = "Small jungle bush plant",
		[0x2E] = "-",
		[0x2F] = "Small plant",
		[0x30] = "Bush", -- Japes
		[0x31] = "-",
		[0x32] = "-",
		[0x33] = "-", -- Fungi Lobby, Unknown
		[0x34] = "Metal Bridge", -- Helm Lobby
		[0x35] = "Large Blue Crystal", -- Crystal Caves Lobby
		[0x36] = "Plant",
		[0x37] = "Plant",
		[0x38] = "-",
		[0x39] = "White Flowers",
		[0x3A] = "Stem 4 Leaves",
		[0x3B] = "-",
		[0x3C] = "-",
		[0x3D] = "Small plant",
		[0x3E] = "-",
		[0x3F] = "-",
		[0x40] = "-",
		[0x41] = "-",
		[0x42] = "-",
		[0x43] = "Yellow Flower",
		[0x44] = "Blade of Grass Large",
		[0x45] = "Lilypad?",
		[0x46] = "Plant",
		[0x47] = "Iron Bars", -- Castle Lobby Coconut Switch
		[0x48] = "Nintendo Coin", -- Not sure if this is collectable
		[0x49] = "Metal Floor",
		[0x4A] = "-",
		[0x4B] = "-",
		[0x4C] = "Bull Rush",
		[0x4D] = "-",
		[0x4E] = "-",
		[0x4F] = "Metal box/platform",
		[0x50] = "K Crate", -- DK Helm Target Barrel
		[0x51] = "-",
		[0x52] = "Wooden panel",
		[0x53] = "-",
		[0x54] = "-",
		[0x55] = "-",
		[0x56] = "Orange",
		[0x57] = "Watermelon Slice",
		[0x58] = "Tree", -- Unused?
		[0x59] = "Tree", -- Unused
		[0x5A] = "Tree",
		[0x5B] = "Tree (Black)", -- Unused
		[0x5C] = "-",
		[0x5D] = "Light Green platform",
		[0x5E] = "-",
		[0x5F] = "-",
		[0x60] = "-",
		[0x61] = "-",
		[0x62] = "Brick Wall",
		[0x63] = "-",
		[0x64] = "-",
		[0x65] = "-",
		[0x66] = "-",
		[0x67] = "Wrinkly Door (Tiny)",
		[0x68] = "-",
		[0x69] = "-",
		[0x6A] = "-",
		[0x6B] = "Conveyor Belt",
		[0x6C] = "Tree", -- Japes?
		[0x6D] = "Tree",
		[0x6E] = "Tree",
		[0x6F] = "-",
		[0x70] = "Primate Punch Switch", -- Factory
		[0x71] = "Hi-Lo toggle machine",
		[0x72] = "Breakable Metal Grate", -- Factory
		[0x73] = "Cranky's Lab",
		[0x74] = "Golden Banana",
		[0x75] = "Metal Platform",
		[0x76] = "Metal Bars",
		[0x77] = "-",
		[0x78] = "Metal fence",
		[0x79] = "Snide's HQ",
		[0x7A] = "Funky's Armory",
		[0x7B] = "-",
		[0x7C] = "Blue lazer field",
		[0x7D] = "-",
		[0x7E] = "Bamboo Gate",
		[0x7F] = "-",
		[0x80] = "Tree Stump",
		[0x81] = "Breakable Hut", -- Japes
		[0x82] = "Mountain Bridge", -- Japes
		[0x83] = "Tree Stump", -- Japes
		[0x84] = "Bamboo Gate",
		[0x85] = "-",
		[0x86] = "Blue/green tree",
		[0x87] = "-",
		[0x88] = "Mushroom",
		[0x89] = "-",
		[0x8A] = "Disco Ball",
		[0x8B] = "2 Door (5DS)", -- Galleon
		[0x8C] = "3 Door (5DS)", -- Galleon
		[0x8D] = "Map of DK island",
		[0x8E] = "Crystal Coconut",
		[0x8F] = "Ammo Crate",
		[0x90] = "Banana Medal",
		[0x91] = "Peanut",
		[0x92] = "Simian Slam Switch (Chunky, Green)",
		[0x93] = "Simian Slam Switch (Diddy, Green)",
		[0x94] = "Simian Slam Switch (DK, Green)",
		[0x95] = "Simian Slam Switch (Lanky, Green)",
		[0x96] = "Simian Slam Switch (Tiny, Green)",
		[0x97] = "Baboon Blast Pad",
		[0x98] = "Film",
		[0x99] = "Chunky Rotating Room", -- Aztec, Tiny Temple
		[0x9A] = "Stone Monkey Face",
		[0x9B] = "Stone Monkey Face",
		[0x9C] = "Aztec Panel blue",
		[0x9D] = "-", -- templestuff, in Tiny Temple
		[0x9E] = "Ice Floor",
		[0x9F] = "Ice Pole", -- I think this is a spotlight
		[0xA0] = "Big Blue wall panel",
		[0xA1] = "Big Blue wall panel",
		[0xA2] = "Big Blue wall panel",
		[0xA3] = "Big Blue wall panel",
		[0xA4] = "KONG Letter (K)",
		[0xA5] = "KONG Letter (O)",
		[0xA6] = "KONG Letter (N)",
		[0xA7] = "KONG Letter (G)",
		[0xA8] = "Bongo Pad", -- DK
		[0xA9] = "Guitar Pad", -- Diddy
		[0xAA] = "Saxaphone Pad", -- Tiny
		[0xAB] = "Triangle Pad", -- Chunky
		[0xAC] = "Trombone Pad", -- Lanky
		[0xAD] = "Wood panel small",
		[0xAE] = "Wood panel small",
		[0xAF] = "Wood panel small",
		[0xB0] = "Wood Panel small",
		[0xB1] = "Wall Panel", -- Aztec
		[0xB2] = "Wall Panel", -- Caves?
		[0xB3] = "Stone Monkey Face (Not Solid)",
		[0xB4] = "Feed Me Totem", -- Aztec
		[0xB5] = "Melon Crate",
		[0xB6] = "Lava Platform", -- Aztec, Llama temple
		[0xB7] = "Rainbow Coin",
		[0xB8] = "Green Switch",
		[0xB9] = "Coconut Indicator", -- Free Diddy
		[0xBA] = "Snake Head", -- Aztec, Llama temple
		[0xBB] = "Matching Game Board", -- Aztec, Llama temple
		[0xBC] = "Stone Monkey Head", -- Aztec
		[0xBD] = "Large metal section",
		[0xBE] = "Production Room Crusher", -- Factory
		[0xBF] = "Metal Platform",
		[0xC0] = "Metal Object",
		[0xC1] = "Metal Object",
		[0xC2] = "Metal Object",
		[0xC3] = "Gong", -- Diddy Kong
		[0xC4] = "Platform", -- Aztec
		[0xC5] = "Bamboo together",
		[0xC6] = "Metal Bars",
		[0xC7] = "Target", -- Minigames
		[0xC8] = "Wooden object",
		[0xC9] = "Ladder",
		[0xCA] = "Ladder",
		[0xCB] = "Wooden pole",
		[0xCC] = "Blue panel",
		[0xCD] = "Ladder",
		[0xCE] = "Grey Switch",
		[0xCF] = "D Block for toy world",
		[0xD0] = "Hatch (Factory)",
		[0xD1] = "Metal Bars",
		[0xD2] = "Raisable Metal Platform",
		[0xD3] = "Metal Cage",
		[0xD4] = "Simian Spring Pad",
		[0xD5] = "Power Shed", -- Factory
		[0xD6] = "Metal platform",
		[0xD7] = "Sun Lighting effect panel",
		[0xD8] = "Wooden Pole",
		[0xD9] = "Wooden Pole",
		[0xDA] = "Wooden Pole",
		[0xDB] = "-",
		[0xDC] = "Question Mark Box",
		[0xDD] = "Blueprint (Tiny)",
		[0xDE] = "Blueprint (DK)",
		[0xDF] = "Blueprint (Chunky)",
		[0xE0] = "Blueprint (Diddy)",
		[0xE1] = "Blueprint (Lanky)",
		[0xE2] = "Tree Dark",
		[0xE3] = "Rope",
		[0xE4] = "-",
		[0xE5] = "-",
		[0xE6] = "Lever",
		[0xE7] = "Green Croc Head (Minecart)",
		[0xE8] = "Metal Gate with red/white stripes",
		[0xE9] = "-",
		[0xEA] = "Purple Croc Head (Minecart)",
		[0xEB] = "Wood panel",
		[0xEC] = "DK coin",
		[0xED] = "Wooden leg",
		[0xEE] = "-",
		[0xEF] = "Wrinkly Door (Lanky)",
		[0xF0] = "Wrinkly Door (DK)",
		[0xF1] = "Wrinkly Door (Chunky)",
		[0xF2] = "Wrinkly Door (Diddy)",
		[0xF3] = "Torch",
		[0xF4] = "Number Game (1)", -- Factory
		[0xF5] = "Number Game (2)", -- Factory
		[0xF6] = "Number Game (3)", -- Factory
		[0xF7] = "Number Game (4)", -- Factory
		[0xF8] = "Number Game (5)", -- Factory
		[0xF9] = "Number Game (6)", -- Factory
		[0xFA] = "Number Game (7)", -- Factory
		[0xFB] = "Number Game (8)", -- Factory
		[0xFC] = "Number Game (9)", -- Factory
		[0xFD] = "Number Game (10)", -- Factory
		[0xFE] = "Number Game (11)", -- Factory
		[0xFF] = "Number Game (12)", -- Factory
		[0x100] = "Number Game (13)", -- Factory
		[0x101] = "Number Game (14)", -- Factory
		[0x102] = "Number Game (15)", -- Factory
		[0x103] = "Number Game (16)", -- Factory
		[0x104] = "Bad Hit Detection Wheel", -- Factory
		[0x105] = "Breakable Gate", -- Galleon Primate Punch
		[0x106] = "-",
		[0x107] = "Picture of DK island",
		[0x108] = "White flashing thing",
		[0x109] = "Barrel", -- Galleon Ship
		[0x10A] = "Gorilla Gone Pad",
		[0x10B] = "Monkeyport Pad",
		[0x10C] = "Baboon Balloon Pad",
		[0x10D] = "Light", -- Factory?
		[0x10E] = "Light", -- Factory?
		[0x10F] = "Barrel", -- Galleon Ship
		[0x110] = "Barrel", -- Galleon Ship
		[0x111] = "Barrel", -- Galleon Ship
		[0x112] = "Barrel", -- Galleon Ship
		[0x113] = "Pad", -- TODO: Empty blue pad? Where is this used?
		[0x114] = "Red Light", -- Factory?
		[0x115] = "Breakable X Panel", -- To enter Japes underground
		[0x116] = "Power Shed Screen", -- Factory
		[0x117] = "Crusher", -- Factory
		[0x118] = "Floor Panel",
		[0x119] = "Metal floor panel mesh",
		[0x11A] = "Metal Door", -- Factory or Car Race
		[0x11B] = "Metal Door", -- Factory or Car Race
		[0x11C] = "Metal Door", -- Factory or Car Race
		[0x11D] = "Metal Door", -- Factory or Car Race
		[0x11E] = "Metal Door", -- Factory or Car Race
		[0x11F] = "Metal Door", -- Factory or Car Race
		[0x120] = "Toyz Box",
		[0x121] = "O Pad", -- Aztec Chunky Puzzle
		[0x122] = "Bonus Barrel Trap", -- Aztec
		[0x123] = "Sun Idol", -- Aztec, top of "feed me" totem
		[0x124] = "Candy's Shop",
		[0x125] = "Pineapple Switch",
		[0x126] = "Peanut Switch",
		[0x127] = "Feather Switch",
		[0x128] = "Grape Switch",
		[0x129] = "Coconut Switch",
		[0x12A] = "-",
		[0x12B] = "Kong Pad",
		[0x12C] = "Boss Door", -- Troff'n'Scoff
		[0x12D] = "Troff 'n' Scoff Feed Pad",
		[0x12E] = "Metal Bars horizontal",
		[0x12F] = "Metal Bars",
		[0x130] = "Harbour Gate", -- Galleon
		[0x131] = "K. Rool's Ship", -- Galleon
		[0x132] = "Metal Platform",
		[0x133] = "-",
		[0x134] = "Flame",
		[0x135] = "Flame",
		[0x136] = "Scoff n Troff platform",
		[0x137] = "Troff 'n' Scoff Banana Count Pad (DK)",
		[0x138] = "Torch",
		[0x139] = "-",
		[0x13A] = "-",
		[0x13B] = "-",
		[0x13C] = "Boss Key",
		[0x13D] = "Machine",
		[0x13E] = "Metal Door", -- Factory or Car Race - Production Room & Lobby - Unused?
		[0x13F] = "Metal Door", -- Factory or Car Race - Testing Dept. & Krem Storage
		[0x140] = "Metal Door", -- Factory or Car Race - R&D
		[0x141] = "Metal Door", -- Factory or Car Race - Testing Dept.
		[0x142] = "Piano Game", -- Factory, Lanky
		[0x143] = "Troff 'n' Scoff Banana Count Pad (Diddy)",
		[0x144] = "Troff 'n' Scoff Banana Count Pad (Lanky)",
		[0x145] = "Troff 'n' Scoff Banana Count Pad (Chunky)",
		[0x146] = "Troff 'n' Scoff Banana Count Pad (Tiny)",
		[0x147] = "Door 1342",
		[0x148] = "Door 3142",
		[0x149] = "Door 4231",
		[0x14A] = "1 Switch (Red)",
		[0x14B] = "2 Switch (Blue)",
		[0x14C] = "3 Switch (Orange)",
		[0x14D] = "4 Switch (Green)",
		[0x14E] = "-",
		[0x14F] = "Metal Archway",
		[0x150] = "Green Crystal thing",
		[0x151] = "Red Crystal thing",
		[0x152] = "Propeller",
		[0x153] = "Large Metal Bar",
		[0x154] = "Ray Sheild?",
		[0x155] = "-",
		[0x156] = "-",
		[0x157] = "-",
		[0x158] = "-",
		[0x159] = "Light",
		[0x15A] = "Target", -- Fungi/Castle minigames
		[0x15B] = "Ladder",
		[0x15C] = "Metal Bars",
		[0x15D] = "Red Feather",
		[0x15E] = "Grape",
		[0x15F] = "Pinapple",
		[0x160] = "Coconut",
		[0x161] = "Rope",
		[0x162] = "On Button",
		[0x163] = "Up Button",
		[0x164] = "Metal barrel or lid",
		[0x165] = "Simian Slam Switch (Chunky, Red)",
		[0x166] = "Simian Slam Switch (Diddy, Red)",
		[0x167] = "Simian Slam Switch (DK, Red)",
		[0x168] = "Simian Slam Switch (Lanky, Red)",
		[0x169] = "Simian Slam Switch (Tiny, Red)",
		[0x16A] = "Simian Slam Switch (Chunky, Blue)",
		[0x16B] = "Simian Slam Switch (Diddy, Blue)",
		[0x16C] = "Simian Slam Switch (DK, Blue)",
		[0x16D] = "Simian Slam Switch (Lanky, Blue)",
		[0x16E] = "Simian Slam Switch (Tiny, Blue)",
		[0x16F] = "Metal Grate", -- Lanky Attic
		[0x170] = "Pendulum", -- Fungi Clock
		[0x171] = "Weight", -- Fungi Clock
		[0x172] = "Door", -- Fungi Clock
		[0x173] = "Day Switch", -- Fungi Clock
		[0x174] = "Night Switch", -- Fungi Clock
		[0x175] = "Hands", -- Fungi Clock
		[0x176] = "Bell", -- (Minecart?)
		[0x177] = "Grate", -- (Minecart?)
		[0x178] = "Crystal", -- Red - No Hitbox (Minecart)
		[0x179] = "Crystal", -- Blue - No Hitbox (Minecart)
		[0x17A] = "Crystal", -- Green - No Hitbox (Minecart)
		[0x17B] = "Door", -- Fungi
		[0x17C] = "Gate", -- Fungi, angled
		[0x17D] = "Breakable Door", -- Fungi
		[0x17E] = "Night Gate", -- Fungi, angled
		[0x17F] = "Night Grate", -- Fungi
		--[0x180] = "Unknown", -- Internal name is "minecart"
		[0x181] = "Metal Grate", -- Fungi, breakable, well
		[0x182] = "Mill Pulley Mechanism", -- Fungi
		[0x183] = "Metal Bar", -- No Hitbox (Unknown Location)
		[0x184] = "Water Wheel", -- Fungi
		[0x185] = "Crusher", -- Fungi Mill
		[0x186] = "Coveyor Belt",
		[0x187] = "Night Gate",
		[0x188] = "Question Mark Box", -- Factory Lobby, probably other places too
		[0x189] = "Spider Web", -- Door
		[0x18A] = "Grey Croc Head", -- Minecart?
		[0x18B] = "Caution Sign (Falling Rocks)", -- Minecart
		[0x18C] = "Door", -- Minecart
		[0x18D] = "Battle Crown",
		[0x18E] = "-",
		[0x18F] = "-",
		[0x190] = "Dogadon Arena Background",
		[0x191] = "Skull Door (Small)", -- Minecart
		[0x192] = "Skull Door (Big)", -- Minecart
		[0x193] = "-",
		[0x194] = "Tombstone", -- RIP, Minecart
		[0x195] = "-",
		[0x196] = "DK Star", -- Baboon Blast
		[0x197] = "K. Rool's Throne",
		[0x198] = "Bean", -- Fungi
		[0x199] = "Power Beam", -- Helm (Lanky - BoM)
		[0x19A] = "Power Beam", -- Helm (Diddy - BoM)
		[0x19B] = "Power Beam", -- Helm (Tiny - Medal Room)
		[0x19C] = "Power Beam", -- Helm (Tiny - BoM)
		[0x19D] = "Power Beam", -- Helm (Chunky - Medal Room)
		[0x19E] = "Power Beam", -- Helm (Chunky - BoM)
		[0x19F] = "Power Beam", -- Helm (Lanky - Medal Room)
		[0x1A0] = "Power Beam", -- Helm (DK - Medal Room)
		[0x1A1] = "Power Beam", -- Helm (DK - BoM)
		[0x1A2] = "Power Beam", -- Helm (Diddy - Medal Room)
		[0x1A3] = "Warning Lights", -- Helm Wheel Room
		[0x1A4] = "K. Rool Door", -- Helm
		[0x1A5] = "Metal Grate",
		[0x1A6] = "Crown Door", -- Helm
		[0x1A7] = "Coin Door", -- Helm
		[0x1A8] = "Medal Barrier (DK)", -- Helm
		[0x1A9] = "Medal Barrier (Diddy)", -- Helm
		[0x1AA] = "Medal Barrier (Tiny)", -- Helm
		[0x1AB] = "Medal Barrier (Chunky)", -- Helm
		[0x1AC] = "Medal Barrier (Lanky)", -- Helm
		[0x1AD] = "I Door (Helm, DK)",
		[0x1AE] = "V Door (Helm, Diddy)",
		[0x1AF] = "III Door (Helm, Tiny)",
		[0x1B0] = "II Door (Helm, Chunky)",
		[0x1B1] = "IV Door (Helm, Lanky)",
		[0x1B2] = "Metal Door", -- Helm CS
		[0x1B3] = "Stone Wall", -- Helm
		[0x1B4] = "Pearl", -- Galleon
		[0x1B5] = "Small Door", -- Fungi
		[0x1B6] = "-",
		[0x1B7] = "Cloud", -- Castle, Fungi?
		[0x1B8] = "Warning Lights", -- Crusher/Grinder
		[0x1B9] = "Door", -- Fungi
		[0x1BA] = "Mushroom (Yellow)",
		[0x1BB] = "Mushroom (Purple)",
		[0x1BC] = "Mushroom (Blue)",
		[0x1BD] = "Mushroom (Green)",
		[0x1BE] = "Mushroom (Red)",
		[0x1BF] = "Mushroom Puzzle Instructions",
		[0x1C0] = "Face Puzzle Board", -- Fungi
		[0x1C1] = "Mushroom", -- Climbable, Fungi
		[0x1C2] = "Small Torch", -- Internal name "test", interestingly
		[0x1C3] = "DK Arcade Machine",
		[0x1C4] = "Simian Slam Switch (Any Kong?)", -- Mad Jack fight
		[0x1C5] = "Spotlight (Crown Arena?)",
		[0x1C6] = "Battle Crown Pad",
		[0x1C7] = "Seaweed",
		[0x1C8] = "Light", -- Galleon Lighthouse
		[0x1C9] = "Dust?",
		[0x1CA] = "Moon Trapdoor", -- Fungi
		[0x1CB] = "Ladder", -- Fungi
		[0x1CC] = "Mushroom Board", -- 5 gunswitches, Fungi
		[0x1CD] = "DK Star",
		[0x1CE] = "Wooden Box", -- Galleon?
		[0x1CF] = "Yellow CB Powerup", -- Multiplayer
		[0x1D0] = "Blue CB Powerup", -- Multiplayer
		[0x1D1] = "Coin Powerup?", -- Multiplayer, causes burp
		[0x1D2] = "DK Coin", -- Multiplayer?
		[0x1D3] = "Snide's Mechanism",
		[0x1D4] = "Snide's Mechanism",
		[0x1D5] = "Snide's Mechanism",
		[0x1D6] = "Snide's Mechanism",
		[0x1D7] = "Snide's Mechanism",
		[0x1D8] = "Snide's Mechanism",
		[0x1D9] = "Snide's Mechanism",
		[0x1DA] = "Snide's Mechanism",
		[0x1DB] = "Snide's Mechanism",
		[0x1DC] = "Snide's Mechanism",
		[0x1DD] = "Snide's Mechanism",
		[0x1DE] = "Blue Flowers", -- 2D
		[0x1DF] = "Plant (Green)", -- 2D
		[0x1E0] = "Plant (Brown)", -- 2D
		[0x1E1] = "Plant", -- 2D
		[0x1E2] = "Pink Flowers", -- 2D
		[0x1E3] = "Pink Flowers", -- 2D
		[0x1E4] = "Plant", -- 2D
		[0x1E5] = "Yellow Flowers", -- 2D
		[0x1E6] = "Yellow Flowers", -- 2D
		[0x1E7] = "Plant", -- 2D
		[0x1E8] = "Blue Flowers", -- 2D
		[0x1E9] = "Blue Flower", -- 2D
		[0x1EA] = "Plant", -- 2D
		[0x1EB] = "Plant", -- 2D
		[0x1EC] = "Red Flowers", -- 2D
		[0x1ED] = "Red Flower", -- 2D
		[0x1EE] = "Mushrooms (Small)", -- 2D
		[0x1EF] = "Mushrooms (Small)", -- 2D
		[0x1F0] = "Purple Flowers", -- 2D
		[0x1F1] = "Tree", -- Castle?
		[0x1F2] = "Cactus", -- Unused
		[0x1F3] = "Cactus", -- Unused
		[0x1F4] = "Ramp", -- Car Race?
		[0x1F5] = "Submerged Pot", -- Unused
		[0x1F6] = "Submerged Pot", -- Unused
		[0x1F7] = "Ladder", -- Fungi
		[0x1F8] = "Ladder", -- Fungi
		[0x1F9] = "Floor Texture?", -- Fungi
		[0x1FA] = "Iron Gate", -- Fungi
		[0x1FB] = "Day Gate", -- Fungi
		[0x1FC] = "Night Gate", -- Fungi
		[0x1FD] = "Cabin Door", -- Caves
		[0x1FE] = "Ice Wall (Breakable)", -- Caves
		[0x1FF] = "Igloo Door", -- Caves
		[0x200] = "Castle Top", -- Caves
		[0x201] = "Ice Dome", -- Caves
		[0x202] = "Boulder Pad", -- Caves
		[0x203] = "Target", -- Caves, Tiny 5DI
		[0x204] = "Metal Gate",
		[0x205] = "CB Bunch (Lanky)",
		[0x206] = "CB Bunch (Chunky)",
		[0x207] = "CB Bunch (Tiny)",
		[0x208] = "CB Bunch (Diddy)",
		[0x209] = "Blue Aura",
		[0x20A] = "Ice Maze", -- Caves
		[0x20B] = "Rotating Room", -- Caves
		[0x20C] = "Light + Barrier", -- Caves
		[0x20D] = "Light", -- Caves
		[0x20E] = "Trapdoor", -- Caves
		[0x20F] = "Large Wooden Door", -- Aztec, Llama Temple?
		[0x210] = "Warp 5 Pad",
		[0x211] = "Warp 3 Pad",
		[0x212] = "Warp 4 Pad",
		[0x213] = "Warp 2 Pad",
		[0x214] = "Warp 1 Pad",
		[0x215] = "Large Door", -- Castle
		[0x216] = "Library Door (Revolving?)", -- Castle
		[0x217] = "Blue Platform", -- Factory / K. Rool, Unused?
		[0x218] = "White Platform", -- Factory / K. Rool, Unused?
		[0x219] = "Wooden Platform", -- Castle
		[0x21A] = "Wooden Bridge", -- Castle
		[0x21B] = "Wooden Door", -- Castle
		[0x21C] = "Metal Grate", -- Castle Pipe
		[0x21D] = "Metal Door", -- Castle Greenhouse
		[0x21E] = "Large Metal Door", -- Castle?
		[0x21F] = "Rotating Chair", -- Castle
		[0x220] = "Baboon Balloon Pad (with platform)",
		[0x221] = "Large Aztec Door",
		[0x222] = "Large Aztec Door",
		[0x223] = "Large Wooden Door", -- Castle Tree
		[0x224] = "Large Breakable Wooden Door", -- Castle Tree
		[0x225] = "Pineapple Switch (Rotating)", -- Castle Tree
		[0x226] = ": Pad", -- Aztec Chunky Puzzle
		[0x227] = "Triangle Pad", -- Aztec Chunky Puzzle
		[0x228] = "+ Pad", -- Aztec Chunky Puzzle
		[0x229] = "Stone Monkey Head", -- Aztec
		[0x22A] = "Stone Monkey Head", -- Aztec
		[0x22B] = "Stone Monkey Head", -- Aztec
		[0x22C] = "Door", -- Caves Beetle Race
		[0x22D] = "Broken Ship Piece", -- Galleon
		[0x22E] = "Broken Ship Piece", -- Galleon
		[0x22F] = "Broken Ship Piece", -- Galleon
		[0x230] = "Flotsam", -- Galleon
		[0x231] = "Metal Grate", -- Factory, above crown pad
		[0x232] = "Treasure Chest", -- Galleon
		[0x233] = "Up Switch", -- Galleon
		[0x234] = "Down Switch",
		[0x235] = "DK Star", -- Caves
		[0x236] = "Enguarde Door", -- Galleon
		[0x237] = "Trash Can", -- Castle
		[0x238] = "Fluorescent Tube", -- Castle Toolshed?
		[0x239] = "Wooden Door Half", -- Castle
		[0x23A] = "Stone Platform", -- Aztec Lobby?
		[0x23B] = "Stone Panel", -- Aztec Lobby?
		[0x23C] = "Stone Panel (Rotating)", -- Aztec Lobby
		[0x23D] = "Wrinkly Door Wheel", -- Fungi Lobby
		[0x23E] = "Wooden Door", -- Fungi Lobby
		[0x23F] = "Wooden Panel", -- Fungi? Lobby?
		[0x240] = "Electricity Shields?", -- One for each kong, roughly in shape of Wrinkly Door wheel -- TODO: Unused?
		--[0x241] = "Unknown", -- Internal name is "torches"
		[0x242] = "Boulder Pad (Red)", -- Caves
		[0x243] = "Candelabra", -- Castle?
		[0x244] = "Banana Peel", -- Slippery
		[0x245] = "Skull+Candle", -- Castle?
		[0x246] = "Metal Box",
		[0x247] = "1 Switch",
		[0x248] = "2 Switch",
		[0x249] = "3 Switch",
		[0x24A] = "4 Switch",
		[0x24B] = "Metal Grate (Breakable?)",
		[0x24C] = "Pound The X Platform", -- DK Isles
		[0x24D] = "Wooden Door", -- Castle Shed
		[0x24E] = "Chandelier", -- Castle
		[0x24F] = "Bone Door", -- Castle
		[0x250] = "Metal Bars", -- Galleon
		[0x251] = "4 Door (5DS)",
		[0x252] = "5 Door (5DS)",
		[0x253] = "Door (Llama Temple)", -- Aztec
		[0x254] = "Coffin Door", -- Breakable?
		[0x255] = "Metal Bars",
		[0x256] = "Metal Grate", -- Galleon
		[0x257] = "-",
		[0x258] = "-",
		[0x259] = "-",
		[0x25A] = "-",
		[0x25B] = "-",
		[0x25C] = "-",
		[0x25D] = "-",
		[0x25E] = "-",
		[0x25F] = "-",
		[0x260] = "-",
		[0x261] = "-",
		[0x262] = "-",
		[0x263] = "-",
		[0x264] = "-",
		[0x265] = "-",
		[0x266] = "Boulder", -- DK Isles, covering cannon to Fungi
		[0x267] = "Boulder", -- DK Isles
		[0x268] = "K. Rool Ship Jaw Bottom", -- DK Isles
		[0x269] = "Blast-O-Matic Cover?", -- DK Isles
		[0x26A] = "Blast-O-Matic Cover", -- DK Isles
		[0x26B] = "Door", -- DK Isles, covering factory lobby, not solid
		[0x26C] = "Platform", -- DK Isles, up to Factory Lobby
		[0x26D] = "Propeller", -- K. Rool's Ship
		[0x26E] = "K. Rool's Ship", -- DK Isles, Intro Story
		[0x26F] = "Mad Jack Platform (White)",
		[0x270] = "Mad Jack Platform (White)", -- Factory
		[0x271] = "Mad Jack Platform (Blue)", -- Factory
		[0x272] = "Mad Jack Platform (Blue)", -- Factory
		[0x273] = "Skull Gate (Minecart)", -- 2D
		[0x274] = "Dogadon Arena Outer",
		[0x275] = "Boxing Ring Corner (Red)",
		[0x276] = "Boxing Ring Corner (Green)",
		[0x277] = "Boxing Ring Corner (Blue)",
		[0x278] = "Boxing Ring Corner (Yellow)",
		[0x279] = "Lightning Rod", -- Pufftoss Fight, DK Isles for some reason
		[0x27A] = "Green Electricity", -- Helm? Chunky BoM stuff?
		[0x27B] = "Blast-O-Matic",
		[0x27C] = "Target", -- K. Rool Fight (Diddy Phase)
		[0x27D] = "Spotlight", -- K. Rool Fight
		[0x27E] = "-",
		[0x27F] = "Vine", -- Unused?
		[0x280] = "Director's Chair", -- Blooper Ending
		[0x281] = "Spotlight", -- Blooper Ending
		[0x282] = "Spotlight", -- Blooper Ending
		[0x283] = "Boom Microphone", -- Blooper Ending
		[0x284] = "Auditions Sign", -- Blooper Ending
		[0x285] = "Banana Hoard",
		[0x286] = "Boulder", -- DK Isles, covering Caves lobby
		[0x287] = "Boulder", -- DK Isles, covering Japes lobby
		[0x288] = "Rareware GB",
		[0x289] = "-",
		[0x28A] = "-",
		[0x28B] = "-",
		[0x28C] = "-",
		[0x28D] = "Platform (Crystal Caves Minigame)", -- Tomato game
		[0x28E] = "King Kut Out Arm (Bloopers)",
		[0x28F] = "Rareware Coin", -- Not collectable?
		[0x290] = "Golden Banana", -- Not collectable?
		[0x291] = "-",
		[0x292] = "-",
		[0x293] = "-",
		[0x294] = "-",
		[0x295] = "-",
		[0x296] = "-",
		[0x297] = "-",
		[0x298] = "-",
		[0x299] = "-",
		[0x29A] = "-",
		[0x29B] = "-",
		[0x29C] = "-",
		[0x29D] = "-",
		[0x29E] = "-",
		[0x29F] = "-",
		[0x2A0] = "-",
		[0x2A1] = "-",
		[0x2A2] = "Rock", -- DK Isles, Covering Castle Cannon?
		[0x2A3] = "K. Rool's Ship", -- DK Isles, Entrance to final fight
		[0x2A4] = "-",
		[0x2A5] = "-",
		[0x2A6] = "-",
		[0x2A7] = "Wooden Door", -- BFI Guarding Rareware GB
		[0x2A8] = "-",
		[0x2A9] = "-",
		[0x2AA] = "-",
		[0x2AB] = "Nothing?",
		[0x2AC] = "Troff'n'Scoff Portal",
		[0x2AD] = "Level Entry/Exit",
		[0x2AE] = "K. Lumsy Key Indicator?",
		[0x2AF] = "-",
		[0x2B0] = "-",
		[0x2B1] = "-",
		[0x2B2] = "-",
		[0x2B3] = "-",
		[0x2B4] = "Red Bell", -- 2D, Minecart
		[0x2B5] = "Green Bell", -- 2D, Minecart
		[0x2B6] = "Race Checkpoint",
		-- Tested up to 0x2CF inclusive, all crashes so far
	},
	-- 0x00 000000 Seen in game, but currently unknown
	-- 0x01 000001 GB - Chunky can collect
	-- 0x02 000010 GB - Diddy can collect
	-- 0x04 000100 GB - Tiny can collect
	-- 0x08 001000 GB - DK can collect
	-- 0x10 010000 GB - Lanky can collect
	-- 0x1F 011111 GB - Anyone can collect?
	-- 0x20 100000 Seen in game, but currently unknown
	-- 0x21 100001 GB - Chunky can collect
	-- 0x22 100010 GB - Diddy can collect
	-- 0x24 100100 GB - Tiny can collect
	-- 0x28 101000 GB - DK can collect
	-- 0x30 110000 GB - Lanky can collect
	-- 0x3F 111111 GB - Anyone can collect?
	collectable_state = 0x8C, -- byte (bitfield)
};

local function getObjectModel2Array()
	if Game.version ~= 4 then
		return dereferencePointer(Game.Memory.obj_model2_array_pointer);
	end
	return Game.Memory.obj_model2_array_pointer; -- Kiosk doesn't move
end

local function getObjectModel2ArraySize()
	if Game.version == 4 then
		return 430; -- TODO: Find maximum size for Kiosk object model 2 array
	end
	local objModel2Array = getObjectModel2Array();
	if isRDRAM(objModel2Array) then
		return mainmemory.read_u32_be(objModel2Array + heap.object_size) / obj_model2_slot_size;
	end
	return 0;
end

local function getInternalName(objectModel2Base)
	local behaviorTypePointer = dereferencePointer(objectModel2Base + obj_model2.behavior_type_pointer);
	if isRDRAM(behaviorTypePointer) then
		return readNullTerminatedString(behaviorTypePointer + 0x0C);
	end
	return "unknown";
end

local function getScriptName(objectModel2Base)
	local model2ID = mainmemory.read_u16_be(objectModel2Base + obj_model2.object_type);
	return obj_model2.object_types[model2ID] or "unknown "..toHexString(model2ID);
end

local function populateObjectModel2Pointers()
	object_pointers = {};
	local objModel2Array = getObjectModel2Array();
	if isRDRAM(objModel2Array) then
		local numSlots = mainmemory.read_u32_be(Game.Memory.obj_model2_array_count);

		if object_model2_filter == nil then
			-- Fill and sort pointer list
			for i = 1, numSlots do
				table.insert(object_pointers, objModel2Array + (i - 1) * obj_model2_slot_size);
			end
		else
			-- Fill and sort pointer list
			for i = 1, numSlots do
				local base = objModel2Array + (i - 1) * obj_model2_slot_size;
				if string.contains(getScriptName(base), object_model2_filter) then
					table.insert(object_pointers, base);
				end
			end
		end
	end
end

local function encirclePlayerObjectModel2()
	if encircle_enabled and string.contains(grab_script_mode, "Model 2") then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			local xPos = mainmemory.readfloat(playerObject + obj_model1.x_pos, true);
			local yPos = mainmemory.readfloat(playerObject + obj_model1.y_pos, true);
			local zPos = mainmemory.readfloat(playerObject + obj_model1.z_pos, true);

			-- Iterate and set position
			local x, z, modelPointer;
			for i = 1, #object_pointers do
				x = xPos + math.cos(math.pi * 2 * i / #object_pointers) * radius;
				z = zPos + math.sin(math.pi * 2 * i / #object_pointers) * radius;

				-- Set hitbox X, Y, Z
				mainmemory.writefloat(object_pointers[i] + obj_model2.x_pos, x, true);
				mainmemory.writefloat(object_pointers[i] + obj_model2.y_pos, yPos, true);
				mainmemory.writefloat(object_pointers[i] + obj_model2.z_pos, z, true);

				-- Set model X, Y, Z
				modelPointer = dereferencePointer(object_pointers[i] + obj_model2.model_pointer);
				if isRDRAM(modelPointer) then
					mainmemory.writefloat(modelPointer + obj_model2.model.x_pos, x, true);
					mainmemory.writefloat(modelPointer + obj_model2.model.y_pos, yPos, true);
					mainmemory.writefloat(modelPointer + obj_model2.model.z_pos, z, true);
				end
			end
		end
	end
end

local function setObjectModel2Position(pointer, x, y, z)
	if isRDRAM(pointer) then
		mainmemory.writefloat(pointer + obj_model2.x_pos, x, true);
		mainmemory.writefloat(pointer + obj_model2.y_pos, y, true);
		mainmemory.writefloat(pointer + obj_model2.z_pos, z, true);
		local modelPointer = dereferencePointer(pointer + obj_model2.model_pointer);
		if isRDRAM(modelPointer) then
			mainmemory.writefloat(modelPointer + obj_model2.model.x_pos, x, true);
			mainmemory.writefloat(modelPointer + obj_model2.model.y_pos, y, true);
			mainmemory.writefloat(modelPointer + obj_model2.model.z_pos, z, true);
		end
	end
end

function offsetObjectModel2(x, y, z)
	-- Iterate and set position
	local behaviorType, modelPointer, currentX, currentY, currentZ;
	for i = 1, #object_pointers do
		behaviorType = getInternalName(object_pointers[i]);
		if behaviorType == "pickups" then
			-- Read hitbox X, Y, Z
			currentX = mainmemory.readfloat(object_pointers[i] + obj_model2.x_pos, true);
			currentY = mainmemory.readfloat(object_pointers[i] + obj_model2.y_pos, true);
			currentZ = mainmemory.readfloat(object_pointers[i] + obj_model2.z_pos, true);

			-- Write hitbox X, Y, Z
			mainmemory.writefloat(object_pointers[i] + obj_model2.x_pos, currentX + x, true);
			mainmemory.writefloat(object_pointers[i] + obj_model2.y_pos, currentY + y, true);
			mainmemory.writefloat(object_pointers[i] + obj_model2.z_pos, currentZ + z, true);

			-- Check for model
			modelPointer = dereferencePointer(object_pointers[i] + obj_model2.model_pointer);
			if isRDRAM(modelPointer) then
				-- Read model X, Y, Z
				currentX = mainmemory.readfloat(modelPointer + obj_model2.model.x_pos, true);
				currentY = mainmemory.readfloat(modelPointer + obj_model2.model.y_pos, true);
				currentZ = mainmemory.readfloat(modelPointer + obj_model2.model.z_pos, true);

				-- Write model X, Y, Z
				mainmemory.writefloat(modelPointer + obj_model2.model.x_pos, currentX + x, true);
				mainmemory.writefloat(modelPointer + obj_model2.model.y_pos, currentY + y, true);
				mainmemory.writefloat(modelPointer + obj_model2.model.z_pos, currentZ + z, true);
			end
		end
	end
end

local function getSpawnSnagState(pointer)
	local behaviorPointer = dereferencePointer(pointer + obj_model2.behavior_pointer);
	if isRDRAM(behaviorPointer) then
		local spawnSnagState = mainmemory.readbyte(behaviorPointer + 0x60);
		if spawnSnagState == 1 then
			return "Uncollectable";
		elseif spawnSnagState == 0 then
			return "Collectable";
		end
	end
	return 0;
end

local function getSpawnSnagCheck(pointer)
	local behaviorPointer = dereferencePointer(pointer + obj_model2.behavior_pointer);
	if isRDRAM(behaviorPointer) then
		local spawnSnagCheck = mainmemory.readbyte(behaviorPointer + 0x54);
		if spawnSnagCheck == 2 then
			return "Done";
		elseif spawnSnagCheck == 0 then
			return "Not Done";
		end
	end
	return 0;
end

local function getSnagResetTrigger(pointer)
	local behaviorPointer = dereferencePointer(pointer + obj_model2.behavior_pointer);
	if isRDRAM(behaviorPointer) then
		local snagResetTrigger = mainmemory.readbyte(behaviorPointer + 0x9B);
		local snagCheck = getSpawnSnagCheck(pointer);
		if snagCheck == "Done" then
			if snagResetTrigger == 2 then
				return "Every LZ";
			elseif snagResetTrigger == 0 then
				return "Level Re-entry";
			else
				return "Unknown";
			end
		else
			return "Unknown";
		end
	end
	return 0;
end

local function getGrabKong(pointer)
	if isRDRAM(pointer) then
		local grabKongByte = mainmemory.readbyte(pointer + 0x8C) % 32;
		if grabKongByte == 16 then
			return "Lanky";
		elseif grabKongByte == 8 then
			return "DK";
		elseif grabKongByte == 4 then
			return "Tiny";
		elseif grabKongByte == 2 then
			return "Diddy";
		elseif grabKongByte == 1 then
			return "Chunky";
		elseif grabKongByte == 0 then
			return "Any Kong";
		else
			return "No Kong";
		end
	end
	return 0;
end

function forceSnagState(pointer, value)
	local behaviorPointer = dereferencePointer(pointer + obj_model2.behavior_pointer);
	if isRDRAM(behaviorPointer) then
		if value == 1 then
			mainmemory.writebyte(behaviorPointer + 0x60, 1);
			mainmemory.writebyte(behaviorPointer + 0x54, 0);
		else
			mainmemory.writebyte(behaviorPointer + 0x60, 0);
			mainmemory.writebyte(behaviorPointer + 0x54, 2);
		end
	end
end

function resetSnagState(pointer)
	local behaviorPointer = dereferencePointer(pointer + obj_model2.behavior_pointer);
	if isRDRAM(behaviorPointer) then
		mainmemory.writebyte(behaviorPointer + 0x54, 0);
		mainmemory.writebyte(behaviorPointer + 0x60, 0);
	end
end

local function getExamineDataModelTwo(pointer)
	local examine_data = {};

	if not isRDRAM(pointer) then
		return examine_data;
	end

	local modelPointer = dereferencePointer(pointer + obj_model2.model_pointer);
	local hasModel = isRDRAM(modelPointer);

	local xPos = mainmemory.readfloat(pointer + obj_model2.x_pos, true);
	local yPos = mainmemory.readfloat(pointer + obj_model2.y_pos, true);
	local zPos = mainmemory.readfloat(pointer + obj_model2.z_pos, true);
	local hasPosition = xPos ~= 0 or yPos ~= 0 or zPos ~= 0 or hasModel;

	table.insert(examine_data, { "Slot base", toHexString(pointer, 6) });

	local behaviorTypePointer = dereferencePointer(pointer + obj_model2.behavior_type_pointer);
	local behaviorType = getScriptName(pointer);
	if isRDRAM(behaviorTypePointer) then
		table.insert(examine_data, { "Behavior Type", behaviorType });
		table.insert(examine_data, { "Behavior Index", toHexString(mainmemory.read_u16_be(pointer + obj_model2.object_type))});
		table.insert(examine_data, { "Internal Name", getInternalName(pointer) });
		table.insert(examine_data, { "Behavior Type Pointer", toHexString(behaviorTypePointer, 6) });
	end
	local behaviorPointer = dereferencePointer(pointer + obj_model2.behavior_pointer);
	if isRDRAM(behaviorPointer) then
		table.insert(examine_data, { "Behavior Pointer", toHexString(behaviorPointer, 6) });
	end

	if Game.version ~= 4 then
		local currentMap = Game.getMap();
		local behaviorID = mainmemory.read_u16_be(pointer + 0x8A);
		for i = 0, 0x70 do -- 0xA5 for extra cs etc flags
			local base = Game.Memory.flag_mapping + i * 8;
			local map = mainmemory.readbyte(base + 0);
			if map == currentMap then
				local id = mainmemory.read_u16_be(base + 2);
				if id == behaviorID then
					local flagIndex = mainmemory.read_u16_be(base + 4);
					local flagByte = math.floor(flagIndex / 8);
					local flagBit = flagIndex % 8;
					table.insert(examine_data, { "Associated Flag", Game.getFlagName(flagByte, flagBit) });
					break;
				end
			end
		end
	end

	table.insert(examine_data, { "Separator", 1 });

	if behaviorType == "pads" then
		table.insert(examine_data, { "Warp Pad Texture", toHexString(mainmemory.read_u32_be(behaviorTypePointer + 0x374), 8) }); -- TODO: figure out the format for behavior scripts
		table.insert(examine_data, { "Separator", 1 });
	end

	if behaviorType == "gunswitches" then
		table.insert(examine_data, { "Gunswitch Texture", toHexString(mainmemory.read_u32_be(behaviorTypePointer + 0x22C), 8) }); -- TODO: figure out the format for behavior scripts
		table.insert(examine_data, { "Separator", 1 });
	end

	if getSpawnSnagState(pointer) ~= 0 then
		table.insert(examine_data, { "Snag State", getSpawnSnagState(pointer)});
	end

	if getSpawnSnagCheck(pointer) ~= 0 then
		table.insert(examine_data, { "Snag Check", getSpawnSnagCheck(pointer)});
	end

	if getSnagResetTrigger(pointer) ~= 0 then
		table.insert(examine_data, { "Snag Reset Trigger", getSnagResetTrigger(pointer)});
	end

	if getGrabKong(pointer) ~= 0 and mainmemory.read_u16_be(pointer + obj_model2.object_type) == 116 then
		table.insert(examine_data, { "Kong Required", getGrabKong(pointer)});
	end

	if getSpawnSnagState(pointer) ~= 0 or getSpawnSnagCheck(pointer) ~= 0 or mainmemory.read_u16_be(pointer + obj_model2.object_type) == 116 then
		table.insert(examine_data, { "Separator", 1 });
	end

	if hasPosition then
		table.insert(examine_data, { "Hitbox X", xPos });
		table.insert(examine_data, { "Hitbox Y", yPos });
		table.insert(examine_data, { "Hitbox Z", zPos });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Hitbox Scale", mainmemory.readfloat(pointer + obj_model2.hitbox_scale, true) });
		table.insert(examine_data, { "Separator", 1 });
	end

	table.insert(examine_data, { "Unknown Counter", mainmemory.read_u16_be(pointer + obj_model2.unknown_counter) });
	table.insert(examine_data, { "GB Interaction Bitfield", toBinaryString(mainmemory.readbyte(pointer + obj_model2.collectable_state)) });

	if hasModel then
		table.insert(examine_data, { "Model Base", toHexString(modelPointer, 6) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Model X", mainmemory.readfloat(modelPointer + obj_model2.model.x_pos, true) });
		table.insert(examine_data, { "Model Y", mainmemory.readfloat(modelPointer + obj_model2.model.y_pos, true) });
		table.insert(examine_data, { "Model Z", mainmemory.readfloat(modelPointer + obj_model2.model.z_pos, true) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Model Rot X", mainmemory.readfloat(modelPointer + obj_model2.model.rot_x, true) });
		table.insert(examine_data, { "Model Rot Y", mainmemory.readfloat(modelPointer + obj_model2.model.rot_y, true) });
		table.insert(examine_data, { "Model Rot Z", mainmemory.readfloat(modelPointer + obj_model2.model.rot_z, true) });
		table.insert(examine_data, { "Separator", 1 });

		table.insert(examine_data, { "Model Scale", mainmemory.readfloat(modelPointer + obj_model2.model.scale, true) });
		table.insert(examine_data, { "Separator", 1 });
	end

	return examine_data;
end

local spawnerAttributes = {
	enemy_value = 0x0, -- u8
	y_rot = 0x2, -- u16
	x_pos = 0x4, -- s16
	y_pos = 0x6, -- s16
	z_pos = 0x8, -- s16
	cs_model = 0xA, -- u8
	max_idle_speed = 0xC, -- u8
	max_aggro_speed = 0xD, -- u8
	scale = 0xF, -- u8
	aggro = 0x10, -- u8
	spawn_trigger = 0x13, -- u8
	tied_actor = 0x18, -- u32
	movement_box_pointer = 0x1C, -- u32
	movement_box = {
		x_pos_0 = 0x0, -- s16
		z_pos_0 = 0x2, -- s16
		x_pos_1 = 0x4, -- s16
		z_pos_1 = 0x6, -- s16
		aggression_box_pointer = 0xC, -- u32
		aggression_box = {
			coords_0 = 0x0,
			coords_1 = 0x6,
			coords_2 = 0xC,
			coords_3 = 0x12,
			coords_4 = 0x18,
		},
	},
	unknown_pointer = 0x20, -- u32
	respawn_timer = 0x24, -- s16
	animation_speed = 0x34, -- float
	acceleration = 0x34, -- float, TODO: Check this
	chunk = 0x40, -- s16
	spawn_state = 0x42, -- u8
	alternative_enemy_spawn = 0x44, -- u8
};

local spawnerStates = {
	[0] = "Inactive",
	[2] = "Ready to Spawn",
	[5] = "Spawned",
	[6] = "Deloaded",
	[7] = "Respawn Pending",
};

local function getSpawnerStateName(pointer)
	stateValue = mainmemory.readbyte(pointer + spawnerAttributes.spawn_state);
	if spawnerStates[stateValue] ~= nil then
		return spawnerStates[stateValue];
	end
	return toHexString(stateValue);
end

function getExamineDataArcade(pointer)
	local examine_data = {};

	local xPos = mainmemory.readfloat(pointer + arcade_object.x_position, true);
	local yPos = mainmemory.readfloat(pointer + arcade_object.y_position, true);
	local xVel = mainmemory.readfloat(pointer + arcade_object.x_velocity, true);
	local yVel = mainmemory.readfloat(pointer + arcade_object.y_velocity, true);

	table.insert(examine_data, { "Slot base", toHexString(pointer, 6) });
	table.insert(examine_data, { "Object Name", getArcadeObjectNameOSD(mainmemory.readbyte(pointer + arcade_object.object_type)) });
	table.insert(examine_data, { "Object Type", mainmemory.readbyte(pointer + arcade_object.object_type) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "X", xPos });
	table.insert(examine_data, { "Y", yPos });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "X Velocity", xVel });
	table.insert(examine_data, { "Y Velocity", yVel });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Object Movement", mainmemory.readbyte(pointer + arcade_object.movement) });
	table.insert(examine_data, { "Object Size", mainmemory.readbyte(pointer + arcade_object.size) });

	return examine_data;
end

function getExamineDataSpawners(pointer)
	local examine_data = {};

	local enemyType = mainmemory.readbyte(pointer + spawnerAttributes.enemy_value);
	local enemyName = getBehaviorNameFromEnemyIndex(enemyType);
	local alt_enemyType = mainmemory.readbyte(pointer + spawnerAttributes.alternative_enemy_spawn);
	local alt_enemyName = getBehaviorNameFromEnemyIndex(alt_enemyType);
	local tiedActor = dereferencePointer(pointer + spawnerAttributes.tied_actor);
	local movement_box = dereferencePointer(pointer + spawnerAttributes.movement_box_pointer);
	local aggression_box = dereferencePointer(movement_box + spawnerAttributes.movement_box.aggression_box_pointer);
	local object_spawner_state = getSpawnerStateName(pointer);
	local unknown_pointer = dereferencePointer(pointer + spawnerAttributes.unknown_pointer);

	table.insert(examine_data, { "Slot base", toHexString(pointer, 6) });
	table.insert(examine_data, { "Object Name", enemyName });
	table.insert(examine_data, { "Object Type", toHexString(enemyType) });
	if enemyType == 0x50 then
		local cutsceneModelIndex = mainmemory.readbyte(pointer + spawnerAttributes.cs_model);
		table.insert(examine_data, { "Cutscene Model", getModelNameFromCutsceneIndex(cutsceneModelIndex) });
	end
	table.insert(examine_data, { "Separator", 1 });

	if enemyType ~= alt_enemyType then
		table.insert(examine_data, { "Alt. Spawn Object Name", alt_enemyName });
		table.insert(examine_data, { "Alt. Spawn Object Type", toHexString(alt_enemyType) });
		table.insert(examine_data, { "Separator", 1 });
	end

	table.insert(examine_data, { "X", mainmemory.read_s16_be(pointer + spawnerAttributes.x_pos) });
	table.insert(examine_data, { "Y", mainmemory.read_s16_be(pointer + spawnerAttributes.y_pos) });
	table.insert(examine_data, { "Z", mainmemory.read_s16_be(pointer + spawnerAttributes.z_pos) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Y Rotation", mainmemory.read_s16_be(pointer + spawnerAttributes.y_rot) });
	table.insert(examine_data, { "Scale", mainmemory.readbyte(pointer + spawnerAttributes.scale) });
	table.insert(examine_data, { "Max Idle Speed", mainmemory.readbyte(pointer + spawnerAttributes.max_idle_speed) });
	table.insert(examine_data, { "Max Aggro Speed", mainmemory.readbyte(pointer + spawnerAttributes.max_aggro_speed) });
	table.insert(examine_data, { "Animation Speed", mainmemory.readfloat(pointer + spawnerAttributes.animation_speed, true) });
	table.insert(examine_data, { "Separator", 1 });

	table.insert(examine_data, { "Aggressive", mainmemory.readbyte(pointer + spawnerAttributes.aggro) });
	table.insert(examine_data, { "Spawn Trigger", mainmemory.readbyte(pointer + spawnerAttributes.spawn_trigger) });
	table.insert(examine_data, { "Spawner State", object_spawner_state });
	table.insert(examine_data, { "Respawn Timer", mainmemory.read_s16_be(pointer + spawnerAttributes.respawn_timer) });
	table.insert(examine_data, { "Chunk", mainmemory.read_s16_be(pointer + spawnerAttributes.chunk) });
	table.insert(examine_data, { "Separator", 1 });

	if isRDRAM(tiedActor) then
		local tiedActorNameValue = mainmemory.read_u16_be(tiedActor + obj_model1.actor_type);
		table.insert(examine_data, { "Tied Actor", toHexString(tiedActor, 6) });
		table.insert(examine_data, { "Tied Actor Name", getActorNameFromBehavior(tiedActorNameValue) });
		table.insert(examine_data, { "Separator", 1 });
	end

	if isRDRAM(unknown_pointer) then
		table.insert(examine_data, { "Unknown Pointer", toHexString(unknown_pointer, 6) });
	end

	if isRDRAM(movement_box) then
		local movement_box_x_low = mainmemory.read_s16_be(movement_box + spawnerAttributes.movement_box.x_pos_0);
		local movement_box_x_high = mainmemory.read_s16_be(movement_box + spawnerAttributes.movement_box.x_pos_1);
		local movement_box_x = movement_box_x_low..", "..movement_box_x_high;
		local movement_box_z_low = mainmemory.read_s16_be(movement_box + spawnerAttributes.movement_box.z_pos_0);
		local movement_box_z_high = mainmemory.read_s16_be(movement_box + spawnerAttributes.movement_box.z_pos_1);
		local movement_box_z = movement_box_z_low..", "..movement_box_z_high;
		table.insert(examine_data, { "Movement Box Pointer", toHexString(movement_box, 6) });
		table.insert(examine_data, { "Movement Box X", movement_box_x });
		table.insert(examine_data, { "Movement Box Z", movement_box_z });
		table.insert(examine_data, { "Separator", 1 });
	end

	if isRDRAM(aggression_box) then
		local coords_0_string = mainmemory.read_s16_be(aggression_box + spawnerAttributes.movement_box.aggression_box.coords_0);
		local coords_1_string = mainmemory.read_s16_be(aggression_box + spawnerAttributes.movement_box.aggression_box.coords_1);
		local coords_2_string = mainmemory.read_s16_be(aggression_box + spawnerAttributes.movement_box.aggression_box.coords_2);
		local coords_3_string = mainmemory.read_s16_be(aggression_box + spawnerAttributes.movement_box.aggression_box.coords_3);
		local coords_4_string = mainmemory.read_s16_be(aggression_box + spawnerAttributes.movement_box.aggression_box.coords_4);
		for i = 1, 2 do
			coords_0_string = coords_0_string..","..mainmemory.read_s16_be(aggression_box + spawnerAttributes.movement_box.aggression_box.coords_0 + (2 * i));
			coords_1_string = coords_1_string..","..mainmemory.read_s16_be(aggression_box + spawnerAttributes.movement_box.aggression_box.coords_1 + (2 * i));
			coords_2_string = coords_2_string..","..mainmemory.read_s16_be(aggression_box + spawnerAttributes.movement_box.aggression_box.coords_2 + (2 * i));
			coords_3_string = coords_3_string..","..mainmemory.read_s16_be(aggression_box + spawnerAttributes.movement_box.aggression_box.coords_3 + (2 * i));
			coords_4_string = coords_4_string..","..mainmemory.read_s16_be(aggression_box + spawnerAttributes.movement_box.aggression_box.coords_4 + (2 * i));
		end
		table.insert(examine_data, { "Aggression Box Pointer", toHexString(aggression_box, 6) });
		table.insert(examine_data, { "Co-ords Set 1", coords_0_string });
		table.insert(examine_data, { "Co-ords Set 2", coords_1_string });
		table.insert(examine_data, { "Co-ords Set 3", coords_2_string });
		table.insert(examine_data, { "Co-ords Set 4", coords_3_string });
		table.insert(examine_data, { "Co-ords Set 5", coords_4_string });
		table.insert(examine_data, { "Separator", 1 });
	end

	return examine_data;
end
--------------------------------
-- Loading Zone Documentation --
--------------------------------

function Game.getLoadingZoneArray()
	return dereferencePointer(Game.Memory.loading_zone_array);
end

local loading_zone_size = 0x3A;
local loading_zone_fields = {
	x_position = 0x00, -- s16_be
	y_position = 0x02, -- s16_be
	z_position = 0x04, -- s16_be
	x_size = 0x06, -- u16_be
	y_size = 0x08, -- u16_be
	z_size = 0x0A, -- u16_be
	object_type = 0x10, -- u16_be
	object_types = {
		[0x05] = "Cutscene Trigger",
		[0x09] = "Loading Zone",
		[0x0A] = "Cutscene Trigger",
		[0x0C] = "Loading Zone + Objects", -- Alows objects through
		[0x0D] = "Loading Zone",
		-- [0x0F] = "Unknown", -- Autowalk trigger?
		[0x10] = "Loading Zone",
		[0x11] = "Loading Zone", -- Snide's
		-- [0x13] = "Unknown - Caves Lobby", -- Behind ice walls
		[0x14] = "Boss Loading Zone", -- Takes you to the boss of that level
		[0x15] = "Cutscene Trigger",
		[0x17] = "Cutscene Trigger",
		-- [0x19] = "Trigger", -- Seal Race
		[0x20] = "Cutscene Trigger",
		-- [0x24] = "Unknown", -- Cannon Trigger?
	},
	destination_map = 0x12, -- u16_be, index of Game.maps
	destination_exit = 0x14, -- u16_be
	fade_type = 0x16, -- u16_be?
	cutscene_is_tied = 0x1A, -- u16_be
	cutscene_activated = 0x1C, -- u16_be
	not_in_zone = 0x38, -- Byte
	active = 0x39, -- Byte
};

local function getExamineDataLoadingZone(base)
	local data = {};
	if isRDRAM(base) then
		local _type = mainmemory.read_u16_be(base + loading_zone_fields.object_type);
		if loading_zone_fields.object_types[_type] ~= nil then
			_type = loading_zone_fields.object_types[_type].." ("..toHexString(_type)..")";
		else
			_type = toHexString(_type);
		end
		table.insert(data, {"Address", toHexString(base)});
		table.insert(data, {"Type", _type});
		table.insert(data, {"Separator", 1});

		if string.contains(_type, "Cutscene Trigger") then
			table.insert(data, {"Cutscene Index", mainmemory.read_u16_be(base + loading_zone_fields.destination_map)});
			table.insert(data, {"Separator", 1});
		end

		if string.contains(_type, "Loading Zone") and not string.contains(_type, "0x14") then
			local destinationMap = mainmemory.read_u16_be(base + loading_zone_fields.destination_map);
			local cutscene_is_tied_byte = mainmemory.read_u16_be(base + loading_zone_fields.cutscene_is_tied);
			if Game.maps[destinationMap + 1] ~= nil then
				destinationMap = Game.maps[destinationMap + 1];
			else
				destinationMap = "Unknown Map "..toHexString(destinationMap);
			end
			table.insert(data, {"Destination Map", destinationMap});
			table.insert(data, {"Destination Exit", mainmemory.read_u16_be(base + loading_zone_fields.destination_exit)});
			table.insert(data, {"Fade", mainmemory.read_u16_be(base + loading_zone_fields.fade_type)});
			table.insert(data, {"Active", mainmemory.readbyte(base + loading_zone_fields.active)});
			table.insert(data, {"In Zone", 1 - mainmemory.readbyte(base + loading_zone_fields.not_in_zone)});
			if cutscene_is_tied_byte == 0xA then
				table.insert(data, {"Tied Cutscene", mainmemory.read_u16_be(base + loading_zone_fields.cutscene_activated)});
			end
			table.insert(data, {"Separator", 1});
		end

		table.insert(data, {"X Position", mainmemory.read_s16_be(base + loading_zone_fields.x_position)});
		table.insert(data, {"Y Position", mainmemory.read_s16_be(base + loading_zone_fields.y_position)});
		table.insert(data, {"Z Position", mainmemory.read_s16_be(base + loading_zone_fields.z_position)});
		table.insert(data, {"Separator", 1});
		table.insert(data, {"Size X", mainmemory.read_u16_be(base + loading_zone_fields.x_size)});
		table.insert(data, {"Size Y", mainmemory.read_u16_be(base + loading_zone_fields.y_size)});
		table.insert(data, {"Size Z", mainmemory.read_u16_be(base + loading_zone_fields.z_size)});
		table.insert(data, {"Separator", 1});
	end
	return data;
end

local function populateLoadingZonePointers()
	object_pointers = {};
	local loadingZoneArray = Game.getLoadingZoneArray();
	if isRDRAM(loadingZoneArray) then
		local arraySize = mainmemory.read_u16_be(Game.Memory.loading_zone_array_size);
		for i = 0, arraySize - 1 do
			table.insert(object_pointers, loadingZoneArray + (i * loading_zone_size));
		end

		-- Clamp index
		object_index = math.min(object_index, math.max(1, #object_pointers));
	end
end

function dumpLoadingZones()
	local loadingZoneArray = Game.getLoadingZoneArray();
	if isRDRAM(loadingZoneArray) then
		local arraySize = mainmemory.read_u16_be(Game.Memory.loading_zone_array_size);
		for i = 0, arraySize do
			local base = loadingZoneArray + (i * loading_zone_size);

			if isRDRAM(base) then
				local _type = mainmemory.read_u16_be(base + loading_zone_fields.object_type);
				if loading_zone_fields.object_types[_type] ~= nil then
					_type = loading_zone_fields.object_types[_type].." ("..toHexString(_type)..")";
				else
					_type = toHexString(_type);
				end

				if string.contains(_type, "Loading Zone") then
					local destinationMap = mainmemory.read_u16_be(base + loading_zone_fields.destination_map);
					if Game.maps[destinationMap + 1] ~= nil then
						destinationMap = Game.maps[destinationMap + 1];
					else
						destinationMap = "Unknown Map "..toHexString(destinationMap);
					end
					local destinationExit = mainmemory.read_u16_be(base + loading_zone_fields.destination_exit);
					local transitionType = mainmemory.read_u16_be(base + loading_zone_fields.fade_type);

					local xPosition = mainmemory.read_s16_be(base + loading_zone_fields.x_position);
					local yPosition = mainmemory.read_s16_be(base + loading_zone_fields.y_position);
					local zPosition = mainmemory.read_s16_be(base + loading_zone_fields.z_position);

					print(Game.maps[map_value + 1]..","..destinationMap..","..destinationExit..","..transitionType..",unknown,"..xPosition..","..yPosition..","..zPosition);
				end
			end
		end
	end
end

function dumpModel2Positions()
	local objModel2Array = getObjectModel2Array();
	if isRDRAM(objModel2Array) then
		local numSlots = mainmemory.read_u32_be(Game.Memory.obj_model2_array_count);
		local scriptName, slotBase;
		local xPos, yPos, zPos;
		-- Fill and sort pointer list
		for i = 0, numSlots - 1 do
			slotBase = objModel2Array + i * obj_model2_slot_size;
			scriptName = getScriptName(slotBase);
			xPos = mainmemory.readfloat(slotBase + obj_model2.x_pos, true);
			yPos = mainmemory.readfloat(slotBase + obj_model2.y_pos, true);
			zPos = mainmemory.readfloat(slotBase + obj_model2.z_pos, true);
			dprint(scriptName.." at "..xPos..", "..yPos..", "..zPos);
		end
		print_deferred();
	end
end

local model1SetupSize = 0x38;
local model1Setup = {
	x_pos = 0x00, -- Float
	y_pos = 0x04, -- Float
	z_pos = 0x08, -- Float
	scale = 0x0C, -- Float
	behavior = 0x32, -- Short, see obj_model1.actor_types table
};

local model2SetupSize = 0x30;
local model2Setup = {
	x_pos = 0x00, -- Float
	y_pos = 0x04, -- Float
	z_pos = 0x08, -- Float
	scale = 0x0C, -- Float
	behavior = 0x28, -- Short, see obj_model2.object_types table
};

function dumpSetup(hideKnown)
	hideKnown = hideKnown or false;
	local setupFile = dereferencePointer(Game.Memory.obj_model2_setup_pointer);
	if isRDRAM(setupFile) then
		dprint("Dumping setup for Object Model 2...");
		local model2Count = mainmemory.read_u32_be(setupFile);
		local model2Base = setupFile + 0x04;
		dprint("Base: "..toHexString(setupFile));
		dprint("Count: "..model2Count);
		dprint();

		for i = 0, model2Count - 1 do
			local entryBase = model2Base + i * model2SetupSize;
			local xPos = mainmemory.readfloat(entryBase + model2Setup.x_pos, true);
			local yPos = mainmemory.readfloat(entryBase + model2Setup.y_pos, true);
			local zPos = mainmemory.readfloat(entryBase + model2Setup.z_pos, true);
			local behavior = mainmemory.read_u16_be(entryBase + model2Setup.behavior);
			local known = false;
			if type(obj_model2.object_types[behavior]) == 'string' then
				known = true;
				behavior = obj_model2.object_types[behavior];
			else
				behavior = toHexString(behavior);
			end
			if not (known and hideKnown) then
				dprint(toHexString(entryBase)..": "..behavior.." at "..round(xPos)..", "..round(yPos)..", "..round(zPos));
			end
		end

		-- TODO: What to heck is this data used for?
		-- It's a bunch of floats that get loaded in to model 2 behaviors as far as I can tell
		local mysteryModelSize = 0x24;
		local mysteryModelBase = model2Base + model2Count * model2SetupSize;
		local mysteryModelCount = mainmemory.read_u32_be(mysteryModelBase);
		dprint();
		dprint("Dumping setup for 'mystery model'...");
		dprint("Base: "..toHexString(mysteryModelBase));
		dprint("Count: "..mysteryModelCount);

		dprint();
		dprint("Dumping setup for Object Model 1...");
		local model1Base = mysteryModelBase + 0x04 + mysteryModelCount * mysteryModelSize;
		local model1Count = mainmemory.read_u32_be(model1Base);
		dprint("Base: "..toHexString(model1Base));
		dprint("Count: "..model1Count);
		dprint();

		for i = 0, model1Count - 1 do
			local entryBase = model1Base + 0x04 + i * model1SetupSize;
			local xPos = mainmemory.readfloat(entryBase + model1Setup.x_pos, true);
			local yPos = mainmemory.readfloat(entryBase + model1Setup.y_pos, true);
			local zPos = mainmemory.readfloat(entryBase + model1Setup.z_pos, true);
			local behavior = (mainmemory.read_u16_be(entryBase + model1Setup.behavior) + 0x10) % 0x10000;
			local known = false;
			if type(obj_model1.actor_types[behavior]) == 'string' then
				known = true;
				behavior = obj_model1.actor_types[behavior];
			else
				behavior = toHexString(behavior);
			end
			if not (known and hideKnown) then
				dprint(toHexString(entryBase)..": "..behavior.." at "..round(xPos)..", "..round(yPos)..", "..round(zPos));
			end
		end
		print_deferred();
	else
		print("Couldn't find setup file in RDRAM :(");
	end
end

----------------------------
-- Dynamic Water Surfaces --
----------------------------

-- Indexed by version, much like Game.Memory.address tables
-- Squished into a single address in Game.detectVersion()
local dynamicWaterSurface = {
	timer_1 = {0x30, 0x30, 0x30, 0x24},
	timer_2 = {0x34, 0x34, 0x34, 0x28},
	timer_3 = {0x38, 0x38, 0x38, 0x2C},
	timer_4 = {0x3C, 0x3C, 0x3C, 0x30},
	next_surface_pointer = {0x50, 0x50, 0x50, 0x44},
};

function dumpWaterSurfaces()
	local waterSurface = dereferencePointer(Game.Memory.water_surface_list);
	if isRDRAM(waterSurface) then
		while isRDRAM(waterSurface) do
			local t1Str = mainmemory.read_u32_be(waterSurface + dynamicWaterSurface.timer_1)..", ";
			local t2Str = mainmemory.read_u32_be(waterSurface + dynamicWaterSurface.timer_2)..", ";
			local t3Str = mainmemory.read_u32_be(waterSurface + dynamicWaterSurface.timer_3)..", ";
			local t4Str = mainmemory.read_u32_be(waterSurface + dynamicWaterSurface.timer_4);
			print(toHexString(waterSurface).." Timers: {"..t1Str..t2Str..t3Str..t4Str.."}");
			waterSurface = dereferencePointer(waterSurface + dynamicWaterSurface.next_surface_pointer);
		end
	else
		print("There is no dynamic water currently loaded.");
	end
end

local function setWaterSurfaceTimers(value)
	local waterSurface = dereferencePointer(Game.Memory.water_surface_list);
	while isRDRAM(waterSurface) do
		mainmemory.write_u32_be(waterSurface + dynamicWaterSurface.timer_1, value);
		mainmemory.write_u32_be(waterSurface + dynamicWaterSurface.timer_2, value);
		mainmemory.write_u32_be(waterSurface + dynamicWaterSurface.timer_3, value);
		mainmemory.write_u32_be(waterSurface + dynamicWaterSurface.timer_4, value);
		waterSurface = dereferencePointer(waterSurface + dynamicWaterSurface.next_surface_pointer);
	end
end

--[[
surfaceTimerHack = 0;
surfaceTimerHackInterval = 100;

function Game.increaseSurfaceTimerHack()
	surfaceTimerHack = surfaceTimerHack + surfaceTimerHackInterval;
end

function Game.decreaseSurfaceTimerHack()
	surfaceTimerHack = surfaceTimerHack - surfaceTimerHackInterval;
end

ScriptHawk.bindKeyFrame("K", Game.decreaseSurfaceTimerHack, false);
ScriptHawk.bindKeyFrame("L", Game.increaseSurfaceTimerHack, false);
--]]

--------------------
-- Region/Version --
--------------------

-- NTSC values
secs_per_major_tick = 94.1104858713; -- 2 ^ 32 * 21.911805 / 1000000000
nano_per_minor_tick = 21.911805; -- Tick rate: 45.6375 Mhz

function Game.detectVersion(romName, romHash)
	require("games.dk64_temp_flags");
	if Game.version == 1 then -- USA
		flag_array = require("games.dk64_flags");
		temp_flag_array = temporary_flags.ntsc_u;
	elseif Game.version == 2 then -- Europe
		flag_array = require("games.dk64_flags");
		temp_flag_array = temporary_flags.pal

		ticks_per_crystal = 125;

		-- PAL values
		secs_per_major_tick = 92.2607229138; -- 2 ^ 32 * 21.4811235 / 1000000000
		nano_per_minor_tick = 21.4811235; -- Tick rate: 46.5525 Mhz
	elseif Game.version == 3 then -- Japan
		flag_array = require("games.dk64_flags_JP");
		temp_flag_array = temporary_flags.ntsc_j
	elseif Game.version == 4 then -- Kiosk
		-- flag_array = require("games.dk64_flags_Kiosk"); -- TODO: Flags?
		temp_flag_array = temporary_flags.kiosk

		health = 12;
		melons = 13;

		-- Kiosk specific Object Model 1 offsets
		obj_model1.floor = 0x9C;

		obj_model1.x_rot = 0xD8;
		obj_model1.y_rot = 0xDA;
		obj_model1.z_rot = 0xDC;

		obj_model1.velocity = 0xB0;
		obj_model1.y_velocity = 0xB8;
		obj_model1.y_acceleration = 0xBC;
		obj_model1.noclip_byte = 0x134;
		obj_model1.hand_state = 0x137;
		obj_model1.control_state_byte = 0x144;
		obj_model1.control_states = { -- TODO: Fill this in
			[0x02] = "First Person Camera",
			[0x03] = "First Person Camera", -- Water
			[0x04] = "Fairy Camera",
			[0x05] = "Fairy Camera", -- Water

			[0x07] = "Minecart (Idle)",
			[0x08] = "Minecart (Crouch)",
			[0x09] = "Minecart (Jump)",
			[0x0A] = "Minecart (Left)",
			[0x0B] = "Minecart (Right)",
			[0x0C] = "Idle",
			[0x0D] = "Walking",

			[0x0F] = "Skidding",

			[0x17] = "Slipping",
			[0x18] = "Jumping",

			[0x1A] = "Double Jump", -- Diddy

			[0x1C] = "Simian Slam",
			[0x1D] = "Long Jumping",
			[0x1E] = "Long Jumping", -- Lanky, weird as hell
			[0x1F] = "Falling",
			[0x20] = "Falling/Splat",

			[0x22] = "Pony Tail twirl",
			[0x23] = "Primate Punch",

			[0x25] = "Ground Attack",
			[0x26] = "Ground Attack",
			[0x27] = "Ground Attack (Final)",

			[0x28] = "Moving Ground Attack",
			[0x29] = "Aerial Attack",
			[0x2A] = "Rolling",
			[0x2B] = "Throwing Orange",
			[0x2C] = "Shockwave",
			[0x2D] = "Charging", -- Rambi

			[0x2F] = "Damaged",

			[0x36] = "Death", -- Dogadon Lava
			[0x37] = "Crouching",
			[0x38] = "Uncrouching",
			[0x39] = "Backflip",
			[0x3A] = "Idle", -- Orangstand
			[0x3B] = "Walking", -- Orangstand
			[0x3C] = "Jumping", -- Orangstand
			[0x3D] = "Barrel",
			[0x3E] = "Baboon Blast Shot",
			[0x3F] = "Leaving Barrel",
			[0x40] = "Cannon Shot",

			[0x43] = "Pushing Object", -- Unused?
			[0x44] = "Picking up Object",
			[0x45] = "Idle", -- Carrying Object
			[0x46] = "Walking", -- Carrying Object
			[0x47] = "Dropping Object",
			[0x48] = "Throwing Object",
			[0x49] = "Jumping", -- Carrying Object
			[0x4A] = "Throwing Object", -- In Air

			[0x4F] = "Bananaporter",

			[0x52] = "Swinging on Vine",
			[0x53] = "Leaving Vine",
			[0x54] = "Climbing Tree",

			[0x56] = "Grabbed Ledge",
			[0x57] = "Pulling up on Ledge",
			[0x58] = "Idle", -- Gun
			[0x59] = "Walking", -- Gun
			[0x5A] = "Gun Action", -- Taking out or putting away
			[0x5B] = "Jumping", -- Gun
			[0x5C] = "Aiming", -- Gun
			[0x5D] = "Rocketbarrel",

			[0x61] = "Instrument",

			[0x6A] = "GB Dance",
			[0x6B] = "Key Dance",

			[0x71] = "Locked", -- Tons of cutscenes use this
		};
		obj_model1.camera.focus_pointer = 0x168;
		obj_model1.player.grab_pointer = 0x2F4;

		obj_model1.actor_types = {
			[2] = "DK",
			[3] = "Diddy",
			[4] = "Lanky",
			[5] = "Tiny",
			[6] = "Chunky",
			[7] = "Rambi",

			--[9] = "Unknown", -- Always loaded -- TODO: Figure out what actors 9-14 do
			--[10] = "Unknown", -- Always loaded -- What is this?
			[11] = "Loading Zone Controller", -- Always loaded
			[12] = "Object Model 2 Controller", -- Always loaded
			--[13] = "Unknown", -- Always loaded -- What is this?
			--[14] = "Unknown", -- Always loaded -- What is this?
			[16] = "Cannon Barrel",
			[17] = "Rambi Crate",
			[18] = "Barrel",
			[20] = "Pushable Box", -- Unused
			[21] = "Barrel Spawner",
			[22] = "Cannon",
			[23] = "Race Checkpoint", -- Circular
			[24] = "Hunky Chunky Barrel",
			[25] = "TNT Barrel",
			[26] = "TNT Barrel Spawner (Army Dillo)",
			[27] = "Bonus Barrel",
			[29] = "Fireball", -- Army Dillo, Dogadon
			[30] = "Bridge", -- Creepy Castle?
			[31] = "Swinging Light", -- Grey
			[32] = "Vine", -- Brown

			[35] = "Peanut", -- Projectile
			[37] = "Pineapple", -- Projectile
			[38] = "Large Bridge", -- Unused?
			[39] = "Mini Monkey Barrel",
			[40] = "Orange",
			[41] = "Grape", -- Projectile
			[42] = "Feather", -- Projectile
			[43] = "Laser",
			[44] = "Golden Banana", -- Held by Vulture
			--[45] = "Unknown", -- Crash
			[46] = "Watermelon Slice",
			[47] = "Coconut", -- Projectile
			[48] = "Rocketbarrel",
			[49] = "Orange/Lime", -- TODO: Not sure which
			[50] = "Ammo Crate", -- Unusued? Normally these are object model 2
			[51] = "Orange", -- Unusued? Normally these are object model 2
			[52] = "Banana Coin", -- Unusued? Normally these are object model 2
			[53] = "DK Coin", -- Unusued? Normally these are object model 2

			[55] = "Orangstand Sprint Barrel",
			[56] = "Strong Kong Barrel",
			[57] = "Swinging Light", -- Green

			[60] = "Boulder",

			[62] = "Vase (O)",
			[63] = "Vase (:)",
			[64] = "Vase (Triangle)",
			[65] = "Vase (+)",
			[66] = "Cannon Ball", -- Fungi Minigame
			[68] = "Vine", -- Green
			[69] = "Counter", -- Unused?

			[71] = "Boss Key",
			[72] = "Cannon", -- Fungi Minigame

			[74] = "Blueprint (Diddy)",
			[75] = "Blueprint (Chunky)",
			[76] = "Blueprint (Lanky)",
			[77] = "Blueprint (DK)",
			[78] = "Blueprint (Tiny)",
			--[79] = "Unknown", -- Crash
			[81] = "Boulder", -- Unused
			[82] = "Spider Web",
			[83] = "Steel Keg Spawner",
			[84] = "Steel Keg", -- Looks different from retail
			[85] = "Collectable", -- Not sure what yet
			--[86] = "Unknown", -- Crash
			[88] = "Missile?",

			[90] = "Balloon (Diddy)",
			[91] = "Stalactite",
			[93] = "Car",
			[95] = "Hunky Chunky Barrel",
			[96] = "TNT Barrel Spawner (Dogadon)",
			[97] = "Tag Barrel",

			[99] = "1 Pad",
			[100] = "2 Pad",
			[101] = "3 Pad",
			[102] = "4 Pad",
			[103] = "5 Pad",
			[104] = "6 Pad",
			[106] = "Lever", -- Gorilla Grab
			[109] = "CB Bunch", -- Unusued? Normally these are object model 2
			[110] = "Balloon (Chunky)",
			[111] = "Balloon (Tiny)",
			[112] = "Balloon (Lanky)",
			[113] = "Balloon (DK)",
			[114] = "Padlock", -- K. Lumsy
			[127] = "Headphones",
			[128] = "Enguarde Crate",
			[134] = "Kaboom",
			[137] = "Beaver",
			[139] = "Krash",
			[140] = "Book",
			[141] = "Jack in the Box (Beta)",
			[142] = "Klobber",
			[143] = "Zinger",
			[144] = "Snide",
			[145] = "Army Dillo",
			[147] = "Klump",
			[148] = "Armadillo (Beta)",
			[149] = "Camera",
			[150] = "Cranky",
			[151] = "Funky",
			[152] = "Candy",
			[153] = "Beetle",
			[154] = "Mermaid",
			[155] = "Vulture",
			[156] = "Squawks",
			[157] = "Cutscene DK",
			[158] = "Cutscene Diddy",
			[159] = "Cutscene Lanky",
			[160] = "Cutscene Tiny",
			[161] = "Cutscene Chunky",
			[162] = "Llama",
			[165] = "Mad Jack",
			[164] = "Padlock & Key",
			[166] = "Klaptrap", -- Green
			[167] = "Zinger",
			[168] = "Vulture",
			[169] = "Klaptrap (Purple)",
			[170] = "Klaptrap (Red)",
			[173] = "Rareware Logo",
			[174] = "Orange Kremling (Beta)",
			[175] = "Rareware Logo",
			[177] = "Minecart (TNT)",
			[178] = "Minecart (TNT)",
			[179] = "Pufftoss",
			[184] = "Rareware Logo",
			[185] = "Rareware Logo",
			[187] = "Boxing Glove in the Box (Beta)",
			[188] = "Mushroom Man",
			[189] = "Rareware Logo",
			[190] = "Troff",
			[191] = "Rareware Logo",
			[193] = "Rareware Logo",
			[194] = "Rareware Logo",
			[195] = "Ruler",
			[196] = "Toy Box",
			[198] = "Squawks",
			[199] = "Scoff",
			[200] = "Robo-Kremling",
			[201] = "Dogadon",
			[202] = "Bug (Beta)",
			[204] = "Kremling",
			[206] = "Spotlight Fish",
			[207] = "Kasplat (DK)",
			[208] = "Kasplat (Diddy)",
			[209] = "Kasplat (Lanky)",
			[210] = "Kasplat (Tiny)",
			[211] = "Kasplat (Chunky)",
			[212] = "Mechanical Fish",
			[213] = "Seal",
			[214] = "Banana Fairy",
			[215] = "Squawks",
			[216] = "Zinger",
			[217] = "Owl",
			[219] = "Rabbit",
			[220] = "Nintendo Logo",
			[222] = "Shockwave",
			[221] = "Cutscene Object", -- Fake Chunky in Dogadon 2 opening cutscene
			[226] = "Guard", -- Stealthy Snoop
			[228] = "Robo-Zinger",
			[229] = "Krossbones",
			[230] = "Fireball Shockwave", -- Dogadon
			[232] = "Light Beam", -- Boss fights etc
			[234] = "Shuri",
			[235] = "Gimpfish",
			[236] = "Mr. Dice",
			[237] = "Sir Domino",
			[238] = "Mr. Dice",
			[239] = "Rabbit",
			[240] = "Beaver",
			[241] = "Fireball (With Glasses)", -- From Chunky 5DI
			[243] = "K. Lumsy",
			[245] = "Squawks",
			[249] = "K. Rool",
			[251] = "Skeleton Head",
			[253] = "Bat",
			[254] = "Giant Clam",
			[256] = "Tomato",
			[257] = "Kritter-in-a-Sheet",
			[258] = "Pufftup",
			[266] = "Enemy Car",
			[271] = "Seal",
			[272] = "Kong Logo (Instrument)",
			[273] = "Spotlight",
			[275] = "Minecart (TNT)",
			[276] = "Idle Particle",
			[279] = "Rareware Logo",
			[281] = "Kong (Tag Barrel)",
			[282] = "Locked Kong (Tag Barrel)",
		};

		obj_model2_slot_size = 0x88;
		obj_model2.behavior_pointer = 0x70;
		obj_model2.object_type = 0x7C;

		-- Kiosk version maps
		--0 Crash
		--1 Crash
		--2 Crash
		--3 Dogadon (2?) fight (Crash??!?!?!)
		--4 Crash
		--5 Crash
		--6 Minecart
		--7 Crash
		--8 Army Dillo fight
		--9-39 Crash
		--40 N+R logo
		--41-75 Crash
		--76 DK Rap
		--77 Crash
		--78 Crash
		--79 Crash
		--80 Title screen
		--81 "Thanks for playing" or Test Map
		--82 Crash?
		--83 Dogadon Fight
		--84-214 Crash
		--215 Partially loads (kong position changes), then crashes
		--216-228 Crash
		--229 Partially loads (kong position changes), then crashes
		--230-240 Crash
		--241 Partially loads (kong position changes), then crashes
		--242-255 Crash

		-- 806FB6D0, pointer table to strings
		levelIndexes = {
			[0x00] = "JUNGLE",
			[0x01] = "TEMPLE",
			[0x02] = "TOY",
			[0x03] = "WRECK",
			[0x04] = "FOREST",
			[0x05] = "CRYSTAL",
			[0x06] = "SPOOKY",
			[0x07] = "WORLD",
			[0x08] = "HIDEOUT",
			[0x09] = "BONUS",
			[0x0A] = "MULTI",
			[0x0B] = "TEST",
			[0x0C] = "SHARED",
		};

		model_indexes = {
			[0x0000] = "No Model",
			[0x0001] = "Diddy (Gun)",
			[0x0002] = "Diddy (Instrument)",
			[0x0003] = "DK",
			[0x0004] = "Lanky",
			[0x0005] = "Lanky (Instrument)",
			[0x0006] = "Tiny",
			[0x0007] = "Tiny (Instrument)",
			[0x0008] = "Chunky",
			[0x0009] = "Chunky (Instrument)",
			[0x000A] = "Disco Chunky",
			[0x000B] = "Cranky",
			[0x000C] = "Funky",
			[0x000D] = "Candy",
			[0x000E] = "Rambi",
			[0x000F] = "Snake", -- Teetering Turtles
			[0x0010] = "Turtle", -- Teetering Turtles
			[0x0011] = "Seal",
			[0x0012] = "Enguarde",
			[0x0013] = "Beaver",
			[0x0014] = "Beaver",
			[0x0015] = "Beaver (Gold)",
			[0x0016] = "Orange Kremling (Beta)",
			[0x0017] = "Zinger",
			[0x0018] = "Squawks",
			[0x0019] = "Klobber",
			[0x001A] = "Snide",
			[0x001B] = "Snake (Beta)",
			[0x001C] = "Kaboom",
			[0x001D] = "Klaptrap (Green)",
			[0x001E] = "Klaptrap (Purple)",
			[0x001F] = "Klaptrap (Red)",
			[0x0020] = "Klaptrap (Teeth)",
			[0x0021] = "Mad Jack",
			[0x0022] = "Krash",
			[0x0023] = "Armadillo (Beta)",
			[0x0024] = "Jack in the Box (Beta)",
			[0x0025] = "Boxing Glove in the Box (Beta)",
			[0x0026] = "Troff",
			[0x0027] = "Nothing?",
			[0x0028] = "Sir Domino",
			[0x0029] = "Mr. Dice",
			[0x002A] = "Ruler",
			[0x002B] = "Bug (Beta)",
			[0x002C] = "Robo-Kremling",
			[0x002D] = "Scoff",
			[0x002E] = "Beetle", -- Race
			[0x002F] = "Kremling Head",
			[0x0030] = "Nintendo Logo",
			[0x0031] = "Kremling",
			[0x0032] = "Kremling (Red)",
			[0x0033] = "Kremling",
			[0x0034] = "Mechanical Fish",
			[0x0035] = "Ememy Car",
			[0x0036] = "Giant Clam",
			[0x0037] = "Kasplat",
			[0x0038] = "Army Dillo",
			[0x0039] = "Mr. Dice",
			[0x003A] = "Klump",
			[0x003B] = "Pufftoss",
			[0x003C] = "Dogadon",
			[0x003D] = "Banana Fairy",
			[0x003E] = "Llama",
			[0x003F] = "Guard", -- Stealthy Snoop
			[0x0040] = "Robo-Zinger",
			[0x0041] = "Turntable",
			[0x0042] = "Krossbones",
			[0x0043] = "Shuri",
			[0x0044] = "Gimpfish",
			[0x0045] = "K. Lumsy",
			[0x0046] = "Spider",
			[0x0047] = "Rabbit",
			[0x0048] = "Beanstalk",
			[0x0049] = "K. Rool",
			[0x004A] = "Fireball (With Glasses)", -- From Chunky 5DI
			[0x004B] = "Skeleton Head",
			[0x004C] = "Skeleton Hand",
			[0x004D] = "Vulture",
			[0x004E] = "Vulture",
			[0x004F] = "Bat",
			[0x0050] = "Skull", -- DK Minecart
			[0x0051] = "Tomato",
			[0x0052] = "Kritter-in-a-Sheet",
			[0x0053] = "Fly", -- Big Bug Bash
			[0x0054] = "Fly Swatter",
			[0x0055] = "Fly swatter Shadow",
			[0x0056] = "Owl",
			[0x0057] = "Book",
			[0x0058] = "Ship's Wheel",
			[0x0059] = "Spotlight Fish",
			[0x005A] = "Pufftup",
			[0x005B] = "Mermaid",
			[0x005C] = "Mushroom Man",
			[0x005D] = "Shockwave",
			[0x005E] = "Squawks",
			[0x005F] = "Worm", -- Fungi
			[0x0060] = "Cuckoo Bird",
			[0x0061] = "Cannon Barrel",
			[0x0062] = "Bonus Barrel Gun?",
			[0x0063] = "Bonus Barrel",
			[0x0064] = "Hunky Chunky Barrel",
			[0x0065] = "Mini Monkey Barrel",
			[0x0066] = "Barrel",
			[0x0067] = "Crate",
			[0x0068] = "Barrel Spawner", -- Star Pad, confirm this
			[0x0069] = "Cannon",
			[0x006A] = "TNT Barrel",
			[0x006B] = "Rambi Crate",
			[0x006C] = "Enguarde Crate",
			[0x006D] = "Chain", -- Diddy, Castle
			[0x006E] = "Swinging Light",
			[0x006F] = "Minecart",
			[0x0070] = "Bonus Barrel Gun?",
			[0x0071] = "Bridge",
			[0x0072] = "Bridge",
			[0x0073] = "Feather",
			[0x0074] = "Laser", -- Castle Boss
			[0x0075] = "Golden Banana",
			[0x0076] = "Rocketbarrel",
			[0x0077] = "Strong Kong Barrel",
			[0x0078] = "Orangstand Spring Barrel",
			[0x0079] = "Diddy's Jetpack",
			[0x007A] = "Photo",
			[0x007B] = "Minecart (TNT)",
			[0x007C] = "Weird glitch texture (computer screen?)",
			[0x007D] = "BBB Slot",
			[0x007E] = "BBB Slot",
			[0x007F] = "BBB Slot",
			[0x0080] = "BBB Slot",
			[0x0081] = "BBB Lever",
			[0x0082] = "Car",
			[0x0083] = "Missile", -- Car Race
			[0x0084] = "Swinging Light", -- Green
			[0x0085] = "Bananaporter Zipper",
			[0x0086] = "Boulder",
			[0x0087] = "Vase (O)",
			[0x0088] = "Vase (:)",
			[0x0089] = "Vase (Triangle)",
			[0x008A] = "Vase (+)",
			[0x008B] = "Toy Box", -- Unfinished
			[0x008C] = "Boat",
			[0x008D] = "Padlock & Key",
			[0x008E] = "Cannon Ball",
			[0x008F] = "Vine", -- Brown
			[0x0090] = "Vine", -- Green
			[0x0091] = "Counter",
			[0x0092] = "Boss Key",
			[0x0093] = "Bongos",
			[0x0094] = "Star", -- Instrument?
			[0x0095] = "Spotlight",
			[0x0096] = "Cannon", -- Galleon Minigame
			[0x0097] = "Boulder Debris",
			[0x0098] = "Spider Web",
			[0x0099] = "Steel Keg", -- Beta Model
			[0x009A] = "Shockwave",
			[0x009B] = "Shockwave",
			[0x009C] = "Battle Crown",
			[0x009D] = "Buoy",
			[0x009E] = "Buoy",
			[0x009F] = "Nothing?",
			[0x00A0] = "DK Banana Counter",
			[0x00A1] = "Diddy Banana Counter",
			[0x00A2] = "Tiny Banana Counter",
			[0x00A3] = "Lanky Banana Counter",
			[0x00A4] = "Chunky Banana Counter",
			[0x00A5] = "Shockwave",
			[0x00A6] = "Potion", -- Cranky's Lab
			[0x00A7] = "Missile (Army Dillo)",
			[0x00A8] = "Shockwave",
			[0x00A9] = "Ice Wall",
			[0x00AA] = "D (3D)", -- Beta
			[0x00AB] = "K (3D)", -- Beta
			[0x00AC] = "6 (3D)", -- Beta
			[0x00AD] = "4 (3D)", -- Beta
			[0x00AE] = "Rareware Logo",
			[0x00AF] = "Stalactite",
			[0x00B0] = "Rock Wall",
			[0x00B1] = "Thin Strip", -- idk
			[0x00B2] = "Tag Barrel",
			[0x00B3] = "Skeleton Head",
			[0x00B4] = "Lever", -- Gorilla Grab
			[0x00B5] = "K. Lumsy's Cage",
			[0x00B6] = "Spider Web?",
			[0x00B7] = "1 Pad (Diddy 5DI)",
			[0x00B8] = "2 Pad (Diddy 5DI)",
			[0x00B9] = "3 Pad (Diddy 5DI)",
			[0x00BA] = "4 Pad (Diddy 5DI)",
			[0x00BB] = "5 Pad (Diddy 5DI)",
			[0x00BC] = "6 Pad (Diddy 5DI)",
			[0x00BD] = "Race Checkpoint", -- Rabbit Race
			[0x00BE] = "Padlock & Key (Gold)",
			[0x00BF] = "Finish Line", -- Rabbit Race
			[0x00C0] = "Shockwave (Green)",
			[0x00C1] = "Shockwave (Blue)",
			[0x00C2] = "Shockwave (Purple)",
			[0x00C3] = "Question Mark", -- Tag Barrel
			[0x00C4] = "Flower (Instrument)",
			[0x00C5] = "DK Logo (Instrument)",
			[0x00C6] = "Golden Banana",
			[0x00C7] = "Apple", -- Fungi
		};
	else
		return false;
	end

	Game.RAMWatch = parseRAMWatch("./Watch/"..romName..".wch");
	Game.RAMWatch = table.join(Game.RAMWatch, parseRAMWatch("./Watch/Constants/"..romName..".wch"));

	-- Read EEPROM checksums
	for i = 1, #eep_checksum do
		eep_checksum[i].value = memory.read_u32_be(eep_checksum[i].address, "EEPROM");
	end

	-- Fill flag names and flags by map
	if #flag_array > 0 then
		for i = 1, #flag_array do
			if not flag_array[i].ignore then
				flag_names[i] = flag_array[i].name;
				if not flag_array[i].nomap then
					if type(flag_array[i].map) == "number" then
						if not flags_by_map[flag_array[i].map] then
							flags_by_map[flag_array[i].map] = {};
						end
						table.insert(flags_by_map[flag_array[i].map], flag_array[i]);
					end
				end
			end
		end
	else
		print("Warning: No flags found");
		flag_names = {"None"};
	end

	for k, v in pairs(dynamicWaterSurface) do
		dynamicWaterSurface[k] = v[Game.version];
	end

	return true;
end

function Game.getFileIndex()
	if Game.version == 4 then
		return 0;
	end
	return mainmemory.readbyte(Game.Memory.file);
end

function Game.getCurrentEEPROMSlot()
	if Game.version == 4 then
		return 0;
	end
	local fileIndex = Game.getFileIndex();
	for i = 0, 3 do
		local EEPROMMap = mainmemory.readbyte(Game.Memory.eeprom_file_mapping + i);
		if EEPROMMap == fileIndex then
			return i;
		end
	end
	return 0; -- Default
end

function Game.getFileOSD()
	return Game.getFileIndex().." (Slot "..Game.getCurrentEEPROMSlot()..")";
end

function Game.getFlagBlockAddress()
	return Game.Memory.eeprom_copy_base + Game.getCurrentEEPROMSlot() * eeprom_slot_size;
end

----------------
-- Flag stuff --
----------------

local flag_block_size = 0x13B; -- TODO: Find exact size, absolute maximum is 0x1A8 based on physical EEPROM slot size but it's likely much smaller than this
local flag_block_cache = {};

local function clearFlagCache()
	flag_block_cache = {};
end

local function getFlag(byte, bit)
	for i = 1, #flag_array do
		if byte == flag_array[i].byte and bit == flag_array[i].bit then
			return flag_array[i];
		end
	end
end

local function isFlagFound(byte, bit)
	return getFlag(byte, bit) ~= nil;
end

local function getFlagByName(flagName)
	for i = 1, #flag_array do
		if not flag_array[i].ignore and flagName == flag_array[i].name then
			return flag_array[i];
		end
	end
end

function Game.getFlagName(byte, bit)
	for i = 1, #flag_array do
		if byte == flag_array[i].byte and bit == flag_array[i].bit and not flag_array[i].ignore then
			return flag_array[i].name;
		end
	end
	return "Unknown at "..toHexString(byte)..">"..bit;
end

function checkFlags(showKnown)
	local flags = Game.getFlagBlockAddress();
	local flagBlock = mainmemory.readbyterange(flags, flag_block_size + 1);

	if #flag_block_cache == flag_block_size then
		local flagFound = false;
		local knownFlagsFound = 0;
		local currentValue, previousValue;

		for i = 0, #flag_block_cache do
			currentValue = flagBlock[i];
			previousValue = flag_block_cache[i];
			if currentValue ~= previousValue then
				for bit = 0, 7 do
					local isSetNow = check_bit(currentValue, bit);
					local wasSet = check_bit(previousValue, bit);
					if isSetNow and not wasSet then
						if not isFlagFound(i, bit) then
							flagFound = true;
							dprint("{byte="..toHexString(i, 2)..", bit="..bit..', name="Name", type="Type", map='..map_value.."},");
						else
							if showKnown then
								local currentFlag = getFlag(i, bit);
								if not currentFlag.ignore then
									if currentFlag.map ~= nil or currentFlag.nomap == true then
										dprint("Flag "..toHexString(i, 2)..">"..bit..': "'..currentFlag.name..'" was set on frame '..emu.framecount());
									else
										dprint("Flag "..toHexString(i, 2)..">"..bit..': "'..currentFlag.name..'" was set on frame '..emu.framecount().." ADD MAP "..map_value.." PLEASE");
									end
								end
							end
							knownFlagsFound = knownFlagsFound + 1;
						end
					elseif not isSetNow and wasSet then
						if not isFlagFound(i, bit) then
							dprint("Flag "..toHexString(i, 2)..">"..bit..': "Unknown" was cleared on frame '..emu.framecount());
						elseif showKnown then
							local currentFlag = getFlag(i, bit);
							if not currentFlag.ignore then
								dprint("Flag "..toHexString(i, 2)..">"..bit..': "'..currentFlag.name..'" was cleared on frame '..emu.framecount());
							end
						end
					end
				end
			end
		end
		flag_block_cache = flagBlock;
		if not showKnown then
			if knownFlagsFound > 0 then
				dprint(knownFlagsFound.." Known flags skipped");
			end
			if not flagFound then
				dprint("No unknown flags were changed");
			end
		end
	else
		flag_block_cache = flagBlock;
		dprint("Populated flag block cache");
	end
	print_deferred();
end

function checkFlag(byte, bit, suppressPrint)
	if type(byte) == "string" then
		local flag = getFlagByName(byte);
		if type(flag) == "table" then
			byte = flag.byte;
			bit = flag.bit;
		end
	end
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit < 8 then
		local flags = Game.getFlagBlockAddress();
		local currentValue = mainmemory.readbyte(flags + byte);
		if check_bit(currentValue, bit) then
			if not suppressPrint then
				print(Game.getFlagName(byte, bit).." is SET");
			end
			return true;
		else
			if not suppressPrint then
				print(Game.getFlagName(byte, bit).." is NOT set");
			end
			return false;
		end
	else
		if not suppressPrint then
			print("Warning: Flag not found");
		end
	end
	return false;
end

----------------------------------
-- Duplicate checking functions --
----------------------------------

local function checkDuplicatedName(flagName)
	local count = 0;
	local flags = {};
	for i = 1, #flag_array do
		if flagName == flag_array[i].name and not flag_array[i].ignore then
			count = count + 1;
			table.insert(flags, flag_array[i]);
		end
	end
	if #flags > 1 then
		for i = 1, #flags do
			print("Warning: Duplicate flag name found for '"..flags[i].name.."' at "..toHexString(flags[i].byte)..">"..flags[i].bit);
		end
	end
end

function checkDuplicateFlagNames()
	for i = 1, #flag_array do
		checkDuplicatedName(flag_array[i].name);
	end
end

function checkFlagOrder()
	local previousByte = 0x00;
	local previousBit = 0;
	local invalidCount = 0;

	for i = 1, #flag_array do
		local flag = flag_array[i];
		if flag.byte == previousByte and flag.bit > previousBit then
			-- All good
		elseif flag.byte == previousByte + 1 and flag.bit == 0 then
			-- All good
		else
			-- No bueno
			invalidCount = invalidCount + 1;
			dprint("Warning: Flag "..toHexString(flag.byte, 2)..">"..flag.bit.." may be out of order");
		end
		previousByte = flag.byte;
		previousBit = flag.bit;
	end

	if invalidCount > 0 then
		print_deferred();
	else
		print("Flags appear to be in correct order!");
	end
end

------------------------
-- Set flag functions --
------------------------

function setFlag(byte, bit, suppressPrint)
	local flags = Game.getFlagBlockAddress();
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit < 8 then
		local currentValue = mainmemory.readbyte(flags + byte);
		mainmemory.writebyte(flags + byte, set_bit(currentValue, bit));
		if not suppressPrint then
			if isFlagFound(byte, bit) then
				print('Set "'..Game.getFlagName(byte, bit)..'" at '..toHexString(byte)..">"..bit);
			else
				print("Set "..Game.getFlagName(byte, bit));
			end
		end
	end
end

function setFlagByName(name)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		setFlag(flag.byte, flag.bit);
	end
end

function setFlagsByType(_type)
	if type(_type) == "string" then
		local numSet = 0;
		for i = 1, #flag_array do
			if flag_array[i].type == _type then
				setFlag(flag_array[i].byte, flag_array[i].bit, true);
				numSet = numSet + 1;
			end
		end
		if numSet > 0 then
			print("Set "..numSet.." flags of type '".._type.."'");
		else
			print("No flags found of type '".._type.."'");
		end
	end
end

function setFlagsByMap(mapIndex)
	for i = 1, #flag_array do
		local flag = flag_array[i];
		if not flag.nomap and flag.map == mapIndex then
			setFlag(flag.byte, flag.bit, true);
		end
	end
end

function setKnownFlags()
	for i = 1, #flag_array do
		local flag = flag_array[i];
		if flag.type ~= "Unknown" then
			setFlag(flag.byte, flag.bit, true);
		end
	end
end

function setAllFlags()
	for byte = 0, flag_block_size do
		for bit = 0, 7 do
			setFlag(byte, bit, true);
		end
	end
end

--------------------------
-- Clear flag functions --
--------------------------

function clearFlag(byte, bit, suppressPrint)
	local flags = Game.getFlagBlockAddress();
	if type(byte) == "number" and type(bit) == "number" and bit >= 0 and bit < 8 then
		local currentValue = mainmemory.readbyte(flags + byte);
		mainmemory.writebyte(flags + byte, clear_bit(currentValue, bit));
		if not suppressPrint then
			if isFlagFound(byte, bit) then
				print('Cleared "'..Game.getFlagName(byte, bit)..'" at '..toHexString(byte)..">"..bit);
			else
				print("Cleared "..Game.getFlagName(byte, bit));
			end
		end
	end
end

function clearFlagByName(name)
	local flag = getFlagByName(name);
	if type(flag) == "table" then
		clearFlag(flag.byte, flag.bit);
	end
end

function clearFlagsByType(_type)
	if type(_type) == "string" then
		local numCleared = 0;
		for i = 1, #flag_array do
			if flag_array[i].type == _type then
				clearFlag(flag_array[i].byte, flag_array[i].bit, true);
				numCleared = numCleared + 1;
			end
		end
		if numCleared > 0 then
			print("Cleared "..numCleared.." flags of type '".._type.."'");
		else
			print("No flags found of type '".._type.."'");
		end
	end
end

function clearFlagsByMap(mapIndex)
	for i = 1, #flag_array do
		local flag = flag_array[i];
		if not flag.nomap and flag.map == mapIndex then
			clearFlag(flag.byte, flag.bit, true);
		end
	end
end

function clearKnownFlags()
	for i = 1, #flag_array do
		local flag = flag_array[i];
		if flag.type ~= "Unknown" then
			clearFlag(flag.byte, flag.bit, true);
		end
	end
end

function clearAllFlags()
	for byte = 0, flag_block_size do
		for bit = 0, 7 do
			clearFlag(byte, bit, true);
		end
	end
end

--------------------------
-- Other flag functions --
--------------------------

function countFlagsOnMap(mapIndex)
	if type(flags_by_map[mapIndex]) == "table" then
		return #flags_by_map[mapIndex];
	end
	return 0;
end

function checkFlagsOnMap(mapIndex)
	local flagsSetOnMap = 0;
	if type(flags_by_map[mapIndex]) == "table" then
		for k, flag in pairs(flags_by_map[mapIndex]) do
			if checkFlag(flag.byte, flag.bit, true) then
				flagsSetOnMap = flagsSetOnMap + 1;
			end
		end
	end
	return flagsSetOnMap;
end

local function getFlagStatsOSD() -- TODO: This is a lot faster but still too slow to be always enabled
	return checkFlagsOnMap(map_value).."/"..countFlagsOnMap(map_value);
end

local function flagSetButtonHandler()
	setFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagClearButtonHandler()
	clearFlagByName(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function flagCheckButtonHandler()
	checkFlag(forms.getproperty(ScriptHawk.UI.form_controls["Flag Dropdown"], "SelectedItem"));
end

local function formatOutputString(caption, value, max)
	return caption..value.."/"..max.." or "..round(value / max * 100, 2).."%";
end

function flagStats(verbose)
	local fairies_known = 0;
	local blueprints_known = 0;
	local warps_known = 0;
	local cb_known = 0;
	local gb_known = 0;
	local crowns_known = 0;
	local coins_known = 0;
	local medals_known = 0;
	local untypedFlags = 0;
	local flagsWithUnknownType = 0;
	local flagsWithMap = 0;

	-- Setting this to true warns the user of flags without types
	verbose = verbose or false;

	if verbose then
		checkFlagOrder();
		checkDuplicateFlagNames();
	end

	for i = 1, #flag_array do
		local flag = flag_array[i];
		local validType = false;
		if flag.type == "Fairy" then
			fairies_known = fairies_known + 1;
			validType = true;
		elseif flag.type == "Blueprint" then
			blueprints_known = blueprints_known + 1;
			validType = true;
		elseif flag.type == "Warp" then
			warps_known = warps_known + 1;
			validType = true;
		elseif flag.type == "GB" then
			if flag.name == "Caves: Tiny GB: W3" or flag.name == "Aztec: DK GB: W5" or flag.name == "Galleon: Diddy GB: W4" then
				warps_known = warps_known + 1;
			end
			gb_known = gb_known + 1;
			validType = true;
		elseif flag.type == "CB" then
			cb_known = cb_known + 1;
			validType = true;
		elseif flag.type == "Bunch" then
			cb_known = cb_known + 5;
			validType = true;
		elseif flag.type == "Balloon" then
			cb_known = cb_known + 10;
			validType = true;
		elseif flag.type == "Crown" then
			crowns_known = crowns_known + 1;
			validType = true;
		elseif flag.type == "Coin" then
			coins_known = coins_known + 1;
			validType = true;
		elseif flag.type == "Medal" then
			medals_known = medals_known + 1;
			validType = true;
		elseif flag.type == "Rainbow Coin" then
			coins_known = coins_known + 25;
			validType = true;
		end
		if flag.type == nil then
			untypedFlags = untypedFlags + 1;
			if verbose then
				dprint("Warning: Flag without type at "..toHexString(flag.byte, 2)..">"..flag.bit..' with name: "'..flag.name..'"');
			end
		else
			if flag.type == "B. Locker" or flag.type == "Cutscene" or flag.type == "FTT" or flag.type == "Key" or flag.type == "Kong" or flag.type == "Physical" or flag.type == "Progress" or flag.type == "Special Coin" or flag.type == "T&S" or flag.type == "Unknown" then
				validType = true;
			end
			if not validType then
				flagsWithUnknownType = flagsWithUnknownType + 1;
				if verbose then
					dprint("Warning: Flag with unknown type at "..toHexString(flag.byte, 2)..">"..flag.bit..' with name: "'..flag.name..'"'..' and type: "'..flag.type..'"');
				end
			end
		end
		if flag.map ~= nil or flag.nomap == true then
			flagsWithMap = flagsWithMap + 1;
		elseif verbose then
			dprint("Warning: Flag without map tag at "..toHexString(flag.byte, 2)..">"..flag.bit..' with name: "'..flag.name..'"');
		end
	end

	local knownFlags = #flag_array;
	local totalFlags = flag_block_size * 8;

	dprint("Block size: "..toHexString(flag_block_size));
	dprint(formatOutputString("Flags known: ", knownFlags, totalFlags));
	dprint(formatOutputString("Without types: ", untypedFlags, knownFlags));
	dprint(formatOutputString("Unknown types: ", flagsWithUnknownType, knownFlags));
	dprint(formatOutputString("With map tag: ", flagsWithMap, knownFlags));
	dprint("");
	dprint(formatOutputString("CB: ", cb_known, max_cb));
	dprint(formatOutputString("GB: ", gb_known, max_gb));
	dprint("");
	dprint(formatOutputString("Crowns: ", crowns_known, max_crowns));
	dprint(formatOutputString("Fairies: ", fairies_known, max_fairies));
	dprint(formatOutputString("Blueprints: ", blueprints_known, max_blueprints));
	dprint(formatOutputString("Medals: ", medals_known, max_medals));
	dprint(formatOutputString("Warps: ", warps_known, max_warps));
	dprint("Coins: "..coins_known); -- Just a note: Fungi Rabbit Race coins aren't flagged
	dprint("");
	print_deferred();
end

function dumpFlagMapping()
	for i = 0, 0xA5 do -- 0x70 for model 2 flags only
		local base = Game.Memory.flag_mapping + i * 8;
		local map = mainmemory.readbyte(base + 0);
		local id = mainmemory.read_u16_be(base + 2);
		local flagIndex = mainmemory.read_u16_be(base + 4);
		local flagByte = math.floor(flagIndex / 8);
		local flagBit = flagIndex % 8;
			local mapName = "Unknown";
			if Game.maps[map + 1] ~= nil then
				mapName = Game.maps[map + 1];
			end
			mapName = mapName.." ("..map..")";
		dprint(mapName.." "..toHexString(id).." "..toHexString(flagByte)..">"..flagBit.." "..Game.getFlagName(flagByte, flagBit));
	end
	print_deferred();
end

---------------------
-- Temporary Flags --
---------------------

temp_flag_boundaries = {
	start = {0x7FDD90,0x7FDCD0,0x7FE220,nil},
	finish = {0x7FDD9F,0x7FDCDF,0x7FE22F,nil},
	size = {0xF,0xF,0xF,nil},
};

function setTempFlag(byte,tempBit)
	temp_flag_value = mainmemory.readbyte(temp_flag_boundaries.start[Game.version] + byte);
	temp_flag_value = bit.set(temp_flag_value,tempBit);
	mainmemory.writebyte(temp_flag_boundaries.start[Game.version] + byte, temp_flag_value);
end

function clearTempFlag(byte,tempBit)
	temp_flag_value = mainmemory.readbyte(temp_flag_boundaries.start[Game.version] + byte);
	temp_flag_value = bit.clear(temp_flag_value,tempBit);
	mainmemory.writebyte(temp_flag_boundaries.start[Game.version] + byte, temp_flag_value);
end

function checkTempFlag(byte,tempBit)
	temp_flag_value = mainmemory.readbyte(temp_flag_boundaries.start[Game.version] + byte);
	return_value = bit.check(temp_flag_value,tempBit);
	return return_value
end

local temp_flag_block_cache = {};

local function clearTempFlagCache()
	temp_flag_block_cache = {};
end

local function getTempFlag(byte, bit)
	for i = 1, #temp_flag_array do
		if byte == temp_flag_array[i].byte and bit == temp_flag_array[i].bit then
			return temp_flag_array[i];
		end
	end
end

local function isTempFlagFound(byte, bit)
	return getTempFlag(byte, bit) ~= nil;
end

function checkTemporaryFlags(showKnown)
	if temp_flag_boundaries.start[Game.version] ~= nil then
		temp_flags = temp_flag_boundaries.start[Game.version];
		temp_flagBlock = mainmemory.readbyterange(temp_flags, temp_flag_boundaries.size[Game.version] + 1);

		if #temp_flag_block_cache == temp_flag_boundaries.size[Game.version] then
			local tempFlagFound = false;
			local knownTempFlagsFound = 0;
			local currentValue, previousValue;

			for i = 0, #temp_flag_block_cache do
				currentValue = temp_flagBlock[i];
				previousValue = temp_flag_block_cache[i];
				if currentValue ~= previousValue then
					for bit = 0, 7 do
						local isSetNow = check_bit(currentValue, bit);
						local wasSet = check_bit(previousValue, bit);
						if isSetNow and not wasSet then
							if not isTempFlagFound(i, bit) then
								tempFlagFound = true;
								dprint("Unknown Temporary Flag Found!");
								dprint("{byte="..toHexString(i, 2)..", bit="..bit..', flagName="Name", type="Type", map='..map_value.."},");
							else
								if showKnown then
									local currentTempFlag = getTempFlag(i, bit);
									if not currentTempFlag.ignore then
										if currentTempFlag.map ~= nil or currentTempFlag.nomap == true then
											dprint("Temporary Flag "..toHexString(i, 2)..">"..bit..': "'..currentTempFlag.flagName..'" was set on frame '..emu.framecount());
										else
											dprint("Temporary Flag "..toHexString(i, 2)..">"..bit..': "'..currentTempFlag.flagName..'" was set on frame '..emu.framecount().." ADD MAP "..map_value.." PLEASE");
										end
									end
								end
								knownTempFlagsFound = knownTempFlagsFound + 1;
							end
						elseif not isSetNow and wasSet then
							if not isTempFlagFound(i, bit) then
								dprint("Temporary Flag "..toHexString(i, 2)..">"..bit..': "Unknown" was cleared on frame '..emu.framecount());
							elseif showKnown then
								local currentTempFlag = getTempFlag(i, bit);
								if not currentTempFlag.ignore then
									dprint("Temporary Flag "..toHexString(i, 2)..">"..bit..': "'..currentTempFlag.flagName..'" was cleared on frame '..emu.framecount());
								end
							end
						end
					end
				end
			end
			temp_flag_block_cache = temp_flagBlock;
			if not showKnown then
				if knownTempFlagsFound > 0 then
					dprint(knownTempFlagsFound.." Known temporary flags skipped");
				end
				if not tempFlagFound then
					dprint("No unknown flags were changed");
				end
			end
		else
			temp_flag_block_cache = temp_flagBlock;
			dprint("Populated temporary flag block cache");
		end
		print_deferred();
	end
end

------------------
-- TBS Nonsense --
------------------

local function forceTBS()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local pointer = dereferencePointer(playerObject + obj_model1.collision_queue_pointer);
		if isRDRAM(pointer) then
			mainmemory.write_u32_be(playerObject + obj_model1.collision_queue_pointer, 0);
			--print("Forcing TBS. Nulled pointer to "..toHexString(pointer));
		end
	end
end

------------------------
-- Memory usage stuff --
------------------------

local memoryStatCache = nil;

function Game.getFreeMemory()
	if memoryStatCache ~= nil then
		return toHexString(memoryStatCache.free).." bytes";
	end
	return "Unknown";
end

function Game.getUsedMemory()
	if memoryStatCache ~= nil then
		return toHexString(memoryStatCache.used).." bytes";
	end
	return "Unknown";
end

function Game.getTotalMemory()
	if memoryStatCache ~= nil then
		return toHexString(memoryStatCache.free + memoryStatCache.used).." bytes";
	end
	return "Unknown";
end

------------------
-- Chunk Deload --
------------------

local chunk = {
	size = 0x1C8, -- Size of a chunk object in RAM
	visible = 0x05, -- Byte, 0x02 = visible, everything else = invisible
	deload1 = 0x68, -- u32_be
	deload2 = 0x6C, -- u32_be
	deload3 = 0x70, -- u32_be
	deload4 = 0x74, -- u32_be
};

function Game.getChunkArray()
	return dereferencePointer(Game.Memory.chunk_array_pointer);
end

function Game.fixChunkDeload()
	--[[
	local chunkArray = Game.getChunkArray();
	if isRDRAM(chunkArray) then
		local numChunks = math.floor(mainmemory.read_u32_be(chunkArray + heap.object_size) / chunk.size);
		for i = 0, numChunks - 1 do
			local chunkBase = chunkArray + i * chunk.size;
			mainmemory.write_u32_be(chunkBase + chunk.deload1, 0xA);
			mainmemory.write_u32_be(chunkBase + chunk.deload2, 0xA);
			mainmemory.write_u32_be(chunkBase + chunk.deload3, 0x135);
			mainmemory.write_u32_be(chunkBase + chunk.deload4, 0xE5);
		end
		print_deferred();
	end
	--]]
	local segmentBase = Game.getMapSegmentBase();
	if isRDRAM(segmentBase) then
		local numSegments = mainmemory.read_u32_be(segmentBase);
		segmentBase = segmentBase + 4;
		for i = 0, numSegments - 1 do
			mainmemory.writebyte(segmentBase + 0x18, 1);
			mainmemory.writebyte(segmentBase + 0x19, 1);
			segmentBase = segmentBase + 0x1C;
		end
	end
end

local function populateChunkPointers()
	object_pointers = {};
	if Game.isLoading() then
		object_index = 1;
		return;
	end
	local chunkArray = Game.getChunkArray();
	if isRDRAM(chunkArray) then
		local numChunks = math.floor(mainmemory.read_u32_be(chunkArray + heap.object_size) / chunk.size);
		for i = 0, numChunks - 1 do
			local chunkBase = chunkArray + i * chunk.size;
			table.insert(object_pointers, chunkBase);
		end

		-- Clamp index
		object_index = math.min(object_index, math.max(1, #object_pointers));
	end
end

-----------
-- Exits --
-----------

local exit = {
	x_pos = 0x00, -- s16_be
	y_pos = 0x02, -- s16_be
	z_pos = 0x04, -- s16_be
	size = 0x0A,
};

function Game.getExitData(exitBase)
	return {
		xPos = mainmemory.read_s16_be(exitBase + exit.x_pos),
		yPos = mainmemory.read_s16_be(exitBase + exit.y_pos),
		zPos = mainmemory.read_s16_be(exitBase + exit.z_pos),
	};
end

function Game.getDestinationExit()
	return mainmemory.read_u32_be(Game.Memory.destination_exit);
end

function Game.getNumberOfExits()
	return mainmemory.readbyte(Game.Memory.number_of_exits);
end

function Game.getExitOSD()
	return Game.getDestinationExit().."/"..Game.getNumberOfExits();
end

function dumpExits()
	local exitArray = dereferencePointer(Game.Memory.exit_array_pointer);
	local numberOfExits = Game.getNumberOfExits();
	if isRDRAM(exitArray) then
		for i = 0, numberOfExits - 1 do
			local exitBase = exitArray + i * exit.size;
			local exitData = Game.getExitData(exitBase);
			dprint("Exit "..i..": "..exitData.xPos..", "..exitData.yPos..", "..exitData.zPos);
		end
		print_deferred();
	end
end

local function populateExitPointers()
	local exitArray = dereferencePointer(Game.Memory.exit_array_pointer);
	object_pointers = {};
	if isRDRAM(exitArray) then
		local numberOfExits = Game.getNumberOfExits();
		for i = 0, numberOfExits - 1 do
			local exitBase = exitArray + i * exit.size;
			table.insert(object_pointers, exitBase);
		end
	end
end

function dumpEnemyTypes()
	dprint("Index,Address,Behavior,Model,Behavior Name,Model Name,");
	for i = 0, Game.Memory.num_enemy_types do
		local base = Game.Memory.enemy_table + i * Game.Memory.enemy_type_size;
		local behavior = mainmemory.read_u16_be(base);
		local model = mainmemory.read_u16_be(base + 2);
		dprint(toHexString(i)..","..toHexString(base)..","..toHexString(behavior, 4)..","..toHexString(model, 4)..","..getActorNameFromBehavior(behavior)..","..getModelNameFromModelIndex(model)..",");
	end
	print_deferred();
end

function everyEnemyIs(index)
	local enemyTypeSize = Game.Memory.enemy_type_size;
	local chosenSlotData = {};
	local chosenSlotBase = Game.Memory.enemy_table + index * enemyTypeSize;
	for i = 0, enemyTypeSize - 1 do
		chosenSlotData[i] = mainmemory.readbyte(chosenSlotBase + i);
	end
	for i = 0, Game.Memory.num_enemy_types do
		local base = Game.Memory.enemy_table + i * enemyTypeSize;
		for j = 0, enemyTypeSize - 1 do
			mainmemory.writebyte(base + j, chosenSlotData[j]);
		end
	end
end

function replaceModels(index)
	-- Cutscene
	local max_index = 0x42;
	if Game.version == 4 then
		max_index = 0x1B;
	end
	for i = 0, max_index do
		mainmemory.write_u16_be(Game.Memory.cutscene_model_table + i * 2, index);
	end

	-- Enemy
	for i = 0, Game.Memory.num_enemy_types do
		local base = Game.Memory.enemy_table + i * Game.Memory.enemy_type_size;
		mainmemory.write_u16_be(base + 2, index);
	end

	-- Object Spawn Table
	max_index = 127;
	if Game.version == 4 then
		max_index = 110;
	end
	for i = 0, max_index do
		local base = Game.Memory.object_spawn_table + i * 0x30;
		mainmemory.write_u16_be(base + 0x02, index);
	end
end

function dumpCutsceneModelTable()
	local max_index = 0x42;
	if Game.version == 4 then
		max_index = 0x1B;
	end
	dprint("Index,Address,Model,Model Name");
	for i = 0, max_index do
		local base = Game.Memory.cutscene_model_table + i * 2;
		local model = mainmemory.read_u16_be(base);
		dprint(i..","..toHexString(base, 6)..","..toHexString(model, 4)..","..getModelNameFromModelIndex(model));
	end
	print_deferred();
end

function getModelNameFromCutsceneIndex(index)
	local modelIndex = mainmemory.read_u16_be(Game.Memory.cutscene_model_table + index * 2);
	return getModelNameFromModelIndex(modelIndex);
end

function getBehaviorNameFromEnemyIndex(index)
	local enemyTypeSize = 0x18;
	if Game.version == 4 then
		enemyTypeSize = 0x1C;
	end
	local behaviorIndex = mainmemory.read_u16_be(Game.Memory.enemy_table + index * enemyTypeSize);
	return getActorNameFromBehavior(behaviorIndex);
end

function Game.getEnemyData(slotBase)
	local enemyType = mainmemory.readbyte(slotBase);
	local enemyName = getBehaviorNameFromEnemyIndex(enemyType);
	if enemyType == 0x50 then
		local cutsceneModelIndex = mainmemory.readbyte(slotBase + 0x0A);
		enemyName = enemyName.." ("..getModelNameFromCutsceneIndex(cutsceneModelIndex)..")";
	end
	return {
		slotBase = slotBase,
		enemyType = enemyType,
		enemyName = enemyName,
		yRot = mainmemory.read_u16_be(slotBase + 0x02),
		xPos = mainmemory.read_s16_be(slotBase + 0x04),
		yPos = mainmemory.read_s16_be(slotBase + 0x06),
		zPos = mainmemory.read_s16_be(slotBase + 0x08),
	};
end

function dumpEnemies()
	local enemyRespawnObject = dereferencePointer(Game.Memory.enemy_respawn_object);
	local enemySlotSize = 0x48;
	if Game.version == 4 then
		enemySlotSize = 0x44;
	end
	if isRDRAM(enemyRespawnObject) then
		local numberOfEnemies = mainmemory.read_u16_be(Game.Memory.num_enemies);
		for i = 1, numberOfEnemies do
			local slotBase = enemyRespawnObject + (i - 1) * enemySlotSize;
			local enemyData = Game.getEnemyData(slotBase);
			dprint(i.." "..toHexString(slotBase)..": "..enemyData.enemyName.." at "..enemyData.xPos..", "..enemyData.yPos..", "..enemyData.zPos);
		end
		print_deferred();
	end
end

function Game.populateEnemyPointers()
	local enemyRespawnObject = dereferencePointer(Game.Memory.enemy_respawn_object);
	local enemySlotSize = 0x48;
	if Game.version == 4 then
		enemySlotSize = 0x44;
	end
	object_pointers = {};
	if isRDRAM(enemyRespawnObject) then
		local numberOfEnemies = mainmemory.read_u16_be(Game.Memory.num_enemies);
		for i = 1, numberOfEnemies do
			local slotBase = enemyRespawnObject + (i - 1) * enemySlotSize;
			table.insert(object_pointers, slotBase);
		end
	end
end

function dumpEnemyDrops()
	local objectBase, object;
	local droppedObject, dropMusic, dropCount;
	local index = -1;
	repeat
		index = index + 1;
		objectBase = Game.Memory.enemy_drop_table + index * 0x06;
		object = mainmemory.read_u16_be(objectBase);
		if object ~= 0 then
			droppedObject = mainmemory.read_u16_be(objectBase + 0x02);
			dropMusic = mainmemory.readbyte(objectBase + 0x04);
			dropCount = mainmemory.readbyte(objectBase + 0x05);
			dprint(toHexString(objectBase)..": "..getActorNameFromBehavior(object).." drops "..dropCount.." "..getActorNameFromBehavior(droppedObject).." and plays "..toHexString(dropMusic));
		end
	until object == 0;
	print_deferred();
end

function everyEnemyDrops(actorType, count, music)
	local object, objectBase;
	local index = -1;
	repeat
		index = index + 1;
		objectBase = Game.Memory.enemy_drop_table + index * 0x06;
		object = mainmemory.read_u16_be(objectBase);
		if object ~= 0 then
			mainmemory.write_u16_be(objectBase + 0x02, actorType);
			mainmemory.writebyte(objectBase + 0x04, music);
			mainmemory.writebyte(objectBase + 0x05, count);
		end
	until object == 0;
end

function dumpObjectSpawnTable()
	print("Index,Behavior,Model,Name,Model Name,Internal Name,");
	local max_index = 127;
	if Game.version == 4 then
		max_index = 110;
	end
	for i = 0, max_index do
		local base = Game.Memory.object_spawn_table + i * 0x30;
		local behavior = mainmemory.read_u16_be(base + 0x00);
		local model = mainmemory.read_u16_be(base + 0x02);
		local name = getActorNameFromBehavior(behavior);
		local modelName = getModelNameFromModelIndex(model);
		local internalName = readNullTerminatedString(base + 0x14);
		dprint(i..","..toHexString(behavior, 4)..","..toHexString(model, 4)..","..name..","..modelName..","..internalName..",");
	end
	print_deferred();
end

-------------------
-- Arcade Object --
-------------------

function populateArcadeObjects()
	object_pointers = {};

	if Game.version == 4 then
		return;
	end

	for i = 0, arcade_object.count - 1 do
		local objectBase = Game.Memory.arcade_object_base + (i * arcade_object.size);
		if mainmemory.readbyte(objectBase + arcade_object.object_type) > 0 and map_value == arcade_map then
			table.insert(object_pointers, objectBase);
		end
	end
end

-------------------
-- Physics/Scale --
-------------------

local function isInSubGame()
	return map_value == arcade_map or map_value == jetpac_map;
end

function Game.getFloor()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		return mainmemory.readfloat(playerObject + obj_model1.floor, true);
	end
	return 0;
end

function Game.setFloor(value)
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		mainmemory.writefloat(playerObject + obj_model1.floor, value, true);
	end
end

function Game.getDistanceFromFloor()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		return mainmemory.readfloat(playerObject + obj_model1.distance_from_floor, true);
	end
	return 0;
end

function Game.getChunk()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		return mainmemory.read_u16_be(playerObject + obj_model1.chunk);
	end
	return 0;
end

function Game.getCameraState()
	local cameraObject = dereferencePointer(Game.Memory.camera_pointer);
	local cameraState = "Unknown";
	if isRDRAM(cameraObject) then
		cameraState = mainmemory.readbyte(cameraObject + obj_model1.camera.state_type);
		if obj_model1.camera.state_values[cameraState] ~= nil then
			cameraState = obj_model1.camera.state_values[cameraState];
		else
			cameraState = toHexString(cameraState);
		end
	end
	return cameraState;
end

function Game.getMovementState()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local controlState = mainmemory.readbyte(playerObject + obj_model1.control_state_byte);
		local shockwave_timer = mainmemory.read_s16_be(playerObject + obj_model1.player.shockwave_charge_timer);
		local controlStateTimer = mainmemory.readbyte(playerObject + obj_model1.control_state_progress);
		if obj_model1.control_states[controlState] ~= nil then
			if controlState == 0x2 or controlState == 0x3 then -- First Person Camera
				return obj_model1.control_states[controlState].." ("..controlStateTimer..")";
			elseif shockwave_timer > -1 then
				return obj_model1.control_states[controlState].." ("..shockwave_timer..")";
			else
				return obj_model1.control_states[controlState];
			end
		end
		return toHexString(controlState);
	end
	return 'Unknown';
end

function Game.setMovementState(value)
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		mainmemory.writebyte(playerObject + obj_model1.control_state_byte, value);
	end
end
Game.setControlState = Game.setMovementState;

function Game.getAnimation()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local animationUsed = mainmemory.read_u16_be(playerObject + obj_model1.player.animation);
		if obj_model1.animations[animationUsed] ~= nil then
			return obj_model1.animations[animationUsed];
		end
		return toHexString(animationUsed);
	end
	return 'Unknown';
end

function Game.getNoclipByte()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		return toHexString(mainmemory.readbyte(playerObject + obj_model1.noclip_byte));
	end
	return "Unknown";
end

function Game.colorNoclipByte()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local value = mainmemory.readbyte(playerObject + obj_model1.noclip_byte);
		if not (bit.check(value, 2) and bit.check(value, 3)) then
			return 0xFF007FFF; -- Blue
		end
	end
end

function Game.setNoclipByte(value)
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		mainmemory.writebyte(playerObject + obj_model1.noclip_byte, value);
	end
end

function Game.getAnimationTimer1()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local renderingParams = dereferencePointer(playerObject + obj_model1.rendering_parameters_pointer);
		if isRDRAM(renderingParams) then
			return mainmemory.readfloat(renderingParams + obj_model1.rendering_parameters.anim_timer1, true);
		end
	end
	return 0;
end

function Game.setAnimationTimer1(value)
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local renderingParams = dereferencePointer(playerObject + obj_model1.rendering_parameters_pointer);
		if isRDRAM(renderingParams) then
			mainmemory.writefloat(renderingParams + obj_model1.rendering_parameters.anim_timer1, value, true);
		end
	end
end

function Game.getAnimationTimer2()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local renderingParams = dereferencePointer(playerObject + obj_model1.rendering_parameters_pointer);
		if isRDRAM(renderingParams) then
			return mainmemory.readfloat(renderingParams + obj_model1.rendering_parameters.anim_timer2, true);
		end
	end
	return 0;
end

function Game.setAnimationTimer2(value)
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local renderingParams = dereferencePointer(playerObject + obj_model1.rendering_parameters_pointer);
		if isRDRAM(renderingParams) then
			mainmemory.writefloat(renderingParams + obj_model1.rendering_parameters.anim_timer2, value, true);
		end
	end
end

function Game.getAnimationTimer3()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local renderingParams = dereferencePointer(playerObject + obj_model1.rendering_parameters_pointer);
		if isRDRAM(renderingParams) then
			return mainmemory.readfloat(renderingParams + obj_model1.rendering_parameters.anim_timer3, true);
		end
	end
	return 0;
end

function Game.setAnimationTimer3(value)
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local renderingParams = dereferencePointer(playerObject + obj_model1.rendering_parameters_pointer);
		if isRDRAM(renderingParams) then
			mainmemory.writefloat(renderingParams + obj_model1.rendering_parameters.anim_timer3, value, true);
		end
	end
end

function Game.getAnimationTimer4()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local renderingParams = dereferencePointer(playerObject + obj_model1.rendering_parameters_pointer);
		if isRDRAM(renderingParams) then
			return mainmemory.readfloat(renderingParams + obj_model1.rendering_parameters.anim_timer4, true);
		end
	end
	return 0;
end

function Game.setAnimationTimer4(value)
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local renderingParams = dereferencePointer(playerObject + obj_model1.rendering_parameters_pointer);
		if isRDRAM(renderingParams) then
			mainmemory.writefloat(renderingParams + obj_model1.rendering_parameters.anim_timer4, value, true);
		end
	end
end

--------------
-- Position --
--------------

function Game.getXPosition()
	if map_value == arcade_map then
		local jumpman = Game.getJumpman();
		if isRDRAM(jumpman) then
			return mainmemory.readfloat(jumpman + arcade_object.x_position, true);
		end
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(Game.Memory.jetman_position_x, true);
	end
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		return mainmemory.readfloat(playerObject + obj_model1.x_pos, true);
	end
	return 0;
end

function Game.getYPosition()
	if map_value == arcade_map then
		local jumpman = Game.getJumpman();
		if isRDRAM(jumpman) then
			return mainmemory.readfloat(jumpman + arcade_object.y_position, true);
		end
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(Game.Memory.jetman_position_y, true);
	end
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		return mainmemory.readfloat(playerObject + obj_model1.y_pos, true);
	end
	return 0;
end

function Game.getZPosition()
	if not isInSubGame() then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			return mainmemory.readfloat(playerObject + obj_model1.z_pos, true);
		end
	end
	return 0;
end

function Game.setXPosition(value)
	if map_value == arcade_map then
		--[[
		local jumpman = Game.getJumpman();
		if isRDRAM(jumpman) then
			mainmemory.writefloat(jumpman + arcade_object.x_position, value, true);
		end
		--]]
	elseif map_value == jetpac_map then
		--mainmemory.writefloat(Game.Memory.jetman_position_x, value, true);
	else
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			local vehiclePointer = dereferencePointer(playerObject + obj_model1.player.vehicle_actor_pointer);
			if isRDRAM(vehiclePointer) then
				mainmemory.writefloat(vehiclePointer + obj_model1.x_pos, value, true);
			end
			mainmemory.writefloat(playerObject + obj_model1.x_pos, value, true);
			mainmemory.writebyte(playerObject + obj_model1.locked_to_pad, 0x00);
			mainmemory.write_u32_be(playerObject + obj_model1.collision_queue_pointer, 0x00);
		end
	end
end

function Game.setYPosition(value)
	if map_value == arcade_map then
		--[[
		local jumpman = Game.getJumpman();
		if isRDRAM(jumpman) then
			mainmemory.writefloat(jumpman + arcade_object.y_position, value, true);
		end
		--]]
	elseif map_value == jetpac_map then
		--mainmemory.writefloat(Game.Memory.jetman_position_y, value, true);
	else
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			local vehiclePointer = dereferencePointer(playerObject + obj_model1.player.vehicle_actor_pointer);
			if isRDRAM(vehiclePointer) then
				if mainmemory.readfloat(vehiclePointer + obj_model1.floor, true) > value then -- Move the vehicle floor down if the desired Y position is lower than the floor
					mainmemory.writefloat(vehiclePointer + obj_model1.floor, value, true);
				end
				mainmemory.writefloat(vehiclePointer + obj_model1.y_pos, value, true);
				mainmemory.writebyte(vehiclePointer + obj_model1.locked_to_pad, 0);
			end
			mainmemory.writefloat(playerObject + obj_model1.y_pos, value, true);
			mainmemory.writebyte(playerObject + obj_model1.locked_to_pad, 0);
			if Game.getFloor() > value then  -- Move the floor down if the desired Y position is lower than the floor
				Game.setFloor(value);
			end
			Game.setYVelocity(0);
		end
	end
end

function Game.setZPosition(value)
	if not isInSubGame() then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			local vehiclePointer = dereferencePointer(playerObject + obj_model1.player.vehicle_actor_pointer);
			if isRDRAM(vehiclePointer) then
				mainmemory.writefloat(vehiclePointer + obj_model1.z_pos, value, true);
			end
			mainmemory.writefloat(playerObject + obj_model1.z_pos, value, true);
			mainmemory.writebyte(playerObject + obj_model1.locked_to_pad, 0x00);
			mainmemory.write_u32_be(playerObject + obj_model1.collision_queue_pointer, 0x00);
		end
	end
end

-- Relative to objects in bone array
local bone_size = 0x40;
local bone = {
	position_x = 0x18, -- int 16 be
	position_y = 0x1A, -- int 16 be
	position_z = 0x1C, -- int 16 be
	scale_x = 0x20, -- uint 16 be
	scale_y = 0x2A, -- uint 16 be
	scale_z = 0x34, -- uint 16 be
};

function Game.getActiveBoneArray(actorPointer)
	if not isInSubGame() then
		if isRDRAM(actorPointer) then
			return mainmemory.read_u32_be(actorPointer + obj_model1.current_bone_array_pointer);
		end
	end
	return 0;
end

function Game.getBoneArray1(actorPointer)
	if isRDRAM(actorPointer) then
		local animationParamObject = dereferencePointer(actorPointer + obj_model1.rendering_parameters_pointer);
		if isRDRAM(animationParamObject) then
			return mainmemory.read_u32_be(animationParamObject + obj_model1.rendering_parameters.bone_array_1);
		end
	end
	return 0;
end

function Game.getBoneArray2(actorPointer)
	if isRDRAM(actorPointer) then
		local animationParamObject = dereferencePointer(actorPointer + obj_model1.rendering_parameters_pointer);
		if isRDRAM(animationParamObject) then
			return mainmemory.read_u32_be(animationParamObject + obj_model1.rendering_parameters.bone_array_2);
		end
	end
	return 0;
end

function Game.getBoneArray1PrettyPrint(actorPointer)
	if isRDRAM(actorPointer) then
		local suffix = " ";
		local boneArray1 = Game.getBoneArray1(actorPointer);
		if Game.getActiveBoneArray(actorPointer) == boneArray1 then
			suffix = "*";
		end
		return toHexString(boneArray1)..suffix;
	end
	return "Not found";
end

function Game.getBoneArray2PrettyPrint(actorPointer)
	if isRDRAM(actorPointer) then
		local suffix = " ";
		local boneArray2 = Game.getBoneArray2(actorPointer);
		if Game.getActiveBoneArray(actorPointer) == boneArray2 then
			suffix = "*";
		end
		return toHexString(boneArray2)..suffix;
	end
	return "Not found";
end

function Game.getStoredX1(actorPointer)
	local boneArray1 = Game.getBoneArray1(actorPointer);
	if isPointer(boneArray1) then
		boneArray1 = boneArray1 - RDRAMBase;
		return mainmemory.read_s16_be(boneArray1 + bone_size + bone.position_x);
	end
	return 0;
end

function Game.getStoredX2(actorPointer)
	local boneArray2 = Game.getBoneArray2(actorPointer);
	if isPointer(boneArray2) then
		boneArray2 = boneArray2 - RDRAMBase;
		return mainmemory.read_s16_be(boneArray2 + bone_size + bone.position_x);
	end
	return 0;
end

function Game.getStoredY1(actorPointer)
	local boneArray1 = Game.getBoneArray1(actorPointer);
	if isPointer(boneArray1) then
		boneArray1 = boneArray1 - RDRAMBase;
		return mainmemory.read_s16_be(boneArray1 + bone_size + bone.position_y);
	end
	return 0;
end

function Game.getStoredY2(actorPointer)
	local boneArray2 = Game.getBoneArray2(actorPointer);
	if isPointer(boneArray2) then
		boneArray2 = boneArray2 - RDRAMBase;
		return mainmemory.read_s16_be(boneArray2 + bone_size + bone.position_y);
	end
	return 0;
end

function Game.getStoredZ1(actorPointer)
	local boneArray1 = Game.getBoneArray1(actorPointer);
	if isPointer(boneArray1) then
		boneArray1 = boneArray1 - RDRAMBase;
		return mainmemory.read_s16_be(boneArray1 + bone_size + bone.position_z);
	end
	return 0;
end

function Game.getStoredZ2(actorPointer)
	local boneArray2 = Game.getBoneArray2(actorPointer);
	if isPointer(boneArray2) then
		boneArray2 = boneArray2 - RDRAMBase;
		return mainmemory.read_s16_be(boneArray2 + bone_size + bone.position_z);
	end
	return 0;
end

--------------
-- Rotation --
--------------

function Game.getXRotation()
	if not isInSubGame() then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			return mainmemory.read_u16_be(playerObject + obj_model1.x_rot);
		end
	end
	return 0;
end

function Game.getYRotation()
	if not isInSubGame() then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			return mainmemory.read_u16_be(playerObject + obj_model1.y_rot);
		end
	end
	return 0;
end

function Game.colorYRotation()
	local currentRotation = Game.getYRotation()
	if currentRotation > 4095 then -- Detect STVW angles
		return 0xFF007FFF; -- Blue
	end
end

function Game.getStoredYRotation()
	if not isInSubGame() then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			return mainmemory.read_u16_be(playerObject + obj_model1.player.stored_y_rotation);
		end
	end
	return 0;
end

function Game.colorStoredYRotation()
	local currentStoredRotation = Game.getStoredYRotation()
	if currentStoredRotation > 4095 then -- Detect STVW angles
		return 0xFF007FFF; -- Blue
	end
end

function Game.getZRotation()
	if not isInSubGame() then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			return mainmemory.read_u16_be(playerObject + obj_model1.z_rot);
		end
	end
	return 0;
end

function Game.setXRotation(value)
	if not isInSubGame() then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			mainmemory.write_u16_be(playerObject + obj_model1.x_rot, value);
		end
	end
end

function Game.setYRotation(value)
	if not isInSubGame() then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			mainmemory.write_u16_be(playerObject + obj_model1.y_rot, value);
		end
	end
end

function Game.setZRotation(value)
	if not isInSubGame() then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			mainmemory.write_u16_be(playerObject + obj_model1.z_rot, value);
		end
	end
end

-----------------------------
-- Velocity & Acceleration --
-----------------------------

function Game.getVelocity()
	local playerObject = Game.getPlayerObject();
	if map_value == arcade_map then
		local jumpman = Game.getJumpman();
		if isRDRAM(jumpman) then
			return mainmemory.readfloat(jumpman + arcade_object.x_velocity, true);
		end
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(Game.Memory.jetman_velocity_x, true);
	elseif isRDRAM(playerObject) then
		return mainmemory.readfloat(playerObject + obj_model1.velocity, true);
	end
	return 0;
end

function Game.setVelocity(value)
	local playerObject = Game.getPlayerObject();
	if map_value == arcade_map then
		--[[
		local jumpman = Game.getJumpman();
		if isRDRAM(jumpman) then
			mainmemory.writefloat(jumpman + arcade_object.x_velocity, value, true);
		end
		--]]
	elseif map_value == jetpac_map then
		mainmemory.writefloat(Game.Memory.jetman_velocity_x, value, true);
	elseif isRDRAM(playerObject) then
		mainmemory.writefloat(playerObject + obj_model1.velocity, value, true);
	end
end

function Game.getYVelocity()
	local playerObject = Game.getPlayerObject();
	if map_value == arcade_map then
		local jumpman = Game.getJumpman();
		if isRDRAM(jumpman) then
			return mainmemory.readfloat(jumpman + arcade_object.y_velocity, true);
		end
	elseif map_value == jetpac_map then
		return mainmemory.readfloat(Game.Memory.jetman_velocity_y, true);
	elseif isRDRAM(playerObject) then
		return mainmemory.readfloat(playerObject + obj_model1.y_velocity, true);
	end
	return 0;
end

function Game.setYVelocity(value)
	local playerObject = Game.getPlayerObject();
	if map_value == arcade_map then
		--[[
		local jumpman = Game.getJumpman();
		if isRDRAM(jumpman) then
			mainmemory.writefloat(jumpman + arcade_object.y_velocity, value, true);
		end
		--]]
	elseif map_value == jetpac_map then
		mainmemory.writefloat(Game.Memory.jetman_velocity_y, value, true);
	elseif isRDRAM(playerObject) then
		mainmemory.writefloat(playerObject + obj_model1.y_velocity, value, true);
	end
end

function Game.getYAcceleration()
	if not isInSubGame() then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			return mainmemory.readfloat(playerObject + obj_model1.y_acceleration, true);
		end
	end
	return 0;
end

function Game.setYAcceleration(value)
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		mainmemory.writefloat(playerObject + obj_model1.y_acceleration, value, true);
	end
end

--------------------
-- Misc functions --
--------------------

local current_invisify = "Invisify";
local function toggle_invisify()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local visibilityBitfieldValue = mainmemory.readbyte(playerObject + obj_model1.visibility);
		mainmemory.writebyte(playerObject + obj_model1.visibility, bit.toggle(visibilityBitfieldValue, 2));
	end
end

local function updateCurrentInvisify()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local isVisible = bit.check(mainmemory.readbyte(playerObject + obj_model1.visibility), 2);
		if isVisible then
			current_invisify = "Invisify";
		else
			current_invisify = "Visify";
		end
		forms.settext(ScriptHawk.UI.form_controls["Toggle Visibility Button"], current_invisify);
	end
end

function Game.toggleTBVoid()
	local tb_void_byte_val = mainmemory.readbyte(Game.Memory.tb_void_byte);
	tb_void_byte_val = bit.toggle(tb_void_byte_val, 4); -- Turn on the lights
	tb_void_byte_val = bit.toggle(tb_void_byte_val, 5); -- Show Object Model 2 Objects
	mainmemory.writebyte(Game.Memory.tb_void_byte, tb_void_byte_val);
end

function Game.forcePause()
	local voidByteValue = mainmemory.readbyte(Game.Memory.tb_void_byte);
	mainmemory.writebyte(Game.Memory.tb_void_byte, bit.set(voidByteValue, 0));
end

function Game.forceZipper()
	local voidByteValue = mainmemory.readbyte(Game.Memory.tb_void_byte - 1);
	mainmemory.writebyte(Game.Memory.tb_void_byte - 1, bit.set(voidByteValue, 0));
end

function Game.pauseCancel()
	local pause_cancel_byte_val = mainmemory.readbyte(Game.Memory.tb_void_byte);
	mainmemory.writebyte(Game.Memory.tb_void_byte, bit.set(pause_cancel_byte_val, 6)); -- Gives Pause Cancel
end

function Game.gainControl()
	local playerObject = Game.getPlayerObject();
	local cameraObject = dereferencePointer(Game.Memory.camera_pointer);
	if isRDRAM(playerObject) then
		local visibilityBitfieldValue = mainmemory.readbyte(playerObject + obj_model1.visibility);
		mainmemory.writebyte(playerObject + obj_model1.visibility, bit.set(visibilityBitfieldValue, 2));
		mainmemory.writebyte(playerObject + obj_model1.control_state_byte, 0x0C);
		local vehiclePointer = dereferencePointer(playerObject + obj_model1.player.vehicle_actor_pointer);
		if isRDRAM(vehiclePointer) then
			mainmemory.write_u32_be(playerObject + obj_model1.player.vehicle_actor_pointer, playerObject + RDRAMBase);
		end
		--mainmemory.write_u32_be(playerObject + obj_model1.collision_queue_pointer, 0);
		if isRDRAM(cameraObject) then
			mainmemory.writebyte(cameraObject + obj_model1.camera.state_type, 1);
			mainmemory.write_u32_be(cameraObject + obj_model1.camera.focused_vehicle_pointer, 0);
			mainmemory.write_u32_be(cameraObject + obj_model1.camera.focused_vehicle_pointer_2, 0);
		end
	end
	mainmemory.write_u16_be(Game.Memory.buttons_enabled_bitfield, 0xFFFF); -- Enable all buttons
	mainmemory.writebyte(Game.Memory.joystick_enabled_x, 0xFF); -- Enable Joystick X axis
	mainmemory.writebyte(Game.Memory.joystick_enabled_y, 0xFF); -- Enable Joystick X axis
	mainmemory.writebyte(Game.Memory.map_state, 0x08); -- Patch map state byte to a value where the player has control, allows gaining control during death and some cutscenes
end

-- TODO: Fix the frame delay for this
function Game.detonateLiveOranges()
	for actorListIndex = 0, getObjectModel1Count() do
		local pointer = dereferencePointer(Game.Memory.actor_pointer_array + (actorListIndex * 4));
		if isRDRAM(pointer) then
			local actorType = mainmemory.read_u16_be(pointer + obj_model1.actor_type);
			if actorType == 41 then -- Orange
				mainmemory.writebyte(pointer + 0x6D, 1); -- Set grounded bit?
				mainmemory.writefloat(pointer + obj_model1.y_pos, mainmemory.readfloat(pointer + obj_model1.floor, true), true);
				mainmemory.writefloat(pointer + obj_model1.distance_from_floor, 0, true);
				mainmemory.writefloat(pointer + obj_model1.y_acceleration, -50, true);
				mainmemory.writefloat(pointer + obj_model1.y_velocity, -50, true);
				mainmemory.writebyte(pointer + obj_model1.orange.bounce_counter, 3);
			end
		end
	end
end

-----------------------------------
-- DK64 - Mad Jack Minimap
-- Written by Isotarge, 2014-2015
-----------------------------------

-- Colors (ARGB32)
local MJ_colors = {
	blue = 0x7F00A2E8,
	blue_switch = 0xFF00A2E8,
	white = 0x7FFFFFFF,
	white_switch = colors.white
};

-- Minimap ui
local MJ_minimap_x_offset  = 19;
local MJ_minimap_y_offset  = 19;
local MJ_minimap_width     = 16;
local MJ_minimap_height    = 16;

local MJ_minimap_text_x = MJ_minimap_x_offset + 4.5 * MJ_minimap_width;
local MJ_minimap_text_y = MJ_minimap_y_offset;

local MJ_minimap_phase_number_y      = MJ_minimap_text_y;
local MJ_minimap_actions_remaining_y = MJ_minimap_phase_number_y + MJ_minimap_height;
local MJ_time_until_next_action_y    = MJ_minimap_actions_remaining_y + MJ_minimap_height;

local MJ_kong_row_y                  = MJ_time_until_next_action_y + MJ_minimap_height;
local MJ_kong_col_y                  = MJ_kong_row_y + MJ_minimap_height;

local function position_to_rowcol(pos)
	pos = math.floor((pos - 330) / 120); -- Calculate row index
	return math.min(7, math.max(0, pos)); -- Clamp between 0 and 7
end

local function MJ_get_col_mask(position)
	return bit.band(position, 0x03);
end

local function MJ_get_row_mask(position)
	return bit.rshift(bit.band(position, 0x0C), 2);
end

local function MJ_get_switch_active_mask(position)
	return bit.rshift(bit.band(position, 0x10), 4) > 0;
end

local function MJ_get_color(col, row)
	local color = 'blue';
	if row % 2 == col % 2 then
		color = 'white';
	end
	return color;
end

local function MJ_get_action_type(phase_byte)
	if phase_byte == 0x28 or phase_byte == 0x2D or phase_byte == 0x32 then
		return "Fireball";
	elseif phase_byte == 0x01 or phase_byte == 0x05 then
		return "Laser";
	end
	return "Jump";
end

local function MJ_get_arrow_image(current, new)
	if new.row > current.row then
		if new.col > current.col then
			return image_directory_root.."up_right.png";
		elseif new.col == current.col then
			return image_directory_root.."up.png";
		elseif new.col < current.col then
			return image_directory_root.."up_left.png";
		end
	elseif new.row == current.row then
		if new.col > current.col then
			return image_directory_root.."right.png";
		elseif new.col < current.col then
			return image_directory_root.."left.png";
		end
	elseif new.row < current.row then
		if new.col > current.col then
			return image_directory_root.."down_right.png";
		elseif new.col == current.col then
			return image_directory_root.."down.png";
		elseif new.col < current.col then
			return image_directory_root.."down_left.png";
		end
	end
	return image_directory_root.."question-mark.png";
end

local function MJ_parse_position(position)
	return {
		active = MJ_get_switch_active_mask(position),
		col = MJ_get_col_mask(position),
		row = MJ_get_row_mask(position),
	};
end

local function getMadJack()
	for object_no = 0, getObjectModel1Count() do
		local pointer = dereferencePointer(Game.Memory.actor_pointer_array + (object_no * 4));
		if isRDRAM(pointer) and getActorName(pointer) == "Mad Jack" then
			return pointer;
		end
	end
end

function Game.drawMJMinimap()
	-- Only draw minimap if the player is in the Mad Jack fight
	if Game.version ~= 4 and map_value == 154 then
		local MJ_state = getMadJack();
		if not isRDRAM(MJ_state) then -- MJ object not found
			return;
		end

		local cur_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + obj_model1.mad_jack.current_position[Game.version]));
		local next_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + obj_model1.mad_jack.next_position[Game.version]));

		local white_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + obj_model1.mad_jack.white_switch_position[Game.version]));
		local blue_pos = MJ_parse_position(mainmemory.readbyte(MJ_state + obj_model1.mad_jack.blue_switch_position[Game.version]));

		local switches_active = white_pos.active or blue_pos.active;

		local x, y, color;

		-- Calculate where the kong is on the MJ Board
		local kongPosition = {
			col = math.floor(position_to_rowcol(Game.getZPosition()) / 2),
			row = math.floor(position_to_rowcol(Game.getXPosition()) / 2),
		};

		for row = 0, 3 do
			for col = 0, 3 do
				x = MJ_minimap_x_offset + col * MJ_minimap_width;
				y = MJ_minimap_y_offset + (3 - row) * MJ_minimap_height;

				color = MJ_colors.blue;
				if MJ_get_color(col, row) == 'white' then
					color = MJ_colors.white;
				end

				if switches_active then
					if white_pos.row == row and white_pos.col == col and MJ_get_color(cur_pos.col, cur_pos.row) == 'white' then
						color = MJ_colors.white_switch;
					elseif blue_pos.row == row and blue_pos.col == col and MJ_get_color(cur_pos.col, cur_pos.row) == 'blue' then
						color = MJ_colors.blue_switch;
					end
				end

				gui.drawRectangle(x, y, MJ_minimap_width, MJ_minimap_height, 0, color);

				if switches_active then
					if (white_pos.row == row and white_pos.col == col) or (blue_pos.row == row and blue_pos.col == col) then
						gui.drawImage(image_directory_root.."switch.png", x, y, MJ_minimap_width, MJ_minimap_height);
						--gui.drawText(x, y, "S");
					end
				end

				if cur_pos.row == row and cur_pos.col == col then
					gui.drawImage(image_directory_root.."jack_icon.png", x, y, MJ_minimap_width, MJ_minimap_height);
					--gui.drawText(x, y, "J")
				elseif next_pos.row == row and next_pos.col == col then
					gui.drawImage(MJ_get_arrow_image(cur_pos, next_pos), x, y, MJ_minimap_width, MJ_minimap_height);
					--gui.drawText(x, y, "N");
				end

				if kongPosition.row == row and kongPosition.col == col then
					gui.drawImage(image_directory_root.."TinyFaceEdited.png", x, y, MJ_minimap_width, MJ_minimap_height);
					--gui.drawText(x, y, "K");
				end
			end
		end

		-- Text info
		local phase_byte = mainmemory.readbyte(MJ_state + obj_model1.mad_jack.action_type[Game.version]);
		local actions_remaining = mainmemory.readbyte(MJ_state + obj_model1.mad_jack.actions_remaining[Game.version]);
		local time_until_next_action = mainmemory.readbyte(MJ_state + obj_model1.mad_jack.ticks_until_next_action[Game.version]);

		local phase = mainmemory.readbyte(MJ_state + obj_model1.mad_jack.phase[Game.version]) + 1;
		local action_type = MJ_get_action_type(phase_byte);

		gui.drawText(MJ_minimap_text_x, MJ_minimap_actions_remaining_y, actions_remaining.." "..action_type.."s remaining");

		if action_type ~= "Jump" then
			gui.drawText(MJ_minimap_text_x, MJ_minimap_phase_number_y, "Phase "..phase.." (switch)");
			gui.drawText(MJ_minimap_text_x, MJ_time_until_next_action_y, time_until_next_action.." ticks until next "..action_type);
		else
			gui.drawText(MJ_minimap_text_x, MJ_minimap_phase_number_y, "Phase "..phase);
		end
	end
end

-----------------------------------
-- DK64 - Kut Out Minimap        --
-- Written by theballaam96, 2019 --
-----------------------------------

-- Static Data
local kko = {
	minimap_x_offset = 19,
	minimap_y_offset = 19,
	minimap_width    = 100,
	minimap_height   = 100,
	map_ubound       = 1006,
	map_lbound   = 394,
	states = {
		[0] = "Ready to Appear",
		[1] = "Ready for Kong Attack",
		[2] = "Not Able to be hit",
		[3] = "Kut-Out Attacking",
		[4] = "Self-Amputation",
		[5] = "Disappearing", -- After final hit in phase
		[6] = "Rotating", -- Phase 4
		[7] = "Defeat Pending",
		[8] = "Defeated",
		[9] = "Spawning Key",
	},
	default_character_image = image_directory_root.."question-mark.png",
	character_images = {
		[0] = image_directory_root.."DKFace.png",
		[1] = image_directory_root.."DiddyFace.png",
		[2] = image_directory_root.."LankyFace.png",
		[3] = image_directory_root.."TinyFace.png",
		[4] = image_directory_root.."ChunkyFace.png",
	},
};

kko.cannon_offset = math.floor(kko.minimap_width * (17 / 100));
kko.icon_x        = math.floor(kko.minimap_width / 4);
kko.icon_y        = math.floor(kko.minimap_height / 4);
kko.text_x        = (2 * kko.minimap_x_offset) + kko.minimap_width;

function kko.getTagBarrelObject()
	for object_no = 0, getObjectModel1Count() do
		local pointer = dereferencePointer(Game.Memory.actor_pointer_array + (object_no * 4));
		if isRDRAM(pointer) and getActorName(pointer) == "Tag Barrel (King Kut Out)" then
			return pointer;
		end
	end
end

function Game.drawKutOutMinimap()
	-- Only draw minimap if the player is in the King Kut Out fight
	if Game.version ~= 4 and map_value == 199 then
		local tagBarrelObject = kko.getTagBarrelObject();
		if tagBarrelObject ~= nil then
			--local kong_active = mainmemory.readbyte(tagBarrelObject + 0x154);
			local kko_state_timer = mainmemory.readbyte(tagBarrelObject + 0x189);
			local kko_phase = mainmemory.readbyte(tagBarrelObject + 0x18A);
			local kko_state = mainmemory.readbyte(tagBarrelObject + 0x18B);
			local kko_position = mainmemory.readbyte(tagBarrelObject + 0x18C);
			local kko_attack_counter = mainmemory.readbyte(tagBarrelObject + 0x18D);
			local kko_phase_hit = mainmemory.readbyte(tagBarrelObject + 0x18E);

			-- Draw Map
			gui.drawImage(image_directory_root.."kko_map.png", kko.minimap_x_offset, kko.minimap_y_offset, kko.minimap_width, kko.minimap_height);

			-- Draw Kut Out Position (Not taking into account the 4+ values)
			if kko_position == 0 then -- top
				local draw_kko_x = kko.minimap_x_offset + (kko.minimap_width / 2) - (kko.icon_x / 2);
				local draw_kko_y = kko.minimap_y_offset + kko.cannon_offset - (kko.icon_y / 2);
				gui.drawImage(image_directory_root.."kko_icon.png", draw_kko_x, draw_kko_y, kko.icon_x, kko.icon_y);
			elseif kko_position == 1 then -- left
				local draw_kko_x = kko.minimap_x_offset + kko.cannon_offset - (kko.icon_x / 2);
				local draw_kko_y = kko.minimap_y_offset + (kko.minimap_height / 2) - (kko.icon_y / 2);
				gui.drawImage(image_directory_root.."kko_icon.png", draw_kko_x, draw_kko_y, kko.icon_x, kko.icon_y);
			elseif kko_position == 2 then -- down
				local draw_kko_x = kko.minimap_x_offset + (kko.minimap_width / 2) - (kko.icon_x / 2);
				local draw_kko_y = kko.minimap_y_offset + kko.minimap_height - kko.cannon_offset - (kko.icon_y / 2);
				gui.drawImage(image_directory_root.."kko_icon.png", draw_kko_x, draw_kko_y, kko.icon_x, kko.icon_y);
			elseif kko_position == 3 then -- right
				local draw_kko_x = kko.minimap_x_offset + kko.minimap_width - kko.cannon_offset - (kko.icon_x / 2);
				local draw_kko_y = kko.minimap_y_offset + (kko.minimap_height / 2) - (kko.icon_y / 2);
				gui.drawImage(image_directory_root.."kko_icon.png", draw_kko_x, draw_kko_y, kko.icon_x, kko.icon_y);
			end

			-- Draw Kong Position (Gives sense of perspective)
			local kko_kong_x = Game.getXPosition();
			local kko_kong_z = Game.getZPosition();
			local kko_distfromtop = 0;
			local kko_distfromleft = 0;

			if kko_kong_z > kko.map_ubound then
				kko_distfromtop = 0;
			elseif kko_kong_z < kko.map_lbound then
				kko_distfromtop = kko.minimap_height;
			else
				kko_distfromtop = math.floor(((kko.map_ubound - kko_kong_z) / (kko.map_ubound - kko.map_lbound)) * kko.minimap_height);
			end

			if kko_kong_x > kko.map_ubound then
				kko_distfromleft = 0;
			elseif kko_kong_x < kko.map_lbound then
				kko_distfromleft = kko.minimap_width;
			else
				kko_distfromleft = math.floor(((kko.map_ubound - kko_kong_x) / (kko.map_ubound - kko.map_lbound)) * kko.minimap_width);
			end

			local kko_character = Game.getCharacter();
			local characterImage = kko.character_images[kko_character] or kko.default_character_image;
			if kko_character == 3 then -- Tiny needs a special draw call
				gui.drawImage(characterImage, kko.minimap_x_offset + kko_distfromleft - (kko.icon_x / 2), kko.minimap_y_offset + kko_distfromtop - (kko.icon_y * 0.3), kko.icon_x * 0.6 , kko.icon_y * 0.6);
			elseif kko_character == 4 then -- Chunky needs a special draw call
				gui.drawImage(characterImage, kko.minimap_x_offset + kko_distfromleft - (kko.icon_x * 0.3), kko.minimap_y_offset + kko_distfromtop - (kko.icon_y / 2), kko.icon_x, kko.icon_y);
			else -- Standard draw call
				gui.drawImage(characterImage, kko.minimap_x_offset + kko_distfromleft - (kko.icon_x / 2), kko.minimap_y_offset + kko_distfromtop - (kko.icon_y / 2), kko.icon_x, kko.icon_y);
			end

			-- Draw Data
			local kko_row = 0;
			local kko_row_height = 16;

			local kko_state_to_text = kko.states[kko_state] or kko_state;
			gui.drawText(kko.text_x, kko.minimap_y_offset + (kko_row * kko_row_height), "State: "..kko_state_to_text);
			kko_row = kko_row + 1;

			gui.drawText(kko.text_x, kko.minimap_y_offset + (kko_row * kko_row_height), "State Timer: "..kko_state_timer);
			kko_row = kko_row + 1;

			if kko_state < 7 then -- Undefeated
				gui.drawText(kko.text_x, kko.minimap_y_offset + (kko_row * kko_row_height), "Phase Health: "..(3 - kko_phase_hit).." (Phase "..(kko_phase + 1)..")");
				kko_row = kko_row + 1;
			end

			if kko_state == 3 then -- Attacking (Lasers)
				gui.drawText(kko.text_x, kko.minimap_y_offset + (kko_row * kko_row_height), "Laser Set "..kko_attack_counter.."/2");
				kko_row = kko_row + 1;
			elseif kko_state < 2 and kko_phase == 2 then -- HaaHaa (11 Max)
				gui.drawText(kko.text_x, kko.minimap_y_offset + (kko_row * kko_row_height), (math.floor((11 - kko_attack_counter) / 2) + 1).." HaaHaa's left");
				kko_row = kko_row + 1;
			end
		end
	end
end

------------------------------------
-- Never Slip                     --
-- Written by Isotarge, 2014-2016 --
------------------------------------

function Game.neverSlip() -- TODO: Set movement state properly
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		mainmemory.writebyte(playerObject + obj_model1.player.slope_timer, 0); -- Patch the slope timer
	end
end

-----------------------
-- Bone Displacement --
-----------------------

print_every_frame = false;
print_threshold = 1;

local safeBoneNumbers = {};

local function setNumberOfBones(modelBasePointer)
	if isRDRAM(modelBasePointer) then
		if safeBoneNumbers[modelBasePointer] == nil then
			safeBoneNumbers[modelBasePointer] = mainmemory.readbyte(modelBasePointer + obj_model1.model.num_bones);
		end

		local currentNumBones = mainmemory.readbyte(modelBasePointer + obj_model1.model.num_bones);
		local newNumBones;

		if joypad.getimmediate()["P1 L"] then
			newNumBones = math.max(currentNumBones - 1, 1);
		else
			newNumBones = math.min(currentNumBones + 1, safeBoneNumbers[modelBasePointer]);
		end

		if newNumBones ~= currentNumBones then
			mainmemory.writebyte(modelBasePointer + obj_model1.model.num_bones, newNumBones);
		end
	end
end

local function getBoneInfo(baseAddress)
	return {
		positionX = mainmemory.read_s16_be(baseAddress + bone.position_x),
		positionY = mainmemory.read_s16_be(baseAddress + bone.position_y),
		positionZ = mainmemory.read_s16_be(baseAddress + bone.position_z),
		scaleX = mainmemory.read_u16_be(baseAddress + bone.scale_x),
		scaleY = mainmemory.read_u16_be(baseAddress + bone.scale_y),
		scaleZ = mainmemory.read_u16_be(baseAddress + bone.scale_z),
	};
end

local function outputBones(boneArrayBase, numBones)
	dprint("Bone,Index,X,Y,Z,ScaleX,ScaleY,ScaleZ,");
	local boneInfoTables = {};
	for i = 0, numBones - 1 do
		local boneInfo = getBoneInfo(boneArrayBase + i * bone_size);
		table.insert(boneInfoTables, boneInfo);
		dprint(toHexString(boneArrayBase + i * bone_size)..","..i..","..boneInfo.positionX..","..boneInfo.positionY..","..boneInfo.positionZ..","..boneInfo.scaleX..","..boneInfo.scaleY..","..boneInfo.scaleZ..",");
	end
	print_deferred();
	return boneInfoTables;
end

local function calculateCompleteBones(boneArrayBase, numberOfBones)
	local numberOfCompletedBones = numberOfBones;
	local statisticallySignificantX = {};
	local statisticallySignificantZ = {};
	for currentBone = 0, numberOfBones - 1 do
		-- Get all known information about the current bone
		local boneInfo = getBoneInfo(boneArrayBase + currentBone * bone_size);
		local boneDisplaced = false;

		-- Detect basic zeroing, the bone displacement method method currently detailed in the document
		if boneInfo.positionX == 0 and boneInfo.positionY == 0 and boneInfo.positionZ == 0 then
			if boneInfo.scaleX == 0 and boneInfo.scaleY == 0 and boneInfo.scaleZ == 0 then
				boneDisplaced = true;
			end
		end

		-- Detect position being set to -32768
		if boneInfo.positionX == -32768 and boneInfo.positionY == -32768 and boneInfo.positionZ == -32768 then
			boneDisplaced = true;
		end

		if boneDisplaced then
			numberOfCompletedBones = numberOfCompletedBones - 1;
		else
			table.insert(statisticallySignificantX, boneInfo.positionX);
			table.insert(statisticallySignificantZ, boneInfo.positionZ);
		end
	end

	-- Stats based check for type 3 "translation"
	local meanX = Stats.mean(statisticallySignificantX);
	local stdX = Stats.standardDeviation(statisticallySignificantX) * 2.5;

	local meanZ = Stats.mean(statisticallySignificantZ);
	local stdZ = Stats.standardDeviation(statisticallySignificantZ) * 2.5;

	-- Check for outliers
	for currentBone = 1, #statisticallySignificantX do
		local diffX = math.abs(meanX - statisticallySignificantX[currentBone]);
		local diffZ = math.abs(meanZ - statisticallySignificantZ[currentBone]);
		if diffX > stdX and diffZ > stdZ then
			numberOfCompletedBones = numberOfCompletedBones - 1;
		end
	end

	return math.max(0, numberOfCompletedBones);
end

local function detectDisplacement(objectPointer)
	local currentModelBase = dereferencePointer(objectPointer + obj_model1.model_pointer);
	local currentBoneArrayBase = dereferencePointer(objectPointer + obj_model1.current_bone_array_pointer);

	if isRDRAM(currentModelBase) and isRDRAM(currentBoneArrayBase) then
		-- Stupid stuff
		setNumberOfBones(currentModelBase);

		-- Calculate how many bones were correctly processed this frame
		local numberOfBones = mainmemory.readbyte(currentModelBase + obj_model1.model.num_bones);
		local completedBones = calculateCompleteBones(currentBoneArrayBase, numberOfBones);

		local completedBoneRatio = completedBones / numberOfBones;

		if completedBoneRatio < print_threshold or print_every_frame then
			--print(toHexString(objectPointer).." ("..getActorName(objectPointer)..") updated "..completedBones.."/"..numberOfBones.." bones.");
			--outputBones(currentBoneArrayBase, numberOfBones);
		end
	end
end

local function displacementDetection()
	for i = 0, getObjectModel1Count() do
		local objectPointer = dereferencePointer(Game.Memory.actor_pointer_array + (i * 4));
		if isRDRAM(objectPointer) then
			detectDisplacement(objectPointer);
		end
	end
end

-----------------------
-- Lag configuration --
-----------------------

local lag_factor = 1;

local function increase_lag_factor()
	local max_lag_factor = 20;
	lag_factor = math.min(max_lag_factor, lag_factor + 1);
end

local function decrease_lag_factor()
	local min_lag_factor = -30;
	lag_factor = math.max(min_lag_factor, lag_factor - 1);
end

local function fixLag()
	if Game.version ~= 4 then -- TODO: Kiosk
		local frames_real_value = mainmemory.read_u32_be(Game.Memory.frames_real);
		mainmemory.write_u32_be(Game.Memory.frames_lag, frames_real_value - lag_factor);
	end
end

function Game.getLagFactor()
	return mainmemory.read_u32_be(Game.Memory.lag_boost);
end

moon_mode = "None";
local function toggle_moonmode()
	if moon_mode == 'None' then
		moon_mode = 'Kick';
	elseif moon_mode == 'Kick' then
		moon_mode = 'All';
	elseif moon_mode == 'All' then
		moon_mode = 'None';
	end
end

function everythingIsKong(unsafe)
	local playerObject = Game.getPlayerObject();
	if not isRDRAM(playerObject) then
		return false;
	end

	local kongSharedModel = dereferencePointer(playerObject + obj_model1.model_pointer);
	if not isRDRAM(kongSharedModel) then
		print("This ain't gonna work...");
		return false;
	end

	local kongNumBones = mainmemory.readbyte(kongSharedModel + obj_model1.model.num_bones);
	local cameraObject = dereferencePointer(Game.Memory.camera_pointer);

	for actorListIndex = 0, getObjectModel1Count() do
		local pointer = dereferencePointer(Game.Memory.actor_pointer_array + (actorListIndex * 4));
		if isRDRAM(pointer) and (pointer ~= cameraObject) then
			local modelPointer = dereferencePointer(pointer + obj_model1.model_pointer);
			if isRDRAM(modelPointer) then
				local numBones = mainmemory.readbyte(modelPointer + obj_model1.model.num_bones);
				if unsafe or numBones >= kongNumBones then
					mainmemory.write_u32_be(pointer + obj_model1.model_pointer, kongSharedModel + RDRAMBase);
					print("Wrote: "..toHexString(pointer).." Bones: "..numBones.." Type: "..getActorName(pointer));
				end
			end
		end
	end
	return true;
end

function Game.getNumBones()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local modelPointer = dereferencePointer(playerObject + obj_model1.model_pointer);
		if isRDRAM(modelPointer) then
			return mainmemory.readbyte(modelPointer + obj_model1.model.num_bones);
		end
	end
	return 0;
end

function Game.setScale(value)
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		for i = 1, #obj_model1.player.scale do
			mainmemory.writefloat(playerObject + obj_model1.player.scale[i], value, true);
		end
	end
end

function Game.randomEffect()
	-- Randomly manipulate the effect byte
	local randomEffect = math.random(0, 0xFFFF);
	mainmemory.write_u16_be(Game.getPlayerObject() + obj_model1.player.effect_byte, randomEffect);

	-- Randomly resize the kong
	local scaleValue = 0.01 + math.random() * 0.49;
	Game.setScale(scaleValue);

	print("Activated effect: "..toBinaryString(randomEffect).." with scale "..scaleValue);
end

function Game.getEffectStatus()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		return mainmemory.read_u16_be(playerObject + obj_model1.player.effect_byte);
	end
	return 0;
end

----------------
-- Paper Mode --
----------------

function Game.paperMode()
	local paper_thickness = 0.015;
	local cameraObject = dereferencePointer(Game.Memory.camera_pointer);

	for actorListIndex = 0, getObjectModel1Count() do
		local pointer = dereferencePointer(Game.Memory.actor_pointer_array + (actorListIndex * 4));

		if isRDRAM(pointer) and pointer ~= cameraObject then
			local objectRenderingParameters = dereferencePointer(pointer + obj_model1.rendering_parameters_pointer);
			if isRDRAM(objectRenderingParameters) then
				mainmemory.writefloat(objectRenderingParameters + obj_model1.rendering_parameters.scale_z, paper_thickness, true);
			end
		end
	end
end

---------------
-- BRB Stuff --
---------------

local brb_message = "BRB";
local is_brb = false;

local japan_charset = {
--   0    1    2    3    4    5    6    7    8    9
	"\0", "\0", "$", "(", ")", "\0", "%", "「", "」", "`", -- 0
	"\0", "<", ">", "&", "~", " ", "0", "1", "2", "3", -- 1
	"4", "5", "6", "7", "8", "9", "A", "B", "C", "D", -- 2
	"E", "F", "G", "H", "I", "J", "K", "\0", "M", "N", -- 3
	"O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", -- 4
	"Y", "Z", "!", '"', "#", "'", "*", "+", ",", "-", -- 5
	".", "/", ":", "=", "?", "@", "。", "゛", " ", "ァ", -- 6
	"ィ", "ゥ", "ェ", "ォ", "ッ", "ャ", "ュ", "ョ", "ヲ", "ン", -- 7
	"ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ", -- 8
	"サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト", -- 9
	"ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", -- 10
	"マ", "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", -- 11
	"ル", "レ", "ロ", "ワ", "ガ", "ギ", "グ", "ゲ", "ゴ", "ザ", -- 12
	"ジ", "ズ", "ゼ", "ゾ", "ダ", "ヂ", "ヅ", "デ", "ド", "バ", -- 13
	"ビ", "ブ", "ベ", "ボ", "パ", "ピ", "プ", "ペ", "ポ", "a", -- 14
	"b", "c", "d", "e", "f", "g", "h", "i", "j", "k", -- 15
	"l", "m", "n", "o", "p", "q", "r", "s", "t", "u", -- 16
	"v", "w", "x", "y", "z", "ぁ", "ぃ", "ぅ", "ぇ", "ぉ", -- 17
	"っ", "ゃ", "ゅ", "ょ", "を", "ん", "あ", "い", "う", "え", -- 18
	"お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", -- 19
	"そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", -- 20
	"の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", -- 21
	"も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", -- 22
	"が", "ぎ", "ぐ", "げ", "ご", "ざ", "じ", "ず", "ぜ", "ぞ", -- 23
	"だ", "ぢ", "づ", "で", "ど", "ば", "び", "ぶ", "べ", "ぼ", -- 24
	"ぱ", "ぴ", "ぷ", "ぺ", "ぽ", "ヴ" -- 25
};

function Game.toJapaneseString(value)
	local length = string.len(value);
	local tempString = "";
	local char, charFound;
	for i = 1, length do
		char = string.sub(value, i, i);
		charFound = false;
		for j = 1, #japan_charset do
			if japan_charset[j] == char then
				tempString = tempString..string.char(j - 1);
				charFound = true;
				break;
			end
		end
		if charFound == false then
			dprint("String parse warning: Didn't find character for '"..char..'\'');
		end
	end
	print_deferred();
	return tempString;
end

function brb(value)
	local message = value or "BRB";
	if Game.version == 3 then -- Japan
		message = Game.toJapaneseString(message);
	else
		message = string.upper(message);
	end
	if Game.version ~= 4 then -- TODO: Kiosk?
		brb_message = message;
		is_brb = true;
	else
		print("Not supported in this version.");
	end
end

function back()
	is_brb = false;
end

local function doBRB()
	mainmemory.writebyte(Game.Memory.security_byte, 0x01);
	local messageLength = math.min(string.len(brb_message), 79); -- 79 bytes appears to be the maximum length we can write here without crashing
	for i = 1, messageLength do
		mainmemory.writebyte(Game.Memory.security_message + i - 1, string.byte(brb_message, i));
	end
	mainmemory.writebyte(Game.Memory.security_message + messageLength, 0x00);
end

-------------------
-- For papa cfox --
-------------------

function setDKTV(message)
	if Game.version == 4 then -- Kiosk text is static
		writeNullTerminatedString(Game.Memory.DKTV_pointer, message);
		return;
	end
	local pointer = dereferencePointer(Game.Memory.DKTV_pointer);
	if isRDRAM(pointer) then
		pointer = dereferencePointer(pointer + 0x04);
		if isRDRAM(pointer) then
			pointer = dereferencePointer(pointer + 0x0C);
			if isRDRAM(pointer) then
				if Game.version == 3 then
					writeNullTerminatedString(pointer, Game.toJapaneseString(message)); -- TODO: This isn't working properly
				else
					writeNullTerminatedString(pointer, message);
				end
			end
		end
	end
end

-----------------------
-- HUD Documentation --
-----------------------

hud_object = {
	display_object = {
		actual_count_pointer = 0x0, -- u32
		hud_count = 0x4, -- u16
		freeze_timer = 0x6, -- u8
		counter_timer = 0x7, -- u8
		screen_x = 0x8, -- u32
		screen_y = 0xC, -- u32
		hud_state = 0x23, -- u8
		hud_states = {
			[0] = "Invisible",
			[1] = "Appearing",
			[2] = "Visible",
			[3] = "Disappearing",
		},
		counter_pointer = 0x28, -- u32
	}
};

--------------------------
-- Free Trade Agreement --
--------------------------

local FTA = {
	Balloons = {
		[DK] = 114,
		[Diddy] = 91,
		[Lanky] = 113,
		[Tiny] = 112,
		[Chunky] = 111,
	},
	Kasplats = { -- Not actually used by the check function for speed reasons, really just here for documentation
		[DK] = 241,
		[Diddy] = 242,
		[Lanky] = 243,
		[Tiny] = 244,
		[Chunky] = 245,
	},
	BulletChecks = {
		[DK] = 0x0030,
		[Diddy] = 0x0024,
		[Lanky] = 0x002A,
		[Tiny] = 0x002B,
		[Chunky] = 0x0026,
		[Krusha] = 0x00AB,
	},
	LowGBStates = {
		[DK] = 0x08,
		[Diddy] = 0x02,
		[Lanky] = 0x10,
		[Tiny] = 0x04,
		[Chunky] = 0x01,
	},
	GBStates = {
		[DK] = 0x28,
		[Diddy] = 0x22,
		[Lanky] = 0x30,
		[Tiny] = 0x24,
		[Chunky] = 0x21,
	},
	GunSwitches = {
		0x125, -- Pineapple Switch
		0x126, -- Peanut Switch
		0x127, -- Feather Switch
		0x128, -- Grape Switch
		0x129, -- Coconut Switch
	},
	SimSlamSwitches = { -- Not actually used by the check function for speed reasons, really just here for documentation
		0x92, -- Chunky, Green
		0x93, -- Diddy, Green
		0x94, -- DK, Green
		0x95, -- Lanky, Green
		0x96, -- Tiny, Green
		0xB8, -- Chunky, Green (Labelled "Green Switch", could be used for more stuff)
		0x165, -- Chunky, Red
		0x166, -- Diddy, Red
		0x167, -- DK, Red
		0x168, -- Lanky, Red
		0x169, -- Tiny, Red
		0x16A, -- Chunky, Blue
		0x16B, -- Diddy, Blue
		0x16C, -- DK, Blue
		0x16D, -- Lanky, Blue
		0x16E, -- Tiny, Blue
	},
	SimSlamChecks = { -- Not actually used by the check function for speed reasons, really just here for documentation
		[DK] = 0x0002,
		[Diddy] = 0x0003,
		[Lanky] = 0x0004,
		[Tiny] = 0x0005,
		[Chunky] = 0x0006,
		[Krusha] = 0x0007,
	},
	CrownMaps = {
		53, -- Beaver Brawl!
		73, -- Kritter Karnage!
		155, -- Arena Ambush!
		156, -- More Kritter Karnage!
		157, -- Forest Fracas!
		158, -- Bish Bash Brawl!
		159, -- Kamikaze Kremlings!
		160, -- Plinth Panic!
		161, -- Pinnacle Palaver!
		162, -- Shockwave Showdown!
	},
};

function FTA.isBalloon(actorType)
	return table.contains(FTA.Balloons, actorType)
end

function FTA.isKasplat(actorType)
	return actorType >= 241 and actorType <= 245;
end

function FTA.isSimSlamSwitch(value)
	return (value >= 0x92 and value <= 0x96) or (value == 0xB8) or (value >= 0x165 and value <= 0x16E);
end

function FTA.isGunSwitch(value)
	return value >= 0x125 and value <= 0x129;
end

function FTA.isBulletCheck(value)
	return table.contains(FTA.BulletChecks, value);
end

function FTA.isLowGB(collectableState)
	return table.contains(FTA.LowGBStates, collectableState);
end

function FTA.isGB(collectableState)
	return table.contains(FTA.GBStates, collectableState);
end

function FTA.isCrownMap(value)
	return table.contains(FTA.CrownMaps, value);
end

-- Script Commands
-- 0000 - nop
-- 0018 xxxx - Check actor collision, index xxxx, 0000 is any actor
-- 0019 xxxx - Check actor sim slam collision, index xxxx
-- 0025 xxxx - Play cutscene, index xxxx

FTA.safePreceedingCommands = {
	0x11,
		-- Working, Aztec top of 5DT Diddy Switch (base + 0x0C, 2 blocks)
	0x18,
		-- Lots of gunswitches
	0x19,
		-- Working, Llama Temple DK Switch (base + 0x1C, 1 block)
		-- Llama Temple Lanky Switch (base + 0x1C, 2 blocks)
		-- Working, Llama Temple Tiny Switches (base + 0x1C, 2 blocks)
		-- Working, Tiny Temple Diddy Switch (base + 0x1C, 2 blocks)
		-- Working, Tiny Temple Lanky Switch (base + 0x1C, 2 blocks)
		-- Used in K. Lumsy Grape Switch to keep pressed, character check
};

function FTA.isSafePreceedingCommand(preceedingCommand)
	return table.contains(FTA.safePreceedingCommands, preceedingCommand);
end

-- Potentially unsafe:
-- 0x0025

function FTA.freeTradeObjectModel1(currentKong)
	if currentKong >= DK and currentKong <= Chunky then
		for object_no = 0, getObjectModel1Count() do
			local pointer = dereferencePointer(Game.Memory.actor_pointer_array + (object_no * 4));
			if isRDRAM(pointer) then
				local actorType = mainmemory.read_u16_be(pointer + obj_model1.actor_type);
				if FTA.isKasplat(actorType) then
					if not FTA.isCrownMap(map_value) then
						mainmemory.write_u16_be(pointer + obj_model1.actor_type, FTA.Kasplats[currentKong]); -- Fix which blueprint the Kasplat drops
						mainmemory.writebyte(pointer + 0x15F, 0x01); -- Make sure white-haired Kasplats still drop Blueprints
					end
				end
				if FTA.isBalloon(actorType) then
					mainmemory.write_u16_be(pointer + obj_model1.actor_type, FTA.Balloons[currentKong]); -- Fix balloon color
				end
			end
		end
	end
end

function FTA.isKnownCollisionType(collisionType)
	return obj_model2.object_types[collisionType] ~= nil;
end

function FTA.fixSingleCollision(objectBase)
	local collisionType = mainmemory.read_u16_be(objectBase + 2);
	local collisionValue = mainmemory.read_u16_be(objectBase + 4);
	if FTA.isKnownCollisionType(collisionType) and isKong(collisionValue) then
		mainmemory.write_u16_be(objectBase + 4, 0); -- Set the collision to accept any Kong
	end
end

function FTA.freeTradeCollisionList()
	local collisionLinkedListPointer = dereferencePointer(Game.Memory.obj_model2_collision_linked_list_pointer);
	if isRDRAM(collisionLinkedListPointer) then
		local collisionListObjectSize = mainmemory.read_u32_be(collisionLinkedListPointer + heap.object_size);
		for i = 0, collisionListObjectSize - 4, 4 do
			local object = dereferencePointer(collisionLinkedListPointer + i);
			local safety;
			while isRDRAM(object) do
				FTA.fixSingleCollision(object);
				safety = dereferencePointer(object + 0x18); -- Get next object
				if safety == object or safety == collisionLinkedListPointer - 0x10 then -- Prevent infinite loops
					break;
				end
				object = safety;
			end
		end
	end
end

function dumpCollisionTypes(kongFilter)
	local kongCounts = {};
	local collisionLinkedListPointer = dereferencePointer(Game.Memory.obj_model2_collision_linked_list_pointer);
	if isRDRAM(collisionLinkedListPointer) then
		local collisionListObjectSize = mainmemory.read_u32_be(collisionLinkedListPointer + heap.object_size);
		for i = 0, collisionListObjectSize - 4, 4 do
			local object = dereferencePointer(collisionLinkedListPointer + i);
			while isRDRAM(object) do
				local kong = mainmemory.read_u16_be(object + 0x04);
				--if isKong(kong) and (kongFilter == nil or kong == kongFilter) then
					local collisionType = mainmemory.read_u16_be(object + 0x02);
					if obj_model2.object_types[collisionType] ~= nil then
						collisionType = obj_model2.object_types[collisionType];
					else
						collisionType = toHexString(collisionType, 4);
					end
					if kongCounts[kong] == nil then
						kongCounts[kong] = 1;
					else
						kongCounts[kong] = kongCounts[kong] + 1;
					end
					dprint(toHexString(object)..": "..collisionType..", Kong: "..toHexString(kong));
				--end
				object = dereferencePointer(object + 0x18);
			end
		end
		for k, v in pairs(kongCounts) do
			dprint("Kong "..toHexString(k).." Count: "..v);
		end
		print_deferred();
	end
end

function replaceCollisionType(target, desired)
	local collisionLinkedListPointer = dereferencePointer(Game.Memory.obj_model2_collision_linked_list_pointer);
	if isRDRAM(collisionLinkedListPointer) then
		local collisionListObjectSize = mainmemory.read_u32_be(collisionLinkedListPointer + heap.object_size);
		for i = 0, collisionListObjectSize - 4, 4 do
			local object = dereferencePointer(collisionLinkedListPointer + i);
			while isRDRAM(object) do
				local collisionType = mainmemory.read_u16_be(object + 0x02);
				if collisionType == target then
					mainmemory.write_u16_be(object + 0x02, desired);
				end
				object = dereferencePointer(object + 0x18);
			end
		end
	end
end

function FTA.debugOut(objName, objBase, scriptBase, scriptOffset)
	local preceedingCommand = mainmemory.read_u16_be(scriptBase + scriptOffset - 2);
	print("patched "..objName.." at "..toHexString(objBase).." -> "..toHexString(scriptBase).." + "..toHexString(scriptOffset).." preceeding command "..toHexString(preceedingCommand));
end

function ohWrongnana(verbose)
	if Game.version == 4 then -- Anything but kiosk
		return;
	end

	local currentMap = Game.getMap();
	-- Don't run FTA on Batty Barrel Bandit maps
	-- TODO: Figure out why the game sometimes crashes when pulling the BBB lever with FTA enabled
	if currentMap == 32 or currentMap == 121 or currentMap == 122 or currentMap == 123 then
		return;
	end

	--if emu.framecount() % 100 ~= 0 then -- Only run this once every 100 frames
	--	return;
	--end

	local currentKong = Game.getCharacter();

	local objModel2Array = getObjectModel2Array();
	if isRDRAM(objModel2Array) and currentKong >= DK and currentKong <= Chunky then
		local numSlots = mainmemory.read_u32_be(Game.Memory.obj_model2_array_count);
		local scriptName, slotBase, currentValue, activationScript, preceedingCommand;
		-- Fill and sort pointer list
		for i = 0, numSlots - 1 do
			slotBase = objModel2Array + i * obj_model2_slot_size;
			currentValue = mainmemory.readbyte(slotBase + obj_model2.collectable_state);
			if FTA.isGB(currentValue) then
				mainmemory.writebyte(slotBase + obj_model2.collectable_state, FTA.GBStates[currentKong]);
				if verbose then
					FTA.debugOut(getScriptName(slotBase), slotBase, slotBase, 0);
				end
			end
			if FTA.isLowGB(currentValue) then
				mainmemory.writebyte(slotBase + obj_model2.collectable_state, FTA.LowGBStates[currentKong]);
				if verbose then
					FTA.debugOut(getScriptName(slotBase), slotBase, slotBase, 0);
				end
			end
			-- Get activation script
			activationScript = dereferencePointer(slotBase + obj_model2.behavior_pointer);
			if isRDRAM(activationScript) then
				currentValue = mainmemory.read_u16_be(slotBase + obj_model2.object_type);
				if FTA.isGunSwitch(currentValue) or FTA.isSimSlamSwitch(currentValue) or currentValue == 0x131 or currentValue == 0x47 or currentValue == 0xDC then -- 0x131 is K. Rool's Ship (Galleon), 0x47 is Castle Lobby coconut switch, 0xDC is Question Mark Box (Sim Slam)
					scriptName = getInternalName(slotBase);
					if currentValue == 0x131 then -- K. Rool's Ship (Galleon)
						activationScript = dereferencePointer(activationScript + 0xA0);
						while isRDRAM(activationScript) do
							for j = 0x04, 0x48, 8 do
								preceedingCommand = mainmemory.readbyte(activationScript + j - 1);
								if preceedingCommand == 0x12 then
									local commandParam = mainmemory.read_u16_be(activationScript + j);
									if isKong(commandParam) then
										mainmemory.write_u16_be(activationScript + j, FTA.SimSlamChecks[currentKong]);
										if verbose then
											FTA.debugOut(scriptName, slotBase, activationScript, j);
										end
									end
								end
							end
							-- Get next script chunk
							activationScript = dereferencePointer(activationScript + 0x4C);
						end
					elseif scriptName == "buttons" or currentValue == 0xDC then -- Sim Slam Switches, Question Mark Boxes (Fungi)
						activationScript = dereferencePointer(activationScript + 0xA0);
						while isRDRAM(activationScript) do
							for j = 0x04, 0x48, 8 do
								preceedingCommand = mainmemory.readbyte(activationScript + j - 1);
								if FTA.isSafePreceedingCommand(preceedingCommand) then
									local commandParam = mainmemory.read_u16_be(activationScript + j);
									if isKong(commandParam) then
										mainmemory.write_u16_be(activationScript + j, FTA.SimSlamChecks[currentKong]);
										if verbose then
											FTA.debugOut(scriptName, slotBase, activationScript, j);
										end
									end
								end
							end
							-- Get next script chunk
							activationScript = dereferencePointer(activationScript + 0x4C);
						end
					elseif scriptName == "gunswitches" or currentValue == 0x47 then
						activationScript = dereferencePointer(activationScript + 0xA0);
						while isRDRAM(activationScript) do
							for j = 0x04, 0x48, 8 do
								preceedingCommand = mainmemory.readbyte(activationScript + j - 1);
								if preceedingCommand == 0x19 then
									local commandParam = mainmemory.read_u16_be(activationScript + j);
									if isKong(commandParam) then
										mainmemory.write_u16_be(activationScript + j, FTA.SimSlamChecks[currentKong]);
										if verbose then
											FTA.debugOut(scriptName, slotBase, activationScript, j);
										end
									end
								elseif FTA.isSafePreceedingCommand(preceedingCommand) then
									local commandParam = mainmemory.read_u16_be(activationScript + j);
									if FTA.isBulletCheck(commandParam) then
										mainmemory.write_u16_be(activationScript + j, FTA.BulletChecks[currentKong]);
										if verbose then
											FTA.debugOut(scriptName, slotBase, activationScript, j);
										end
									end
								end
							end
							-- Get next script chunk
							activationScript = dereferencePointer(activationScript + 0x4C);
						end
					end
				end
			end
		end

		FTA.freeTradeObjectModel1(currentKong);
		FTA.freeTradeCollisionList();
	end
end

function fixMonkeyHead()
	mainmemory.writebyte(0x41F8C8, 0x0B);
	mainmemory.writebyte(0x41F8CB, 0x0B);
	mainmemory.writebyte(0x41F8D4, 0x00);
	mainmemory.writebyte(0x41F8DC, 0x00);
	mainmemory.writebyte(0x41F8DE, 0x01);
	mainmemory.writebyte(0x41F8DF, 0x2A);
	mainmemory.writebyte(0x41F8E0, 0x00);
end

----------------------
-- Framebuffer Jank --
----------------------

function fillFB()
	local image_filename = forms.openfile(nil, nil, "PNG Images (*.png)|*.png");
	if not fileExists(image_filename) then
		print("No image selected. Exiting.");
		return;
	end

	local framebuffer_width = 320; -- Oddly enough it's the same size on PAL
	local framebuffer_height = 240; -- Oddly enough it's the same size on PAL
	local frameBufferLocation = dereferencePointer(Game.Memory.framebuffer_pointer);
	if isRDRAM(frameBufferLocation) then
		replaceTextureRGBA5551(image_filename, frameBufferLocation, framebuffer_width, framebuffer_height);
	end
	frameBufferLocation = dereferencePointer(Game.Memory.framebuffer_pointer + 4);
	if isRDRAM(frameBufferLocation) then
		replaceTextureRGBA5551(image_filename, frameBufferLocation, framebuffer_width, framebuffer_height);
	end
end

function fillFBNative()
	local image_filename = forms.openfile(nil, nil, "All Files (*.*)|*.*");
	if not fileExists(image_filename) then
		print("No image selected. Exiting.");
		return;
	end

	local frameBufferLocation = dereferencePointer(Game.Memory.framebuffer_pointer);
	if isRDRAM(frameBufferLocation) then
		local frameBuffer = frameBufferLocation;
		local backBuffer = frameBufferLocation + 320 * 240 * 2;

		local input_file = io.open(image_filename, "rb");
		for i = 0, 320 * 240 * 2 - 1, 2 do
			local byte1 = string.byte(input_file:read(1));
			local byte2 = string.byte(input_file:read(1));

			mainmemory.writebyte(frameBuffer + i + 0, byte2);
			mainmemory.writebyte(frameBuffer + i + 1, byte1);

			mainmemory.writebyte(backBuffer + i + 0, byte2);
			mainmemory.writebyte(backBuffer + i + 1, byte1);
		end
		input_file:close();
	end
end

-----------------
-- Grab Script --
-----------------

function Game.incrementObjectIndex()
	object_index = object_index + 1;
	if object_index > #object_pointers then
		object_index = 1;
	end
end

function Game.decrementObjectIndex()
	object_index = object_index - 1;
	if object_index <= 0 then
		object_index = #object_pointers;
	end
end

function Game.grabObject(pointer)
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		mainmemory.write_u32_be(playerObject + obj_model1.player.grab_pointer, pointer + RDRAMBase);
		mainmemory.write_u32_be(playerObject + obj_model1.player.grab_pointer + 4, pointer + RDRAMBase);
	end
end

function Game.grabSelectedObject()
	if grab_script_mode == "Chunks" then
		local loaded = mainmemory.readbyte(object_pointers[object_index] + chunk.visible);
		if loaded == 2 then
			mainmemory.writebyte(object_pointers[object_index] + chunk.visible, 0);
		else
			mainmemory.writebyte(object_pointers[object_index] + chunk.visible, 2);
		end
	end
	if string.contains(grab_script_mode, "Model 1") then
		Game.grabObject(object_pointers[object_index]);
	end
end

function Game.focusObject(pointer) -- TODO: There's more pointers to set here, mainly vehicle stuff
	local cameraObject = dereferencePointer(Game.Memory.camera_pointer);
	if isRDRAM(cameraObject) and isRDRAM(pointer) then
		mainmemory.write_u32_be(cameraObject + obj_model1.camera.focused_actor_pointer, pointer + RDRAMBase);
	end
end

function Game.focusSelectedObject()
	if string.contains(grab_script_mode, "Model 1") then
		Game.focusObject(object_pointers[object_index]);
	end
end

function Game.zipToSelectedObject()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local desiredX, desiredY, desiredZ;
		local selectedObject = object_pointers[object_index];
		if isRDRAM(selectedObject) then
			-- Get selected object X,Y,Z position
			if string.contains(grab_script_mode, "Model 1") then
				desiredX = mainmemory.readfloat(selectedObject + obj_model1.x_pos, true);
				desiredY = mainmemory.readfloat(selectedObject + obj_model1.y_pos, true);
				desiredZ = mainmemory.readfloat(selectedObject + obj_model1.z_pos, true);
			elseif string.contains(grab_script_mode, "Model 2") then
				desiredX = mainmemory.readfloat(selectedObject + obj_model2.x_pos, true);
				desiredY = mainmemory.readfloat(selectedObject + obj_model2.y_pos, true);
				desiredZ = mainmemory.readfloat(selectedObject + obj_model2.z_pos, true);
			elseif string.contains(grab_script_mode, "Loading Zones") then
				desiredX = mainmemory.read_s16_be(selectedObject + loading_zone_fields.x_position);
				desiredY = mainmemory.read_s16_be(selectedObject + loading_zone_fields.y_position);
				desiredZ = mainmemory.read_s16_be(selectedObject + loading_zone_fields.z_position);
			elseif grab_script_mode == "Exits" then
				desiredX = mainmemory.read_s16_be(selectedObject + exit.x_pos);
				desiredY = mainmemory.read_s16_be(selectedObject + exit.y_pos);
				desiredZ = mainmemory.read_s16_be(selectedObject + exit.z_pos);
			elseif string.contains(grab_script_mode, "Spawners") then
				desiredX = mainmemory.read_s16_be(selectedObject + 4); -- TODO: Stop using magic numbers for this
				desiredY = mainmemory.read_s16_be(selectedObject + 6);
				desiredZ = mainmemory.read_s16_be(selectedObject + 8);
			end
		end

		-- Update player position
		if type(desiredX) == "number" and type(desiredY) == "number" and type(desiredZ) == "number" then
			Game.setPosition(desiredX, desiredY, desiredZ);
		end
	end
end

ScriptHawk.bindMouse("mousewheelup", Game.decrementObjectIndex);
ScriptHawk.bindMouse("mousewheeldown", Game.incrementObjectIndex);

ScriptHawk.bindKeyRealtime("N", Game.decrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("M", Game.incrementObjectIndex, true);
ScriptHawk.bindKeyRealtime("Z", Game.zipToSelectedObject, true);
ScriptHawk.bindKeyRealtime("V", Game.grabSelectedObject, true);
ScriptHawk.bindKeyRealtime("B", Game.focusSelectedObject, true);
--ScriptHawk.bindKeyRealtime("C", switch_grab_script_mode, true);

ScriptHawk.bindKeyRealtime("H", decrementPage, true);
ScriptHawk.bindKeyRealtime("J", incrementPage, true);

------------------------------
-- Grab Script              --
-- Object Model 1 Functions --
------------------------------

local function populateObjectModel1Pointers()
	object_pointers = {};
	local playerObject = Game.getPlayerObject();
	local cameraObject = dereferencePointer(Game.Memory.camera_pointer);
	if isRDRAM(playerObject) and isRDRAM(cameraObject) then
		if encircle_enabled then
			for object_no = 0, getObjectModel1Count() do
				local pointer = dereferencePointer(Game.Memory.actor_pointer_array + (object_no * 4));
				if isRDRAM(pointer) and pointer ~= playerObject then
					local modelPointer = dereferencePointer(pointer + obj_model1.model_pointer);
					if isRDRAM(modelPointer) then
						table.insert(object_pointers, pointer);
					end
				end
			end
		else
			if object_model1_filter == nil then
				for object_no = 0, getObjectModel1Count() do
					local pointer = dereferencePointer(Game.Memory.actor_pointer_array + (object_no * 4));
					if isRDRAM(pointer) then
						table.insert(object_pointers, pointer);
					end
				end
			else
				for object_no = 0, getObjectModel1Count() do
					local pointer = dereferencePointer(Game.Memory.actor_pointer_array + (object_no * 4));
					if string.contains(getActorName(pointer), object_model1_filter) then
						table.insert(object_pointers, pointer);
					end
				end
			end
		end

		-- Clamp index
		object_index = math.min(object_index, math.max(1, #object_pointers));
	end
end

local function encirclePlayerObjectModel1()
	if encircle_enabled and string.contains(grab_script_mode, "Model 1") then
		local playerObject = Game.getPlayerObject();
		if isRDRAM(playerObject) then
			local x, z;
			local xPos = mainmemory.readfloat(playerObject + obj_model1.x_pos, true);
			local yPos = mainmemory.readfloat(playerObject + obj_model1.y_pos, true);
			local zPos = mainmemory.readfloat(playerObject + obj_model1.z_pos, true);

			for i = 1, #object_pointers do
				x = xPos + math.cos(math.pi * 2 * i / #object_pointers) * radius;
				z = zPos + math.sin(math.pi * 2 * i / #object_pointers) * radius;

				mainmemory.writefloat(object_pointers[i] + obj_model1.x_pos, x, true);
				mainmemory.writefloat(object_pointers[i] + obj_model1.y_pos, yPos, true);
				mainmemory.writefloat(object_pointers[i] + obj_model1.z_pos, z, true);
			end
		end
	end
end

-----------------------
-- Kremling Kosh Bot --
-----------------------

koshBot = {
	enabled = false,
	joypad_angles = {
		[0] = {["X Axis"] = 0,    ["Y Axis"] = 0},
		[1] = {["X Axis"] = -128, ["Y Axis"] = 0},
		[2] = {["X Axis"] = -128, ["Y Axis"] = -128},
		[3] = {["X Axis"] = 0,    ["Y Axis"] = -128},
		[4] = {["X Axis"] = 127,  ["Y Axis"] = -128},
		[5] = {["X Axis"] = 127,  ["Y Axis"] = 0},
		[6] = {["X Axis"] = 127,  ["Y Axis"] = 127},
		[7] = {["X Axis"] = 0,    ["Y Axis"] = 127},
		[8] = {["X Axis"] = -128, ["Y Axis"] = 127},
	},
	shots_fired = {
		0, 0, 0, 0, 0, 0, 0, 0,
	},
	previousFrameMelonCount = 0,
	quickfire_reload_enabled = 0,
	previousMelonFireFrame = 0,
};

koshBot.getKoshController = function()
	for object_no = 0, getObjectModel1Count() do
		local pointer = dereferencePointer(Game.Memory.actor_pointer_array + (object_no * 4));
		if getActorName(pointer) == "Kremling Kosh Controller" then
			return pointer;
		end
	end
end

koshBot.resetSlots = function()
	koshBot.shots_fired = {
		0, 0, 0, 0, 0, 0, 0, 0,
	};
end

koshBot.getSlotPointer = function(koshController, slotIndex)
	return dereferencePointer(koshController + obj_model1.kosh_kontroller.slot_pointer_base + (slotIndex - 1) * 4);
end

koshBot.getCurrentSlot = function(koshController)
	return mainmemory.readbyte(koshController + obj_model1.kosh_kontroller.slot_location);
end

koshBot.getDesiredSlot = function(koshController)
	local melonsRemaining = mainmemory.readbyte(koshController + obj_model1.kosh_kontroller.melons_remaining);
	if melonsRemaining == 0 then
		return 0;
	end

	-- Check for kremlings
	local desiredSlot = 0;
	local slotPointer;
	for slotIndex = 1, 8 do
		slotPointer = koshBot.getSlotPointer(koshController, slotIndex);
		if slotPointer ~= nil then
			if slotPointer > 0 and koshBot.shots_fired[slotIndex] == 0 then
				koshBot.shots_fired[slotIndex] = 1;
			end
		end
		if slotPointer == 0 or slotPointer == nil then
			if koshBot.shots_fired[slotIndex] == 2 then
				koshBot.shots_fired[slotIndex] = 0;
			end
		end
		if koshBot.shots_fired[slotIndex] == 1 then
			desiredSlot = slotIndex;
		end
	end

	if desiredSlot > 0 then
		return desiredSlot;
	end
end

koshBot.Loop = function()
	local koshController = koshBot.getKoshController();
	if koshController ~= nil then
		local desiredSlot = koshBot.getDesiredSlot(koshController);
		local currentFrame = mainmemory.read_u32_be(Game.Memory.frames_lag);

		if currentFrame > koshBot.previousMelonFireFrame and koshBot.quickfire_reload_enabled == 2 then
			koshBot.quickfire_reload_enabled = 1;
		end

		if koshBot.quickfire_reload_enabled == 3 then
			joypad.setanalog({["X Axis"] = false, ["Y Axis"] = false}, 1);
			joypad.set({["A"] = true}, 1);
			koshBot.quickfire_reload_enabled = 0;
		elseif koshBot.quickfire_reload_enabled == 1 then
			joypad.setanalog({["X Axis"] = false, ["Y Axis"] = false}, 1);
			joypad.set({["A"] = true}, 1);
			koshBot.quickfire_reload_enabled = 3;
		elseif koshBot.quickfire_reload_enabled == 0 then
			if desiredSlot ~= nil and desiredSlot > 0 then
				joypad.setanalog(koshBot.joypad_angles[desiredSlot], 1);
				--print("Moving to slot "..desiredSlot);
				joypad.set({["B"] = true}, 1);
				--print("Firing!");
			else
				joypad.setanalog({["X Axis"] = false, ["Y Axis"] = false}, 1);
			end
		end

		local joypadInputs = joypad.get();
		if joypadInputs["P1 X Axis"] ~= 0 or joypadInputs["P1 Y Axis"] ~= 0 then
			joypad.set({["B"] = true}, 1);
			koshBot.quickfire_reload_enabled = 2;
			koshBot.previousMelonFireFrame = mainmemory.read_u32_be(Game.Memory.frames_lag);
			if desiredSlot ~= nil and desiredSlot > 0 then
				koshBot.shots_fired[desiredSlot] = 2;
			end
		end
	end
end

local function drawGrabScriptUI()
	if grab_script_mode == "Disabled" then
		return;
	end

	local gui_x = 32;
	local gui_y = 32;
	local row = 0;
	local height = 16;

	gui.text(gui_x, gui_y + height * row, "Mode: "..grab_script_mode, nil, 'bottomright');
	row = row + 1;

	local playerObject = Game.getPlayerObject();
	if not isRDRAM(playerObject) then
		return;
	end

	local cameraObject = dereferencePointer(Game.Memory.camera_pointer);
	if not isRDRAM(cameraObject) then
		return;
	end

	if string.contains(grab_script_mode, "Model 1") then
		populateObjectModel1Pointers();
		encirclePlayerObjectModel1();
	end

	if string.contains(grab_script_mode, "Model 2") then
		populateObjectModel2Pointers();
		encirclePlayerObjectModel2();
	end

	if string.contains(grab_script_mode, "Arcade Objects") then
		populateArcadeObjects();
	end

	if string.contains(grab_script_mode, "Loading Zones") then
		populateLoadingZonePointers();
	end

	if grab_script_mode == "Chunks" then
		populateChunkPointers();
	end

	if grab_script_mode == "Exits" then
		populateExitPointers();
	end

	if string.contains(grab_script_mode, "Spawners") then
		Game.populateEnemyPointers();
	end

	if rat_enabled then
		local renderingParams = dereferencePointer(playerObject + obj_model1.rendering_parameters_pointer);
		if isRDRAM(renderingParams) then
			if math.random() > 0.9 then
				local timerValue = math.random() * 50;
				mainmemory.writefloat(renderingParams + obj_model1.rendering_parameters.anim_timer1, timerValue, true);
				mainmemory.writefloat(renderingParams + obj_model1.rendering_parameters.anim_timer2, timerValue, true);
				mainmemory.writefloat(renderingParams + obj_model1.rendering_parameters.anim_timer3, timerValue, true);
				mainmemory.writefloat(renderingParams + obj_model1.rendering_parameters.anim_timer4, timerValue, true);
			end
		end
	end

	if string.contains(grab_script_mode, "Model 2") then
		gui.text(gui_x, gui_y + height * row, "Array Size: "..getObjectModel2ArraySize(), nil, 'bottomright');
		row = row + 1;
	end

	gui.text(gui_x, gui_y + height * row, "Index: "..object_index.."/"..#object_pointers, nil, 'bottomright');
	row = row + 1;
	gui.text(gui_x, gui_y + height * row, "Page: "..(page_pos).."/"..(page_total), nil, 'bottomright');
	row = row + 1;
	row = row + 1;

	if string.contains(grab_script_mode, "Model 1") then
		local focusedActor = dereferencePointer(cameraObject + obj_model1.camera.focused_actor_pointer);
		local grabbedActor = dereferencePointer(playerObject + obj_model1.player.grab_pointer);

		local focusedActorType = "Unknown";
		local grabbedActorType = "Unknown";
		local collisionCount = 0;

		if isRDRAM(focusedActor) then
			focusedActorType = getActorName(focusedActor);
			gui.text(gui_x, gui_y + height * row, "Focused Actor: "..toHexString(focusedActor, 6).." "..focusedActorType, nil, 'bottomright');
			row = row + 1;
		end

		if isRDRAM(grabbedActor) then
			grabbedActorType = getActorName(grabbedActor);
			--local collision = dereferencePointer(grabbedActor + obj_model1.collision_queue_pointer);
			collisionCount = getActorCollisions(grabbedActor);
			gui.text(gui_x, gui_y + height * row, "Grabbed Actor: "..toHexString(grabbedActor, 6).." "..grabbedActorType.." Collisions: "..collisionCount, nil, 'bottomright');
			row = row + 1;
		end
	end

	-- Clamp index to number of objects
	if #object_pointers > 0 and object_index > #object_pointers then
		object_index = #object_pointers;
	end

	if #object_pointers > 0 and object_index <= #object_pointers then
		if string.contains(grab_script_mode, "Examine") then
			local examine_data = {};
			if grab_script_mode == "Examine (Object Model 1)" then
				examine_data = getExamineDataModelOne(object_pointers[object_index]);
			elseif grab_script_mode == "Examine (Object Model 2)" then
				examine_data = getExamineDataModelTwo(object_pointers[object_index]);
			elseif grab_script_mode == "Examine (Loading Zones)" then
				examine_data = getExamineDataLoadingZone(object_pointers[object_index]);
			elseif grab_script_mode == "Examine (Arcade Objects)" then
				examine_data = getExamineDataArcade(object_pointers[object_index]);
			elseif grab_script_mode == "Examine (Spawners)" then
				examine_data = getExamineDataSpawners(object_pointers[object_index]);
			end

			pagifyThis(examine_data, 40);

			for i = page_finish, page_start + 1, -1 do
				if examine_data[i][1] ~= "Separator" then
					if type(examine_data[i][2]) == "number" then
						examine_data[i][2] = round(examine_data[i][2], precision);
					end
					gui.text(gui_x, gui_y + height * row, examine_data[i][1]..": "..examine_data[i][2], nil, 'bottomright');
					row = row + 1;
				else
					row = row + examine_data[i][2];
				end
			end
		end

		if grab_script_mode == "List (Object Model 1)" then
			row = row + 1;
			pagifyThis(object_pointers, 40);
			for i = page_finish, page_start + 1, -1 do
				local currentActorSize = mainmemory.read_u32_be(object_pointers[i] + heap.object_size); -- TODO: Got an exception here while kiosk was booting
				local color = nil;
				if object_index == i then
					color = colors.yellow;
				end
				if object_pointers[i] == playerObject then
					color = colors.green;
				end
				gui.text(gui_x, gui_y + height * row, i..": "..getActorName(object_pointers[i]).." "..toHexString(object_pointers[i] or 0, 6).." ("..toHexString(currentActorSize)..")", color, 'bottomright');
				--gui.text(gui_x, gui_y + height * row, i..": "..getActorName(object_pointers[i]).." "..toHexString(object_pointers[i] or 0, 6).." ("..toHexString(currentActorSize)..")".." ("..getActorCollisions(object_pointers[i]).." cols)", color, 'bottomright');
				row = row + 1;
			end
		end

		if grab_script_mode == "List (Object Model 2)" then
			pagifyThis(object_pointers, 40);
			for i = page_finish, page_start + 1, -1 do
				local behaviorPointer = dereferencePointer(object_pointers[i] + obj_model2.behavior_pointer);
				local behaviorType = " "..getScriptName(object_pointers[i]);
				local collectableState = mainmemory.readbyte(object_pointers[i] + obj_model2.collectable_state);
				if isRDRAM(behaviorPointer) then
					behaviorPointer = " ("..toHexString(behaviorPointer, 6)..")";
				else
					behaviorPointer = "";
				end
				local behaviorID = mainmemory.read_u16_be(object_pointers[i] + 0x8A);
				behaviorPointer = behaviorPointer.." ("..toHexString(behaviorID, 4)..")";
				local color = nil;
				if FTA.isGB(collectableState) or FTA.isLowGB(collectableState) then
					color = colors.yellow;
				end
				if object_index == i then
					color = colors.green;
				end

				if not (behaviorPointer == "" and hide_non_scripted) then
					gui.text(gui_x, gui_y + height * row, i..": "..toHexString(object_pointers[i] or 0, 6)..behaviorType..behaviorPointer, color, 'bottomright');
					row = row + 1;
				end
			end
		end

		if grab_script_mode == "List (Arcade Objects)" then
			pagifyThis(object_pointers, 40);
			for i = page_finish, page_start + 1, -1 do
				local color = nil;
				if object_index == i then
					color = colors.green;
				end

				local objectType = mainmemory.readbyte(object_pointers[i] + arcade_object.object_type);
				local objectName = getArcadeObjectNameOSD(objectType);
				if objectType > 0 then
					gui.text(gui_x, gui_y + height * row, i..": "..objectName.." ("..objectType..") ("..toHexString(object_pointers[i] or 0, 6)..")", color, 'bottomright');
					row = row + 1;
				end
			end
		end

		if grab_script_mode == "List (Loading Zones)" then
			pagifyThis(object_pointers, 40);
			for i = page_finish, page_start + 1, -1 do
				local color = nil;
				if object_index == i then
					color = colors.green;
				end

				local base = object_pointers[i];
				if isRDRAM(base) then
					local _type = mainmemory.read_u16_be(base + loading_zone_fields.object_type);
					if loading_zone_fields.object_types[_type] ~= nil then
						_type = loading_zone_fields.object_types[_type].." ("..toHexString(_type)..")";
					else
						_type = toHexString(_type);
					end
					if string.contains(_type, "Loading Zone") then
						local destinationMap = mainmemory.read_u16_be(base + loading_zone_fields.destination_map);
						if Game.maps[destinationMap + 1] ~= nil then
							destinationMap = Game.maps[destinationMap + 1];
						else
							destinationMap = "Unknown Map "..toHexString(destinationMap);
						end
						local destinationExit = mainmemory.read_u16_be(base + loading_zone_fields.destination_exit);
						gui.text(gui_x, gui_y + height * row, destinationMap.." ("..destinationExit..") "..toHexString(base or 0, 6).." "..i, color, 'bottomright');
						row = row + 1;
					elseif string.contains(_type, "Cutscene Trigger") then
						gui.text(gui_x, gui_y + height * row, _type.." ("..mainmemory.read_u16_be(base + loading_zone_fields.destination_map)..") "..toHexString(base or 0, 6).." "..i, color, 'bottomright');
						row = row + 1;
					else
						gui.text(gui_x, gui_y + height * row, _type.." "..toHexString(base or 0, 6).." "..i, color, 'bottomright');
						row = row + 1;
					end
				end
			end
		end

		if grab_script_mode == "Chunks" then
			pagifyThis(object_pointers, 40);
			for i = page_finish, page_start + 1, -1 do
				local color = nil;
				if object_index == i then
					color = colors.green;
				end
				local d1 = mainmemory.read_u32_be(object_pointers[i] + chunk.deload1);
				local d2 = mainmemory.read_u32_be(object_pointers[i] + chunk.deload2);
				local d3 = mainmemory.read_u32_be(object_pointers[i] + chunk.deload3);
				local d4 = mainmemory.read_u32_be(object_pointers[i] + chunk.deload4);
				local v = mainmemory.readbyte(object_pointers[i] + chunk.visible);
				gui.text(gui_x, gui_y + height * row, toHexString(d1).." "..toHexString(d2).." "..toHexString(d3).." "..toHexString(d4).." "..v.." - "..i.." "..toHexString(object_pointers[i] or 0, 6), color, 'bottomright');
				row = row + 1;
			end
		end

		if grab_script_mode == "Exits" then
			pagifyThis(object_pointers, 40);
			for i = page_finish, page_start + 1, -1 do
				local exitBase = object_pointers[i];
				local color = nil;
				if object_index == i then
					color = colors.green;
				end
				local xPos = mainmemory.read_s16_be(exitBase + exit.x_pos);
				local yPos = mainmemory.read_s16_be(exitBase + exit.y_pos);
				local zPos = mainmemory.read_s16_be(exitBase + exit.z_pos);
				gui.text(gui_x, gui_y + height * row, xPos..", "..yPos..", "..zPos.." - "..i.." "..toHexString(exitBase or 0, 6), color, 'bottomright');
				row = row + 1;
			end
		end

		if grab_script_mode == "List (Spawners)" then
			pagifyThis(object_pointers, 40);
			for i = page_finish, page_start + 1, -1 do
				local slotBase = object_pointers[i];
				local enemyData = Game.getEnemyData(slotBase);
				local color = nil;
				if object_index == i then
					color = colors.green;
				end
				gui.text(gui_x, gui_y + height * row, i..": "..enemyData.enemyName.." ("..toHexString(slotBase)..")", color, 'bottomright');
				row = row + 1;
			end
		end
	end
end

------------
-- Events --
------------

function Game.setSimSlam(value)
	for kong = DK, Krusha do
		local base = Game.Memory.kong_base + kong * Game.Memory.kong_size;
		mainmemory.writebyte(base + sim_slam, value);
	end
end

function Game.unlockMoves()
	for kong = DK, Krusha do
		local base = Game.Memory.kong_base + kong * Game.Memory.kong_size;
		mainmemory.writebyte(base + moves, 3);
		mainmemory.writebyte(base + sim_slam, 3);
		mainmemory.writebyte(base + weapon, 7);
		mainmemory.writebyte(base + instrument, 15);
	end

	-- Complete Training barrels & Unlock Camera
	setFlagByName("Camera/Shockwave");
	setFlagByName("Training Grounds: Dive Barrel Completed");
	setFlagByName("Training Grounds: Orange Barrel Completed");
	setFlagByName("Training Grounds: Barrel Barrel Completed");
	setFlagByName("Training Grounds: Vine Barrel Completed");

	-- Unlock Kongs
	setFlagsByType("Kong");
end

function Game.getMap()
	return mainmemory.read_u32_be(Game.Memory.current_map);
end

function Game.getMapOSD()
	local currentMap = Game.getMap();
	local currentMapName = "Unknown";
	if Game.maps[currentMap + 1] ~= nil then
		currentMapName = Game.maps[currentMap + 1];
	end
	return currentMapName.." ("..currentMap..")";
end

function Game.setMap(value)
	if value >= 1 and value <= #Game.maps then
		value = value - 1;
		if Game.version == 4 then -- Replace setup, rather than the scene index since basically everything crashes on Kiosk
			----[[
			-- RuneHero's v1.0 code
			mainmemory.write_u16_be(0x59319C, 0x2004);
			mainmemory.write_u16_be(0x59319E, value);
			mainmemory.write_u16_be(0x5931B8, 0x2005);
			mainmemory.write_u16_be(0x5931BA, value);
			mainmemory.write_u16_be(0x5931B0, 0x2004);
			mainmemory.write_u16_be(0x5931B2, value);
			mainmemory.write_u16_be(0x5FE58C, 0x2005);
			mainmemory.write_u16_be(0x5FE58E, value);
			mainmemory.write_u16_be(0x5C5690, 0x2004);
			mainmemory.write_u16_be(0x5C5692, value);
			mainmemory.write_u16_be(0x5C8DFC, 0x2004);
			mainmemory.write_u16_be(0x5C8DFE, value);
			--]]

			-- RuneHero's v3.0 code, kinda crashy
			--[[
			mainmemory.write_u16_be(0x59319C, 0x2004);
			mainmemory.write_u16_be(0x59319E, value - 1);

			mainmemory.write_u16_be(0x5F5E5C, 0x2004);
			mainmemory.write_u16_be(0x5F5E5E, value - 1);

			-- A hook, methinks
			mainmemory.write_u32_be(0x66815C, 0x0C1FFC00);

			-- Some kind of ASM patch, will research what this does eventually
			mainmemory.write_u32_be(0x7FF000, 0x3C1B8073);
			mainmemory.write_u32_be(0x7FF004, 0x277BCDE4);
			mainmemory.write_u16_be(0x7FF008, 0xAF64);
			mainmemory.write_u32_be(0x7FF00C, 0xAFA40018);
			mainmemory.write_u32_be(0x7FF010, 0x03E00008);
			--]]
		else
			mainmemory.write_u32_be(Game.Memory.destination_map, value);
		end
	end
end

function Game.getLevelIndex()
	local currentMap = Game.getMap();
	local levelIndex = mainmemory.readbyte(Game.Memory.level_index_mapping + currentMap);
	if Game.version == 4 then
		if levelIndex == 0x09 or levelIndex == 0x0C then
			-- TODO: Figure out exactly what Kiosk does for submaps
			-- Kiosk is lacking the usual submap bytes it seems, compare "getLevelIndex" functions at 805FF030 (US 1.0) and 80593564 (US Kiosk)
		end
	else
		if levelIndex == 0x09 or levelIndex == 0x0D then -- "Bonus" or "Shared"
			if mainmemory.readbyte(Game.Memory.in_submap) > 0 then
				currentMap = mainmemory.read_u16_be(Game.Memory.parent_map);
				levelIndex = mainmemory.readbyte(Game.Memory.level_index_mapping + currentMap);
			end
		end
	end
	return levelIndex;
end

function Game.getLevelIndexOSD()
	local levelIndex = Game.getLevelIndex();
	return levelIndexes[levelIndex] or "Unknown "..toHexString(levelIndex);
end

function Game.dumpLevelIndexMap()
	for i = 1, #Game.maps do
		local mapName = Game.maps[i] or "Unknown "..toHexString(i - 1);
		local levelIndex = mainmemory.readbyte(Game.Memory.level_index_mapping + i - 1);
		local levelIndexName = levelIndexes[levelIndex] or "Unknown "..toHexString(levelIndex);
		dprint(toHexString(i - 1)..","..levelIndexName..","..mapName);
	end
	print_deferred();
end

function Game.initUI()
	-- Flag stuff
	if Game.version ~= 4 then
		ScriptHawk.UI.form_controls["Flag Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, flag_names, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(8) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);
		ScriptHawk.UI.button(10, 8, {46}, nil, "Set Flag Button", "Set", flagSetButtonHandler);
		ScriptHawk.UI.button(12, 8, {46}, nil, "Check Flag Button", "Check", flagCheckButtonHandler);
		ScriptHawk.UI.button(14, 8, {46}, nil, "Clear Flag Button", "Clear", flagClearButtonHandler);
		ScriptHawk.UI.checkbox(10, 6, "realtime_flags", "Realtime Flags", true);
	end

	-- Moon stuff
	--ScriptHawk.UI.form_controls["Moon Mode Label"] = forms.label(ScriptHawk.UI.options_form, "Moon:", ScriptHawk.UI.col(10), ScriptHawk.UI.row(2) + ScriptHawk.UI.label_offset, 48, ScriptHawk.UI.button_height);
	--ScriptHawk.UI.button({13, -18}, 2, {59}, nil, "Moon Mode Button", moon_mode, toggle_moonmode);

	-- Buttons
	ScriptHawk.UI.button(5, 4, {4, 10}, nil, nil, "Force Zipper", Game.forceZipper);
	--ScriptHawk.UI.button(5, 5, {4, 10}, nil, nil, "Random Color", Game.setKongColor);

	ScriptHawk.UI.button(7, 1, {64}, nil, "Toggle Visibility Button", "Invisify", toggle_invisify);
	ScriptHawk.UI.button(7, 2, {64}, nil, nil, "Detonate", Game.detonateLiveOranges);

	ScriptHawk.UI.button(10, 0, {4, 10}, nil, nil, "Unlock Moves", Game.unlockMoves);
	ScriptHawk.UI.button(10, 1, {4, 10}, nil, nil, "Toggle TB Void", Game.toggleTBVoid);
	ScriptHawk.UI.button(10, 2, {4, 10}, nil, nil, "Pause Cancel", Game.pauseCancel);
	--ScriptHawk.UI.button(10, 3, {4, 10}, nil, "Everything is Kong Button", "Kong", everythingIsKong);
	--ScriptHawk.UI.button(10, 4, {4, 10}, nil, nil, "Force Pause", Game.forcePause);
	ScriptHawk.UI.button(10, 4, {4, 10}, nil, nil, "Gain Control", Game.gainControl);
	--ScriptHawk.UI.button(10, 6, {4, 10}, nil, nil, "Random effect", random_effect);

	-- Lag fix
	ScriptHawk.UI.button({13, -5}, 5, {ScriptHawk.UI.button_height}, nil, "Decrease Lag Factor Button", "-", decrease_lag_factor);
	ScriptHawk.UI.button({13, ScriptHawk.UI.button_height - 5}, 5, {ScriptHawk.UI.button_height}, nil, "Increase Lag Factor Button", "+", increase_lag_factor);
	ScriptHawk.UI.form_controls["Lag Factor Value Label"] = forms.label(ScriptHawk.UI.options_form, "0", ScriptHawk.UI.col(13) + ScriptHawk.UI.button_height + 21, ScriptHawk.UI.row(5) + ScriptHawk.UI.label_offset, 54, 14);
	ScriptHawk.UI.checkbox(10, 5, "Toggle Lag Fix Checkbox", "Lag fix");

	-- Checkboxes
	ScriptHawk.UI.checkbox(0, 6, "Toggle Homing Ammo Checkbox", "Homing Ammo");
	ScriptHawk.UI.checkbox(5, 5, "Toggle Noclip Checkbox", "Noclip");
	--ScriptHawk.UI.checkbox(10, 5, "Toggle Neverslip Checkbox", "Never Slip");
	--ScriptHawk.UI.checkbox(5, 5, "Toggle Paper Mode Checkbox", "Paper Mode");
	ScriptHawk.UI.checkbox(5, 6, "Toggle OhWrongnana", "OhWrongnana");

	-- Heap Visualizer
	ScriptHawk.UI.checkbox(0, 7, "Heap Visualizer", "Heap Visualizer");
	ScriptHawk.UI.checkbox(5, 7, "Heap Visualizer Free Only", "Free Only");
	ScriptHawk.UI.checkbox(10, 7, "Heap Visualizer Dump Blocks", "Dump Blocks");

	-- Set character
	-- TODO: Different indexes on Kiosk
	ScriptHawk.UI.form_controls["Character Dropdown"] = forms.dropdown(ScriptHawk.UI.options_form, {"0. DK", "1. Diddy", "2. Lanky", "3. Tiny", "4. Chunky", "5. Krusha", "6. Rambi", "7. Enguarde", "8. Squawks", "9. Squawks"}, ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(9) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(9) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI.button(10, 9, {4, 10}, nil, nil, "Set Character", Game.setCharacterFromDropdown);

	-- Set Object Tools
	ScriptHawk.UI.form_controls["Analysis Type Text"] = forms.label(ScriptHawk.UI.options_form, analysis_slide_type, ScriptHawk.UI.col(9) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(10) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI.button(14, 10, {1, 1}, nil, nil, ">", increase_analysis_slide_type);
	ScriptHawk.UI.button(7.5, 10, {1, 1}, nil, nil, "<", decrease_analysis_slide_type);

	ScriptHawk.UI.form_controls["Analysis Subtype Text"] = forms.label(ScriptHawk.UI.options_form, analysis_slide_subtype, ScriptHawk.UI.col(9) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(11) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(4) + 8, ScriptHawk.UI.button_height);
	ScriptHawk.UI.button(14, 11, {1, 1}, nil, nil, ">", increase_analysis_slide_subtype);
	ScriptHawk.UI.button(7.5, 11, {1, 1}, nil, nil, "<", decrease_analysis_slide_subtype);

	ScriptHawk.UI.form_controls["Analysis Filter Label"] = forms.label(ScriptHawk.UI.options_form, "Filter:", ScriptHawk.UI.col(0) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.row(11) + ScriptHawk.UI.dropdown_offset, ScriptHawk.UI.col(1) + 15, ScriptHawk.UI.button_height);
	ScriptHawk.UI.form_controls["Analysis Filter Textbox"] = forms.textbox(ScriptHawk.UI.options_form, nil, ScriptHawk.UI.col(5), ScriptHawk.UI.button_height, nil, ScriptHawk.UI.col(2) + 4, ScriptHawk.UI.row(11));

	-- Output flag statistics
	flagStats();
end

function Game.unlockMenus()
	if Game.version ~= 4 then -- Anything but the Kiosk version
		mainmemory.write_u32_be(Game.Memory.menu_flags, 0xFFFFFFFF);
		mainmemory.write_u32_be(Game.Memory.menu_flags + 4, 0xFFFFFFFF);
	end
end

function Game.applyInfinites()
	local shared_collectables = Game.Memory.shared_collectables;

	mainmemory.write_u16_be(shared_collectables + standard_ammo, Game.getMaxStandardAmmo());
	if ScriptHawk.UI.ischecked("Toggle Homing Ammo Checkbox") then
		mainmemory.write_u16_be(shared_collectables + homing_ammo, Game.getMaxHomingAmmo());
	else
		mainmemory.write_u16_be(shared_collectables + homing_ammo, 0);
	end

	mainmemory.write_u16_be(shared_collectables + oranges, max_oranges);
	mainmemory.write_u16_be(shared_collectables + crystals, max_crystals * ticks_per_crystal);
	mainmemory.write_u16_be(shared_collectables + film, max_film);
	mainmemory.write_s8(shared_collectables + health, mainmemory.read_u8(shared_collectables + melons) * 4);

	for kong = DK, Krusha do
		local base = Game.Memory.kong_base + kong * Game.Memory.kong_size;
		mainmemory.write_u16_be(base + coins, max_coins);
		mainmemory.write_u16_be(base + lives, max_musical_energy);
	end

	--[[
	-- Make sure all fairy pics succeed
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		mainmemory.writebyte(playerObject + obj_model1.player.fairy_active, 0x01);
	end
	--]]
end

--------------------
-- Object Overlay --
--------------------
local viewport_YAngleRange = 75;
local viewport_XAngleRange = 70;
local object_selectable_size = 10;
local reference_distance = 2000;

local screen = {
	width = client.bufferwidth(),
	height = client.bufferheight(),
};

function drawObjectPositions()
	screen.width = client.bufferwidth();
	screen.height = client.bufferheight();

	local objectModel;
	if string.contains(grab_script_mode, "Model 2") then
		objectModel = 2;
		populateObjectModel2Pointers();
	elseif string.contains(grab_script_mode, "Model 1") then
		objectModel = 1;
		populateObjectModel1Pointers();
	else
		return;
	end

	local startDrag = false;
	local dragging = false;
	local dragTransform = {0, 0};
	local mouse = input.getmouse();

	if mouse.Left then -- if mouse clicked object is being dragged
		if not mouseClickedLastFrame then
			startDrag = true;
			startDragPosition = {mouse.X, mouse.Y};
		end
		mouseClickedLastFrame = true;
		dragging = true;
		dragTransform = {mouse.X - startDragPosition[1], mouse.Y - startDragPosition[2]};
	else
		draggedObjects = {};
		mouseClickedLastFrame = false;
		dragging = false;
	end

	local camera = dereferencePointer(Game.Memory.camera_pointer);
	local cameraData = {};
	if isRDRAM(camera) then
		cameraData.xPos = mainmemory.readfloat(camera + obj_model1.camera.viewport_x_position, true);
		cameraData.yPos = mainmemory.readfloat(camera + obj_model1.camera.viewport_y_position, true);
		cameraData.zPos = mainmemory.readfloat(camera + obj_model1.camera.viewport_z_position, true);
		cameraData.xRot = (mainmemory.readfloat(camera + obj_model1.camera.viewport_x_rotation, true) / 360) * math.pi / 180;
		cameraData.yRot = (mainmemory.read_u16_be(camera + obj_model1.camera.viewport_y_rotation) / Game.max_rot_units * 360) * math.pi / 180;
	else
		return;
	end

	for i = 1, #object_pointers do
		local slotBase = object_pointers[i];

		-- Translate origin to camera position
		local xDifference, yDifference, zDifference;
		if objectModel == 1 then
			xDifference = mainmemory.readfloat(slotBase + obj_model1.x_pos, true) - cameraData.xPos;
			yDifference = mainmemory.readfloat(slotBase + obj_model1.y_pos, true) - cameraData.yPos;
			zDifference = mainmemory.readfloat(slotBase + obj_model1.z_pos, true) - cameraData.zPos;
		else
			xDifference = mainmemory.readfloat(slotBase + obj_model2.x_pos, true) - cameraData.xPos;
			yDifference = mainmemory.readfloat(slotBase + obj_model2.y_pos, true) - cameraData.yPos;
			zDifference = mainmemory.readfloat(slotBase + obj_model2.z_pos, true) - cameraData.zPos;
		end

		local drawXPos = 0;
		local drawYPos = 0;
		local scaling_factor = 0;

		-- Transform object point to point in coordinate system based on camera normal
		-- Rotation transform 1
		local tempData = {
			xPos = -math.cos(cameraData.yRot) * xDifference + math.sin(cameraData.yRot) * zDifference,
			yPos = yDifference,
			zPos = math.sin(cameraData.yRot) * xDifference + math.cos(cameraData.yRot) * zDifference,
		};

		-- Rotation transform 2
		local objectData = { -- NEED TO DOUBLE CHECK ONCE RELIABLE X ROTATION FOUND
			xPos = tempData.xPos,
			yPos = -math.sin(cameraData.xRot) * tempData.zPos + math.cos(cameraData.xRot) * tempData.yPos,
			zPos = math.cos(cameraData.xRot) * tempData.zPos + math.sin(cameraData.xRot) * tempData.yPos,
		};

		-- Fix for first person view
		if mainmemory.readbyte(camera + obj_model1.camera.state_type) == 0x03 then
			objectData.xPos = -objectData.xPos;
			objectData.zPos = -objectData.zPos;
		end

		if objectData.zPos > 50 then
			local XAngle_local = math.atan(objectData.yPos / objectData.zPos); -- Horizontal Angle
			local YAngle_local = math.atan(objectData.xPos / objectData.zPos); -- Horizontal Angle
			-- Don't need to compentate for tan since angle between

			YAngle_local = ((YAngle_local + math.pi) % (2 * math.pi)) - math.pi; -- Get angle between -180 and +180
			XAngle_local = ((XAngle_local + math.pi) % (2 * math.pi)) - math.pi;

			if YAngle_local <= (viewport_YAngleRange / 2) and YAngle_local > (-viewport_XAngleRange / 2) then
				if XAngle_local <= (viewport_XAngleRange / 2) and XAngle_local > (-viewport_YAngleRange / 2) then

					-- At this point object is selectable/draggable
					drawXPos = (screen.width / 2) * math.sin(YAngle_local) / math.sin(viewport_YAngleRange * math.pi / 360) + screen.width / 2;
					drawYPos = -(screen.height / 2) * math.sin(XAngle_local) / math.sin(viewport_XAngleRange * math.pi / 360) + screen.height / 2;
					--drawYPos = -(screen.height) * math.sin(XAngle_local) / math.sin(viewport_XAngleRange * math.pi / 360);

					-- Calc scaling factor -- current calc might be incorrect
					scaling_factor = reference_distance / objectData.zPos;

					--[[
					if draggedObjects[1] ~= nil then
						if i == draggedObjects[1][1] then
							if dragging then
								drawXPos = draggedObjects[1][2] + dragTransform[1];
								drawYPos = draggedObjects[1][3] + dragTransform[2];
								objectData.zPos = draggedObjects[1][4];

								-- Transform screen-to-game coords
								YAngle_local = math.asin(math.sin(viewport_YAngleRange * math.pi / 360) * (2 * drawXPos / screen.width - 1));
								XAngle_local = math.asin(math.sin(viewport_XAngleRange * math.pi / 360) * (1 - 2 * drawYPos / screen.height));

								objectData.yPos = objectData.zPos * math.tan(XAngle_local); -- Horizontal Angle
								objectData.xPos = objectData.zPos * math.tan(YAngle_local);

								tempData.xPos = objectData.xPos;
								tempData.yPos = math.cos(cameraData.xRot)*objectData.yPos + math.sin(cameraData.xRot)*objectData.zPos;
								tempData.zPos = - math.sin(cameraData.xRot)*objectData.yPos + math.cos(cameraData.xRot)*objectData.zPos;

								xDifference = -math.cos(cameraData.yRot)*tempData.xPos + math.sin(cameraData.yRot)*tempData.zPos;
								yDifference = tempData.yPos;
								zDifference = math.sin(cameraData.yRot)*tempData.xPos + math.cos(cameraData.yRot)*tempData.zPos;

								-- Save new object position to RDRAM
								if objectModel == 1 then
									setObjectModel1Position(slotBase, cameraData.xPos + xDifference, cameraData.yPos + yDifference, cameraData.zPos + zDifference);
								else
									setObjectModel2Position(slotBase, cameraData.xPos + xDifference, cameraData.yPos + yDifference, cameraData.zPos + zDifference);
								end
							end
						end
					end
					--]]

					-- Draw to screen
					local color = colors.white;
					if object_index == i then
						color = colors.yellow;
						if startDrag then
							table.insert(draggedObjects, {i, drawXPos, drawYPos, objectData.zPos});
						end
					end

					gui.drawLine(drawXPos, 0, drawXPos, 20, color);
					gui.drawText(drawXPos, 0, string.format("%d", i), color, nil, 12);
					--gui.drawLine(drawXPos - scaling_factor * object_selectable_size / 2, drawYPos, drawXPos + scaling_factor * object_selectable_size / 2, drawYPos, color);
					--gui.drawLine(drawXPos, drawYPos - scaling_factor * object_selectable_size / 2, drawXPos, drawYPos + scaling_factor * object_selectable_size / 2, color);
					--gui.drawText(drawXPos, drawYPos, string.format("%d", i), color, nil, 9 + 3 * scaling_factor);
				end
			end
		end

		-- Object selection
		if mouse.Left then
			if (mouse.X >= drawXPos - scaling_factor * object_selectable_size / 2 and mouse.X <= drawXPos + scaling_factor * object_selectable_size / 2) 
				and (mouse.Y >= drawYPos - scaling_factor * object_selectable_size / 2 and mouse.Y <= drawYPos + scaling_factor * object_selectable_size / 2) then
				object_index = i;
			end
		end
	end
end

-------------------
-- Color setters --
-------------------

local function getNextTextureRenderer(texturePointer)
	return dereferencePointer(texturePointer + obj_model1.texture_renderer.next_renderer);
end

function Game.getTextureRenderers()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = dereferencePointer(playerObject + obj_model1.texture_renderer_pointer);
		while isRDRAM(texturePointer) do
			print(toHexString(texturePointer));
			texturePointer = getNextTextureRenderer(texturePointer);
		end
	end
end

function Game.setDKColors()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = dereferencePointer(playerObject + obj_model1.texture_renderer_pointer);
		if isRDRAM(texturePointer) then
			local DKBodyColors = {
				{"Normal", 0},
				{"Light Blue", 1},
				{"Light Green", 2},
				{"Purple", 3},
				{"Bright Orange", 16},
				{"Yellow", 19},
			};

			local DKTieColors = {
				{"Red (Normal)", 0},
				{"Purple", 1},
				{"Blue", 2},
				{"Yellow", 3},
			};

			texturePointer = getNextTextureRenderer(texturePointer); -- Skip eyes

			-- 1 Body
			mainmemory.write_u16_be(texturePointer + obj_model1.texture_renderer.texture_index, DKBodyColors[math.random(1, #DKBodyColors)][2]);
			texturePointer = getNextTextureRenderer(texturePointer);

			-- 2 Tie Outer
			mainmemory.write_u16_be(texturePointer + obj_model1.texture_renderer.texture_index, DKTieColors[math.random(1, #DKTieColors)][2]);

			-- TODO: Tie inner
		end
	end
end

function Game.setDiddyColors()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = dereferencePointer(playerObject + obj_model1.texture_renderer_pointer);
		if isRDRAM(texturePointer) then
			local DiddyHatColors = {
				{"Red (Normal)", 0},
				{"Dark Blue", 1},
				{"Yellow", 2},
				{"Blue", 3},
				{"Purple", 19},
				{"Dark Red", 24},
				{"Green", 26},
			};

			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Left eye
			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Right eye

			-- 3 Hat
			mainmemory.write_u16_be(texturePointer + obj_model1.texture_renderer.texture_index, DiddyHatColors[math.random(1, #DiddyHatColors)][2]);
		end
	end
end

function Game.setLankyColors()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = dereferencePointer(playerObject + obj_model1.texture_renderer_pointer);
		if isRDRAM(texturePointer) then
			local LankyTopColors = {
				{"Blue (Normal)", 0},
				{"Green", 1},
				{"Purple", 2},
				{"Red", 3},
				{"Yellow", 27},
			};

			texturePointer = getNextTextureRenderer(texturePointer); -- Skip eyes

			-- 1 Top
			mainmemory.write_u16_be(texturePointer + obj_model1.texture_renderer.texture_index, LankyTopColors[math.random(1, #LankyTopColors)][2]);

			-- TODO: Bottom
		end
	end
end

function Game.setTinyColors()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = dereferencePointer(playerObject + obj_model1.texture_renderer_pointer);
		if isRDRAM(texturePointer) then
			local TinyBodyColors = {
				{"Blue (Normal)", 0},
				{"Green", 1},
				{"Purple", 2},
				{"Orange", 3},
			};

			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Left eye
			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Right eye

			-- 3 Body
			mainmemory.write_u16_be(texturePointer + obj_model1.texture_renderer.texture_index, TinyBodyColors[math.random(1, #TinyBodyColors)][2]);
		end
	end
end

function Game.setChunkyColors()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = dereferencePointer(playerObject + obj_model1.texture_renderer_pointer);
		if isRDRAM(texturePointer) then
			local ChunkyBackColors = {
				{"Green + Yellow (Normal)", 0},
				{"Red + Yellow", 1},
				{"Blue + Light Blue", 2},
				{"Purple + Pink", 3},
				{"Blue", 16},
				{"Red", 17},
				{"Purple", 18},
				{"Green", 19},
			};

			local ChunkyFrontColors = {
				{"Blue (Normal)", 0},
				{"Red", 1},
				{"Purple", 2},
				{"Green", 3},
			};

			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Eyes

			-- 1 Back
			mainmemory.write_u16_be(texturePointer + obj_model1.texture_renderer.texture_index, ChunkyBackColors[math.random(1, #ChunkyBackColors)][2]);
			texturePointer = getNextTextureRenderer(texturePointer);

			-- 2 Front
			mainmemory.write_u16_be(texturePointer + obj_model1.texture_renderer.texture_index, ChunkyFrontColors[math.random(1, #ChunkyFrontColors)][2]);
		end
	end
end

function Game.setKrushaColors()
	local playerObject = Game.getPlayerObject();
	if isRDRAM(playerObject) then
		local texturePointer = dereferencePointer(playerObject + obj_model1.texture_renderer_pointer);
		if isRDRAM(texturePointer) then
			local KrushaColors = {
				{"Blue (Normal)", 0},
				{"Green", 1},
				{"Purple", 2},
				{"Yellow", 3},
			};

			texturePointer = getNextTextureRenderer(texturePointer); -- Skip Eyes

			-- 2 Body
			mainmemory.write_u16_be(texturePointer + obj_model1.texture_renderer.texture_index, KrushaColors[math.random(1, #KrushaColors)][2]);
		end
	end
end

local setColorFunctions = {
	[DK] = Game.setDKColors,
	[Diddy] = Game.setDiddyColors,
	[Lanky] = Game.setLankyColors,
	[Tiny] = Game.setTinyColors,
	[Chunky] = Game.setChunkyColors,
	[Krusha] = Game.setKrushaColors
};

function Game.setKongColor()
	local currentKong = Game.getCharacter();
	if type(setColorFunctions[currentKong]) == "function" then
		setColorFunctions[currentKong]();
	end
end

function Game.getCharacter()
	return mainmemory.readbyte(Game.Memory.character);
end

function Game.setCharacter(value)
	-- Slow tag method, go through loading zone
	--mainmemory.writebyte(Game.Memory.character, value);

	-- Fast tag method, instant
	-- Thanks to: Tom Ballaam, 2dos, retroben, Kaze Emanuar
	local player = Game.getPlayerObject();
	mainmemory.writebyte(player + Game.Memory.character_change_offset_player_actor, value + 2);
	local mysteryObject = dereferencePointer(Game.Memory.character_change_pointer);
	if isRDRAM(mysteryObject) then
		mainmemory.write_u16_be(mysteryObject + Game.Memory.character_change_offset_mystery_object, Game.Memory.character_change_value_mystery_object);
	end
end

function Game.setCharacterFromDropdown()
	local index = tonumber(forms.getproperty(ScriptHawk.UI.form_controls["Character Dropdown"], "SelectedIndex"));
	Game.setCharacter(index);
end

local function readTimestamp(address)
	local major = mainmemory.read_u32_be(address) * secs_per_major_tick;
	local minor = mainmemory.read_u32_be(address + 4) * nano_per_minor_tick / 1000000000;
	return major + minor; -- Seconds
end

local isgFadeouts = {
	-- [fadeoutNumber] = {timeWhenActivatedNTSC, timeWhenActivatedPAL, destinationMap, destinationCutscene},
	[1] = {54.402840201712, 53.3563167242293, 172, 0}, -- 0:55
	[2] = {86.0060613902424, 84.3184562118823, 152, 0}, -- 1:25
	[3] = {158.617401149804, 155.501121154548, 172, 1}, -- 2:36
	[4] = {183.54729382101, 179.927929853791, 153, 7}, -- 3:01
	[5] = {208.719224903778, 204.596787380047, 152, 8}, -- 3:25
	[6] = {271.268708638889, 265.895772889864, 171, 0}, -- 4:26
};

function Game.drawUI()
	updateCurrentInvisify();
	forms.settext(ScriptHawk.UI.form_controls["Lag Factor Value Label"], lag_factor);
	forms.settext(ScriptHawk.UI.form_controls["Toggle Visibility Button"], current_invisify);
	forms.settext(ScriptHawk.UI.form_controls["Analysis Type Text"],analysis_slide_type);
	forms.settext(ScriptHawk.UI.form_controls["Analysis Subtype Text"],analysis_slide_subtype);
	grab_script_mode_from_inputs();
	turnFilterBoxIntoFilter();
	--forms.settext(ScriptHawk.UI.form_controls["Moon Mode Button"], moon_mode);
	drawGrabScriptUI();

	if ScriptHawk.UI.ischecked("Heap Visualizer") then
		Game.drawHeap();
		gui.DrawNew("emu");
	else
		--gui.DrawNew("native"); -- Clear off any old heap visualization stuff from the screen
		--gui.DrawNew("emu");
	end

	-- Mad Jack
	Game.drawMJMinimap();

	-- King Kut Out
	Game.drawKutOutMinimap();

	-- Arcade hitboxes
	if isInSubGame() then
		drawSubGameHitboxes();
	else
		--drawObjectPositions(); -- TODO: Get the Y position working properly for this
	end

	if Game.version ~= 4 then
		-- Draw ISG timer
		if mainmemory.readbyte(Game.Memory.isg_active) > 0 then
			local isg_start = readTimestamp(Game.Memory.isg_timestamp);
			if isg_start > 0 then -- If intro story start timestamp is 0 fadeouts will never happen
				local isg_time = readTimestamp(Game.Memory.timestamp) - isg_start;
				local timer_string = string.format("%.2d:%05.2f", isg_time / 60 % 60, isg_time % 60);
				gui.text(16, 16, "ISG Timer: "..timer_string, nil, 'topright');

				local introStoryStage = 0;
				for i = 1, #isgFadeouts do
					if Game.version == 2 then
						if isg_time > isgFadeouts[i][2] then
							introStoryStage = i;
						end
					else
						if isg_time > isgFadeouts[i][1] then
							introStoryStage = i;
						end
					end
				end
				local lastFadeout = mainmemory.readbyte(Game.Memory.isg_previous_fadeout);
				local destinationMap = mainmemory.read_u32_be(Game.Memory.destination_map);
				local destinationCutscene = mainmemory.read_u16_be(Game.Memory.cutscene_to_play_next_map);
				local cutsceneFading = mainmemory.readbyte(Game.Memory.cutscene_will_play_next_map);
				if introStoryStage > 0 then
					if introStoryStage > lastFadeout then
						gui.text(16, 32, "Fadeout "..introStoryStage.." pending", nil, 'topright');
					elseif destinationMap == isgFadeouts[introStoryStage][3] and destinationCutscene == isgFadeouts[introStoryStage][4] and cutsceneFading == 1 then
						gui.text(16, 32, "Fading (Fadeout "..introStoryStage..")", nil, 'topright');
					end
				end
			end
		else
			--gui.text(16, 16, "Waiting for ISG", nil, 'topright');
		end
	end
end

function Game.getISG()
	if Game.version == 4 then
		return;
	end
	local ts1 = mainmemory.read_u32_be(Game.Memory.timestamp);
	local ts2 = mainmemory.read_u32_be(Game.Memory.timestamp + 4);
	mainmemory.write_u32_be(Game.Memory.isg_timestamp, ts1);
	mainmemory.write_u32_be(Game.Memory.isg_timestamp + 4, ts2);
	mainmemory.writebyte(Game.Memory.isg_active, 1);
end

--[[
RNGLock = 0;
function increaseRNGLock()
	RNGLock = RNGLock + 1;
end

function decreaseRNGLock()
	RNGLock = RNGLock - 1;
end

ScriptHawk.bindKeyFrame("K", decreaseRNGLock, false);
ScriptHawk.bindKeyFrame("L", increaseRNGLock, false);
--]]

function Game.realTime()
	-- Lock RNG at constant value
	--mainmemory.write_u32_be(Game.Memory.RNG, RNGLock);
end

local vertSize = 0x10;
local vert = {
	x_position = 0x00, -- s16_be
	y_position = 0x02, -- s16_be
	z_position = 0x04, -- s16_be
	mapping_1 = 0x08, -- Texture mapping, unknown datatype
	mapping_2 = 0x0A, -- Texture mapping, unknown datatype
	shading_1 = 0x0C, -- Unknown datatype
	shading_2 = 0x0E, -- Unknown datatype
};

function Game.getMapBlock()
	return dereferencePointer(Game.Memory.map_block_pointer);
end

function Game.getMapSegmentBase()
	local mapBase = Game.getMapBlock();
	if isRDRAM(mapBase) then
		return mapBase + mainmemory.read_u32_be(mapBase + 0x58);
	end
end

function Game.getMapVerts()
	return dereferencePointer(Game.Memory.map_vertex_pointer);
end

function Game.getMapVertsEnd()
	local mapBase = Game.getMapBlock();
	if isRDRAM(mapBase) then
		return mapBase + mainmemory.read_u32_be(mapBase + 0x40);
	end
end

function Game.getMapDLStart()
	return dereferencePointer(Game.Memory.map_displaylist_pointer);
end

function crumbleVerts(vertBase, vertEnd)
	for v = vertBase, vertEnd, vertSize do
		if math.random() > 0.9 then
			local xPos = mainmemory.read_s16_be(v + vert.x_position);
			local yPos = mainmemory.read_s16_be(v + vert.y_position);
			local zPos = mainmemory.read_s16_be(v + vert.z_position);

			local mapping1 = mainmemory.read_s16_be(v + vert.mapping_1);
			local mapping2 = mainmemory.read_s16_be(v + vert.mapping_2);

			if math.random() > 0.5 then
				mainmemory.write_s16_be(v + vert.x_position, xPos - 1);
				mainmemory.write_s16_be(v + vert.y_position, yPos - 1);
				mainmemory.write_s16_be(v + vert.z_position, zPos - 1);

				mainmemory.write_s16_be(v + vert.mapping_1, mapping1 + math.floor(math.random(50, 100)));
				mainmemory.write_s16_be(v + vert.mapping_2, mapping2 + math.floor(math.random(50, 100)));
			else
				mainmemory.write_s16_be(v + vert.x_position, xPos + 1);
				mainmemory.write_s16_be(v + vert.y_position, yPos + 1);
				mainmemory.write_s16_be(v + vert.z_position, zPos + 1);

				mainmemory.write_s16_be(v + vert.mapping_1, mapping1 - math.floor(math.random(50, 100)));
				mainmemory.write_s16_be(v + vert.mapping_2, mapping2 - math.floor(math.random(50, 100)));
			end
		end
	end
end

function crumble()
	local mapBase = Game.getMapBlock();
	local vertBase = Game.getMapVerts();
	local vertEnd = Game.getMapVertsEnd();

	if isRDRAM(mapBase) and isRDRAM(vertBase) and isRDRAM(vertEnd) then
		crumbleVerts(vertBase, vertEnd);

		local chunkArray = Game.getChunkArray();
		local DLBase = Game.getMapDLStart();
		if isRDRAM(chunkArray) and isRDRAM(DLBase)then
			local numChunks = math.floor(mainmemory.read_u32_be(chunkArray + heap.object_size) / chunk.size);
			for i = 0, numChunks - 1 do
				local chunkBase = chunkArray + i * chunk.size;
				local chunkDLArrayHeap = dereferencePointer(chunkBase + 0x4C);
				if isRDRAM(chunkDLArrayHeap) then
					local chunkMappingSize = mainmemory.read_u32_be(chunkDLArrayHeap + heap.object_size);
					local numChunkMappings = math.floor(chunkMappingSize / 0x24);
					for j = 0, numChunkMappings - 1 do
						local chunkMappingBase = chunkDLArrayHeap + j * 0x24;
						local DLPointer1 = dereferencePointer(chunkMappingBase + 0x04);
						local DLPointer2 = dereferencePointer(chunkMappingBase + 0x08);
						local vertPointer1 = dereferencePointer(chunkMappingBase + 0x14);
						local vertPointer2 = dereferencePointer(chunkMappingBase + 0x18);
						local size1 = parseDLVertPointerPair(DLBase, vertBase, vertEnd, DLPointer1, vertPointer1, true);
						local size2 = parseDLVertPointerPair(DLBase, vertBase, vertEnd, DLPointer2, vertPointer2, true);
						if type(size1) == "number" and size1 > 0 then
							crumbleVerts(vertPointer1, vertPointer1 + size1 - 0x40);
						end
						if type(size2) == "number" and size2 > 0 then
							crumbleVerts(vertPointer2, vertPointer2 + size2 - 0x40);
						end
					end
				end
			end
		end
	end
end

function dumpSegments()
	local segmentBase = Game.getMapSegmentBase();
	if isRDRAM(segmentBase) then
		local numSegments = mainmemory.read_u32_be(segmentBase);
		dprint(numSegments.." segments at "..toHexString(segmentBase));
		segmentBase = segmentBase + 4;
		for i = 0, numSegments - 1 do
			dprint("Segment ID: "..mainmemory.read_u16_be(segmentBase + 2));
			dprint("Vert 0x08: "..toHexString(mainmemory.read_u16_be(segmentBase + 0x08)));
			dprint("Vert 0x0A: "..toHexString(mainmemory.read_u16_be(segmentBase + 0x0A)));
			dprint("Vert 0x0C: "..toHexString(mainmemory.read_u16_be(segmentBase + 0x0C)));
			dprint("Vert 0x0E: "..toHexString(mainmemory.read_u16_be(segmentBase + 0x0E)));
			dprint("Vert 0x10: "..toHexString(mainmemory.read_u16_be(segmentBase + 0x10)));
			dprint("Loaded 0x18: "..mainmemory.readbyte(segmentBase + 0x18));
			dprint("Loaded 0x19: "..mainmemory.readbyte(segmentBase + 0x19));
			dprint();
			segmentBase = segmentBase + 0x1C;
		end
		print_deferred();
	end
end

function fuckSegments()
	local segmentBase = Game.getMapSegmentBase();
	if isRDRAM(segmentBase) then
		local numSegments = mainmemory.read_u32_be(segmentBase);
		segmentBase = segmentBase + 4;
		for i = 0, numSegments - 1 do
			mainmemory.write_u16_be(segmentBase + 0x08, 0x0000);
			mainmemory.write_u16_be(segmentBase + 0x0A, 0x0000);
			mainmemory.write_u16_be(segmentBase + 0x0C, 0x0000);
			mainmemory.write_u16_be(segmentBase + 0x0E, 0x0000);
			mainmemory.write_u16_be(segmentBase + 0x10, 0x0000);
			segmentBase = segmentBase + 0x1C;
		end
	end
	dumpSegments();
end

function fuckSegmentIDs()
	local segmentBase = Game.getMapSegmentBase();
	if isRDRAM(segmentBase) then
		local numSegments = mainmemory.read_u32_be(segmentBase);
		segmentBase = segmentBase + 4;
		for i = 0, numSegments - 1 do
			mainmemory.write_u16_be(segmentBase + 2, 0x0000);
			segmentBase = segmentBase + 0x1C;
		end
	end
	dumpSegments();
end

function fuckSegment(segmentIndex)
	local segmentBase = Game.getMapSegmentBase();
	if isRDRAM(segmentBase) then
		local numSegments = mainmemory.read_u32_be(segmentBase);
		segmentBase = segmentBase + 4;
		for i = 0, numSegments - 1 do
			if mainmemory.read_u16_be(segmentBase + 2) == segmentIndex then
				mainmemory.write_u16_be(segmentBase + 0x08, 0x0000);
				mainmemory.write_u16_be(segmentBase + 0x0A, 0x0000);
				mainmemory.write_u16_be(segmentBase + 0x0C, 0x0000);
				mainmemory.write_u16_be(segmentBase + 0x0E, 0x0000);
				mainmemory.write_u16_be(segmentBase + 0x10, 0x0000);
			end
			segmentBase = segmentBase + 0x1C;
		end
	end
	dumpSegments();
end

function parseDLVertPointerPair(DLBase, vertBase, vertEnd, DLPointer, vertPointer, suppressPrint)
	suppressPrint = suppressPrint or false;
	if isRDRAM(DLPointer) then
		local NOPTagString = "";
		if mainmemory.read_u32_be(DLPointer - 0x08) == 0x00000000 then
			NOPTagString = " NOPTag: "..toHexString(mainmemory.read_u32_be(DLPointer - 0x04));
		end
		if not suppressPrint then
			dprint("DLPointer: "..toHexString(DLPointer).." relative: "..toHexString(DLPointer - DLBase)..NOPTagString);
		end
		if isRDRAM(vertPointer) then
			local relativeString = "";
			local size = 0;
			if vertPointer >= vertBase and vertPointer < vertEnd then
				local relativeActual = vertPointer - vertBase;
				local relativeVert = relativeActual / vertSize;
				relativeString = " relative: "..toHexString(relativeActual).." or vert no "..toHexString(relativeVert);
			else
				local prev = dereferencePointer(vertPointer - 0x30 + heap.previous_object);
				local freeprev = mainmemory.read_u32_be(vertPointer - 0x30 + heap.prev_free_block);
				local freenext = mainmemory.read_u32_be(vertPointer - 0x30 + heap.next_free_block);
				if isRDRAM(prev) and freeprev == 0x00000000 and freenext == 0x00000000 then
					size = mainmemory.read_u32_be(vertPointer - 0x30 + heap.object_size);
					relativeString = " ON HEAP! Size: "..toHexString(size);
				else
					relativeString = " ON HEAP! Mid block, unknown size";
				end
			end
			if not suppressPrint then
				dprint("VertPointer: "..toHexString(vertPointer)..relativeString);
			end
			if suppressPrint and size > 0 then
				return size;
			end
		end
	end
end

function dumpDLBases()
	local chunkArray = Game.getChunkArray();
	local DLBase = Game.getMapDLStart();
	local vertBase = Game.getMapVerts();
	local vertEnd = Game.getMapVertsEnd();
	if isRDRAM(chunkArray) and isRDRAM(DLBase) and isRDRAM(vertBase) and isRDRAM(vertEnd) then
		local numChunks = math.floor(mainmemory.read_u32_be(chunkArray + heap.object_size) / chunk.size);
		for i = 0, numChunks - 1 do
			local chunkBase = chunkArray + i * chunk.size;
			local chunkDLArrayHeap = dereferencePointer(chunkBase + 0x4C);
			if isRDRAM(chunkDLArrayHeap) then
				dprint("ChunkBase "..toHexString(chunkBase).." points to -> "..toHexString(chunkDLArrayHeap));
				local chunkMappingSize = mainmemory.read_u32_be(chunkDLArrayHeap + heap.object_size);
				local numChunkMappings = math.floor(chunkMappingSize / 0x24);
				for j = 0, numChunkMappings - 1 do
					local chunkMappingBase = chunkDLArrayHeap + j * 0x24;
					local DLPointer1 = dereferencePointer(chunkMappingBase + 0x04);
					local DLPointer2 = dereferencePointer(chunkMappingBase + 0x08);
					local vertPointer1 = dereferencePointer(chunkMappingBase + 0x14);
					local vertPointer2 = dereferencePointer(chunkMappingBase + 0x18);
					parseDLVertPointerPair(DLBase, vertBase, vertEnd, DLPointer1, vertPointer1);
					parseDLVertPointerPair(DLBase, vertBase, vertEnd, DLPointer2, vertPointer2);
				end
			end
		end
		print_deferred();
	end
end

function F3DEX2Trace()
	local DLBase = Game.getMapDLStart();
	local vertBase = Game.getMapVerts();
	if isRDRAM(DLBase) and isRDRAM(vertBase) and vertBase > DLBase then
		local returnStack = {};
		local commandBase = DLBase;
		while commandBase < vertBase - 8 do
			local command = mainmemory.readbyte(commandBase);
			local commandStr = toHexString(commandBase)..": "..toHexString(command, 2)..": ";
			if command == 0x00 then
				dprint(commandStr.."NOP, Tag: "..mainmemory.read_u32_be(commandBase + 4));
			elseif command == 0x01 then
				local bank = mainmemory.readbyte(commandBase + 4);
				local address = mainmemory.read_u24_be(commandBase + 5);
				local num = bit.rshift(bit.band(mainmemory.read_u32_be(commandBase), 0x000FF000), 12);
				dprint(commandStr.."Loading "..num.." Verts: Bank "..bank.." Address "..toHexString(address));
			elseif command == 0x03 then
				--dprint(commandStr.."G_CULLDL");
			elseif command == 0x05 then
				local v1 = mainmemory.readbyte(commandBase + 1) / 2;
				local v2 = mainmemory.readbyte(commandBase + 2) / 2;
				local v3 = mainmemory.readbyte(commandBase + 3) / 2;
				dprint(commandStr.."Triangle, Verts: "..v1..","..v2..","..v3);
			elseif command == 0x06 then
				local v1 = mainmemory.readbyte(commandBase + 1) / 2;
				local v2 = mainmemory.readbyte(commandBase + 2) / 2;
				local v3 = mainmemory.readbyte(commandBase + 3) / 2;
				local v4 = mainmemory.readbyte(commandBase + 5) / 2;
				local v5 = mainmemory.readbyte(commandBase + 6) / 2;
				local v6 = mainmemory.readbyte(commandBase + 7) / 2;
				dprint(commandStr.."Triangles, Verts: "..v1..","..v2..","..v3.." and "..v4..","..v5..","..v6);
			elseif command == 0x07 then
				local v1 = mainmemory.readbyte(commandBase + 1) / 2;
				local v2 = mainmemory.readbyte(commandBase + 2) / 2;
				local v3 = mainmemory.readbyte(commandBase + 3) / 2;
				local v4 = mainmemory.readbyte(commandBase + 5) / 2;
				local v5 = mainmemory.readbyte(commandBase + 6) / 2;
				local v6 = mainmemory.readbyte(commandBase + 7) / 2;
				dprint(commandStr.."Quad, Verts: "..v1..","..v2..","..v3.." and "..v4..","..v5..","..v6);
			elseif command == 0xD7 then
				dprint(commandStr.."G_TEXTURE");
			elseif command == 0xD9 then
				dprint(commandStr.."G_GEOMETRYMODE");
			elseif command == 0xDB then
				dprint(commandStr.."G_MOVEWORD");
			elseif command == 0xDE then
				local destination = mainmemory.read_u24_be(commandBase + 5);
				local pushRA = mainmemory.readbyte(commandBase + 1);
				if pushRA == 0x00 then
					table.insert(returnStack, commandBase);
				end
				commandBase = DLBase + destination;
				dprint(commandStr.."Start DL: "..toHexString(destination, 6));
			elseif command == 0xDF then
				if #returnStack > 0 then
					commandBase = returnStack[#returnStack];
					table.remove(returnStack, 1);
					dprint(commandStr.."End DL and returning to "..toHexString(commandBase, 6));
				else
					dprint(commandStr.."End DL");
				end
			elseif command == 0xE2 then
				dprint(commandStr.."G_SETOTHERMODE_L");
			elseif command == 0xE3 then
				dprint(commandStr.."G_SETOTHERMODE_H");
			elseif command == 0xE6 then
				--dprint(commandStr.."G_RDPLOADSYNC"); -- Synchronize with rendering to safely load texture
			elseif command == 0xE7 then
				--dprint(commandStr.."G_RDPPIPESYNC"); -- Synchronize with rendering to safely update RDP attributes
			elseif command == 0xE8 then
				--dprint(commandStr.."G_RDPTILESYNC"); -- Synchronize with rendering to safely update tile descriptor attributes
			elseif command == 0xE9 then
				--dprint(commandStr.."G_RDPFULLSYNC"); -- Indicates end of RDP processing; interrupts CPU when RDP has nothing more to do
			elseif command == 0xF0 then
				dprint(commandStr.."G_LOADTLUT");
			elseif command == 0xF2 then
				dprint(commandStr.."G_SETTILESIZE");
			elseif command == 0xF3 then
				dprint(commandStr.."G_LOADBLOCK");
			elseif command == 0xF5 then
				dprint(commandStr.."G_SETTILE");
			elseif command == 0xF6 then
				dprint(commandStr.."G_FILLRECT");
			elseif command == 0xFC then
				dprint(commandStr.."G_SETCOMBINE");
			elseif command == 0xFD then
				local texturePointer = mainmemory.read_u32_be(commandBase + 4);
				dprint(commandStr.."Set Texture "..toHexString(texturePointer));
			else
				dprint(commandStr.."Unknown");
			end
			commandBase = commandBase + 8;
		end
		print_deferred();
	end
end

local globalVertIndex = 0;

local wallTriangle = {
	size = 0x18,
	x1 = 0x00, -- s16 be
	y1 = 0x02, -- s16 be
	z1 = 0x04, -- s16 be
	x2 = 0x06, -- s16 be
	y2 = 0x08, -- s16 be
	z2 = 0x0A, -- s16 be
	x3 = 0x0C, -- s16 be
	y3 = 0x0E, -- s16 be
	z3 = 0x10, -- s16 be
	nx = 0x12, -- s16 be
	ny = 0x14, -- s16 be
	nz = 0x16, -- s16 be
};

function readWallTriangle(base)
	if isPointer(base) then
		base = base - RDRAMBase;
	end
	if not isRDRAM(base) then
		return {
			base = 0,
			x1 = 0, y1 = 0, z1 = 0,
			x2 = 0, y2 = 0, z2 = 0,
			x3 = 0, y3 = 0, z3 = 0,
			nx = 0, ny = 0, nz = 0,
		};
	end
	return {
		base = base,
		x1 = mainmemory.read_s16_be(base + wallTriangle.x1),
		y1 = mainmemory.read_s16_be(base + wallTriangle.y1),
		z1 = mainmemory.read_s16_be(base + wallTriangle.z1),
		x2 = mainmemory.read_s16_be(base + wallTriangle.x2),
		y2 = mainmemory.read_s16_be(base + wallTriangle.y2),
		z2 = mainmemory.read_s16_be(base + wallTriangle.z2),
		x3 = mainmemory.read_s16_be(base + wallTriangle.x3),
		y3 = mainmemory.read_s16_be(base + wallTriangle.y3),
		z3 = mainmemory.read_s16_be(base + wallTriangle.z3),
		nx = mainmemory.read_s16_be(base + wallTriangle.nx),
		ny = mainmemory.read_s16_be(base + wallTriangle.ny),
		nz = mainmemory.read_s16_be(base + wallTriangle.nz),
	};
end

function outputWallTris(base, numTris)
	--print("Dumping "..numTris.." triangles at "..toHexString(base));
	if isRDRAM(base) then
		dprint("g mesh"..toHexString(base));
		for i = 0, numTris - 1 do
			local triBase = base + i * wallTriangle.size;
			local triangle = readWallTriangle(triBase);
			dprint("v "..triangle.x1.." "..triangle.y1.." "..triangle.z1);
			dprint("v "..triangle.x2.." "..triangle.y2.." "..triangle.z2);
			dprint("v "..triangle.x3.." "..triangle.y3.." "..triangle.z3);
			--dprint("vn "..triangle.nx.." "..triangle.ny.." "..triangle.nz);
			dprint("f "..(globalVertIndex + 1).." "..(globalVertIndex + 2).." "..(globalVertIndex + 3));
			globalVertIndex = globalVertIndex + 3;
		end
		print_deferred();
	end
end

function dumpMapWalls()
	local collisionMetaBlock = dereferencePointer(Game.Memory.map_wall_pointer);
	if isRDRAM(collisionMetaBlock) then
		local tris = dereferencePointer(collisionMetaBlock + 0x04);
		if isRDRAM(tris) then
			local blockStart = tris - 0x08;
			local blockSize = mainmemory.read_u32_be(blockStart + heap.object_size);
			tris = tris - 0x04;
			while tris < blockStart + blockSize do
				local trisRelative = tris + 4 - blockStart;
				local numTris = (mainmemory.read_u32_be(tris) - trisRelative) / wallTriangle.size;
				if numTris > 0 and numTris < blockSize / wallTriangle.size then
					outputWallTris(tris + 4, numTris);
				else
					--print("Warning: Block with <= 0 tris at "..toHexString(tris));
				end
				tris = mainmemory.read_u32_be(tris);
				if tris == 0 then
					break;
				end
				tris = blockStart + tris;
			end
		end
	end
end

local floorTriangle = {
	size = 0x18,
	x1 = 0x00, -- s16 be / 6
	x2 = 0x02, -- s16 be / 6
	x3 = 0x04, -- s16 be / 6
	y1 = 0x06, -- s16 be / 6
	y2 = 0x08, -- s16 be / 6
	y3 = 0x0A, -- s16 be / 6
	z1 = 0x0C, -- s16 be / 6
	z2 = 0x0E, -- s16 be / 6
	z3 = 0x10, -- s16 be / 6
	water = 0x13, -- byte
	sfx = 0x15, -- byte
	brightness = 0x16, -- byte % 16
};

function readFloorTriangle(base)
	if isPointer(base) then
		base = base - RDRAMBase;
	end
	if not isRDRAM(base) then
		return {
			base = 0,
			x1 = 0, y1 = 0, z1 = 0,
			x2 = 0, y2 = 0, z2 = 0,
			x3 = 0, y3 = 0, z3 = 0,
			water = 0, sfx = 0, brightness = 0,
		};
	end
	return {
		base = base,
		x1 = mainmemory.read_s16_be(base + floorTriangle.x1) / 6,
		y1 = mainmemory.read_s16_be(base + floorTriangle.y1) / 6,
		z1 = mainmemory.read_s16_be(base + floorTriangle.z1) / 6,
		x2 = mainmemory.read_s16_be(base + floorTriangle.x2) / 6,
		y2 = mainmemory.read_s16_be(base + floorTriangle.y2) / 6,
		z2 = mainmemory.read_s16_be(base + floorTriangle.z2) / 6,
		x3 = mainmemory.read_s16_be(base + floorTriangle.x3) / 6,
		y3 = mainmemory.read_s16_be(base + floorTriangle.y3) / 6,
		z3 = mainmemory.read_s16_be(base + floorTriangle.z3) / 6,
		water = mainmemory.readbyte(base + floorTriangle.water),
		sfx = mainmemory.readbyte(base + floorTriangle.sfx),
		brightness = mainmemory.readbyte(base + floorTriangle.brightness),
	};
end

function outputMapFloors(base, numTris)
	--print("Dumping "..numTris.." triangles at "..toHexString(base));
	if isRDRAM(base) then
		dprint("g mesh"..toHexString(base));
		for i = 0, numTris - 1 do
			local triBase = base + i * floorTriangle.size;
			local triangle = readFloorTriangle(triBase);
			dprint("v "..triangle.x1.." "..triangle.y1.." "..triangle.z1);
			dprint("v "..triangle.x2.." "..triangle.y2.." "..triangle.z2);
			dprint("v "..triangle.x3.." "..triangle.y3.." "..triangle.z3);
			dprint("f "..(globalVertIndex + 1).." "..(globalVertIndex + 2).." "..(globalVertIndex + 3));
			--dprint("Water: "..triangle.water);
			--dprint("SFX: "..triangle.sfx);
			--dprint("Brightness: "..toHexString(triangle.brightness % 16));
			globalVertIndex = globalVertIndex + 3;
		end
		print_deferred();
	end
end

function dumpMapFloors()
	local collisionMetaBlock = dereferencePointer(Game.Memory.map_floor_pointer);
	if isRDRAM(collisionMetaBlock) then
		local tris = dereferencePointer(collisionMetaBlock);
		if isRDRAM(tris) then
			local blockStart = tris - 0x08;
			local blockSize = mainmemory.read_u32_be(blockStart + heap.object_size);
			tris = tris - 0x04;
			while tris < blockStart + blockSize do
				local trisRelative = tris + 4 - blockStart;
				local numTris = (mainmemory.read_u32_be(tris) - trisRelative) / wallTriangle.size;
				if numTris > 0 and numTris < blockSize / wallTriangle.size then
					outputMapFloors(tris + 4, numTris);
				else
					--print("Warning: Block with <= 0 tris at "..toHexString(tris));
				end
				tris = mainmemory.read_u32_be(tris);
				if tris == 0 then
					break;
				end
				tris = blockStart + tris;
			end
		end
	end
end

function dumpMapCollisions()
	globalVertIndex = 0;
	dumpMapWalls();
	dumpMapFloors();
end

function Game.onLoadState()
	clearFlagCache();
	clearTempFlagCache();
	koshBot.resetSlots();
end

function Game.eachFrame()
	local playerObject = Game.getPlayerObject();
	map_value = Game.getMap();

	if isInSubGame() then
		Game.OSD = Game.subgameOSD;
	else
		Game.OSD = Game.standardOSD;
		if string.contains(grab_script_mode, "Chunks") then
			Game.OSD = Game.mapDebugOSD;
		end
	end

	if not Game.isLoading() then
		if crumbling then
			crumble();
		end

		if force_tbs then
			forceTBS();
		end

		if enable_phase then
			local currentCameraState = Game.getCameraState();
			if (currentCameraState == "Normal" or currentCameraState == "Locked" or currentCameraState == "Water") and (previousCameraState == "Fairy" or previousCameraState == "First Person") then
				local yRot = Game.getYRotation();
				if yRot < 2048 then
					Game.setYRotation(yRot + Game.max_rot_units);
				end
			end
			previousCameraState = currentCameraState;
		end

		-- TODO: This is really slow and doesn't cover all memory domains
		--memoryStatCache = getMemoryStats(dereferencePointer(Game.Memory.heap_pointer));

		--setWaterSurfaceTimers(surfaceTimerHack);
		--Game.unlockMenus(); -- TODO: Allow user to toggle this

		if ScriptHawk.UI.ischecked("Toggle Lag Fix Checkbox") then
			fixLag();
		end

		if koshBot.enabled then
			koshBot.Loop(); -- TODO: This probably stops the virtual pad from working
		end

		if never_slip then
			Game.neverSlip();
		end

		if paper_mode then
			Game.paperMode();
		end

		if fix_chunk_deload then
			Game.fixChunkDeload();
		end

		if ScriptHawk.UI.ischecked("Toggle Noclip Checkbox") then
			Game.setNoclipByte(0x01);
		end

		if ScriptHawk.UI.ischecked("Toggle OhWrongnana") then
			ohWrongnana();
		end

		if displacement_detection then
			displacementDetection();
		end

		if is_brb then
			doBRB();
		end

		-- Moonkick
		if moon_mode == 'All' or (moon_mode == 'Kick' and isRDRAM(playerObject) and mainmemory.readbyte(playerObject + obj_model1.player.animation_type) == 0x29) then
			Game.setYAcceleration(-2.5);
		end
	end

	-- Check EEPROM checksums
	local slotChanged = false;
	local checksum_value;
	for i = 1, #eep_checksum do
		checksum_value = memory.read_u32_be(eep_checksum[i].address, "EEPROM");
		if eep_checksum[i].value ~= checksum_value then
			slotChanged = true;
			if i == 5 then
				dprint("Global flags Checksum: "..toHexString(eep_checksum[i].value, 8).." -> "..toHexString(checksum_value, 8));
			else
				dprint("Slot "..(i - 1).." Checksum: "..toHexString(eep_checksum[i].value, 8).." -> "..toHexString(checksum_value, 8));
			end
			eep_checksum[i].value = checksum_value;
		end
	end
	if slotChanged then
		print_deferred();
	end

	-- Check for new flags being set
	if ScriptHawk.UI.ischecked("realtime_flags") then
		checkFlags(true);
		checkTemporaryFlags(true);
	end

	if force_gb_load then
		local objModel2Array = getObjectModel2Array();
		if isRDRAM(objModel2Array) then
			local numSlots = mainmemory.read_u32_be(Game.Memory.obj_model2_array_count);
			for i = 1, numSlots do
				local base = objModel2Array + (i - 1) * obj_model2_slot_size;
				if string.contains(getScriptName(base), "Golden Banana") then
					local behaviorPointer = dereferencePointer(base + obj_model2.behavior_pointer);
					if isRDRAM(behaviorPointer) then
						mainmemory.write_u16_be(behaviorPointer + 0x60, 0);
					end
				end
			end
		end
	end
end

function Game.crankyCutsceneMinimumRequirements()
	setFlagsByType("Crown");
	setFlagsByType("Fairy");
	setFlagsByType("Key");
	setFlagsByType("Medal");
	setFlagByName("Nintendo Coin");
	setFlagByName("Rareware Coin");

	-- GB counters
	for kong = DK, Chunky do
		local base = Game.Memory.kong_base + kong * Game.Memory.kong_size;
		for level = 0, 7 do
			mainmemory.write_s16_be(base + GB_Base + (level * 2), 5); -- Normal GBs
			if level == 7 and kong == Tiny then
				mainmemory.write_s16_be(base + GB_Base + (level * 2), 6); -- Rareware GB
			end
		end
	end
end

function Game.completeFile()
	Game.unlockMoves();

	setFlagsByType("Blueprint"); -- Not needed to trigger Cranky Cutscene
	setFlagsByType("CB"); -- Not needed to trigger the Cranky Cutscene
	setFlagsByType("Bunch"); -- Not needed to trigger the Cranky Cutscene
	setFlagsByType("Balloon"); -- Not needed to trigger the Cranky Cutscene
	setFlagsByType("Crown");
	setFlagsByType("Fairy");
	setFlagsByType("GB"); -- Not needed to trigger Cranky Cutscene
	setFlagsByType("Key");
	setFlagsByType("Medal");
	setFlagByName("Nintendo Coin");
	setFlagByName("Rareware Coin");

	-- CB and GB counters
	for kong = DK, Chunky do
		local base = Game.Memory.kong_base + kong * Game.Memory.kong_size;
		for level = 0, 6 do
			mainmemory.write_u16_be(base + CB_Base + (level * 2), 75); -- Not needed to trigger Cranky Cutscene
		end
		for level = 0, 7 do
			mainmemory.write_s16_be(base + GB_Base + (level * 2), 5); -- Normal GBs
			if level == 7 and kong == Tiny then
				mainmemory.write_s16_be(base + GB_Base + (level * 2), 6); -- Rareware GB
			end
		end
	end
end

Game.standardOSD = {
	{"Map", Game.getMapOSD, category="mapData"},
	{"Level", Game.getLevelIndexOSD, category="mapData"},
	{"Cutscene", Game.getCutsceneOSD, category="cutsceneData"},
	{"Exit", Game.getExitOSD, category="mapData"},
	{"Character", Game.getCharacter, category="player"},
	{"Player", hexifyOSD(Game.getPlayerObject), category="player"},
	{"Separator"},
	{"Mode", Game.getCurrentMode, category="gamemode"},
	{"File", Game.getFileOSD, category="fileView"},
	{"Flags", getFlagStatsOSD, category="flags"},
	{"Separator"},
	{"X", category="position"},
	{"Y", category="position"},
	{"Z", category="position"},
	{"Separator"},
	{"Floor", Game.getFloor, category="position"},
	{"Chunk", Game.getChunk, category="position"},
	{"Separator"},
	{"Lag Factor", Game.getLagFactor, category="lag"},
	{"dY", category="positionStats"},
	{"dXZ", category="positionStats"},
	{"Velocity", Game.getVelocity, category="speed"},
	--{"Accel", Game.getAcceleration, category="speed"}, -- TODO: Game.getAcceleration
	{"Y Velocity", Game.getYVelocity, category="speed"},
	{"Y Accel", Game.getYAcceleration, category="speed"},
	{"Separator"},
	{"Max dY", category="positionStatsMore"},
	{"Max dXZ", category="positionStatsMore"},
	{"Odometer", category="positionStatsMore"},
	{"Separator"},
	{"Rot. X", Game.getXRotation, category="angle"},
	{"Facing", Game.getYRotation, Game.colorYRotation, category="angle"},
	--{"Stored Rotation", Game.getStoredYRotation, Game.colorStoredYRotation, category="angle"},
	--{"Moving", Game.getMovingRotation, "angle"}, -- TODO: Game.getMovingRotation
	{"Rot. Z", Game.getZRotation, category="angle"},
	{"Movement", Game.getMovementState, category="movement"},
	{"Animation", Game.getAnimation, category="animation"},
	{"Num Bones", Game.getNumBones, category="animation"},
	{"Effect", hexifyOSD(Game.getEffectStatus), category="animation"},
	{"Camera", Game.getCameraState, category="camera"},
	{"Noclip", Game.getNoclipByte, Game.colorNoclipByte, category="noclip"},
	{"Separator"},
	{"Anim Timer 1", Game.getAnimationTimer1, category="animation"},
	{"Anim Timer 2", Game.getAnimationTimer2, category="animation"},
	{"Anim Timer 3", Game.getAnimationTimer3, category="animation"},
	{"Anim Timer 4", Game.getAnimationTimer4, category="animation"},
	{"Separator"},
	{"Bone Array 1", function() return Game.getBoneArray1PrettyPrint(Game.getPlayerObject()) end, category="bonearray"},
	{"Stored X1", function() return Game.getStoredX1(Game.getPlayerObject()) end, category="bonearray"},
	{"Stored Y1", function() return Game.getStoredY1(Game.getPlayerObject()) end, category="bonearray"},
	{"Stored Z1", function() return Game.getStoredZ1(Game.getPlayerObject()) end, category="bonearray"},
	{"Separator"},
	{"Bone Array 2", function() return Game.getBoneArray2PrettyPrint(Game.getPlayerObject()) end, category="bonearray"},
	{"Stored X2", function() return Game.getStoredX2(Game.getPlayerObject()) end, category="bonearray"},
	{"Stored Y2", function() return Game.getStoredY2(Game.getPlayerObject()) end, category="bonearray"},
	{"Stored Z2", function() return Game.getStoredZ2(Game.getPlayerObject()) end, category="bonearray"},
	{"Separator"},
	{"Free", Game.getFreeMemory, category="memory"},
	{"Used", Game.getUsedMemory, category="memory"},
	{"Total", Game.getTotalMemory, category="memory"},
};

Game.mapDebugOSD = {
	{"Map", Game.getMapOSD, category="mapData"},
	{"X", nil, category="position"},
	{"Y", nil, category="position"},
	{"Z", nil, category="position"},
	{"Separator"},
	{"dY", nil, category="positionStats"},
	{"dXZ", nil, category="positionStats"},
	{"Movement", Game.getMovementState, category="movement"},
	{"Separator"},
	{"Map Block", hexifyOSD(Game.getMapBlock, 6, ""), category="mapData"},
	{"Map Verts Start", hexifyOSD(Game.getMapVerts, 6, ""), category="mapData"},
	{"Map Verts End", hexifyOSD(Game.getMapVertsEnd, 6, ""), category="mapData"},
	{"Map DL Start", hexifyOSD(Game.getMapDLStart, 6, ""), category="mapData"},
	{"Chunk Array", hexifyOSD(Game.getChunkArray, 6, ""), category="mapData"},
};

Game.subgameOSD = {
	{"Level", getSubgameLevel, "mapData"},
	{"Separator"},
	{"X", nil, "position"},
	{"Y", nil, "position"},
	{"Separator"},
	{"dX", nil, "positionStats"},
	{"dY", nil, "positionStats"},
	{"Separator"},
	{"Velocity", Game.getVelocity, "speed"},
	{"Y Velocity", Game.getYVelocity, "speed"},
	{"Separator"},
	--{"Max dX", nil, "positionStatsMore"},
	--{"Max dY", nil, "positionStatsMore"},
	--{"Odometer", nil, "positionStatsMore"},
	--{"Separator"},
};

Game.OSDPosition = {32, 76}; -- TODO: Adjust this for subgames & different regions
Game.OSD = Game.standardOSD;

--print("Local Variables: "..countLocals().."/200");

function traverseHeap()
	local heapBase = dereferencePointer(Game.Memory.heap_pointer);
	if isRDRAM(heapBase) then
		traverseSize(heapBase);
	else
		print("Invalid heap pointer... Hmm...");
	end
end

function withinHeapBlock(address, block, size, includeHeader)
	if isRDRAM(address) and isRDRAM(block) then
		if type(size) ~= "number" then
			size = mainmemory.read_u32_be(block + heap.object_size);
		end
		if includeHeader then
			return address >= block - 0x10 and address < block + size;
		else
			return address >= block and address < block + size;
		end
	end
	return false;
end

--[[
RGBA
RRRGGGBB
00000000 - 00 - Black
11111111 - FF - White
00011100 - 1C - Green
11100000 - E0 - Red
00000011 - 03 - Blue
11100011 - E3 - Purple/Pink
11111100 - FC - Yellow
--]]

local addressColors = {
	[0] = 0x00, -- BLACK    - Unknown
	[1] = 0x1C, -- GREEN    - Free Memory
	[2] = 0xFC, -- YELLOW   - Framebuffer/Textures
	[3] = 0xF0, -- GOLD     - Object Model 1
	[4] = 0xE0, -- RED      - Object Model 2
	[5] = 0x83, -- PURPLE   - Code
	[6] = 0xE3, -- PINK     - Data
	[7] = 0x0F, -- BLUE     - Map
	[8] = 0x03, -- DARKBLUE - EEPROM Copy
};

identifyMemoryCache = nil;

function addHeapMetadata(address, key, value)
	if type(identifyMemoryCache.heapCache[address]) == "table" then
		identifyMemoryCache.heapCache[address][key] = value;
	end
end

function getHeapBlocksByFunction(comparator)
	if comparator == nil then
		comparator = function() return true; end;
	end
	buildIdentifyMemoryCache();
	for i = identifyMemoryCache.heapBase, identifyMemoryCache.heapEnd, 0x10 do
		if (identifyMemoryCache.heapCache[i] ~= nil) then
			local cachedBlock = identifyMemoryCache.heapCache[i];
			if comparator(cachedBlock) then
				if cachedBlock.references > 0 then
					local refStr = "";
					for j = 1, #cachedBlock.referenceAddresses do
						refStr = refStr..toHexString(cachedBlock.referenceAddresses[j]).." ";
					end
					dprint(toHexString(cachedBlock.block, 6, "").." Size: "..toHexString(cachedBlock.size).." "..cachedBlock.description.." Ref: "..cachedBlock.references.." "..refStr);
				else
					dprint(toHexString(cachedBlock.block, 6, "").." Size: "..toHexString(cachedBlock.size).." "..cachedBlock.description);
				end
			end
		end
	end
	print_deferred();
end

function getHeapBlocksByMetadata(key, value)
	buildIdentifyMemoryCache();
	print("Finding heap blocks with: "..tostring(key).." = "..tostring(value));
	for k, cachedBlock in pairs(identifyMemoryCache.heapCache) do
		if cachedBlock[key] == value then
			dprint(toHexString(cachedBlock.block, 6, "").." Size: "..toHexString(cachedBlock.size).." "..cachedBlock.description);
		end
	end
	print_deferred();
end

function buildIdentifyMemoryCache()
	identifyMemoryCache = {
		heapCache = {},
		heapBase = 0,
		heapEnd = RDRAMSize,
		textureCache = {},
		actorCollisions = {},
		actorTextureRenderers = {},
		model2CollisionCache = {},
		frameBuffers = {},
	};

	-- Cache framebuffers
	local frameBuffer = dereferencePointer(Game.Memory.framebuffer_pointer);
	if isRDRAM(frameBuffer) then
		table.insert(identifyMemoryCache.frameBuffers, {base=frameBuffer, width=320, height=240, bpp=16});
	end
	frameBuffer = dereferencePointer(Game.Memory.framebuffer_pointer + 4);
	if isRDRAM(frameBuffer) then
		table.insert(identifyMemoryCache.frameBuffers, {base=frameBuffer, width=320, height=240, bpp=16});
	end

	-- Cache heap
	local heapBase = dereferencePointer(Game.Memory.heap_pointer);
	if isRDRAM(heapBase) then
		local block, size, prev, nextFree, prevFree, isFree;
		local header = heapBase;
		repeat
			block = header + 0x10;
			size = mainmemory.read_u32_be(header + 4);
			nextFree = dereferencePointer(header + 8);
			prevFree = dereferencePointer(header + 12);
			isFree = isRDRAM(nextFree) or isRDRAM(prevFree);
			identifyMemoryCache.heapCache[block] = {
				description = "",
				header = header,
				block = block,
				size = size,
				next = block+size,
				prev = prev,
				isFree = isFree,
				nextFree = nextFree,
				prevFree = prevFree,
				references = 0,
				referenceAddresses = {},
			};
			if isFree then
				identifyMemoryCache.heapCache[block].description = "Free";
				identifyMemoryCache.heapCache[block].addressFound = true;
				identifyMemoryCache.heapCache[block].addressType = 1;
			end
			header = block + size;
			prev = mainmemory.read_u32_be(header);
		until prev == 0 or not isRDRAM(header);
		identifyMemoryCache.heapBase = heapBase;
		identifyMemoryCache.heapEnd = header;
	end

	-- Find references to heap blocks
	--[[
	for address = 0, RDRAMSize - 4, 4 do
		local value = dereferencePointer(address);
		if isRDRAM(value) and type(identifyMemoryCache.heapCache[value]) == "table" then
			identifyMemoryCache.heapCache[value].references = identifyMemoryCache.heapCache[value].references + 1;
			table.insert(identifyMemoryCache.heapCache[value].referenceAddresses, address);
		end
	end
	--]]

	-- Cache model 1
	for object_no = 0, 255 do
		local pointerAddress = Game.Memory.actor_pointer_array + (object_no * 4);
		local actor = dereferencePointer(pointerAddress);
		if isRDRAM(actor) then
			local actorName = getActorName(actor);
			addHeapMetadata(actor, "description", "Actor: "..actorName);
			addHeapMetadata(actor, "isActor", true);
			addHeapMetadata(actor, "addressFound", true);
			addHeapMetadata(actor, "addressType", 3);
			addHeapMetadata(actor, "actorName", actorName);
			local animationParamObject = dereferencePointer(actor + obj_model1.rendering_parameters_pointer);
			if isRDRAM(animationParamObject) then
				addHeapMetadata(animationParamObject, "description", "ActorAnimationParam: "..actorName);
				addHeapMetadata(animationParamObject, "isActorAnimationParamObject", true);
				addHeapMetadata(animationParamObject, "addressFound", true);
				addHeapMetadata(animationParamObject, "addressType", 3);
				addHeapMetadata(animationParamObject, "actor", actor);
				addHeapMetadata(animationParamObject, "actorName", actorName);
				local anim1Pointer = dereferencePointer(animationParamObject + 0x90);
				if isRDRAM(anim1Pointer) then
					addHeapMetadata(anim1Pointer, "description", "ActorAnimation: "..actorName);
					addHeapMetadata(anim1Pointer, "isActorAnimation", true);
					addHeapMetadata(anim1Pointer, "addressFound", true);
					addHeapMetadata(anim1Pointer, "addressType", 3);
					addHeapMetadata(anim1Pointer, "actor", actor);
					addHeapMetadata(anim1Pointer, "actorName", actorName);
				end
				local anim2Pointer = dereferencePointer(animationParamObject + 0x100);
				if isRDRAM(anim2Pointer) then
					addHeapMetadata(anim2Pointer, "description", "ActorAnimation: "..actorName);
					addHeapMetadata(anim2Pointer, "isActorAnimation", true);
					addHeapMetadata(anim2Pointer, "addressFound", true);
					addHeapMetadata(anim2Pointer, "addressType", 3);
					addHeapMetadata(anim2Pointer, "actor", actor);
					addHeapMetadata(anim2Pointer, "actorName", actorName);
				end
				local sharedModelObject = dereferencePointer(actor + obj_model1.model_pointer);
				if isRDRAM(sharedModelObject) then
					local numBones = mainmemory.readbyte(sharedModelObject + obj_model1.model.num_bones);
					addHeapMetadata(sharedModelObject, "description", "ActorSharedModel: "..actorName);
					addHeapMetadata(sharedModelObject, "isActorSharedModelObject", true);
					addHeapMetadata(sharedModelObject, "addressFound", true);
					addHeapMetadata(sharedModelObject, "addressType", 3);
					addHeapMetadata(sharedModelObject, "numBones", numBones);
					addHeapMetadata(sharedModelObject, "actor", actor);
					addHeapMetadata(sharedModelObject, "actorName", actorName);
					if numBones > 0 then
						local boneArraySize = numBones * bone_size;
						local boneArray1 = dereferencePointer(animationParamObject + obj_model1.rendering_parameters.bone_array_1);
						local boneArray2 = dereferencePointer(animationParamObject + obj_model1.rendering_parameters.bone_array_2);
						addHeapMetadata(animationParamObject, "numBones", numBones);
						addHeapMetadata(animationParamObject, "boneArraySize", boneArraySize);
						addHeapMetadata(animationParamObject, "boneArray1", boneArray1);
						addHeapMetadata(animationParamObject, "boneArray2", boneArray2);
					end
				end
			end
			-- Texture Renderer
			local textureRenderer = dereferencePointer(actor + obj_model1.texture_renderer_pointer);
			while isRDRAM(textureRenderer) do
				-- TODO: Can they be used by multiple actors?
				-- TODO: Figure out which texture is being rendered
				identifyMemoryCache.actorTextureRenderers[textureRenderer] = {
					block = textureRenderer,
					size = mainmemory.read_u32_be(textureRenderer + heap.object_size),
					actor = actor,
					actorName = actorName
				};
				textureRenderer = getNextTextureRenderer(textureRenderer);
			end
			-- Collision Queue
			local collision = dereferencePointer(actor + obj_model1.collision_queue_pointer);
			local target, targetName, size;
			local collisionCount = 0;
			local collisionPosition;
			while isRDRAM(collision) do
				size = mainmemory.read_u32_be(collision + heap.object_size);
				target = dereferencePointer(collision + 0x08);
				if isRDRAM(target) then
					targetName = getActorName(target);
				else
					target = 0;
					targetName = "";
				end

				if type(identifyMemoryCache.heapCache[collision]) == "table" then
					addHeapMetadata(collision, "description", "ActorCollision "..collisionCount..": "..actorName..":"..targetName);
					addHeapMetadata(collision, "isActorCollision", true);
					addHeapMetadata(collision, "addressFound", true);
					addHeapMetadata(collision, "addressType", 3);
					addHeapMetadata(collision, "actor", actor);
					addHeapMetadata(collision, "actorName", actorName);
					addHeapMetadata(collision, "target", target);
					addHeapMetadata(collision, "targetName", targetName);
					addHeapMetadata(collision, "collisionCount", collisionCount);
				elseif isRDRAM(collision) then
					identifyMemoryCache.actorCollisions[collision] = {
						isActorCollision = true,
						block = collision,
						size = size,
						actor = actor,
						actorName = actorName,
						target = target,
						targetName = targetName,
						collisionCount = collisionCount
					};
				end

				collisionPosition = dereferencePointer(collision + 0x10);
				if type(identifyMemoryCache.heapCache[collisionPosition]) == "table" then
					addHeapMetadata(collisionPosition, "description", "ActorCollisionPosition "..collisionCount..": "..actorName..":"..targetName);
					addHeapMetadata(collisionPosition, "isActorCollisionPosition", true);
					addHeapMetadata(collisionPosition, "addressFound", true);
					addHeapMetadata(collisionPosition, "addressType", 3);
					addHeapMetadata(collisionPosition, "actor", actor);
					addHeapMetadata(collisionPosition, "actorName", actorName);
					addHeapMetadata(collisionPosition, "target", target);
					addHeapMetadata(collisionPosition, "targetName", targetName);
					addHeapMetadata(collisionPosition, "collisionCount", collisionCount);
					addHeapMetadata(collisionPosition, "x", mainmemory.readfloat(collisionPosition + 0x00, true));
					addHeapMetadata(collisionPosition, "y", mainmemory.readfloat(collisionPosition + 0x04, true));
					addHeapMetadata(collisionPosition, "z", mainmemory.readfloat(collisionPosition + 0x08, true));
				elseif isRDRAM(collision) then
					--dprint("ActorCollisionPosition "..toHexString(collisionPosition).." was not on the heap!");
					identifyMemoryCache.actorCollisions[collisionPosition] = {
						isActorCollisionPosition = true,
						block = collisionPosition,
						size = mainmemory.read_u32_be(collisionPosition + heap.object_size),
						actor = actor,
						actorName = actorName,
						target = target,
						targetName = targetName,
						collisionCount = collisionCount,
						x = mainmemory.readfloat(collisionPosition + 0x00, true),
						y = mainmemory.readfloat(collisionPosition + 0x04, true),
						z = mainmemory.readfloat(collisionPosition + 0x08, true)
					};
				end

				collision = dereferencePointer(collision + 0x14);
				collisionCount = collisionCount + 1;
			end
		end
	end

	-- Cache model 2
	local objModel2Array = getObjectModel2Array();
	if isRDRAM(objModel2Array) then
		local numSlots = mainmemory.read_u32_be(Game.Memory.obj_model2_array_count);
		local arraySize = getObjectModel2ArraySize();
		addHeapMetadata(objModel2Array, "description", "Object Model 2 Array ("..numSlots.."/"..arraySize..")");
		addHeapMetadata(objModel2Array, "isObjectModel2Array", true);
		addHeapMetadata(objModel2Array, "addressFound", true);
		addHeapMetadata(objModel2Array, "addressType", 4);
		addHeapMetadata(objModel2Array, "numSlots", numSlots);
		addHeapMetadata(objModel2Array, "arraySize", arraySize);
		for i = 0, numSlots - 1 do
			local slotBase = objModel2Array + i * obj_model2_slot_size;
			local objectName = getScriptName(slotBase);
			local modelPointer = dereferencePointer(slotBase + obj_model2.behavior_type_pointer);
			if isRDRAM(modelPointer) then
				addHeapMetadata(modelPointer, "description", "Display List: "..objectName);
				addHeapMetadata(modelPointer, "isObjectModel2DisplayList", true);
				addHeapMetadata(modelPointer, "addressFound", true);
				addHeapMetadata(modelPointer, "addressType", 4);
				addHeapMetadata(modelPointer, "associatedModel2Object", slotBase);
				addHeapMetadata(modelPointer, "associatedModel2ObjectName", objectName);
			end
			-- BehaviorObject
			local activationScript = dereferencePointer(slotBase + obj_model2.behavior_pointer);
			if isRDRAM(activationScript) then
				addHeapMetadata(activationScript, "description", "Behavior Script (First): "..objectName);
				addHeapMetadata(activationScript, "isBehaviorScript", true);
				addHeapMetadata(activationScript, "addressFound", true);
				addHeapMetadata(activationScript, "addressType", 4);
				addHeapMetadata(activationScript, "topLevel", true);
				addHeapMetadata(activationScript, "associatedModel2Object", slotBase);
				addHeapMetadata(activationScript, "associatedModel2ObjectName", objectName);
				-- BehaviorScript
				activationScript = dereferencePointer(activationScript + 0xA0);
				while isRDRAM(activationScript) do
					addHeapMetadata(activationScript, "description", "Behavior Script: "..objectName);
					addHeapMetadata(activationScript, "isBehaviorScript", true);
					addHeapMetadata(activationScript, "addressFound", true);
					addHeapMetadata(activationScript, "addressType", 4);
					addHeapMetadata(activationScript, "topLevel", false);
					addHeapMetadata(activationScript, "associatedModel2Object", slotBase);
					addHeapMetadata(activationScript, "associatedModel2ObjectName", objectName);
					-- Get next script chunk
					activationScript = dereferencePointer(activationScript + 0x4C);
				end
			end
		end
	end

	-- Cache HUD
	local HUDObject = dereferencePointer(Game.Memory.hud_pointer);
	if isRDRAM(HUDObject) then
		addHeapMetadata(HUDObject, "description", "HUD");
		addHeapMetadata(HUDObject, "isHUDObject", true);
		addHeapMetadata(HUDObject, "addressFound", true);
		addHeapMetadata(HUDObject, "addressType", 6);
	end

	-- Cache enemies
	local enemyRespawnObject = dereferencePointer(Game.Memory.enemy_respawn_object);
	if isRDRAM(enemyRespawnObject) then
		addHeapMetadata(enemyRespawnObject, "description", "Enemy Respawn Object");
		addHeapMetadata(enemyRespawnObject, "isEnemyRespawnObject", true);
		addHeapMetadata(enemyRespawnObject, "addressFound", true);
		addHeapMetadata(enemyRespawnObject, "addressType", 3);
	end

	-- Cache map
	local mapBase = Game.getMapBlock();
	if isRDRAM(mapBase) then
		addHeapMetadata(mapBase, "description", "Map");
		addHeapMetadata(mapBase, "isMap", true);
		addHeapMetadata(mapBase, "addressFound", true);
		addHeapMetadata(mapBase, "addressType", 7);
	end

	-- Cache chunks
	local chunkArray = Game.getChunkArray();
	if isRDRAM(chunkArray) then
		addHeapMetadata(chunkArray, "description", "Map Chunk Array");
		addHeapMetadata(chunkArray, "isMapChunkArray", true);
		addHeapMetadata(chunkArray, "addressFound", true);
		addHeapMetadata(chunkArray, "addressType", 7);

		local vertBase = Game.getMapVerts();
		local vertEnd = Game.getMapVertsEnd();
		if isRDRAM(vertBase) and isRDRAM(vertEnd) then
			local numChunks = math.floor(mainmemory.read_u32_be(chunkArray + heap.object_size) / chunk.size);
			for i = 0, numChunks - 1 do
				local chunkBase = chunkArray + i * chunk.size;
				local chunkDLArrayHeap = dereferencePointer(chunkBase + 0x4C);
				if isRDRAM(chunkDLArrayHeap) then
					addHeapMetadata(chunkDLArrayHeap, "description", "Map Chunk DL Vert Mapping Array");
					addHeapMetadata(chunkDLArrayHeap, "isMapChunkDLVertMappingArray", true);
					addHeapMetadata(chunkDLArrayHeap, "addressFound", true);
					addHeapMetadata(chunkDLArrayHeap, "addressType", 7);
					local chunkMappingSize = mainmemory.read_u32_be(chunkDLArrayHeap + heap.object_size);
					local numChunkMappings = math.floor(chunkMappingSize / 0x24);
					for j = 0, numChunkMappings - 1 do
						local chunkMappingBase = chunkDLArrayHeap + j * 0x24;
						local DLPointer1 = dereferencePointer(chunkMappingBase + 0x04);
						local DLPointer2 = dereferencePointer(chunkMappingBase + 0x08);
						local vertPointer1 = dereferencePointer(chunkMappingBase + 0x14);
						local vertPointer2 = dereferencePointer(chunkMappingBase + 0x18);
						local size1 = parseDLVertPointerPair(DLBase, vertBase, vertEnd, DLPointer1, vertPointer1, true); -- TODO: DLBase might be undefined here
						local size2 = parseDLVertPointerPair(DLBase, vertBase, vertEnd, DLPointer2, vertPointer2, true); -- TODO: DLBase might be undefined here
						if type(size1) == "number" then
							vertPointer1 = vertPointer1 - 0x30;
							addHeapMetadata(vertPointer1, "description", "Map Vert Block");
							addHeapMetadata(vertPointer1, "DLPointer", DLPointer1);
							addHeapMetadata(vertPointer1, "isMapVertBlock", true);
							addHeapMetadata(vertPointer1, "addressFound", true);
							addHeapMetadata(vertPointer1, "addressType", 7);
						end
						if type(size2) == "number" then
							vertPointer2 = vertPointer2 - 0x30;
							addHeapMetadata(vertPointer2, "description", "Map Vert Block");
							addHeapMetadata(vertPointer2, "DLPointer", DLPointer2);
							addHeapMetadata(vertPointer2, "isMapVertBlock", true);
							addHeapMetadata(vertPointer2, "addressFound", true);
							addHeapMetadata(vertPointer2, "addressType", 7);
						end
					end
				end
			end
		end
	end

	-- Cache weather particle array
	local weatherParticleArray = dereferencePointer(Game.Memory.weather_particle_array_pointer);
	if isRDRAM(weatherParticleArray) then
		addHeapMetadata(weatherParticleArray, "description", "Weather Particle Array");
		addHeapMetadata(weatherParticleArray, "isWeatherParticleArray", true);
		addHeapMetadata(weatherParticleArray, "addressFound", true);
		addHeapMetadata(weatherParticleArray, "addressType", 7);
	end

	-- Cache dynamic water surfaces
	local waterSurface = dereferencePointer(Game.Memory.water_surface_list);
	while isRDRAM(waterSurface) do
		addHeapMetadata(waterSurface, "description", "Dynamic Water Surface");
		addHeapMetadata(waterSurface, "isDynamicWaterSurface", true);
		addHeapMetadata(waterSurface, "addressFound", true);
		addHeapMetadata(waterSurface, "addressType", 7);
		addHeapMetadata(waterSurface, "timer1", mainmemory.read_u32_be(waterSurface + dynamicWaterSurface.timer_1));
		addHeapMetadata(waterSurface, "timer2", mainmemory.read_u32_be(waterSurface + dynamicWaterSurface.timer_2));
		addHeapMetadata(waterSurface, "timer3", mainmemory.read_u32_be(waterSurface + dynamicWaterSurface.timer_3));
		addHeapMetadata(waterSurface, "timer4", mainmemory.read_u32_be(waterSurface + dynamicWaterSurface.timer_4));
		waterSurface = dereferencePointer(waterSurface + dynamicWaterSurface.next_surface_pointer);
	end

	-- Cache exits
	local exitArray = dereferencePointer(Game.Memory.exit_array_pointer);
	if isRDRAM(exitArray) then
		addHeapMetadata(exitArray, "description", "Map Exit Array");
		addHeapMetadata(exitArray, "isExitArray", true);
		addHeapMetadata(exitArray, "addressFound", true);
		addHeapMetadata(exitArray, "addressType", 7);
	end

	-- Cache loading zones
	local lzArray = Game.getLoadingZoneArray();
	if isRDRAM(lzArray) then
		addHeapMetadata(lzArray, "description", "Loading Zone Array");
		addHeapMetadata(lzArray, "isLoadingZoneArray", true);
		addHeapMetadata(lzArray, "addressFound", true);
		addHeapMetadata(lzArray, "addressType", 7);
	end

	-- Cache setup
	local setupFile = dereferencePointer(Game.Memory.obj_model2_setup_pointer);
	if isRDRAM(setupFile) then
		addHeapMetadata(setupFile, "description", "Map Setup");
		addHeapMetadata(setupFile, "isMapSetup", true);
		addHeapMetadata(setupFile, "addressFound", true);
		addHeapMetadata(setupFile, "addressType", 7);
	end

	-- Cache textures (heap)
	local textureIndexObject = dereferencePointer(Game.Memory.texture_index_object_pointer);
	if isRDRAM(textureIndexObject) then
		addHeapMetadata(textureIndexObject, "description", "Texture Index");
		addHeapMetadata(textureIndexObject, "isTextureIndexObject", true);
		addHeapMetadata(textureIndexObject, "addressFound", true);
		addHeapMetadata(textureIndexObject, "addressType", 2);
		for i = identifyMemoryCache.heapCache[textureIndexObject].block, identifyMemoryCache.heapCache[textureIndexObject].block + identifyMemoryCache.heapCache[textureIndexObject].size - 4, 4 do
			local texture = dereferencePointer(i);
			if isRDRAM(texture) then
				if type(identifyMemoryCache.heapCache[texture]) == "table" then
					addHeapMetadata(texture, "description", "Texture");
					addHeapMetadata(texture, "isTexture", true);
					addHeapMetadata(texture, "addressFound", true);
					addHeapMetadata(texture, "addressType", 2);
					identifyMemoryCache.heapCache[texture].textureID = (i - identifyMemoryCache.heapCache[textureIndexObject].block) / 4;
				else
					--dprint("Warning: Texture "..toHexString(texture).." was not on the heap");
				end
			end
		end
	end
	textureIndexObject = dereferencePointer(Game.Memory.texture_index_object_pointer_2);
	if isRDRAM(textureIndexObject) then
		addHeapMetadata(textureIndexObject, "description", "Texture Index");
		addHeapMetadata(textureIndexObject, "isTextureIndexObject", true);
		addHeapMetadata(textureIndexObject, "addressFound", true);
		addHeapMetadata(textureIndexObject, "addressType", 2);
		for i = identifyMemoryCache.heapCache[textureIndexObject].block, identifyMemoryCache.heapCache[textureIndexObject].block + identifyMemoryCache.heapCache[textureIndexObject].size - 4, 4 do
			local texture = dereferencePointer(i);
			if isRDRAM(texture) then
				if type(identifyMemoryCache.heapCache[texture]) == "table" then
					addHeapMetadata(texture, "description", "Texture");
					addHeapMetadata(texture, "isTexture", true);
					addHeapMetadata(texture, "addressFound", true);
					addHeapMetadata(texture, "addressType", 2);
					identifyMemoryCache.heapCache[texture].textureID = (i - identifyMemoryCache.heapCache[textureIndexObject].block) / 4;
				else
					--dprint("Warning: Texture "..toHexString(texture).." was not on the heap");
				end
			end
		end
	end
	textureIndexObject = dereferencePointer(Game.Memory.ffa_texture_index_object_pointer);
	if isRDRAM(textureIndexObject) then
		addHeapMetadata(textureIndexObject, "description", "FFA Texture Index");
		addHeapMetadata(textureIndexObject, "isFFATextureIndexObject", true);
		addHeapMetadata(textureIndexObject, "addressFound", true);
		addHeapMetadata(textureIndexObject, "addressType", 2);
		for i = identifyMemoryCache.heapCache[textureIndexObject].block, identifyMemoryCache.heapCache[textureIndexObject].block + identifyMemoryCache.heapCache[textureIndexObject].size - 4, 4 do
			local texture = dereferencePointer(i);
			if isRDRAM(texture) then
				if type(identifyMemoryCache.heapCache[texture]) == "table" then
					addHeapMetadata(texture, "description", "FFA Texture");
					addHeapMetadata(texture, "isFFATexture", true);
					addHeapMetadata(texture, "addressFound", true);
					addHeapMetadata(texture, "addressType", 2);
					identifyMemoryCache.heapCache[texture].textureID = (i - identifyMemoryCache.heapCache[textureIndexObject].block) / 4;
				else
					--dprint("Warning: Texture "..toHexString(texture).." was not on the heap");
				end
			end
		end
	end

	local textureROMMapObject = dereferencePointer(Game.Memory.texture_rom_map_object_pointer);
	if isRDRAM(textureROMMapObject) then
		addHeapMetadata(textureROMMapObject, "description", "Texture ROM Map");
		addHeapMetadata(textureROMMapObject, "isTextureROMMapObject", true);
		addHeapMetadata(textureROMMapObject, "addressFound", true);
		addHeapMetadata(textureROMMapObject, "addressType", 2);
	end
	textureROMMapObject = dereferencePointer(Game.Memory.texture_rom_map_object_pointer_2);
	if isRDRAM(textureROMMapObject) then
		addHeapMetadata(textureROMMapObject, "description", "Texture ROM Map");
		addHeapMetadata(textureROMMapObject, "isTextureROMMapObject", true);
		addHeapMetadata(textureROMMapObject, "addressFound", true);
		addHeapMetadata(textureROMMapObject, "addressType", 2);
	end
	textureROMMapObject = dereferencePointer(Game.Memory.ffa_texture_rom_map_object_pointer);
	if isRDRAM(textureROMMapObject) then
		addHeapMetadata(textureROMMapObject, "description", "FFA Texture ROM Map");
		addHeapMetadata(textureROMMapObject, "isFFATextureROMMapObject", true);
		addHeapMetadata(textureROMMapObject, "addressFound", true);
		addHeapMetadata(textureROMMapObject, "addressType", 2);
	end

	-- Cache texture list (off heap)
	local textureList = dereferencePointer(Game.Memory.texture_list_pointer);
	if isRDRAM(textureList) then
		local block, size, prev;
		local header = textureList;
		repeat
			block = header + 0x10;
			size = mainmemory.read_u32_be(header + 4);
			if size == 0 then
				break;
			end
			identifyMemoryCache.textureCache[block] = {header=header, block=block, size=size};
			header = block + size;
			prev = mainmemory.read_u32_be(header);
		until prev == 0 or not isRDRAM(header);
	end

	local model2DLIndexObject = dereferencePointer(Game.Memory.model2_dl_index_object_pointer);
	if isRDRAM(model2DLIndexObject) then
		addHeapMetadata(model2DLIndexObject, "description", "Model 2 Display List Index");
		addHeapMetadata(model2DLIndexObject, "isModel2DLIndexObject", true);
		addHeapMetadata(model2DLIndexObject, "addressFound", true);
		addHeapMetadata(model2DLIndexObject, "addressType", 4);
	end
	local model2DLROMMapObject = dereferencePointer(Game.Memory.model2_dl_rom_map_object_pointer);
	if isRDRAM(model2DLROMMapObject) then
		addHeapMetadata(model2DLROMMapObject, "description", "Model 2 Display List ROM Map");
		addHeapMetadata(model2DLROMMapObject, "isModel2DLROMMapObject", true);
		addHeapMetadata(model2DLROMMapObject, "addressFound", true);
		addHeapMetadata(model2DLROMMapObject, "addressType", 4);
	end

	-- Cache object model 2 collisions
	local collisionLinkedListPointer = dereferencePointer(Game.Memory.obj_model2_collision_linked_list_pointer);
	if isRDRAM(collisionLinkedListPointer) then
		local collisionListObjectSize = mainmemory.read_u32_be(collisionLinkedListPointer + heap.object_size);
		addHeapMetadata(collisionLinkedListPointer, "description", "Collision Index");
		addHeapMetadata(collisionLinkedListPointer, "isCollisionLinkedListObject", true);
		addHeapMetadata(collisionLinkedListPointer, "addressFound", true);
		addHeapMetadata(collisionLinkedListPointer, "addressType", 4);
		for i = 0, collisionListObjectSize - 4, 4 do
			local object = dereferencePointer(collisionLinkedListPointer + i);
			local safety;
			while isRDRAM(object) do
				local kong = mainmemory.read_u16_be(object + 0x04);
				local collisionType = mainmemory.read_u16_be(object + 0x02);
				if obj_model2.object_types[collisionType] ~= nil then
					collisionType = obj_model2.object_types[collisionType];
				else
					collisionType = toHexString(collisionType, 4);
				end
				safety = dereferencePointer(object + 0x18); -- Get next object
				identifyMemoryCache.model2CollisionCache[object] = {block=object, next=safety, kong=kong, collisionType=collisionType};
				if safety == object or safety == collisionLinkedListPointer - 0x10 then -- Prevent infinite loops
					break;
				end
				object = safety;
			end
		end
	end
end

function dumpTexturesFromHeapCache()
	for k, cachedBlock in pairs(identifyMemoryCache.heapCache) do
		if cachedBlock.isTexture or cachedBlock.isFFATexture then
			dprint(toHexString(cachedBlock.block).." textureID: "..toHexString(cachedBlock.textureID).." size: "..toHexString(cachedBlock.size));
		end
	end
	print_deferred();
end

function randomizeTexturesFromHeapCache()
	for k, cachedBlock in pairs(identifyMemoryCache.heapCache) do
		if cachedBlock.isTexture or cachedBlock.isFFATexture then
			for i = cachedBlock.block, cachedBlock.block + cachedBlock.size - 1, 1 do
				mainmemory.writebyte(i, math.random(0, 255));
			end
			print("Randomized texture "..toHexString(cachedBlock.block));
		end
	end
end

function setTexturesFromHeapCache(value)
	for k, cachedBlock in pairs(identifyMemoryCache.heapCache) do
		if cachedBlock.isTexture or cachedBlock.isFFATexture then
			for i = cachedBlock.block, cachedBlock.block + cachedBlock.size - 1, 1 do
				mainmemory.writebyte(i, value);
			end
			print("Set texture "..toHexString(cachedBlock.block));
		end
	end
	for k, cachedBlock in pairs(identifyMemoryCache.textureCache) do
		for i = cachedBlock.block, cachedBlock.block + cachedBlock.size - 1, 1 do
			mainmemory.writebyte(i, value);
		end
		print("Set texture "..toHexString(cachedBlock.block));
	end
end

local textval = 0;
function bleh()
	identifyMemory(0x400000, false, false, true);
	setTexturesFromHeapCache(textval);
	textval = textval + 1;
	print(textval);
end

function identifyMemory(address, findReferences, reuseCache, suppressPrint)
	findReferences = findReferences or false;
	suppressPrint = suppressPrint or false;
	local addressInfo = {};

	if type(address) ~= "number" then
		table.insert(addressInfo, "Please enter a valid memory address");
	end
	if isPointer(address) then
		address = address - RDRAMBase;
	end
	if not isRDRAM(address) then
		table.insert(addressInfo, "Please enter a valid memory address");
	end
	local inExpansionPak = false;
	if address >= RDRAMSize / 2 then
		inExpansionPak = true;
	end
	local addressFound = false;
	local addressType = 0;
	local skipToAddress = nil;
	local address_4byte_align = address - address % 4;

	table.insert(addressInfo, "Valid address detected, checking "..toHexString(address, 6));
	if inExpansionPak then
		table.insert(addressInfo, "This address is in the expansion pak.");
	end

	-- Cache stuff
	if identifyMemoryCache == nil or not reuseCache then
		buildIdentifyMemoryCache();
	end

	-- Detect RAM Watch
	for i = 1, #Game.RAMWatch do
		local watch = Game.RAMWatch[i];
		if watch.data_type == "b" then
			if address == watch.address then
				addressFound = true;
				addressType = 6;
				table.insert(addressInfo, "This address is in the RAM watch: "..watch.name.." (1 byte)");
				break;
			end
		elseif watch.data_type == "w" then
			if address >= watch.address and address < watch.address + 2 then
				addressFound = true;
				addressType = 6;
				skipToAddress = watch.address + 2;
				table.insert(addressInfo, "This address is in the RAM watch: "..watch.name.." (2 bytes)");
				break;
			end
		elseif watch.data_type == "d" then
			if address >= watch.address and address < watch.address + 4 then
				addressFound = true;
				addressType = 6;
				skipToAddress = watch.address + 4;
				table.insert(addressInfo, "This address is in the RAM watch: "..watch.name.." (4 bytes)");
				break;
			end
		end
	end

	-- Detect OS Code
	if not addressFound then
		if Game.Memory.os_code_start ~= nil then
			if address >= Game.Memory.os_code_start and address < Game.Memory.os_code_start + Game.Memory.os_code_size then
				addressFound = true;
				addressType = 5;
				skipToAddress = Game.Memory.os_code_start + Game.Memory.os_code_size;
				table.insert(addressInfo, "This address is part of OS Code.");
			end
		end
	end

	-- Detect Game Code
	if not addressFound then
		if Game.Memory.game_code_start ~= nil then
			if address >= Game.Memory.game_code_start and address < Game.Memory.game_code_start + Game.Memory.game_code_size then
				addressFound = true;
				addressType = 5;
				skipToAddress = Game.Memory.game_code_start + Game.Memory.game_code_size;
				table.insert(addressInfo, "This address is part of Game Code.");
			end
		end
	end

	-- Detect Game Constants
	if not addressFound then
		if Game.Memory.game_constants_start ~= nil then
			if address >= Game.Memory.game_constants_start and address < Game.Memory.game_constants_start + Game.Memory.game_constants_size then
				addressFound = true;
				addressType = 6;
				skipToAddress = Game.Memory.game_constants_start + Game.Memory.game_constants_size;
				table.insert(addressInfo, "This address is part of the Game Constants file.");
			end
		end
	end

	-- Detect EEPROM copy
	if not addressFound and Game.version ~= 4 then -- TODO: Kiosk?
		if address >= Game.Memory.eeprom_copy_base and address < Game.Memory.eeprom_copy_base + 4 * eeprom_slot_size then
			addressFound = true;
			addressType = 8;
			skipToAddress = Game.Memory.eeprom_copy_base + 4 * eeprom_slot_size;
			local EEPROMOffset = address - Game.Memory.eeprom_copy_base;
			local EEPROMSlot = math.floor(EEPROMOffset / eeprom_slot_size);
			local EEPROMSlotOffset = EEPROMOffset % eeprom_slot_size;
			table.insert(addressInfo, "This address is part of the EEPROM copy.");
			table.insert(addressInfo, "EEPROM + "..toHexString(EEPROMOffset).." or Slot "..EEPROMSlot.." + "..toHexString(EEPROMSlotOffset));
		end
	end

	-- Detect framebuffers
	if not addressFound then
		for k, frameBuffer in pairs(identifyMemoryCache.frameBuffers) do
			if address >= frameBuffer.base and address < frameBuffer.base + frameBuffer.width * frameBuffer.height * (frameBuffer.bpp / 8) then
				addressFound = true;
				addressType = 2;
				skipToAddress = frameBuffer.base + frameBuffer.width * frameBuffer.height * (frameBuffer.bpp / 8);
				local fbOffset = address - frameBuffer.base;
				local xPixel = (fbOffset / (frameBuffer.bpp / 8)) % frameBuffer.width;
				local yPixel = math.floor(fbOffset / (frameBuffer.width * (frameBuffer.bpp / 8)));
				table.insert(addressInfo, "This address is in the first framebuffer! "..toHexString(frameBuffer.base).." + "..toHexString(fbOffset));
				table.insert(addressInfo, "Pixel Coords: X: "..xPixel..", Y:"..yPixel);
				break;
			end
		end
	end

	-- Detect heap
	if not addressFound then
		if address >= identifyMemoryCache.heapBase and address < identifyMemoryCache.heapEnd then
			local inHeapHeader = false;
			local inHeapBlock = false;
			local heapBlock = nil;

			for k, cachedBlock in pairs(identifyMemoryCache.heapCache) do
				if withinHeapBlock(address, cachedBlock.block, cachedBlock.size, true) then
					heapBlock = cachedBlock;
					skipToAddress = heapBlock.block + heapBlock.size;
					if address < cachedBlock.block then
						inHeapHeader = true;
						inHeapBlock = false;
					else
						inHeapHeader = false;
						inHeapBlock = true;
					end
					if cachedBlock.addressFound then
						addressFound = true;
						addressType = cachedBlock.addressType;
					end
					break;
				end
			end

			table.insert(addressInfo, "This address is on the heap!");
			if inHeapHeader then
				table.insert(addressInfo, "This address is in a heap header.");
			end
			if inHeapBlock then
				table.insert(addressInfo, "This address is in a heap block: "..toHexString(heapBlock.block, 6).." + "..toHexString(address - heapBlock.block));
			end
			if heapBlock.isFree then
				table.insert(addressInfo, "The heap block is considered free memory by the game.");
			end
			table.insert(addressInfo, "Heap Header: "..toHexString(heapBlock.header, 6));
			table.insert(addressInfo, "Heap Block: "..toHexString(heapBlock.block, 6));
			table.insert(addressInfo, "Block Size: "..toHexString(heapBlock.size));

			if findReferences then
				table.insert(addressInfo, "");
				table.insert(addressInfo, "Searching for references to this heap block:");
				local references = searchPointers(heapBlock.block + heapBlock.size + RDRAMBase, heapBlock.size, false, true);
				if #references > 0 then
					for i = 1, #references do
						table.insert(addressInfo, toHexString(references[i].Address).." -> "..toHexString(references[i].Value).." (Block + "..toHexString(references[i].Value - RDRAMBase - heapBlock.block)..")");
					end
					table.insert(addressInfo, #references.." references found.");
					if heapBlock.isFree then
						table.insert(addressInfo, "Hmm, there's references to free memory here, possible use after free exploit?");
					end
				end
			end

			if heapBlock.isActor then
				table.insert(addressInfo, "This address is part of the Actor: "..heapBlock.actorName.." at "..toHexString(heapBlock.block));
			end

			if heapBlock.isActorAnimationParamObject then
				table.insert(addressInfo, "This address is part of the AnimationParam object for the actor: "..heapBlock.actorName.." at "..toHexString(heapBlock.actor));
				if isRDRAM(heapBlock.boneArray1) and address >= heapBlock.boneArray1 and address < heapBlock.boneArray1 + heapBlock.boneArraySize then
					table.insert(addressInfo, "This address is part of the first BoneArray for the actor: "..heapBlock.actorName.." at "..toHexString(heapBlock.actor));
				end
				if isRDRAM(heapBlock.boneArray2) and address >= heapBlock.boneArray2 and address < heapBlock.boneArray2 + heapBlock.boneArraySize then
					table.insert(addressInfo, "This address is part of the second BoneArray for the actor: "..heapBlock.actorName.." at "..toHexString(heapBlock.actor));
				end
			end

			if heapBlock.isActorAnimation then
				table.insert(addressInfo, "This address is part of an Animation object for the actor: "..heapBlock.actorName.." at "..toHexString(heapBlock.actor));
			end

			if heapBlock.isActorSharedModelObject then
				table.insert(addressInfo, "This address is part of the SharedModel object for the actor: "..heapBlock.actorName.." at "..toHexString(heapBlock.actor));
			end

			if heapBlock.isActorCollision then
				table.insert(addressInfo, "This address is part of ActorCollision number "..heapBlock.collisionCount.." between: "..heapBlock.actorName.." at "..toHexString(heapBlock.actor).." and "..heapBlock.targetName.." at "..toHexString(heapBlock.target));
			end
			if heapBlock.isActorCollisionPosition then
				table.insert(addressInfo, "This address is part of the ActorCollisionPosition object for ActorCollision number "..heapBlock.collisionCount.." between: "..heapBlock.actorName.." at "..toHexString(heapBlock.actor).." and "..heapBlock.targetName.." at "..toHexString(heapBlock.target));
				table.insert(addressInfo, "Position: "..heapBlock.x..", "..heapBlock.y..", "..heapBlock.z);
			end

			-- Detect model 2
			if heapBlock.isObjectModel2Array then
				local objectBase = address - (address - heapBlock.block) % obj_model2_slot_size;
				table.insert(addressInfo, "Oh man! The address is in the object model 2 array!");
				table.insert(addressInfo, "Object Base: "..toHexString(objectBase));
				if address >= heapBlock.block and address < heapBlock.block + heapBlock.numSlots * obj_model2_slot_size then
					table.insert(addressInfo, "It's in a proper object too, not just free space.");
					table.insert(addressInfo, "Object Name: "..getScriptName(objectBase));
					-- TODO: Position?
				else
					table.insert(addressInfo, "It's in an empty array element though, hmm...");
				end
			end

			if heapBlock.isObjectModel2DisplayList then
				table.insert(addressInfo, "The address is in a DisplayList for the object: "..heapBlock.associatedModel2ObjectName.." at "..toHexString(heapBlock.associatedModel2Object));
				table.insert(addressInfo, "Offset: DisplayList + "..toHexString(address - heapBlock.block));
			end

			if heapBlock.isBehaviorScript then
				if heapBlock.topLevel then
					table.insert(addressInfo, "The address is in a BehaviorObject for the object: "..heapBlock.associatedModel2ObjectName.." at "..toHexString(heapBlock.associatedModel2Object));
					table.insert(addressInfo, "Offset: BehaviorObject + "..toHexString(address - heapBlock.block));
				else
					table.insert(addressInfo, "The address is in a BehaviorScript for the object: "..heapBlock.associatedModel2ObjectName.." at "..toHexString(heapBlock.associatedModel2Object));
					table.insert(addressInfo, "Offset: BehaviorScript + "..toHexString(address - heapBlock.block));
				end
			end

			-- Detect HUD
			if heapBlock.isHUDObject then
				table.insert(addressInfo, "This address is part of the HUD object!");
			end

			-- Detect enemies
			if heapBlock.isEnemyRespawnObject then
				table.insert(addressInfo, "This address is part of the enemy array object!");
				table.insert(addressInfo, "Run dumpEnemies() for more information.");
			end

			-- Detect map
			if heapBlock.isMap then
				table.insert(addressInfo, "This address is part of the map block!");
				table.insert(addressInfo, "Could be verts, displaylist etc.");
			end

			-- Detect chunks
			if heapBlock.isMapChunkArray then
				table.insert(addressInfo, "This address is part of the chunk array for the map!");
				table.insert(addressInfo, "Use the Object Analysis Tools for more information.");
			end

			if heapBlock.isMapChunkDLVertMappingArray then
				table.insert(addressInfo, "This address is part of the chunk:DL:vert mapping!");
				table.insert(addressInfo, "Run dumpDLBases() for more information.");
			end

			if heapBlock.isMapVertBlock then
				table.insert(addressInfo, "This address is part of a vert block for the DL at "..toHexString(heapBlock.DLPointer).."!");
				table.insert(addressInfo, "Run dumpDLBases() for more information.");
			end

			-- Detect weather particle array
			if heapBlock.isWeatherParticleArray then
				table.insert(addressInfo, "This address is part of the weather particle array!");
			end

			-- Detect dynamic water surfaces
			if heapBlock.isDynamicWaterSurface then
				local t1Str = heapBlock.timer1..", ";
				local t2Str = heapBlock.timer2..", ";
				local t3Str = heapBlock.timer3..", ";
				local t4Str = heapBlock.timer4;
				table.insert(addressInfo, "This address is part of a dynamic water surface!");
				table.insert(addressInfo, toHexString(heapBlock.block).." Timers: {"..t1Str..t2Str..t3Str..t4Str.."}");
			end

			-- Detect exits
			if heapBlock.isExitArray then
				table.insert(addressInfo, "This address is part of the exit array!");
				table.insert(addressInfo, "Use the Object Analysis Tools or run dumpExits() for more information.");
			end

			-- Detect loading zones
			if heapBlock.isLoadingZoneArray then
				table.insert(addressInfo, "This address is part of the loading zone array!");
				table.insert(addressInfo, "Use the Object Analysis Tools or run dumpLoadingZones() for more information.");
			end

			-- Detect setup
			if heapBlock.isMapSetup then
				table.insert(addressInfo, "This address is part of the map setup!");
				table.insert(addressInfo, "Run dumpSetup() for more information.");
			end

			-- Detect Model 2 Collision Object
			if heapBlock.isCollisionLinkedListObject then
				table.insert(addressInfo, "The address is in the object model 2 collision linked list pointer array!");
				local object = dereferencePointer(address);
				if isRDRAM(object) then
					table.insert(addressInfo, "The address you passed points to a collision linked list!");
					table.insert(addressInfo, "Iterating through and checking what's in that list:");
					local safety;
					local cachedCollision = identifyMemoryCache.model2CollisionCache[object];
					while type(cachedCollision) == "table" do
						table.insert(addressInfo, toHexString(object)..": "..cachedCollision.collisionType..", Kong: "..toHexString(cachedCollision.kong));
						safety = cachedCollision.next;
						if safety == object or safety == heapBlock.header then -- Prevent infinite loops
							break;
						end
						object = safety;
						cachedCollision = identifyMemoryCache.model2CollisionCache[object];
					end
				else
					table.insert(addressInfo, "The address you passed isn't a pointer to a collision linked list though...");
				end
			end

			if heapBlock.isModel2DLIndexObject then
				table.insert(addressInfo, "The address is in the object model 2 display list index object!");
			end
			if heapBlock.isModel2DLROMMapObject then
				table.insert(addressInfo, "The address is in the object model 2 display list ROM map object!");
			end

			-- Detect textures (heap)
			if heapBlock.isTextureIndexObject then
				table.insert(addressInfo, "This address is in the TextureIndexObject.");
			end
			if heapBlock.isFFATextureIndexObject then
				table.insert(addressInfo, "This address is in the FFATextureIndexObject.");
			end
			if heapBlock.isTextureROMMapObject then
				table.insert(addressInfo, "This address is in the TextureROMMapObject.");
			end
			if heapBlock.isFFATextureROMMapObject then
				table.insert(addressInfo, "This address is in the FFATextureROMMapObject.");
			end
			if heapBlock.isTexture or heapBlock.isFFATexture then
				if address < heapBlock.block then
					table.insert(addressInfo, "This address is in a heap header for texture ID "..heapBlock.textureID);
				else
					table.insert(addressInfo, "This address is in a texture: "..toHexString(heapBlock.block, 6).." + "..toHexString(address - heapBlock.block).." TextureID: "..heapBlock.textureID);
				end
			end

			--[[
			if not addressFound then
				dprint("Unknown Heap Block: "..toHexString(heapBlock.block, 6, "").." Size: "..toHexString(heapBlock.size));
			end
			--]]
		end
	end

	-- Detect ActorCollisions
	if not addressFound then
		for k, collision in pairs(identifyMemoryCache.actorCollisions) do
			if withinHeapBlock(address, collision.block, collision.size, true) then
				addressFound = true;
				addressType = 3;
				skipToAddress = collision.block + collision.size;
				if collision.isActorCollision then
					table.insert(addressInfo, "This address is part of ActorCollision number "..collision.collisionCount.." between: "..collision.actorName.." at "..toHexString(collision.actor).." and "..collision.targetName.." at "..toHexString(collision.target));
				elseif collision.isActorCollisionPosition then
					table.insert(addressInfo, "This address is part of the ActorCollisionPosition object for ActorCollision number "..collision.collisionCount.." between: "..collision.actorName.." at "..toHexString(collision.actor).." and "..collision.targetName.." at "..toHexString(collision.target));
					table.insert(addressInfo, "Position: "..collision.x..", "..collision.y..", "..collision.z);
				end
				break;
			end
		end
	end

	-- Detect model 2 collisions
	if not addressFound then
		for k, collision in pairs(identifyMemoryCache.model2CollisionCache) do
			if withinHeapBlock(address, collision.block, nil, true) then
				addressFound = true;
				addressType = 4;
				local kong = collision.kong;
				local collisionType = collision.collisionType;
				table.insert(addressInfo, "The address is part of an object model 2 collision!");
				table.insert(addressInfo, toHexString(collision.block)..": "..collision.collisionType..", Kong: "..toHexString(collision.kong));
				break;
			end
		end
	end

	-- Detect textures
	if not addressFound then
		for k, texture in pairs(identifyMemoryCache.textureCache) do
			if withinHeapBlock(address, texture.block, texture.size, true) then
				addressFound = true;
				addressType = 2;
				skipToAddress = texture.block + texture.size;
				if address < texture.block then
					table.insert(addressInfo, "This address is in a heap header for a texture block.");
				else
					table.insert(addressInfo, "This address is in a texture block: "..toHexString(texture.block, 6).." + "..toHexString(address - texture.block));
				end

				table.insert(addressInfo, "Header: "..toHexString(texture.header, 6));
				table.insert(addressInfo, "Block Size: "..toHexString(texture.size));

				if findReferences then
					table.insert(addressInfo, "");
					table.insert(addressInfo, "Searching for references to this texture block:");
					local references = searchPointers(texture.block + texture.size + RDRAMBase, texture.size, false, true);
					if #references > 0 then
						for i = 1, #references do
							table.insert(addressInfo, toHexString(references[i].Address).." -> "..toHexString(references[i].Value).." (Block + "..toHexString(references[i].Value - RDRAMBase - texture.block)..")");
						end
						table.insert(addressInfo, #references.." references found.");
					end
				end
				break;
			end
		end
	end

	-- Detect actor texture renderers
	if not addressFound then
		for k, textureRenderer in pairs(identifyMemoryCache.actorTextureRenderers) do
			if withinHeapBlock(address, textureRenderer.block, textureRenderer.size, true) then
				table.insert(addressInfo, "This address is part of a TextureRenderer for the actor: "..textureRenderer.actorName.." at "..toHexString(textureRenderer.actor));
				addressFound = true;
				addressType = 3;
				skipToAddress = textureRenderer.block + textureRenderer.size;
			end
		end
	end

	-- Detect actor pointer list
	if not addressFound then
		for object_no = 0, 255 do
			local pointerAddress = Game.Memory.actor_pointer_array + (object_no * 4);
			if address_4byte_align == pointerAddress then
				table.insert(addressInfo, "Pointer number "..object_no.." in the actor pointer list. Value is "..toHexString(pointerAddress, 8));
				addressFound = true;
				addressType = 3;
				local actor = dereferencePointer(pointerAddress);
				if isRDRAM(actor) then
					table.insert(addressInfo, "Points to "..getActorName(actor).." at "..toHexString(actor));
				end
				break;
			end
		end
	end

	if not addressFound then
		table.insert(addressInfo, "This address is currently unknown.");
	end
	if not suppressPrint then
		for i = 1, #addressInfo do
			dprint(addressInfo[i]);
		end
		print_deferred();
		return addressFound;
	end
	if type(skipToAddress) == "number" then
		return {addressType = addressType, skipToAddress = skipToAddress};
	else
		return addressType;
	end
end

function calculateKnownMemory(dumpBitmap)
	buildIdentifyMemoryCache();
	local output_file = nil;
	if dumpBitmap then
		output_file = io.open("./known_memory.bin", "wb");
	end
	local knownBytes = 0;
	local i = 0;
	while i < RDRAMSize do
		local result = identifyMemory(i, false, true, true);
		if type(result) == "number" then
			if dumpBitmap then
				if type(addressColors[result]) == "number" then
					result = addressColors[result];
				end
				output_file:write(string.char(result));
			end
			if result > 0 then
				knownBytes = knownBytes + 1;
			end
			if i % 0x1000 == 0 then
				print(toHexString(i).." known: "..toHexString(knownBytes));
			end
			i = i + 1;
		elseif type(result) == "table" then
			local diff = result.skipToAddress - i;
			i = result.skipToAddress;
			if result.addressType > 0 then
				knownBytes = knownBytes + diff;
			end
			if dumpBitmap then
				if type(addressColors[result.addressType]) == "number" then
					result.addressType = addressColors[result.addressType];
				end
				for j = 1, diff do
					output_file:write(string.char(result.addressType));
				end
			end
			--print(toHexString(i).." known: "..toHexString(knownBytes).." i: "..toHexString(i));
		end
	end
	if dumpBitmap then
		output_file:close();
	end
	print(formatOutputString("Bytes Known: ", knownBytes, RDRAMSize));
end

-- DK64 Heap Visualizer
-- Originally written by MrCheeze
-- Cleanups, Fixes, & Optimizations by Isotarge
UPDATE_EVERY_N_FRAMES = 1;

function Game.drawHeap()
	if emu.framecount() % UPDATE_EVERY_N_FRAMES == 0 or client.ispaused() then
		gui.DrawNew("native"); -- Coordinates are now based on screen pixels rather than game pixels, and stuff is not erased automatically each frame.

		local dynamic_memory_start = dereferencePointer(Game.Memory.heap_pointer);
		local dynamic_memory_end = Game.Memory.heap_end;
		local dynamic_memory_len = dynamic_memory_end - dynamic_memory_start;

		local addr = dynamic_memory_end;
		local screenwidth = client.screenwidth();

		gui.drawBox(0, 0, screenwidth, 50, 0x40000000, colors.green);

		local used_memory = 0;
		local free_memory = 0;
		local used_count = 0;
		local free_count = 0;

		local dump_block_list = ScriptHawk.UI.isChecked("Heap Visualizer Dump Blocks");
		local free_only = ScriptHawk.UI.isChecked("Heap Visualizer Free Only");

		local next_addr, blocksize, block_end, next_free, prev_free, in_use, bgcolor;

		while addr >= dynamic_memory_start and addr <= dynamic_memory_end do
			next_addr = mainmemory.read_u32_be(addr);
			blocksize = mainmemory.read_u32_be(addr + 0x04) + 0x10; -- Extra 0x10 bytes for the header
			block_end = addr + blocksize;
			next_free = mainmemory.read_u32_be(addr + 0x08);
			prev_free = mainmemory.read_u32_be(addr + 0x0C);
			in_use = next_free == 0 and prev_free == 0;

			if in_use then
				used_memory = used_memory + blocksize;
				used_count = used_count + 1;
				bgcolor = colors.green;
			else
				free_memory = free_memory + blocksize;
				free_count = free_count + 1;
				bgcolor = colors.red;
			end

			if (not free_only) or (free_only and not in_use) then
				gui.drawBox((addr - dynamic_memory_start) * screenwidth / dynamic_memory_len - 1, 0, (block_end - dynamic_memory_start) * screenwidth / dynamic_memory_len + 1, 50, 0x40000000, bgcolor);
			end

			if dump_block_list then
				dprint(string.format("addr:%X next_addr:%X  prev_free:%X next_free:%X  used:%s blocksize:%X", addr, next_addr, prev_free, next_free, tostring(in_use), blocksize - 0x10));
			end

			addr = next_addr - 0x80000000;
		end

		gui.drawText(24, 50, string.format("Used Memory: %X (%d blocks)", used_memory, used_count));
		gui.drawText(24, 65, string.format("Free Memory: %X (%d blocks)", free_memory, free_count));

		if dump_block_list then
			print_deferred();
		end
	end
end

return Game;