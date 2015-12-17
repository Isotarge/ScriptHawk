----------------------
-- Memory addresses --
----------------------

local p_meter = 0x106;
local max_p = 32;

local velocity_base = 0x110;
local max_velocity_base = 30735;
local velocity_ground = 0x112;

local x_position = 0x120;

-----------
-- State --
-----------

local currentFrame;
local previousFrame;

local currentP;
local previousP;

local currentVelocityBase;
local previousVelocityBase;

local currentVelocityGround;
local previousVelocityGround;

local currentXPosition;
local previousXPosition;

--------------------
-- The main event --
--------------------

local function output(msg)
	print("Frame "..currentFrame..": "..msg);
end

local function checkForMovementErrors()
	currentFrame = emu.framecount();
	currentP = mainmemory.readbyte(p_meter);
	currentVelocityBase = mainmemory.read_s16_le(velocity_base);
	currentVelocityGround = mainmemory.read_s8(velocity_ground);
	currentXPosition = mainmemory.read_u16_le(x_position);

	if currentFrame == previousFrame or 0 + 1 then
		if currentP == max_p and previousP == max_p then
			output("2 frames with P meter at "..max_p..", consider spinning earlier.");
		end

		if currentVelocityGround == 4 then
			output("4 ground velocity, consider spinning.")
		end

		if currentVelocityBase == max_velocity_base and (currentVelocityGround == 2 or currentVelocityGround == 5) then
			output("Suboptimal jump detected, consider jumping earlier or longer.");
		end
	end

	previousFrame = currentFrame;
	previousP = currentP;
	previousVelocityBase = currentVelocityBase;
	previousVelocityGround = currentVelocityGround;
	previousXPosition = currentXPosition;
end

event.onframestart(checkForMovementErrors, "Check for movement errors");