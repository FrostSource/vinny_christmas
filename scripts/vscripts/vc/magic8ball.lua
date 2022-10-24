
---@class HintBall : EntityClass
local base, self = entity("HintBall")
if self.Initiated then return end

local hints = require"vc.hints"
local HintReminders = hints.reminders
local HintAreas = hints.areas

---@type table<integer,integer>
base.HintAreaIndex = {}
---@type integer[]
base.HintAreaStack = {}
---@type integer[]
base.HintReminderStack = {}
---@type integer
base.ReminderStackIndex = 1
--LastHintArea = LastHintArea or ''
base.HaltAtEnd = false
---@type EntityHandle
base.TextPanel = nil


-- local FORCE_THRESHOLD = 0.25

-- All shaking must be in this time frame
-- local SHAKE_TIMEOUT = 0.8
-- local SHAKE_COUNT = 5


---Seconds that a hint is shown before disappearing.
local HINT_TIMEOUT = 5.5
---Seconds before another hint can be displayed.
local TIME_BETWEEN_HINTS = 1.5
---Seconds in which each shake movement must be made.
local TIME_BETWEEN_SHAKES = 0.2
---Number of shakes required to show a hint.
local SHAKES_PER_HINT = 6

local MIN_ANGULAR_VELOCITY = 17
local MIN_LINEAR_VELOCITY = 21

local last_shake_ang = Vector()
local last_shake_vel = Vector()
local last_shake_time = 0
local last_hint_time = 0
local number_of_shakes = 0

local panel_is_open = false

-- local fLastShake = 0
-- local fLastForce = 0
-- local iShakeCount = 0
-- local vLastDirectionVector = Vector(0,0,0)
-- local fLastDirectionSign = 0
-- local vLastPos = nil

-- function base:OnSpawn(spawnkeys)
-- 	self.TextPanel = 
-- end

function base:OnReady(loaded)
	-- vLastPos = thisEntity:GetAbsOrigin()
	-- Init index saving table (should save between loads using attributes?)
	-- not needed because new entityy script saves it
	-- for i = 1, #HintAreas do
	-- 	self.HintAreaIndex[i] = 0
	-- end
	if not loaded then
		self.TextPanel = self:FindInPrefab("hint_panel")--[[@as EntityHandle]]
	else
		panel_is_open = false
		self.TextPanel:EntFire("RemoveCSSClass", "Open")
		self.TextPanel:EntFire("RemoveCSSClass", "NewHint")
	end
end


---Used to make new script compatible with setup in Hammer.
local private = thisEntity:GetPrivateScriptScope()
--#region Areas

---Adds a hint area by index.
---@param index integer
function base:AddArea(index)
	if not self:HintAreaExistsInStack(index) then
		prints("Hint:", "Adding area", index)
		self:RemoveArea(index)
		self.HintAreaStack[#self.HintAreaStack + 1] = index
	end
end
private.AddArea = function(index) self:AddArea(index) end

---Removes a hint area by index.
---@param index integer
function base:RemoveArea(index)
	for i=1, #self.HintAreaStack do
		if self.HintAreaStack[i] == index then
			prints("Hint:", "Removing area", index)
			table.remove(self.HintAreaStack, i)
			break
		end
	end
end
private.RemoveArea = function(index) self:RemoveArea(index) end

function base:HintAreaExistsInStack(index)
	for i=1, #self.HintAreaStack do
		if self.HintAreaStack[i] == index then
			return true
		end
	end
	return false
end

---Gets the next hint for the current area.
---@return string
function base:GetAreaHint()
	-- Return blank if no area hints, so reminder can be shown
	if #self.HintAreaStack == 0 then return '' end

	local area = HintAreas[self.HintAreaStack[#self.HintAreaStack]]
	local line = self.HintAreaIndex[self.HintAreaStack[#self.HintAreaStack]]

	-- Increment hint line if not halting
	if not self.HaltAtEnd or line < #area then

		-- Reset if at end of hints
		if line >= #area then
			line = 0
		end

		line = line + 1
		self.HintAreaIndex[self.HintAreaStack[#self.HintAreaStack]] = line

	end

	return area[line]
end

--#endregion

--#region Reminders

function base:AddReminder(index)
	if not self:HintReminderExistsInStack(index) then
		prints("Hint:", "Add reminder", index)
		self.HintReminderStack[#self.HintReminderStack + 1] = index
	end
end
private.AddReminder = function(index) self:AddReminder(index) end

function base:RemoveReminder(index)
	local found = nil
	for i=1, #self.HintReminderStack do
		if self.HintReminderStack[i] == index then
			prints("Hint:", "Removing reminder", index)
			found = i
			break
		end
	end

	if found ~= nil then
		table.remove(self.HintReminderStack, found)
	end
end
private.RemoveReminder = function(index) self:RemoveReminder(index) end

function base:HintReminderExistsInStack(index)
	for i=1, #self.HintReminderStack do
		if self.HintReminderStack[i] == index then
			return true
		end
	end
	return false
end

function base:GetReminderHint()
	-- Return if no area hints so fallback can be shown
	if #self.HintReminderStack == 0 then return '' end

	-- Re-shuffle and reset reminders if at end
	if self.ReminderStackIndex >= #self.HintReminderStack then
		self:ShuffleReminderStack()
		self.ReminderStackIndex = 0
	end

	-- Increment hint line and return hint text
	self.ReminderStackIndex = self.ReminderStackIndex + 1
	return HintReminders[self.HintReminderStack[self.ReminderStackIndex]]
end

function base:ShuffleReminderStack()
	-- Just return if not enough reminders to shuffle
	if #self.HintReminderStack < 2 then return false end

	for i = #self.HintReminderStack, 2, -1 do
		local j = RandomInt(1, i)
		self.HintReminderStack[i], self.HintReminderStack[j] = self.HintReminderStack[j], self.HintReminderStack[i]
	end

	return true
end

--#endregion

--#region Other

function base:EnableHalt()
	self.HaltAtEnd = true
end
function base:DisableHalt()
	self.HaltAtEnd = false
end

--#endregion

--#region Thinking

---comment
---@param data PLAYER_EVENT_ITEM_PICKUP
RegisterPlayerEventCallback("item_pickup", function(data)
	if data.item ~= self then return end

	self:ResumeThink()
end)
---comment
---@param data PLAYER_EVENT_ITEM_RELEASED
RegisterPlayerEventCallback("item_released", function(data)
	if data.item ~= self then return end

	self:CloseHint()
	self:PauseThink()
end)

-- function base:StartThinking()
-- 	self:StopThink('ThinkFunc')
-- 	-- self:SetThink(self.ThinkFunc, 'ThinkFunc', 0.1, self)
-- 	self:ResumeThink()
-- 	vLastPos = self:GetAbsOrigin()
-- 	SendToConsole('sv_gameinstructor_disable 0')
-- end
-- function base:StopThinking()
-- 	-- self:StopThink('ThinkFunc')
-- 	self:PauseThink()
-- 	SendToConsole('sv_gameinstructor_disable 1')

-- 	-- Kill all built up dynamic hints
-- 	-- (For some reason killing one hint makes the others end so we do it on drop)
-- 	--print('Killing hints:',#Entities:FindAllByName('magic8ball_dynamic_hint'))
-- 	DoEntFire('magic8ball_dynamic_hint', 'Kill', '', 0, nil, nil)
-- end

function base:Think()

	local time = Time()

	if time - last_hint_time < TIME_BETWEEN_HINTS then
		return 0
	end

	if number_of_shakes > 0 and time - last_shake_time >= TIME_BETWEEN_SHAKES then
		number_of_shakes = 0
		print("reset shakes")
	end

	local ang = GetPhysAngularVelocity(self)
	-- This has issues based on angle it's held
	if ang:Length() >= MIN_ANGULAR_VELOCITY then
		-- Check if movement is opposite of previous
		if ang:Dot(last_shake_ang) < 0.2 then
			number_of_shakes = number_of_shakes + 1
			-- print("ANGLE SHAKE", number_of_shakes)
		end
		last_shake_ang = ang
		last_shake_time = time
	else
		local vel = GetPhysVelocity(self)
		if vel:Length() >= MIN_LINEAR_VELOCITY then
			if vel:Dot(last_shake_vel) < 0 then
				number_of_shakes = number_of_shakes + 1
				-- print("VELOCITY SHAKE", number_of_shakes)
			end
			last_shake_vel = vel
			last_shake_time = time
		end
	end

	if number_of_shakes >= SHAKES_PER_HINT then
		-- print("\nGOT HINT!\n")
		self:ShowContextHint()
		number_of_shakes = 0
		last_hint_time = time
	end

	-- print(GetPhysVelocity(self):Length())
	-- print(GetPhysAngularVelocity(self):Length())

	-- local now = Time()
	-- -- Time between hints
	-- if (now - fLastShake) < TIME_BETWEEN_SHAKES then
	-- 	return 0.5
	-- end

	-- if now - fLastForce > SHAKE_TIMEOUT then
	-- 	iShakeCount = 0
	-- 	fLastForce = now
	-- 	return 0.1
	-- end

	-- local vPos = self:GetAbsOrigin()
	-- local diff = vPos - vLastPos
	-- local forceVector = diff:Length()
	-- local directionSign = vLastDirectionVector:Dot(diff)
	-- if directionSign < 0 then directionSign = -1 else directionSign = 1 end

	-- if forceVector > FORCE_THRESHOLD and directionSign ~= fLastDirectionSign then
	-- 	iShakeCount = iShakeCount + 1
	-- 	if iShakeCount >= SHAKE_COUNT then
	-- 		fLastShake = now
	-- 		iShakeCount = 0

	-- 		self:ShowContextHint()
	-- 	end
	-- end

	-- fLastDirectionSign = directionSign
	-- vLastDirectionVector = diff
	-- vLastPos = vPos
	return 0
end

---Show a hint for the current game context.
function base:ShowContextHint()
	print("Showing context hint")
	local text = self:GetAreaHint()
	prints("Area Hint:",text)
	if text == '' then
		text = self:GetReminderHint()
		prints("Reminder Hint:",text)
	end
	if text == '' then
		text = 'No hints for this area, try somewhere else'
		print(text)
	end

	self:ShowHint(text)
end

function base:CloseHint()
	if panel_is_open then
		self.TextPanel:EntFire("RemoveCSSClass", "NewHint")
		self.TextPanel:EntFire("RemoveCSSClass", "Open")
		self.TextPanel:EntFire("AddCSSClass", "Close")
		panel_is_open = false
	end
end

function base:ShowHint(text)
	-- local t = {
	-- 	'There is something to do in the downstairs bathroom',
	-- 	'Check the closet',
	-- 	'I can tell you all the places the key might be\nif you really don\'t want to look',
	-- 	'The attic key is probably somewhere deeper in the house'
	-- }
	-- text = t[RandomInt(1,#t)]
	if panel_is_open then
		self.TextPanel:EntFire("RemoveCSSClass", "Open")
		self.TextPanel:EntFire("RemoveCSSClass", "NewHint")
		self.TextPanel:EntFire("AddCSSClass", "NewHint")
	else
		panel_is_open = true
		self.TextPanel:EntFire("RemoveCSSClass", "Close")
		self.TextPanel:EntFire("AddCSSClass", "Open")
	end
	self:EmitSound("vinny.hint_popup")
	self.TextPanel:EntFire("SetMessage", text)
	-- self:SetContextThink("CloseHint", function()
	-- 	self:CloseHint()
	-- end, HINT_TIMEOUT)
end

Convars:RegisterCommand("vinny_debug_hint", function()
	-- self:SetOrigin(Player:EyePosition() + Player:EyeAngles():Forward() * 32)
	-- self:EntFire("Sleep")
	self:ShowContextHint()
end, "", 0)
Convars:RegisterCommand("vinny_debug_hint_all_reminders", function()
	for index, value in ipairs(HintReminders) do
		self:AddReminder(index)
	end
end, "", 0)
Convars:RegisterCommand("vinny_debug_hint_grab", function()
	self:Grab(Player.PrimaryHand)
end, "", 0)
