
local PortEnt = nil
local ToyEnt = nil
local SpeakLength = 16

function Activate()
    PortEnt = Entities:FindByNameNearest("*scientist_toy_port", thisEntity:GetAbsOrigin(), 10)
    ToyEnt = Entities:FindByNameNearest("*scientist_toy", thisEntity:GetAbsOrigin(), 10)
end

function Speak()
    --if PortEnt == nil or ToyEnt == nil then return end
    local len = (PortEnt:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Length()
    print("Ring length", len)
    if len >= SpeakLength then
        ToyEnt:EmitSound("Addon.ScientistVox")
    end
end
