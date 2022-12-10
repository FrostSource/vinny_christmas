
-- ---@class Magic8Ball : HintBall
-- local base, self = entity("Magic8Ball", "vc.hint_ball")
-- if self and self.Initiated then return end
---@type HintBall, HintBall
local base, self = inherit("vc.hint_ball")
if self and self.Initiated then return end

local hints = require"vc.hints"
self.__HintReminders = hints.reminders
self.__HintAreas = hints.areas

return base