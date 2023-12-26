
-- ---@class SecretsBall : HintBall
-- local base, self = entity("SecretsBall", "vc.hint_ball")
---@type HintBall
local base, self = inherit("vc.hint_ball")
if self and self.Initiated then return end

local hints = require"vc.secrets"
self.__HintReminders = hints.reminders
self.__HintAreas = hints.areas



Convars:RegisterCommand("vinny_debug_secret", function()
	if GetMapName() ~= '__test_hints' then
		self:SetOrigin(Player:EyePosition() + Player:EyeAngles():Forward() * 32)
		self:EntFire("Sleep")
	end
	self:ShowContextHint()
end, "", 0)
Convars:RegisterCommand("vinny_debug_add_all_secrets", function()
	for index, value in ipairs(self.__HintReminders) do
		self:AddReminder(index)
	end
end, "", 0)
Convars:RegisterCommand("vinny_debug_grab_secret_ball", function()
	self:Grab(Player.PrimaryHand)
end, "", 0)

return base