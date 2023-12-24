--[[
	This is a class script, not an entity script!
]]
---@class HintBall : HintPanel
---@field HintCallback fun(self: HintBall, area_index: integer, line: integer)|nil
local base, _, super, private = entity("HintBall", "vc.hint_panel")
-- if self and self.Initiated then return end

base.__HintReminders = {}
base.__HintAreas = {}

---@type table<integer,integer>
base.HintAreaIndex = {}
---@type integer[]
base.HintAreaStack = {}
---@type integer[]
base.HintReminderStack = {}
---@type integer
base.ReminderStackIndex = 1
---Consider making this not save
---@type integer
base.PreviousArea = -1

base.HaltAtEnd = false
base.IsHintBall = true


---Seconds before another hint can be displayed.
local TIME_BETWEEN_HINTS = 0.75
---Seconds in which each shake movement must be made.
local TIME_BETWEEN_SHAKES = 0.2
---Number of shakes required to show a hint.
local SHAKES_PER_HINT = 6

local MIN_ANGULAR_VELOCITY = 17
local MIN_LINEAR_VELOCITY = 21

base.__last_shake_ang = Vector()
base.__last_shake_vel = Vector()
base.__last_shake_time = 0
base.__last_hint_time = 0
base.__number_of_shakes = 0



--#region Areas

---Adds a hint area by index.
---@param index integer
function base:AddArea(index)
	if not self:HintAreaExistsInStack(index) then
		-- prints(self:GetName()..":", "Add area", index)
		self:RemoveArea(index)
		self.HintAreaStack[#self.HintAreaStack + 1] = index
	end
	self:Save()
end
-- private.AddArea = function(index) self:AddArea(index) end
private.AddArea = base.AddArea

---Removes a hint area by index.
---@param index integer
function base:RemoveArea(index)
	for i=1, #self.HintAreaStack do
		if self.HintAreaStack[i] == index then
			-- prints(self:GetName()..":", "Remove area", index)
			table.remove(self.HintAreaStack, i)
			break
		end
	end
	self:Save()
end
-- private.RemoveArea = function(index) self:RemoveArea(index) end
private.RemoveArea = base.RemoveArea

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

	local area_index = self.HintAreaStack[#self.HintAreaStack]
	local area = self.__HintAreas[area_index]
	local line = self.HintAreaIndex[area_index] or 1

	-- Don't increment if player has changed area, Increment hint line if not halting
	if self.PreviousArea == area_index then

		if (not self.HaltAtEnd or line < #area) then
			line = line + 1

			-- Reset if at end of hints
			if line > #area then
				line = 1
			end
		end

	end

	self.HintAreaIndex[area_index] = line
	self.PreviousArea = area_index

	if self.HintCallback then
		self:HintCallback(area_index, line)
	end

	print("area[line]", area[line])
	print("area", area)
	print("area_index", area_index)
	print("line", line)
	print("#area", #area)
	return area[line] .. "\n" .. line .. "/" .. #area
end

--#endregion

--#region Reminders

function base:AddReminder(index)
	if not self:HintReminderExistsInStack(index) then
		-- prints(self:GetName()..":", "Add reminder", index)
		self.HintReminderStack[#self.HintReminderStack + 1] = index
	end
	self:Save()
end
-- private.AddReminder = function(index) self:AddReminder(index) end
private.AddReminder = base.AddReminder

function base:RemoveReminder(index)
	local found = nil
	for i=1, #self.HintReminderStack do
		if self.HintReminderStack[i] == index then
			-- prints(self:GetName()..":", "Removing reminder", index)
			found = i
			break
		end
	end

	if found ~= nil then
		table.remove(self.HintReminderStack, found)
	end
	self:Save()
end
-- private.RemoveReminder = function(index) self:RemoveReminder(index) end
private.RemoveReminder = base.RemoveReminder

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
	return self.__HintReminders[self.HintReminderStack[self.ReminderStackIndex]]
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
	-- if data.item ~= self then return end
	local item = data.item--[[@as HintBall]]
	if not item.IsHintBall then return end

	item:ResumeThink()
	-- item:Delay(function()
	-- 	item:HideHint()
	-- end, 0.1)
end)
---comment
---@param data PLAYER_EVENT_ITEM_RELEASED
RegisterPlayerEventCallback("item_released", function(data)
    -- if data.item ~= self then return end
	local item = data.item--[[@as HintBall]]
    if not item.IsHintBall then return end

    print("Ball dropped")

	item:HideHint()
	item:ForceHide(true)
    item:PauseThink()
	-- item:Delay(function()
	-- 	item:HideHint()
	-- end, 0.1)
end)

function base:Think()

	local time = Time()

	if time - self.__last_hint_time < TIME_BETWEEN_HINTS then
		return 0
	end

	if self.__number_of_shakes > 0 and time - self.__last_shake_time >= TIME_BETWEEN_SHAKES then
		self.__number_of_shakes = 0
		print("reset shakes")
	end

	local ang = GetPhysAngularVelocity(self)
	-- This has issues based on angle it's held
	if ang:Length() >= MIN_ANGULAR_VELOCITY then
		-- Check if movement is opposite of previous
		if ang:Dot(self.__last_shake_ang) < 0.2 then
			self.__number_of_shakes = self.__number_of_shakes + 1
			-- print("ANGLE SHAKE", number_of_shakes)
		end
		self.__last_shake_ang = ang
		self.__last_shake_time = time
	else
		local vel = GetPhysVelocity(self)
		if vel:Length() >= MIN_LINEAR_VELOCITY then
			if vel:Dot(self.__last_shake_vel) < 0 then
				self.__number_of_shakes = self.__number_of_shakes + 1
				-- print("VELOCITY SHAKE", number_of_shakes)
			end
			self.__last_shake_vel = vel
			self.__last_shake_time = time
		end
	end

	if self.__number_of_shakes >= SHAKES_PER_HINT then
		-- print("\nGOT HINT!\n")
		self:ShowContextHint()
		self.__number_of_shakes = 0
		self.__last_hint_time = time
	end

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

	self:ForceHide(false)
	self:ShowHint(text)
end


return base