
---@class Magic8Ball : HintBall
local base, self = entity("Magic8Ball", "vc.hint_ball")
if self and self.Initiated then return end

local hints = require"vc.hints"
base.__HintReminders = hints.reminders
base.__HintAreas = hints.areas



Convars:RegisterCommand("vinny_debug_hint", function()
	if GetMapName() ~= '__test_hints' then
		self:SetOrigin(Player:EyePosition() + Player:EyeAngles():Forward() * 32)
		self:EntFire("Sleep")
	end
	self:ShowContextHint()
end, "", 0)
Convars:RegisterCommand("vinny_debug_hint_all_reminders", function()
	for index, value in ipairs(self.__HintReminders) do
		self:AddReminder(index)
	end
end, "", 0)
Convars:RegisterCommand("vinny_debug_hint_grab", function()
	self:Grab(Player.PrimaryHand)
end, "", 0)

return base