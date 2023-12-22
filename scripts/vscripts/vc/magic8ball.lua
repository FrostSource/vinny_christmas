
-- ---@class Magic8Ball : HintBall
-- local base, self = entity("Magic8Ball", "vc.hint_ball")
-- if self and self.Initiated then return end
---@type HintBall, HintBall
local base, self = inherit("vc.hint_ball")
if self and self.Initiated then return end

local hints = require"vc.hints"
self.__HintReminders = hints.reminders
self.__HintAreas = hints.areas

function self:HintCallback(area_index, line)
    if area_index == 11 and line == 7 then
        print("Show key glow")
        local key = Entities:FindByName(nil, "@fridge_key")
        if key then
            DebugDrawSphere(key:GetOrigin(), Vector(255,0,0), 1, 8, true, 100)
            key:EntFire("StartGlowing")
            key:AddOutput("OnPlayerPickup", "!self", "StopGlowing", nil, nil, nil, nil, true)
        end
    end
end

return base