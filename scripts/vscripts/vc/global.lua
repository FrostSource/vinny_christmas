
---comment
---@param io TypeIOInvoke
function HasMilk(_, io)
    -- Commented to allow for errors
    -- if io and io.activator then
        if io.activator:HasAttribute("has_milk") then
            io.caller:EntFire("FireUser1")
        end
    -- end
end

function DoSpeen(_, io)
    print("Doing speen")
    DoEntFire("@speen_particle", "Start", "", 0, nil, nil)
    local proxy =SpawnEntityFromTableSynchronous("prop_dynamic", {
        -- model = "models/vinny_house/gman_speen.vmdl",
        origin = io.caller:GetOrigin(),
        rendermode = "kRenderNone",
        ScriptedMovement = "1",
    })
    proxy:SetVelocity(Vector(-51.25, 0, 50) * 30)
    proxy:EntFire("Kill", "", 5)
    proxy:EmitSound("vinny.speen")
    StartSoundEventFromPosition("RapidFire.SingleShotOld", io.caller:GetOrigin())
end

