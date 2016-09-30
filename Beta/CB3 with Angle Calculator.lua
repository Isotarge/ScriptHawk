local HEADER = 0x60A90;
local pScale = 3000;
local vScale = 100000;

--Code by The8bitbeast

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

local function set_point_1()
    forms.settext(p1xbox,x)
    forms.settext(p1zbox,z)
    forms.settext(anglebox,"")
end
    
local function set_point_2()
	forms.settext(p2xbox,x)
    forms.settext(p2zbox,z)
    forms.settext(anglebox,"")
end
    
local function calculate_angle()
    local p1x = forms.gettext(p1xbox)
    local p1z = forms.gettext(p1zbox)
    local p2x = forms.gettext(p2xbox)
    local p2z = forms.gettext(p2zbox)
    local dx = p2x-p1x;
    local dz = p2z-p1z;
    
    angle = 180*(math.atan2(dx,dz))/math.pi;
    angle = (angle+360)%360
    
    --distance = math.sqrt(dx*dx+dz*dz)
    
    forms.settext(anglebox,angle)
    
    print('Point 1:', round(p1x,4), round(p1z,4))
    print('Point 2:', round(p2x,4), round(p2z,4))
    print('Angle:', angle)
    --print('Distance:', distance)
    print("")
end

local function clear_all()
    forms.settext(p1xbox,"")
    forms.settext(p1zbox,"")
    forms.settext(p2xbox,"")
    forms.settext(p2zbox,"")
    forms.settext(anglebox,"")
end

buttonX = 220

local formhandle = forms.newform(390, 190, "Crash 3 Angle Calculator");
local button_set_point_1 = forms.button(formhandle, "Use Current Coordinates", set_point_1, buttonX, 40, 150, 32);
local button_set_point_2 = forms.button(formhandle, "Use Current Coordinates", set_point_2, buttonX, 74, 150, 32);
local button_calculate_coordinates = forms.button(formhandle, "Calculate Angle", calculate_angle, buttonX, 108, 90, 32);
local button_clear = forms.button(formhandle,"Clear All",clear_all, buttonX+95, 108, 55, 32)
forms.label(formhandle, "Calculates the angle of the straight line betwen 2 points", 0, 0, 500, 15)    
forms.label(formhandle, "Point 1:", 0, 50, 50, 15)
forms.label(formhandle, "Point 2:", 0, 84, 50, 15)
forms.label(formhandle, "Angle:", 0, 118, 50, 15)
forms.label(formhandle, "x", 85, 20, 20, 15)
forms.label(formhandle, "z", 170, 20, 20, 15)
p1xbox = forms.textbox(formhandle, "", 80, 20, 1, 50, 45)
p1zbox = forms.textbox(formhandle, "", 80, 20, 1, 135, 45)
p2xbox = forms.textbox(formhandle, "", 80, 20, 1, 50, 79)
p2zbox = forms.textbox(formhandle, "", 80, 20, 1, 135, 79)
anglebox = forms.textbox(formhandle, "", 70, 20, 1, 50, 113)

--Existing script by pirohiko, ported by Isotarge

function drawOSD()
	local row = 0;
	local xOffset = 2;
	local yOffset = 70;
	local height = 16;

	local actor = mainmemory.read_u32_le(HEADER);
	if actor >= 0x80000000 and actor <= 0x80200000 then
		actor = actor - 0x80000000;
	else
		gui.text(xOffset, yOffset + row * height, "Crash not found...");
		return;
	end

	local X  = mainmemory.read_s32_le(actor + 0x60) / pScale;
	local Y  = mainmemory.read_s32_le(actor + 0x64) / pScale;
	local Z  = mainmemory.read_s32_le(actor + 0x68) / pScale;
	local XV = mainmemory.read_s32_le(actor + 0x84) / vScale;
	local YV = mainmemory.read_s32_le(actor + 0x88) / vScale;
	local ZV = mainmemory.read_s32_le(actor + 0x8C) / vScale;
	local V  = mainmemory.read_s32_le(actor + 0x104) / vScale;
	local XZ = math.sqrt(XV*XV + ZV*ZV);
	local D  = mainmemory.read_s32_le(actor + 0x94) / 4096*360;
	local J  = mainmemory.read_u32_le(actor + 0x1B5);
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

	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : X Vel", XV));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Y Vel", YV));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Z Vel", ZV));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : XZ Vel", XZ));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Velocity", V));
	row = row + 1;
	gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Jumps", J));
	row = row + 2;
    
 --Calculated moving angle by The8bitbeast
    
    if type(oldX) == "number" then
        
        local movingAngle2 = 180*(math.atan2(X-oldX,Z-oldZ))/math.pi;
        movingAngle2 = (movingAngle2+360)%360;
        
        if movingAngle2 ~= 0 then 
            movingAngle = movingAngle2
        elseif V==0 then
            movingAngle = 0
        end
        
        gui.text(xOffset, yOffset + row * height, string.format("%8.2f : Moving Angle", movingAngle));
	    row = row + 1;
    end
    
    oldX=X;
    oldZ=Z;
        
    x=X
    z=Z
end

event.onframestart(drawOSD);
--[[
function key_input()
	local t = joypad.getdown(1);
	local a = {xleft = 128, yleft = 128, xright = 128, yright = 128};
	if t.right == true then
		a.xleft = 255;
	elseif t.left == true then
		a.xleft = 0;
	end
	if t.down == true then
		a.yleft = 255;
	elseif t.up == true then
		a.yleft = 0;
	end
	joypad.set(1,t)
	joypad.setanalog(1,a)
	joypad.setanalog(2,{xleft=128,yleft=128,xright=128,yright=128})
	--   joypad.setanalog(1,{xleft=132,yleft=0})
end

--emu.registerbefore(key_input)
]]--