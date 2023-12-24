
---Draw debug text with an outline
---@param text string
---@param x number
---@param y number
---@param line integer
---@param outline_col Vector
---@param size integer
---@param time number
local function outline_text(text, x, y, line, outline_col, size, time)
    DebugScreenTextPretty(x, y, line, text, 14,104,89, 255, 60, "", size, true)
    DebugScreenTextPretty(x-1, y-1, line, text, outline_col.x,outline_col.y,outline_col.z, 255, time, "", size, true)
    DebugScreenTextPretty(x-1, y+1, line, text, outline_col.x,outline_col.y,outline_col.z, 255, time, "", size, true)
    DebugScreenTextPretty(x+1, y+1, line, text, outline_col.x,outline_col.y,outline_col.z, 255, time, "", size, true)
    DebugScreenTextPretty(x+1, y-1, line, text, outline_col.x,outline_col.y,outline_col.z, 255, time, "", size, true)
end

local screen_line = 0
local function screen(...)
    local l
    for i, text in ipairs({...}) do
        outline_text(text, 16, 16, screen_line + (i-1), Vector(255, 255, 255), 22, 60)
        l = i
    end
    screen_line = screen_line + l
end


RegisterPlayerEventCallback("novr_player", function()
    screen("Vinny Christmas Debug Helper:", "Type 'vinny_' in the vconsole for a list of commands")
    SendToConsole("r_drawviewmodel 0; cl_drawhud 0; closecaption 2")
    SendToConsole("bind v noclip; sv_noclipspeed 1")
    screen("Toggle noclip with 'V'")
    SendToConsole("bind h vinny_hint")
    screen("Display hint with 'H'")
    SendToConsole("bind j vinny_secret")
    screen("Display secret with 'J'")
    SendToConsole("bind t vinny_disable_intro")
    screen("Skip intro triggers with 'T'")

    -- this is debug until next compile!
    -- local ball = Entities:FindByName(nil, "*secrets_ball")--[[@as HintBall]]
    -- if ball and ball.IsHintBall then
    --     if not ball.TextPanel then
    --         print('Secret ball text panel is not defined!')
    --     elseif ball.TextPanel:GetMoveParent() ~= ball then
    --         ball.TextPanel:SetParent(ball, nil)
    --     end
    -- end
end)

RegisterPlayerEventCallback("vr_player_ready", function (params)
    if IsInToolsMode() then
        DoEntFire("@fade_in_quick", "Fade", "", 0.3, nil, nil)
        SendToConsole("vinny_stop_alarm")
    end
end)

-- Hint debugging

Convars:RegisterCommand("vinny_hint", function()
    local ball = Entities:FindByName(nil, "*magic8ball")--[[@as HintBall]]
    if not ball.IsHintBall then
        print("Could not find magic8ball! Make sure name search is correct in code...")
        return
    end

	if GetMapName() ~= '__test_hints' then
		ball:SetOrigin(Player:EyePosition() + Player:EyeAngles():Forward() * 32)
		ball:EntFire("Sleep")
	end
	ball:ShowContextHint()
end, "", 0)
Convars:RegisterCommand("vinny_hint_ball_add_all_reminders", function()
    local ball = Entities:FindByName(nil, "*magic8ball")--[[@as HintBall]]
    if not ball.IsHintBall then
        print("Could not find magic8ball! Make sure name search is correct in code...")
        return
    end

	for index in ipairs(ball.__HintReminders) do
		ball:AddReminder(index)
	end
end, "", 0)
Convars:RegisterCommand("vinny_hint_ball_force_grab", function()
    local ball = Entities:FindByName(nil, "*magic8ball")--[[@as HintBall]]
    if not ball.IsHintBall then
        print("Could not find magic8ball! Make sure name search is correct in code...")
        return
    end

	ball:Grab(Player.PrimaryHand)
end, "", 0)

-- Secret debugging

Convars:RegisterCommand("vinny_secret", function()
    local ball = Entities:FindByName(nil, "*secrets_ball")--[[@as HintBall]]
    if not ball.IsHintBall then
        print("Could not find secret ball! Make sure name search is correct in code...")
        return
    end

	if GetMapName() ~= '__test_hints' then
		ball:SetOrigin(Player:EyePosition() + Player:EyeAngles():Forward() * 32)
		ball:EntFire("Sleep")
	end
	ball:ShowContextHint()
end, "", 0)
Convars:RegisterCommand("vinny_secret_ball_force_grab", function()
    local ball = Entities:FindByName(nil, "*secrets_ball")--[[@as HintBall]]
    if not ball.IsHintBall then
        print("Could not find secret ball! Make sure name search is correct in code...")
        return
    end

	ball:Grab(Player.PrimaryHand)
end, "", 0)


-- Other

Convars:RegisterCommand("vinny_disable_intro", function()
    DoEntFire("copyright_music_morningmagic_trigger", "Kill", "", 0, nil, nil)
    DoEntFire("narrator_trigger_objectives", "Kill", "", 0, nil, nil)

    DoEntFire("relay_post_objectives", "Trigger", "", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_pachinko_drop_ball", function()
    local ball = Entities:FindByModelWithin(nil, "models/props/interior_furniture/interior_pool_ball_0.vmdl", Vector(31.4553, -56.966, -124), 64)
    if not ball then
        print("Could not find a ball nearby to drop!")
        return
    end
    ball:SetOrigin(Vector(30, RandomFloat(-71.5015, -39.5015), -49))
end, "", 0)

Convars:RegisterCommand("vinny_pachinko_win", function()
    DoEntFire("relay_pachinko_win", "Trigger", "", 0, nil, nil)
end, "", 0)
Convars:RegisterCommand("vinny_pachinko_lose", function()
    DoEntFire("2401_relay_power_receive", "Trigger", "", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_get_all_gifts", function()
    -- for _, value in ipairs(Entities:FindAllByName("christmas_gift")) do
    --     value:EntFire("FireUser3")
    -- end
    DoEntFire("hint_gifts_found", "SetValue", "5", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_gifts_put_under_tree", function()
    local gifts = Entities:FindAllByName("christmas_gift")
    for index, value in ipairs(gifts) do
        print(index, value:GetModelName())
    end
    -- Medium gray 03
    gifts[1]:SetAngles(-75.00658416748, -96.602470397949, 0.62969315052032)
    gifts[1]:SetOrigin(Vector(40.076206207275, -138.30166625977, 6.1656360626221))
    -- Medium gray 03
    gifts[2]:SetAngles(0.033091511577368, 17.428499221802, 0.048689749091864)
    gifts[2]:SetOrigin(Vector(22.48021697998, -157.07766723633, 3.6735529899597))
    -- Small 02
    gifts[3]:SetAngles(-0.019339678809047, -54.065254211426, -54.18921661377)
    gifts[3]:SetOrigin(Vector(27.294418334961, -141.62278747559, 2.8534486293793))
    -- Medium green 04
    gifts[4]:SetAngles(0.01491470169276, -83.284309387207, -0.03235836327076)
    gifts[4]:SetOrigin(Vector(22.784019470215, -151.7059173584, 0.35398745536804))
    -- Big 01
    gifts[5]:SetAngles(0.0028036476578563, 94.875350952148, 0.002115743001923)
    gifts[5]:SetOrigin(Vector(47.73722076416, -151.62020874023, -0.00013828277587891))

end, "", 0)

Convars:RegisterCommand("vinny_unclog_toilet", function()
    DoEntFire("clogged_toilet_counter", "SetValue", "4", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_bake_cookies", function()
    local ent
    ent = Entities:FindByName(nil, "cooking_tray")
    if ent then
        ent:SetOrigin(Vector(-69.923, 317.417, 20))
        ent:SetAngles(0, 90, 0)
    end
    ent = Entities:FindByName(nil, "ingredient_flour")
    if ent then
        ent:SetOrigin(Vector(-75.3513, 313.017, 23.0366))
        ent:SetAngles(-90, 270, 0)
    end
    ent = Entities:FindByName(nil, "ingredient_sugar")
    if ent then
        ent:SetOrigin(Vector(-67.7252, 313.714, 22.288))
        ent:SetAngles(-90, 270, 0)
    end
    ent = Entities:FindByName(nil, "ingredient_butter")
    if ent then
        ent:SetOrigin(Vector(-62.5537, 316.582, 21.2674))
        ent:SetAngles(0, 90, 0)
    end
    DoEntFire("oven_turn_on", "Trigger", "", 0, nil, nil)
    -- DoEntFire("oven_timer", "SubtractFromTimer", "210", 0, nil, nil)
    DoEntFire("oven_timer", "FireTimer", "", 5, nil, nil)
    DoEntFire("oven_timer", "ResetTimer", "", 5, nil, nil)
    print("Please wait 5 seconds for oven to finish...")
end, "", 0)

Convars:RegisterCommand("vinny_unlock_fridge_door", function()
    DoEntFire("fridge_padlock_break", "Trigger", "", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_unlock_shed_door", function()
    local handle = Entities:FindByName(nil, "buried_handle_for_shed")
    if not handle then
        print("Could not find shed handle!")
        return
    end
    handle:SetOrigin(Vector(-65.5, 684.5, 16.5))
end, "", 0)

Convars:RegisterCommand("vinny_unlock_meat_door", function()
    DoEntFire("meat_unlock_door_relay", "Trigger", "", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_unlock_rat_door", function()
    DoEntFire("jerma_rat_activate", "Trigger", "", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_unlock_basement_door", function()
    local trigger = Entities:FindByName(nil, "trigger_meat_basement_door")
    if not trigger then
        print("Basement door Meat trigger not found! Door must already be unlocked...")
        return
    end
    trigger:FireOutput("OnTrigger", nil, nil, nil, 0)
end, "", 0)

Convars:RegisterCommand("vinny_flush_rat", function()
    local filter = Entities:FindByName(nil, "filter_rat_with_flies")
    if not filter then
        print("Rat filter not found!")
        return
    end
    -- Make sure this actually works
    filter:FireOutput("OnPass", nil, nil, nil, 0)
end, "", 0)

Convars:RegisterCommand("vinny_tp_to_roof", function()
    Player:SetOrigin(Vector(-64, -64, 480))
end, "", 0)

Convars:RegisterCommand("vinny_saw_unlock_freezer", function()
    DoEntFire("2848_4442_barricade_doors_unlock_relay", "Trigger", "", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_saw_complete_lever_puzzle", function()
    DoEntFire("unlock_saw_cafe_exit_doors", "Trigger", "", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_saw_complete_crush_puzzle", function()
    DoEntFire("color_puzzle_counter_successes", "SetValue", "6", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_put_cookies_by_tree", function()
    local cookies = Entities:FindAllByName("baked_christmas_cookie")
    if #cookies == 0 then
        print("Cookies must be baked first! Use command 'vinny_bake_cookies' ...")
        return
    end
    cookies[1]:SetOrigin(Vector(68.2656, -180.832, 29.0827))
    cookies[1]:SetAngles(-90, 90, 0)
    cookies[2]:SetOrigin(Vector(68.2656, -180.832, 30.3356))
    cookies[2]:SetAngles(-90, 90, 0)
end, "", 0)

Convars:RegisterCommand("vinny_put_milk_by_tree", function()
    for _, cup in ipairs(Entities:FindAllByName("*glass_without_milk")) do
        if cup:GetHealth() == 0 then
            for _,child in ipairs(cup:GetChildren()) do
                if child:GetClassname() == "trigger_once" then
                    child:FireOutput("OnTrigger", nil, nil, nil, 0)
                end
            end
            cup:SetOrigin(Vector(58.8532, -181.121, 31))
            cup:SetAngles(0, 0, 0)
        end
    end
end, "", 0)

Convars:RegisterCommand("vinny_put_grimoire_book_on_grave", function()
    local book = Entities:FindByName(nil, "grimoire_book")
    if not book then
        print("Could not find grimoire book!")
        return
    end
    book:SetOrigin(Vector(467.859, -238.455, -16))
    book:EnablePickup()
end, "", 0)

Convars:RegisterCommand("vinny_put_grimoire_book_on_altar", function()
    local book = Entities:FindByName(nil, "grimoire_book")
    if not book then
        print("Could not find grimoire book!")
        return
    end
    book:SetOrigin(Vector(-684.608, 4627.13, -1676.07 + 6))
end, "", 0)

Convars:RegisterCommand("vinny_tp_to_attic_end", function()
    Player:SetOrigin(Vector(-239.226, 1353.18, -1677.71))
end, "", 0)

Convars:RegisterCommand("vinny_set_up_tree", function()
    local box = Entities:FindByName(nil, "christmas_tree_box")
    if not box then
        print("Could not find christmas tree box!")
        return
    end
    box:SetOrigin(Vector(28, -181.81, 11.5))
end, "", 0)

Convars:RegisterCommand("vinny_put_gnome_on_tree", function()
    local tree = Entities:FindByName(nil, "christmas_tree_placed")
    if not tree then
        print("Tree must be set up before placing gnome! Use command 'vinny_set_up_tree' ...")
        return
    end
    local gnome = Entities:FindByName(nil, "gnome_santa")
    if not gnome then
        print("Could not find gnome!")
        return
    end
    gnome:SetOrigin(Vector(28.4122, -181.899, 115.25))
end, "", 0)

Convars:RegisterCommand("vinny_change_time_to_morning", function()
    DoEntFire("@snow_relay_init", "Trigger", "", 0, nil, nil)
    if not IsVREnabled() then
        local snow = Entities:FindByName(nil, "@snow_local")
        if snow then
            snow:SetParent(Player, "")
            snow:SetLocalOrigin(Vector(0, 0, 48))
            snow:SetLocalAngles(0,0,0)
        end
    end
end, "", 0)

Convars:RegisterCommand("vinny_saw_open_color_puzzle", function()
    DoEntFire("color_puzzle_wheel", "Lock", "", 0, nil, nil)
    DoEntFire("color_puzzle_cover_open_snd", "StartSound", "", 0, nil, nil)
    DoEntFire("color_puzzle_music", "StartSound", "", 0, nil, nil)
    DoEntFire("color_puzzle_music_timer", "Enable", "", 0, nil, nil)
    DoEntFire("color_puzzle_wall_cover", "Open", "", 0, nil, nil)
    DoEntFire("snd_saw_vox_goodatmakinggames", "StartSound", "", 5, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_feed_meat", function()
    local trigger = Entities:FindByName(nil, "meat_mouth_trigger")
    if not trigger then
        print("Could not find Meat mouth trigger!")
        return
    end
    local gherkin = Entities:FindByModel(nil, "models/pickle/pickle_b.vmdl")
    if not gherkin then
        print("Could not find a gherkin to feed Meat! Make sure at least one exists...")
        return
    end
    trigger:FireOutput("OnTrigger", gherkin, gherkin, nil, 0)
end, "", 0)

Convars:RegisterCommand("vinny_ring_phone", function()
    local timer = Entities:FindByName(nil, "phone_timer")
    if not timer then
        print("Could not find phone timer!")
        return
    end
    timer:EntFire("SubtractFromTimer", "400")
end, "", 0)

Convars:RegisterCommand("vinny_answer_phone", function()
    local phone = Entities:FindByName(nil, "phone_reciever")
    if not phone then
        print("Could not find phone receiver!")
        return
    end
    phone:EntFire("SubtractFromTimer", "400")
    phone:Grab()
    phone:Drop()
    phone:SetParent(Player, "")
    phone:SetLocalOrigin(Vector(0, -8, 68))
    phone:SetLocalAngles(0, 0, 90)
end, "", 0)

Convars:RegisterCommand("vinny_drop_phone", function()
    local phone = Entities:FindByName(nil, "phone_reciever")
    if not phone then
        print("Could not find phone receiver!")
        return
    end
    phone:SetParent(nil, "")
end, "", 0)

Convars:RegisterCommand("vinny_speen_guy", function()
    -- local speen = Entities:FindByName(nil, "@speen_template")
    -- if not speen then
    --     print("Could not find speen template!")
    --     return
    -- end
    -- DoEntFire("@vr_debug_speen_tp", "Teleport", "", 0, nil, nil)
    -- speen:EntFire("ForceSpawn")
    -- local speen = Entities:FindByName(nil, "speen_particle")
    -- if speen then
        DoEntFire("@vr_debug_speen_tp", "Teleport", "", 0, nil, nil)
        DoEntFire("speen_relay", "Trigger", "", 0, nil, nil)
        -- local pt = ParticleManager:CreateParticle("particles/speen_guy.vpcf", 0, Player)
        -- ParticleManager:SetParticleControl(pt, 0, speen:GetAbsOrigin())
        -- ParticleManager:SetParticleControlOrientation(pt, 0, speen:GetForwardVector(), speen:GetRightVector(), speen:GetUpVector())
    -- end
end, "", 0)

Convars:RegisterCommand("vinny_stop_alarm", function()
    DoEntFire("2497_alarmclock", "Kill", "", 0, nil, nil)
    DoEntFire("2497_alarmclock_snd", "StopSound", "", 0, nil, nil)
    DoEntFire("2497_alarmclock_snd", "Kill", "", 0.1, nil, nil)
    DoEntFire("2497_alarmclock_timer", "Kill", "", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_unlock_front_door", function()
    DoEntFire("front_door_open_locks", "Trigger", "", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_unlock_attic", function()
    DoEntFire("attic_hatch_relay", "Trigger", "", 0, nil, nil)
end, "", 0)

Convars:RegisterCommand("vinny_tp_to_crush_puzzle", function()
    DoEntFire("nonvr_crush_tp", "teleport", "", 0, nil, nil)
end, "", 0)


print("debug/vinny_christmas initialized...")