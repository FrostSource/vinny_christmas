---@diagnostic disable: lowercase-global

function Speak(sound)
    EmitSoundOn(sound, Entities:GetLocalPlayer())
end

vinny_slept_sound = function()
    local player = Entities:GetLocalPlayer()
    EmitSoundOn("narrator.christmas_complete", player)
    EmitSoundOn("caption.narrator.christmas_complete_01", player)
    EmitSoundOn("caption.narrator.christmas_complete_02", player)
    --EmitSoundOn("caption.narrator.christmas_complete_03", player)
    --EmitSoundOn("caption.narrator.christmas_complete_04", player)
    --EmitSoundOn("caption.narrator.christmas_complete_05", player)
    --EmitSoundOn("caption.narrator.christmas_complete_06", player)
end

