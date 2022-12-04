-- ABSOLUTELY NO WARRANTY - YOU WILL RISK A GAME BAN FOR YOURSELF BY USING THIS - USE AT YOUR OWN RISK
-- Even then, PLEASE use it ONLY in the Training mode for learning and researching purposes.

-- Tuned ONLY for the following setup:
-- Beryl, Full Auto, standing and breathing
-- Red Dot, Compensator, Vertical Foregrip, Quickdraw Mag

-- Tested with Logitech G Hub app & Logitech G Pro Superlight mouse
-- Adjust mouseSensitivity to fit your mouse sensitivity settings

-- Scope modes can be used when universal sensitivity is used in-game ("monitor distance sensitivity")
-- All scopes work (except 1x with breath holding) automatically with 360deg/cm sensitivities

mouseBind_activation = 6 -- 4: thumb near
mouseBind_switchFireMode = 5 -- 5: thumb far
mouseBind_switchScope = 3 -- 3: MMB
mouseBind_switchStance = 6 -- 6: ???
mouseBind_fireInGame = 1 -- 1: LMB
mouseBind_scopeInGame = 2 -- 2: RMB
mouseBind_testPixelSkipping = 4
keyBind_reloadInGame = "r"
keyBind_holdBreathInGame = "lshift"

mouseSensitivity = 50 -- [1..n], adjust this factor for the script to work with your sensitivity settings
-- My in-game sensitivity settings (1000dpi):
-- SensitiveMap=((Mouse, (Array=((SensitiveName="Normal",Sensitivity=21.750566,LastConvertedSensitivity=0.005446),
-- (SensitiveName="Targeting",Sensitivity=21.750566,LastConvertedSensitivity=0.005446),
-- (SensitiveName="Scoping",Sensitivity=24.650163,LastConvertedSensitivity=0.006223),
-- (SensitiveName="ScopingMagnified",Sensitivity=50.000000,LastConvertedSensitivity=0.020000),
-- (SensitiveName="Scope2X",Sensitivity=36.802066,LastConvertedSensitivity=0.010891),
-- (SensitiveName="Scope3X",Sensitivity=45.606629,LastConvertedSensitivity=0.016337),
-- (SensitiveName="Scope4X",Sensitivity=52.967385,LastConvertedSensitivity=0.022929),
-- (SensitiveName="Scope6X",Sensitivity=60.658129,LastConvertedSensitivity=0.032673),
-- (SensitiveName="Scope8X",Sensitivity=66.905065,LastConvertedSensitivity=0.043564),
-- (SensitiveName="Scope15X",Sensitivity=75.709628,LastConvertedSensitivity=0.065347))))),
-- MouseVerticalSensitivityMultiplierAdjusted=1.000000

weapon = "Beryl" -- Beryl/M4
fireMode = "auto" -- auto/single/burst
scope = 1 -- 1/1.31/2/3/4/4.21/6/8/15 (1.31: 1x hold breath, 4.21: ACOG)
stance = "stand" -- stand/crouch/prone
autoReload = false -- boolean
autoScope = false -- boolean
autoHoldBreath = false -- boolean
magSize = 30

function SetDefaults()
    ClearLog()
    -- magSize = 1
    timePerShot_accurate = 100
    moveY = 1
    moveY_increasePerShot = 0
    moveY_increaseAfterShot = 999
    moveY_doubleIncreaseAfterShot = 999
    moveY_stopIncreaseAfterShot = 999

    -- magSize: [pcs], shots to fire
    -- timePerShot_accurate: [ms], rate of fire
    -- moveY: [%], vertical movement compensation per shot
    -- moveY_increasePerShot: [%], compensation increase per shot
    -- moveY_increaseAfterShot: [pcs], starts increasing compensation after this shot by using moveY_increasePerShot
    -- moveY_doubleIncreaseAfterShot: [pcs], doubles compensation increasement after this shot
    -- moveY_stopIncreaseAfterShot: [pcs], stops compensation increasement after this shot

    if weapon == "Beryl" then
        timePerShot_accurate = 85.71
        if fireMode == "auto" then
            moveY = 1.61
            moveY_increasePerShot = 0.056
            moveY_increaseAfterShot = 5
            moveY_stopIncreaseAfterShot = 16
        elseif fireMode == "single" then
            moveY = 1.75
            moveY_increasePerShot = 0.0
        elseif fireMode == "burst" then
            moveY = 1.75
            moveY_increasePerShot = 0.0
        end

    elseif weapong == "M4" then -- TODO: Tune values for M4
        if fireMode == "auto" then
            timePerShot_accurate = 86 -- accurate: 85.71
            moveY = 1.9
            moveY_increasePerShot = 0.021 -- NOTE: probably should be checked again
        elseif fireMode == "single" then
            timePerShot_accurate = 110
            moveY = 1.75
            moveY_increasePerShot = 0.0
        end
    end

    timePerShot = Rounding(timePerShot_accurate)
    scopeFactor = CalculateScope()
    stanceFactor = CalculateStance()
    moveY = Rounding( moveY * mouseSensitivity * scopeFactor * stanceFactor )
    moveY_increasePerShot = Rounding( moveY * moveY_increasePerShot )
    mouseTimer_offset = Rounding( timePerShot / 2  )
end


function Rounding(value) -- because LUA doesn't have rounding implemented
    -- TODO: Confirm that rounding works as excepted with different values
    value_floor = math.floor(value)
    value_ceil = math.ceil(value)
    if value_floor < (value - 0.5) then
        return value_ceil
    else
        return value_floor
    end
end


function CalculateScope()
    -- default ADS FOV is 72
    -- eg. 1x Red Dot is 72 FOV and holding breath decreases FOV to 55
    -- 72/55 = 1,309.. => 72/1,31 = 54,96..
    if     scope == 1    then
        return scope
    elseif scope == 1.31 then -- hold breath (72FOV/55FOV)
        return scope * 1.11
    else
        return scope / 1.11 -- scopes (80FOV/scopeFOV)
    end
end


function CalculateStance() -- NOTE: May be a bit inaccurate estimation (due to moveY & increasePerShot, etc.)
    if     stance == "stand"  then
        return 1
    elseif stance == "crouch" then
        return 0.76
    elseif stance == "prone"  then
        return 0.52
    end
end


function OnEvent(event, arg)
    if     ( event == "MOUSE_BUTTON_PRESSED" and arg == mouseBind_activation        ) then
        TriggerAction()
    elseif ( event == "MOUSE_BUTTON_PRESSED" and arg == mouseBind_switchFireMode    ) then
        SwitchFireMode()
    elseif ( event == "MOUSE_BUTTON_PRESSED" and arg == mouseBind_switchScope       ) then
        SwitchScope()
    elseif ( event == "MOUSE_BUTTON_PRESSED" and arg == mouseBind_switchStance      ) then
        SwitchStance()
    elseif ( event == "MOUSE_BUTTON_PRESSED" and arg == mouseBind_testPixelSkipping ) then
        TestPixelSkipping()
    end
end


function SwitchFireMode()
    if     fireMode == "auto"   then
        fireMode = "single"
    elseif fireMode == "single" then
        fireMode = "burst"
    elseif fireMode == "burst"  then
        fireMode = "auto"
    end

    OutputLogMessage("\nSwitching Fire Mode to: " .. fireMode .. "\n")
end


function SwitchScope()
    if     scope == 1    then
        scope = 1.31
    elseif scope == 1.31 then
        scope = 2
    elseif scope == 2    then
        scope = 3
    elseif scope == 3    then
        scope = 4
    elseif scope == 4    then
        scope = 4.21
    elseif scope == 4.21 then
        scope = 6
    elseif scope == 6    then
        scope = 8
    elseif scope == 8    then
        scope = 15
    elseif scope == 15   then
        scope = 1
    end

    OutputLogMessage("\nSwitching Scope to: " .. scope .. "\n")
end


function SwitchStance()
    if     stance == "stand"  then
        stance = "crouch"
    elseif stance == "crouch" then
        stance = "prone"
    elseif stance == "prone"  then
        stance = "stand"
    end

    OutputLogMessage("\nSwitching Stance to: " .. stance .. "\n")
end


function TriggerAction()
    SetDefaults()

    if autoScope then
        PressAndReleaseMouseButton(mouseBind_scopeInGame)
        Sleep(500)
    end

    if autoHoldBreath then
        PressKey(keyBind_holdBreathInGame)
        Sleep(100)
    end

    if     fireMode == "auto"   then
        AutoFire()
    elseif fireMode == "single" then
        SingleFire()
    elseif fireMode == "burst"  then
        BurstFire()
    end

    if autoHoldBreath then
        ReleaseKey(keyBind_holdBreathInGame)
    end
    if autoScope then
        PressAndReleaseMouseButton(mouseBind_scopeInGame)
        Sleep(100)
    end
    if autoReload then
        PressAndReleaseKey(keyBind_reloadInGame)
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

    moveY_steps = 4
    moveY_sleepPerStep = 3
    moveY_movePerStep = math.floor( moveY / moveY_steps )

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

            for i = 1, moveY_steps, 1 do
                MoveMouseRelative(0, moveY_movePerStep)
                Sleep(moveY_sleepPerStep)
            end
            
            moveY_lastStep = moveY - (moveY_steps * moveY_movePerStep)
            MoveMouseRelative(0, moveY_lastStep)
            
            if moveY_stopIncreaseAfterShot <= shotCounter then
              -- do nothing
            elseif moveY_doubleIncreaseAfterShot <= shotCounter then
              moveY = moveY + moveY_increasePerShot + moveY_increasePerShot
            elseif moveY_increaseAfterShot <= shotCounter then
              moveY = moveY + moveY_increasePerShot
            end

            shotCounter = shotCounter + 1

        end

        Sleep(1)

    until shotCounter == magSize + 1 -- +1 includes last shot

    ReleaseMouseButton(mouseBind_fireInGame)
    OutputLogMessage("AutoFire() Running Time: ".. (GetRunningTime() - sprayTimer_start) .." ms\n\n")

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


function TestPixelSkipping()
    OutputLogMessage("TestPixelSkipping()\n")

    steps = 200
    jumpSteps = 100
    delay = 250 --ms
    sleepDelay = 1 --ms

    OutputLogMessage("Steps: " .. steps .. " \t Jump Steps: " .. jumpSteps .. " \t Delay: " .. delay .. " \n")
    OutputLogMessage("Watch for uneven movement to detect possible pixel skipping\n")
    OutputLogMessage("Primarily test with full zoomed 8x and 15x scopes\n\n")
    
    OutputLogMessage("Down\n")
    stepCount = 0
    repeat
        MoveMouseRelative(0,1)
        Sleep(sleepDelay)
        stepCount = stepCount + 1
    until stepCount == steps

    Sleep(delay)

    OutputLogMessage("Up\n")
    stepCount = 0
    repeat
        MoveMouseRelative(0,-1)
        Sleep(sleepDelay)
        stepCount = stepCount + 1
    until stepCount == steps

    Sleep(delay)

    OutputLogMessage("Right\n")
    stepCount = 0
    repeat
        MoveMouseRelative(1,0)
        Sleep(sleepDelay)
        stepCount = stepCount + 1
    until stepCount == steps

    Sleep(delay)

    OutputLogMessage("Left\n")
    stepCount = 0
    repeat
        MoveMouseRelative(-1,0)
        Sleep(sleepDelay)
        stepCount = stepCount + 1
    until stepCount == steps

    Sleep(delay)

    OutputLogMessage("Down + Right\n")
    stepCount = 0
    repeat
        MoveMouseRelative(1,1)
        Sleep(sleepDelay)
        stepCount = stepCount + 1
    until stepCount == steps

    Sleep(delay)

    OutputLogMessage("Up + Left\n")
    stepCount = 0
    repeat
        MoveMouseRelative(-1,-1)
        Sleep(sleepDelay)
        stepCount = stepCount + 1
    until stepCount == steps

    Sleep(delay)
    OutputLogMessage("Jump Down + Right\n")
    MoveMouseRelative(jumpSteps,jumpSteps)

    Sleep(delay)
    OutputLogMessage("Jump Up + Left\n")
    MoveMouseRelative(jumpSteps * -1, jumpSteps * -1)

    OutputLogMessage("TestPixelSkipping(): Finished")
end
