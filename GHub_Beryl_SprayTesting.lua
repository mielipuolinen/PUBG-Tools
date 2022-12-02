-- ABSOLUTELY NO WARRANTY - YOU WILL RISK A GAME BAN FOR YOURSELF BY USING THIS - USE AT YOUR OWN RISK
-- Even then, PLEASE use it ONLY in the Training mode for learning and researching purposes.

-- Tuned ONLY for the following setup:
-- Beryl, Full Auto, standing and breathing
-- Red Dot, Compensator, Vertical Foregrip, Quickdraw Mag

mouseBind_activation = 4 -- 4: thumb near, 5: thumb far
mouseBind_fireInGame = 1 -- 1: LMB, 2: RMB

function SetDefaults()
    ClearLog()
    magSize = 30 -- shots to fire
    timePerShot = 86 -- rate of fire (ms)
    mouseTimer_offset = math.floor( timePerShot / 2 )
    moveY = 95 -- mouse X axis compensation per shot (px)
    moveY_increasePerShot = 2 -- mouse X axis compensation increase per shot (px)
    fireMode = "auto" -- auto/single/burst
end

function OnEvent(event, arg)
    if (event == "MOUSE_BUTTON_PRESSED" and arg == MouseBind) then
        SetDefaults()

        if fireMode == "auto" then
            AutoFire()
        elseif fireMode == "single" then
            SingleFire()
        elseif fireMode == "burst" then
            BurstFire()
        end
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

    until shotCounter == magSize + 1 -- +1 includes last shot

    ReleaseMouseButton(mouseBind_fireInGame)

end

function SingleFire()
end

function BurstFire()
end
