
---comment
---@param io IOParams
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
    local spawn = ArrayRandom(spawns)

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

RegisterPlayerEventCallback("vr_player_ready", function()
    Player:UpdateHandAttachmentsForGordon()
end)

function CBasePlayer:UpdateHandAttachmentsForGordon()
    local leftGlove = self.LeftHand:GetGrabbityGlove()
    if leftGlove then
        leftGlove:SetLocalOrigin(Vector(0, 0.3, 0))
    end
    local rightGlove = self.RightHand:GetGrabbityGlove()
    if rightGlove then
        rightGlove:SetLocalOrigin(Vector(0, -0.3, 0))
    end

    local leftHolder = self.LeftHand:GetFirstChildWithClassname("hlvr_hand_item_holder")
    if leftHolder then
        leftHolder:SetLocalOrigin(leftHolder:GetLocalOrigin() + Vector(-0.5, 0, 0))
    end
    local rightHolder = self.RightHand:GetFirstChildWithClassname("hlvr_hand_item_holder")
    if rightHolder then
        rightHolder:SetLocalOrigin(rightHolder:GetLocalOrigin() + Vector(-0.5, 0, 0))
    end
end