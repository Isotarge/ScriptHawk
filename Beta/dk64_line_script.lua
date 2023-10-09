---------------------
------- DK64 --------
---- LINE SCRTPT ----
-- MADE BY BALLAAM --
------ MORNIN' ------
---------------------

--[[
    USAGE GUIDELINES:

    - line.setHere() to set the target position to the kong's current position
    - line.set(x, z) to set the target position to a specific x & z co-ordinate
    - line.disable() to disable the autocalculation the next stick input
    - line.enable() to re-enable the autocalculation

    - Default stuff:
        - By default, the game uses a series of angle calculations/trig to determine the stick angle.
        - This doesn't do any iterative corrections. The angle provided is usually the best one, however there are situations where it can be a couple stick units off
        - To enable iterative correction, enter `line.iterative_correction` to true. It's worth noting that this has proven to be slightly worse, probably something that I need to hash out
        - Since the game has many forms of correct movement that's very context dependent, this doesn't alter button presses. Duties of button pressing are down to the TASer

    - Other settings:
        - line.use_cam_to_focus: This changes the calcuation to use the angle from the camera position to it's focal point rather than input angle. This ends up producing a suboptimal line
        - line.use_radian_calc: Input angle is also stored as radians in the camera object. This is slightly more precise and might save a couple frames here and there
        - line.camera_turn_correction: Corrects the cam-to-focus angle with a little formula to try and emulate the next frame's camera turn.
        - line.debug_print: prints a bunch of information useful for debugging
]]--

line = {
    -- Base args
    targ_x = 0,
    targ_z = 0,
    enabled = false,
    initialize = true,
    frame = 0,
    closeness = 0,
    targ_deg = 0,
    prev_is_lt = false,
    prev_is_gt = false,
    current_x = 0,
    current_y = 0,
    calculated_x = 0,
    calculated_y = 0,
    check_threshold = 60,
    checked = 0,
    previous_delta = 0,
    diverge_counter = 0,
    diverge_threshold = 5,
    previous_angle = 0,
    sameness_counter = 0,
    sameness_threshold = 5,
    forcing_inputs = false,
    debug_print = true,
    -- Defs
    player_pointer = 0x7FBB4C,
    change_pointer = 0x7FC924,
    stick_mag = 80,
    max = 10000000,
    -- Settings
    camera_turn_correction = false,
    savestate = "line-correction",
    iterative_correction = false,
    use_cam_to_focus = false,
    radian_angle_calc = true,
}

function line.set(x, z)
    line.targ_x = x;
    line.targ_z = z;
    line.enabled = true;
    line.initialize = true;
    if type(setTarget) == "function" then -- Usage with ScriptHawk, update readout
        setTarget(x, z)
    end
    print("Set target to "..x..", "..z)
end

function line.disable()
    print("Line function disabled on frame "..emu.framecount())
    joypad.setanalog({["X Axis"] = false, ["Y Axis"] = false}, 1);
    line.enabled = false;
end
    
function line.enable()
    print("Line function re-enabled on frame "..emu.framecount())
    line.enabled = true;
    line.get_angles();
end

-------------------------
-- SHORTHAND FUNCTIONS --
-------------------------

function line.d() line.disable() end
function line.e() line.enable() end
function line.s(a, b) line.set(a, b) end
function line.h() line.setHere() end

-------------------------

function line.angle_calculator(x1, z1, x2, z2)
    local dx = x2 - x1;
    local dz = z2 - z1;
    if dx == 0 then
        if dz == 0 then
            return 0;
        end
    end
    local angle = (630 - ((math.atan2(dz,dx) * (180 / math.pi)) + 180)) % 360;
    local angle_roundedToUnits = (math.floor((angle * (4096/360)) + 0.5) % 4096) * (360/4096);
    return angle_roundedToUnits;
end

function line.readObjOffset(obj_pointer, offset, is_float)
    local ptr = mainmemory.read_u32_be(obj_pointer)
    if (ptr >= 0x80000000) then
        if (ptr < 0x80800000) then
            local obj = ptr - 0x80000000
            if is_float then
                return mainmemory.readfloat(obj + offset, true)
            else
                return mainmemory.read_u32_be(obj + offset)
            end
        end
    end
    return 0
end

function line.getMovingAngle()
    local ptr = mainmemory.read_u32_be(line.player_pointer)
    if (ptr >= 0x80000000) then
        if (ptr < 0x80800000) then
            local obj = ptr - 0x80000000
            return line.dk64u_to_deg(mainmemory.read_u16_be(obj + 0xEE))
        end
    end
    return 0
end

function line.getInputAngle()
    if line.radian_angle_calc then
        local cam_ptr = line.readObjOffset(line.player_pointer, 0x284, false)
        if cam_ptr ~= 0 then
            local cam_paad = mainmemory.read_u32_be((cam_ptr - 0x80000000) + 0x174)
            if cam_paad ~= 0 then
                cam_paad = cam_paad - 0x80000000
                local angle = mainmemory.readfloat(cam_paad + 0xA8, true)
                angle = angle / (2 * math.pi)
                angle = angle * 360
                return (angle + 180) % 360
            end
        end
    else
        local ptr = mainmemory.read_u32_be(line.change_pointer)
        if (ptr >= 0x80000000) then
            if (ptr < 0x80800000) then
                local obj = ptr - 0x80000000
                local units = mainmemory.read_u16_be(obj + 0x2C8)
                return (line.dk64u_to_deg(units) + 180) % 360
            end
        end
    end
    return 0
end

function line.readPlayerFloatOffset(offset)
    return line.readObjOffset(line.player_pointer, offset, true)
end

function line.readChangeFloatOffset(offset)
    return line.readObjOffset(line.change_pointer, offset, true)
end

function line.getPlayerX()
    return line.readPlayerFloatOffset(0x7C)
end

function line.getPlayerZ()
    return line.readPlayerFloatOffset(0x84)
end

function line.setHere()
    line.set(line.getPlayerX(), line.getPlayerZ())
end

function line.deg_to_radians(deg)
    return (deg / 180) * math.pi
end

function line.dk64u_to_deg(units)
    return ((units / 4096) * 360) % 360
end

function line.setStick(x, y)
    joypad.setanalog({["X Axis"] = x, ["Y Axis"] = y}, 1);
end

function line.reloadState()
    savestate.load(line.savestate)
    rerec = movie.getrerecordcount()
    movie.setrerecordcount(rerec + 1)
    line.checked = line.checked + 1
end

function line.printDebugInfo(str)
    if line.debug_print then
        print(str)
    end
end

function line.getNextStick(x, y, move_clockwise, return_x)
    local projected_x = x
    local projected_y = y
    local is_corner = false
    -- Check corner cases
    if x == 80 then -- r
        if y == 80 then -- tr
            is_corner = true
            if move_clockwise then
                projected_y = projected_y - 1
            else
                projected_x = projected_x - 1
            end
        elseif y == -80 then -- br
            is_corner = true
            if move_clockwise then
                projected_x = projected_x - 1
            else
                projected_y = projected_y + 1
            end
        end
    elseif x == -80 then -- l
        if y == 80 then -- tl
            is_corner = true
            if move_clockwise then
                projected_x = projected_x + 1
            else
                projected_y = projected_y - 1
            end
        elseif y == -80 then -- bl
            is_corner = true
            if move_clockwise then
                projected_y = projected_y + 1
            else
                projected_x = projected_x + 1
            end
        end
    end
    -- Check generic cases
    if is_corner == false then
        if math.abs(x) < line.stick_mag then
            -- top or bottom
            if y > 0 then
                -- top
                if move_clockwise then
                    projected_x = projected_x + 1
                else
                    projected_x = projected_x - 1
                end
            else
                -- bottom
                if move_clockwise then
                    projected_x = projected_x - 1
                else
                    projected_x = projected_x + 1
                end
            end
        else
            -- left or right
            if x < 0 then
                -- left
                if move_clockwise then
                    projected_y = projected_y + 1
                else
                    projected_y = projected_y - 1
                end
            else
                -- right
                if move_clockwise then
                    projected_y = projected_y - 1
                else
                    projected_y = projected_y + 1
                end
            end
        end
    end
    if return_x then
        return projected_x
    else
        return projected_y
    end
end

function line.angleCompare(a, b)
    -- Returns true if angle a > angle b
    if math.abs(a - b) > 180 then
        -- Optimal comparison goes through 0
        a = (a + 180) % 360
        b = (b + 180) % 360
    end
    return a > b
end

function line.forceCalculated()
    line.forcing_inputs = true
    line.reloadState()
    line.setStick(line.calculated_x, line.calculated_y)
end

function line.get_angles()
    if line.enabled == false then
        return
    end
    if line.iterative_correction == false then
        line.initialize = true
    end
    if emu.islagged() then
        return
    end
    if line.initialize then
        if line.iterative_correction then
            line.frame = emu.framecount()
            line.closeness = line.max
            line.prev_is_lt = false
            line.prev_is_gt = false
            savestate.save(line.savestate)
            line.checked = 0
            line.previous_delta = line.max
            line.diverge_counter = 0
            line.sameness_counter = 0
            line.forcing_inputs = false
        end
        -- get player -> target
        local px = line.getPlayerX()
        local pz = line.getPlayerZ()
        local player_to_targ = line.angle_calculator(px, pz, line.targ_x, line.targ_z)
        line.targ_deg = player_to_targ

        -- calculate camera position
        local cx = line.readChangeFloatOffset(0x210)
        local cz = line.readChangeFloatOffset(0x218)
        
        -- Calculate focus
        local fx = line.readChangeFloatOffset(0x228) -- raw x focus
        local fz = line.readChangeFloatOffset(0x230) -- raw z focus
        if line.camera_turn_correction then
            local cam_ptr = line.readObjOffset(line.player_pointer, 0x284, false)
            if cam_ptr ~= 0 then
                local cam_paad = mainmemory.read_u32_be((cam_ptr - 0x80000000) + 0x174)
                if cam_paad ~= 0 then
                    cam_paad = cam_paad - 0x80000000
                    local ftargx = line.readObjOffset(cam_paad, 0x78, true)
                    local ftargz = line.readObjOffset(cam_paad, 0x80, true)
                    fx = fx + ((ftargx - fx) * 0.03)
                    fz = fz + ((ftargz - fz) * 0.03)
                end
            end
        end

        -- Get input angle
        local input_angle = line.getInputAngle()
        local cam_to_focus = line.angle_calculator(cx, cz, fx, fz)

        -- Calculate Angles
        local angle_diff = input_angle - player_to_targ
        if line.use_cam_to_focus then
            angle_diff = cam_to_focus - player_to_targ
        end
        local angle_diff_radians = line.deg_to_radians(angle_diff)

        -- Convert angle to x and y coordinates,
        local stick_x_raw = line.stick_mag * math.sin(angle_diff_radians)
        local stick_y_raw = line.stick_mag * math.cos(angle_diff_radians)
        local x_ratio = line.max
        local y_ratio = line.max
        if stick_x_raw ~= 0 then
            x_ratio = line.stick_mag / math.abs(stick_x_raw)
        end
        if stick_y_raw ~= 0 then
            y_ratio = line.stick_mag / math.abs(stick_y_raw)
        end
        local scale_up = math.min(x_ratio, y_ratio)
        local stick_x_scaled = stick_x_raw * scale_up
        local stick_y_scaled = stick_y_raw * scale_up
        --print(stick_x_scaled.." | "..stick_y_scaled)
        local stick_x = math.floor(stick_x_scaled + 0.5)
        local stick_y = math.floor(stick_y_scaled + 0.5)

        -- Resolve deadzone issues +/- 1 on either x or y axis results in the game interpretting it as 0
        if math.abs(stick_x) == 1 then
            local new_x = 0
            if math.abs(stick_x_scaled) >= 1 then
                new_x = -2
                if stick_x == 1 then
                    new_x = 2
                end
            end
            stick_x = new_x
        end
        if math.abs(stick_y) == 1 then
            local new_y = 0
            if math.abs(stick_y_scaled) >= 1 then
                new_y = -2
                if stick_y == 1 then
                    new_y = 2
                end
            end
            stick_y = new_y
        end
        line.setStick(stick_x, stick_y)
        if (line.iterative_correction) then
            line.current_x = stick_x
            line.current_y = stick_y
            line.calculated_x = stick_x
            line.calculated_y = stick_y
        end
        line.initialize = false
    end
    if line.iterative_correction then
        if emu.framecount() > line.frame then
            if emu.islagged() == false then
                if line.forcing_inputs then
                    line.initialize = true
                    line.forcing_inputs = false
                    return
                end
                local delta = line.getMovingAngle() - line.targ_deg
                delta = (delta + 180) % 360 - 180
                delta = math.abs(delta)
                if line.checked > line.check_threshold then
                    line.forceCalculated()
                    line.printDebugInfo("Checked "..line.check_threshold.." times")
                    line.printDebugInfo("")
                    return
                end
                if delta > line.previous_delta then
                    line.diverge_counter = line.diverge_counter + 1
                    if line.diverge_counter > line.diverge_threshold then
                        line.forceCalculated()
                        line.printDebugInfo("Diverging")
                        line.printDebugInfo("")
                        return
                    end
                else
                    line.diverge_counter = 0
                end
                line.previous_delta = delta
                if line.getMovingAngle() == line.previous_angle then
                    line.sameness_counter = line.sameness_counter + 1
                    if line.sameness_counter > line.sameness_threshold then
                        line.forceCalculated()
                        line.printDebugInfo("No change occurring")
                        line.printDebugInfo("")
                        return
                    end
                else
                    line.sameness_counter = 0
                end
                line.previous_angle = line.getMovingAngle()
                line.printDebugInfo("X: "..line.current_x.." Y: "..line.current_y.." Angle: "..line.getMovingAngle().." Target: "..line.targ_deg.." ("..line.checked..")")
                if delta == 0 then
                    -- Exact match found
                    line.initialize = true
                    line.printDebugInfo("Exact match found "..line.checked.." checks")
                    line.printDebugInfo("")
                else
                    --[[
                        Procedure:
                            - Check whether it's greater or less than
                            - Check if previous advice is in opposite direction, if so, pick closest
                            - Set GT/LT variables
                            - Shift stick by 1 unit in correct direction
                    ]]--
                    if line.angleCompare(line.getMovingAngle(), line.targ_deg) then
                        -- Move stick clockwise
                        if line.prev_is_lt then
                            if delta >= line.closeness then -- This one is further
                                line.current_x = line.getNextStick(line.current_x, line.current_y, false, true)
                                line.current_y = line.getNextStick(line.current_x, line.current_y, false, false)
                            end
                            line.printDebugInfo("Found convergence after "..line.checked.." checks")
                            line.printDebugInfo("")
                            line.initialize = true
                        else
                            line.current_x = line.getNextStick(line.current_x, line.current_y, true, true)
                            line.current_y = line.getNextStick(line.current_x, line.current_y, true, false)
                        end
                    else
                        -- Move stick anti-clockwise
                        if line.prev_is_gt then
                            if delta >= line.closeness then -- This one is further
                                line.current_x = line.getNextStick(line.current_x, line.current_y, true, true)
                                line.current_y = line.getNextStick(line.current_x, line.current_y, true, false)
                            end
                            line.printDebugInfo("Found convergence after "..line.checked.." checks")
                            line.printDebugInfo("")
                            line.initialize = true
                        else
                            line.current_x = line.getNextStick(line.current_x, line.current_y, false, true)
                            line.current_y = line.getNextStick(line.current_x, line.current_y, false, false)
                        end
                    end

                    line.prev_is_gt = line.angleCompare(line.getMovingAngle(), line.targ_deg)
                    line.prev_is_lt = line.angleCompare(line.getMovingAngle(), line.targ_deg) == false

                    if delta < line.closeness then
                        line.closeness = delta
                    end
                    line.setStick(line.current_x, line.current_y)
                end
                if line.initialize == false then
                    line.reloadState()
                end
            end
        end
    end
end

event.onframestart(line.get_angles, "")
event.onloadstate(line.get_angles, "")