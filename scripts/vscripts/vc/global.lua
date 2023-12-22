
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

function SpawnFridgeKey(_, io)
    local spawns = Entities:FindAllByName("fridge_key_spawn")
    local spawn = RandomFromArray(spawns)

    SpawnEntityFromTableSynchronous("prop_physics", {
        targetname = "@fridge_key",
        origin = spawn:GetOrigin(),
        angles = spawn:GetAngles(),
        CanDepositInItemHolder = "1",
        rendercolor = "211 161 76 255",
        interactAs = "important_item,fridge_key",
        glowrange = "0",
        glowrangemin = "0",
        glowcolor = "211 161 76 255",
        spawnflags = 16777473,
        model = "models/props/interior_deco/tabletop_key02.vmdl",
    })
end
