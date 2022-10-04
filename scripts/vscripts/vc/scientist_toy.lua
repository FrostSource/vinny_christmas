
local speak_length = 16

local function Speak()
    local toy = thisEntity:FindInPrefab("scientist_toy")
    local port = thisEntity:FindInPrefab("scientist_toy_port")
    if not toy or not port then return end

    local len = (port:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Length()
    -- print("Ring length", len)
    if len >= speak_length then
        toy:EmitSound("vinny.scientist_vox")
    end
end
Expose(Speak)
