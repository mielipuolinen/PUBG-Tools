-- ABSOLUTELY NO WARRANTY - YOU WILL RISK A GAME BAN FOR YOURSELF BY USING THIS - USE AT YOUR OWN RISK
-- Even then, PLEASE use it ONLY in the Training mode for learning and researching purposes.

-- Tuned ONLY for the following setup:
-- Beryl, Full Auto, standing and breathing
-- Red Dot, Compensator, Vertical Foregrip, Quickdraw Mag

-- Tested with Logitech G Hub app & Logitech G Pro Superlight mouse (600dpi)
-- Different mouse sensitivy configurations require different mouseSensitivity values

mouseBind_activation = 4 -- 4: thumb near
mouseBind_changeFireMode = 5 -- 5: thumb far
mouseBind_changeScope = 3 -- 3: MMB
mouseBind_changeStance = 6 -- 6: ???
mouseBind_fireInGame = 1 -- 1: LMB

mouseSensitivity = 50 -- [1..n], adjust this factor for the script to work with your sensitivity settings

weapon = "Beryl" -- Beryl/Mini
fireMode = "auto" -- auto/single/burst
scope = 1 -- 1/1.31/2/3/4/4.21/6/8/15 (1.31: 1x hold breath, 4.21: ACOG)
stance = "stand" -- stand/crouch/prone

function SetDefaults()
    ClearLog()

    -- magSize: [pcs], shots to fire
    -- timePerShot: [ms], rate of fire
    -- moveY: [%], vertical movement compensation per shot
    -- moveY_increasePerShot: [%], compensation increase per shot

    if weapon == "Beryl" and fireMode == "auto" then
        magSize = 30
        timePerShot = 86 -- accurate: 85.71
        moveY = 1.9
        moveY_increasePerShot = 0.021
    elseif weapon == "Beryl" and fireMode == "single" then
        magSize = 30
        timePerShot = 110
        moveY = 1.75
        moveY_increasePerShot = 0.0
    elseif weapon == "Beryl" and fireMode == "burst" then
        magSize = 30
        timePerShot = 86
        moveY = 1.75
        moveY_increasePerShot = 0.0
    end

    scopeFactor = changeScope()
    stanceFactor = changeStance()
    moveY = Rounding( moveY * mouseSensitivity * scopeFactor * stanceFactor )
    moveY_increasePerShot = Rounding( moveY * moveY_increasePerShot )
    mouseTimer_offset = Rounding( timePerShot / 2  )
end


function Rounding(value) -- because LUA doesn't have rounding implemented
    value_floor = math.floor(value)
    value_ceil = math.ceil(value)
    if value_floor < (value - 0.5) then
        return value_ceil
    else
        return value_floor
    end
end


function changeScope()
    -- default ADS FOV is 72
    -- eg. 1x Red Dot is 72 FOV and holding breath decreases FOV to 55
    -- 72/55 = 1,309.. => 72/1,31 = 54,96..
    return Rounding( 72 / scope )
end


function ChangeStance()
    if stance == "stand" then
        return 1
    elseif stance == "crouch" then
        return 0.5
    elseif stance == "prone" then
        return 0.25
    end
end


function OnEvent(event, arg)
    if (event == "MOUSE_BUTTON_PRESSED" and arg == mouseBind_activation) then
        SetDefaults()
        if fireMode == "auto" then
            AutoFire()
        elseif fireMode == "single" then
            SingleFire()
        elseif fireMode == "burst" then
            BurstFire()
        end

    elseif (event == "MOUSE_BUTTON_PRESSED" and arg == mouseBind_changeFireMode) then
        if fireMode == "auto" then
            fireMode = "single"
        elseif fireMode == "single" then
            fireMode = "burst"
        elseif fireMode == "burst" then
            fireMode = "auto"
        end

        OutputLogMessage("\nSwitching Fire Mode to: " .. fireMode .. "\n")

    elseif (event == "MOUSE_BUTTON_PRESSED" and arg == mouseBind_changeScope) then
        if scope == 1 then
            scope = 1.31
        elseif scope == 1.31 then
            scope = 2
        elseif scope == 2 then
            scope = 3
        elseif scope == 3 then
            scope = 4
        elseif scope == 4 then
            scope = 4.21
        elseif scope == 4.21 then
            scope = 6
        elseif scope == 6 then
            scope = 8
        elseif scope == 8 then
            scope = 15
        elseif scope == 15 then
            scope = 1
        end

        OutputLogMessage("\nChanging Scope to: " .. scope .. "\n")

    elseif (event == "MOUSE_BUTTON_PRESSED" and arg == mouseBind_changeStance) then
        if stance == "stand" then
            stance = "crouch"
        elseif stance == "crouch" then
            stance = "prone"
        elseif stance == "prone" then
            stance = "stand"
        end

        OutputLogMessage("\nSwitching Stance to: " .. stance .. "\n")
    end
end


function AutoFire()

    OutputLogMessage("AutoFire():\n")
    OutputLogMessage("magSize: " .. magSize .. " pcs, timePerShot: " .. timePerShot)
    OutputLogMessage(" ms, mouseTimer_offset: " .. mouseTimer_offset)
    OutputLogMessage(" ms, moveY: " .. moveY .. " px, moveY_increasePerShot: " .. moveY_increasePerShot)
    OutputLogMessage(" px, fireMode: " .. fireMode .. "\n\n")

    PressMouseButton(mouseBind_fireInGame)
    sprayTimer_start = GetRunningTime()
    shotCounter = 1

    repeat

        sprayTimer = GetRunningTime() - sprayTimer_start
        mouseTimer = (shotCounter * timePerShot) - mouseTimer_offset

        if sprayTimer >= mouseTimer then

            actualTimer_f = math.floor(shotCounter * 85.71 - 85.71)
            actualTimer_c = math.ceil(shotCounter * 85.71 - 85.71)
            OutputLogMessage(shotCounter .. "/" .. magSize)
            OutputLogMessage("\t moveY: " .. moveY .. " px\t\t mouseTimer: " .. mouseTimer .. " ms")
            OutputLogMessage("\t\t actual shot: " .. actualTimer_f .. " - " .. actualTimer_c .. " ms\n")
            OutputLogMessage("\t sprayTimer: " .. sprayTimer .. " ms\t sprayTimer_start: " .. sprayTimer_start .. " ms\n")

            MoveMouseRelative(0,moveY)

            moveY = moveY + moveY_increasePerShot
            shotCounter = shotCounter + 1

        end

        Sleep(1)

    until shotCounter == magSize + 1 -- +1 includes last shot

    ReleaseMouseButton(mouseBind_fireInGame)

end


function SingleFire()

    OutputLogMessage("SingleFire():\n")
    OutputLogMessage("magSize: " .. magSize .. " pcs, timePerShot: " .. timePerShot)
    OutputLogMessage(" ms, mouseTimer_offset: " .. mouseTimer_offset)
    OutputLogMessage(" ms, moveY: " .. moveY .. " px, moveY_increasePerShot: " .. moveY_increasePerShot)
    OutputLogMessage(" px, fireMode: " .. fireMode .. "\n\n")

    sprayTimer_start = GetRunningTime()
    shotCounter = 1

    repeat

        sprayTimer = GetRunningTime() - sprayTimer_start
        shootTimer = shotCounter * timePerShot

        if sprayTimer >= shootTimer then

            actualTimer_f = math.floor(shotCounter * 85.71 - 85.71)
            actualTimer_c = math.ceil(shotCounter * 85.71 - 85.71)
            OutputLogMessage(shotCounter .. "/" .. magSize)
            OutputLogMessage("\t moveY: " .. moveY .. " px\t\t shootTimer: " .. shootTimer .. " ms")
            OutputLogMessage("\t\t actual shot: " .. actualTimer_f .. " - " .. actualTimer_c .. " ms\n")
            OutputLogMessage("\t sprayTimer: " .. sprayTimer .. " ms\t sprayTimer_start: " .. sprayTimer_start .. " ms\n")

            PressAndReleaseMouseButton(mouseBind_fireInGame)
            Sleep(mouseTimer_offset) -- A short delay before compensating the recoil
            MoveMouseRelative(0,moveY)

            moveY = moveY + moveY_increasePerShot
            shotCounter = shotCounter + 1

        end

        Sleep(1)

    until shotCounter == magSize + 1 -- +1 includes last shot

end


function BurstFire()

    OutputLogMessage("BurstFire():\n")
    OutputLogMessage("magSize: " .. magSize .. " pcs, timePerShot: " .. timePerShot)
    OutputLogMessage(" ms, mouseTimer_offset: " .. mouseTimer_offset)
    OutputLogMessage(" ms, moveY: " .. moveY .. " px, moveY_increasePerShot: " .. moveY_increasePerShot)
    OutputLogMessage(" px, fireMode: " .. fireMode .. "\n\n")

    sprayTimer_start = GetRunningTime()
    shotCounter = 1

    repeat

        sprayTimer = GetRunningTime() - sprayTimer_start
        shootTimer = shotCounter * timePerShot

        if sprayTimer >= shootTimer then

            actualTimer_f = math.floor(shotCounter * 85.71 - 85.71)
            actualTimer_c = math.ceil(shotCounter * 85.71 - 85.71)
            OutputLogMessage(shotCounter .. "/" .. magSize)
            OutputLogMessage("\t moveY: " .. moveY .. " px\t\t shootTimer: " .. shootTimer .. " ms")
            OutputLogMessage("\t\t actual shot: " .. actualTimer_f .. " - " .. actualTimer_c .. " ms\n")
            OutputLogMessage("\t sprayTimer: " .. sprayTimer .. " ms\t sprayTimer_start: " .. sprayTimer_start .. " ms\n")

            PressAndReleaseMouseButton(mouseBind_fireInGame)
            Sleep(mouseTimer_offset) -- A short delay before compensating the recoil
            MoveMouseRelative(0,moveY)

            moveY = moveY + moveY_increasePerShot
            shotCounter = shotCounter + 1

        end

        Sleep(1)

    until shotCounter == magSize + 1 -- +1 includes last shot

end
