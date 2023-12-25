
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
    devprint("Doing speen")
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
    if not IsVREnabled() then
        return
    end
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
        leftHolder:SetLocalOrigin(leftHolder:GetLocalOrigin() + Vector(-0.6, 0, 0))
    end
    local rightHolder = self.RightHand:GetFirstChildWithClassname("hlvr_hand_item_holder")
    if rightHolder then
        rightHolder:SetLocalOrigin(rightHolder:GetLocalOrigin() + Vector(-0.6, 0, 0))
    end
end

function ReturnHintBall(_, io)
    local hint_ball = Entities:FindByModel(nil, "models/vinny_house/hint_ball.vmdl")
    if hint_ball then
        print("Returning lost hint ball")
        hint_ball:SetOrigin(Vector(-139.189, 129.855, 171.696))---139.189, 129.855, 169.696
        hint_ball:SetAngles(0, 0, 0)
    end
end

function ReturnSecretBall(_, io)
    local secret_ball = Entities:FindByModel(nil, "models/vinny_house/secrets_ball.vmdl")
    if secret_ball then
        print("Returning lost secret ball")
        secret_ball:SetOrigin(Vector(-104.419, 198, 43.4904))---104.419, 198, 41.4904
        secret_ball:SetAngles(0, 285, 0)
    end
end

function ReturnHintBalls(_, io)
    local hint_ball = Entities:FindByModel(nil, "models/vinny_house/hint_ball.vmdl")
    if hint_ball and VectorDistance(hint_ball:GetOrigin(), Player:GetOrigin()) > 512 then
        ReturnHintBall(_, io)
    end
    local secret_ball = Entities:FindByModel(nil, "models/vinny_house/secrets_ball.vmdl")
    if secret_ball and VectorDistance(secret_ball:GetOrigin(), Player:GetOrigin()) > 512 then
        ReturnSecretBall(_, io)
    end
end