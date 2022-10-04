---@diagnostic disable: lowercase-global

function Speak(sound)
    EmitSoundOn(sound, Player)
end

vinny_slept_sound = function()
    local player = Player
    EmitSoundOn("narrator.christmas_complete", player)
    EmitSoundOn("caption.narrator.christmas_complete_01", player)
    EmitSoundOn("caption.narrator.christmas_complete_02", player)
    --EmitSoundOn("caption.narrator.christmas_complete_03", player)
    --EmitSoundOn("caption.narrator.christmas_complete_04", player)
    --EmitSoundOn("caption.narrator.christmas_complete_05", player)
    --EmitSoundOn("caption.narrator.christmas_complete_06", player)
end

