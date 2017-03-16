-- Original script by pirohiko, http://tasvideos.org/forum/viewtopic.php?p=315430#315430
-- Ported to BizHawk and ScriptHawk API by Isotarge
-- Angle calculator and calculated movement angle code by The8bitbeast

Game = {};

local HEADER = 0x60A90;
local pScale = 3000;
local vScale = 100000;

local oldX = nil;
local oldZ = nil;
local movingAngle = 0;

function round(num, idp)
	local mult = 10 ^ (idp or 0);
	return math.floor(num * mult + 0.5) / mult;
end

function angleBetweenPoints(x1, y1, x2, y2)
	local angle = 180 * (math.atan2(x2 - x1, y2 - y1)) / math.pi;
	return (angle + 360) % 360;
end

RAMBase = 0x80000000;
RAMSize = 0x200000;

function isPointer(addr)
	if type(addr) ~= "number" then
		return false;
	end
	return addr >= RAMBase and addr < RAMBase + RAMSize;
end

function isRAM(addr)
	if type(addr) ~= "number" then
		return false;
	end
	return addr >= 0 and addr < RAMSize;
end

function dereferencePointer(addr)
	if isRAM(addr) then
		addr = mainmemory.read_u32_le(addr);
		if isPointer(addr) then
			return addr - RAMBase;
		end
	end
end

function Game.getPlayerActor()
	return dereferencePointer(HEADER);
end

function Game.getXPosition()
	local player = Game.getPlayerActor();
	if player ~= nil then
		return mainmemory.read_s32_le(player + 0x60) / pScale;
	end
	return 0;
end

function Game.getYPosition()
	local player = Game.getPlayerActor();
	if player ~= nil then
		return mainmemory.read_s32_le(player + 0x64) / pScale;
	end
	return 0;
end

function Game.getZPosition()
	local player = Game.getPlayerActor();
	if player ~= nil then
		return mainmemory.read_s32_le(player + 0x68) / pScale;
	end
	return 0;
end

function Game.getXVelocity()
	local player = Game.getPlayerActor();
	if player ~= nil then
		return mainmemory.read_s32_le(player + 0x84) / vScale;
	end
	return 0;
end

function Game.getYVelocity()
	local player = Game.getPlayerActor();
	if player ~= nil then
		return mainmemory.read_s32_le(player + 0x88) / vScale;
	end
	return 0;
end

function Game.getZVelocity()
	local player = Game.getPlayerActor();
	if player ~= nil then
		return mainmemory.read_s32_le(player + 0x8C) / vScale;
	end
	return 0;
end

function Game.getXZVelocity()
	local XV = Game.getXVelocity();
	local ZV = Game.getZVelocity();
	return math.sqrt(XV*XV + ZV*ZV);
end

function Game.getVelocity()
	local player = Game.getPlayerActor();
	if player ~= nil then
		return mainmemory.read_s32_le(player + 0x104) / vScale;
	end
	return 0;
end

local function drawOSD()
	local row = 0;
	local xOffset = 2;
	local yOffset = 70;
	local height = 16;

	local actor = Game.getPlayerActor();
	if not isRAM(actor) then
		gui.text(xOffset, yOffset + row * height, "Crash not found...");
		return;
	end

	local X = Game.getXPosition();
	local Y = Game.getYPosition();
	local Z = Game.getZPosition();
	local D = mainmemory.read_s32_le(actor + 0x94) / 4096 * 360;
	local J = mainmemory.read_u32_le(actor + 0x1B5);
	local BOXi = mainmemory.read_u32_le(0x6CC69);
	local BOXs = mainmemory.read_u32_le(0x6CDC1);
	local Level = mainmemory.read_u32_le(0x618DC);

	gui.text(xOffset, yOffset + row * height, string.format("%8X : Crash Pointer", actor));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8d : Level", Level));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%4d/%3d : Box", BOXi, BOXs));
	row = row + 2;

	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : X Pos", X));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Y Pos", Y));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Z Pos", Z));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Facing", D));
	row = row + 2;

	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : X Vel", Game.getXVelocity()));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Y Vel", Game.getYVelocity()));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Z Vel", Game.getZVelocity()));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : XZ Vel", Game.getXZVelocity()));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Velocity", Game.getVelocity()));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Jumps", J));
	row = row + 2;

	if type(oldX) == "number" then
		if Game.getVelocity() == 0 then
			movingAngle = 0;
		else
			local possibleMovingAngle = angleBetweenPoints(oldX, oldZ, X, Z);
			if possibleMovingAngle ~= 0 then
				movingAngle = possibleMovingAngle;
			end
		end

		gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Moving Angle", movingAngle));
		row = row + 1;
	end

	oldX = X;
	oldZ = Z;
end

event.onframestart(drawOSD);

local function loadclear()
	oldX = nil;
	oldZ = nil;
end
event.onloadstate(loadclear);

angleCalc = {
	buttonX = 220,
	visible = false,
	form = nil,
	p1xbox = nil,
	p1zbox = nil,
	p2xbox = nil,
	p2zbox = nil,
	anglebox = nil,
};

angleCalc.setPoint1 = function()
	forms.settext(angleCalc.p1xbox, Game.getXPosition())
	forms.settext(angleCalc.p1zbox, Game.getZPosition())
	forms.settext(angleCalc.anglebox, "");
end

angleCalc.setPoint2 = function()
	forms.settext(angleCalc.p2xbox, Game.getXPosition());
	forms.settext(angleCalc.p2zbox, Game.getZPosition());
	forms.settext(angleCalc.anglebox, "");
end

angleCalc.calculateAngle = function()
	local p1x = forms.gettext(angleCalc.p1xbox);
	local p1z = forms.gettext(angleCalc.p1zbox);
	local p2x = forms.gettext(angleCalc.p2xbox);
	local p2z = forms.gettext(angleCalc.p2zbox);

	local angle = angleBetweenPoints(p1x, p1z, p2x, p2z);

	forms.settext(angleCalc.anglebox, angle);

	print('Point 1: '..round(p1x, 4)..", "..round(p1z, 4));
	print('Point 2: '..round(p2x, 4)..", "..round(p2z, 4));
	print('Angle: '..angle);
	print("");
end

angleCalc.clearAll = function()
	forms.settext(angleCalc.p1xbox, "");
	forms.settext(angleCalc.p1zbox, "");
	forms.settext(angleCalc.p2xbox, "");
	forms.settext(angleCalc.p2zbox, "");
	forms.settext(angleCalc.anglebox, "");
end

angleCalc.close = function()
	angleCalc.visible = false;
end

angleCalc.open = function()
	if not angleCalc.visible then
		angleCalc.visible = true;
		angleCalc.form = forms.newform(390, 190, "Angle Calculator", angleCalc.close);

		-- Buttons
		forms.button(angleCalc.form, "Use Current Coordinates", angleCalc.setPoint1, angleCalc.buttonX, 40, 150, 32);
		forms.button(angleCalc.form, "Use Current Coordinates", angleCalc.setPoint2, angleCalc.buttonX, 74, 150, 32);
		forms.button(angleCalc.form, "Calculate Angle", angleCalc.calculateAngle, angleCalc.buttonX, 108, 90, 32);
		forms.button(angleCalc.form, "Clear All", angleCalc.clearAll, angleCalc.buttonX + 95, 108, 55, 32);
		forms.label(angleCalc.form, "Calculates the angle of the straight line betwen 2 points", 0, 0, 500, 15);

		-- Labels
		forms.label(angleCalc.form, "Point 1:", 0, 50, 50, 15);
		forms.label(angleCalc.form, "Point 2:", 0, 84, 50, 15);
		forms.label(angleCalc.form, "Angle:", 0, 118, 50, 15);
		forms.label(angleCalc.form, "x", 85, 20, 20, 15);
		forms.label(angleCalc.form, "z", 170, 20, 20, 15);

		-- Textboxes
		angleCalc.p1xbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 50, 45);
		angleCalc.p1zbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 135, 45);
		angleCalc.p2xbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 50, 79);
		angleCalc.p2zbox = forms.textbox(angleCalc.form, "", 80, 20, 1, 135, 79);
		angleCalc.anglebox = forms.textbox(angleCalc.form, "", 70, 20, 1, 50, 113);
	else
		--print("Please close the angle calculator before opening another one.");
	end
end
angleCalc.open();