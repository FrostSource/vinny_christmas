


-- Hint reminders:
-- 1 = Explore
-- 2 = Cookies
-- 3 = Milk
-- 4 = Attic tree
-- 5 = Attic tree placement
-- 6 = Attic key
-- 7 = Santa crash
-- 8 = Gift placement
local HintReminders = {
	'There are no hints for this area',
	'There are still places you haven\'t explored',
	'Santa needs cookies by the fireplace',
	'Santa needs milk to wash down the cookies',
	'There is one Christmas tree box left in the attic',
	'Put the Christmas tree box in the spot near the fireplace',
	'There is still a prize waiting in the basement',
	'Find out what that noise on the roof was',
	'Gifts should be put next to the Christmas tree'
}

-- Hint areas:
-- 1 = Hint intro
-- 2 = Gift Vinny
-- 3 = Gift kitchen
-- 4 = Gift car
-- 5 = Gift Joel/Meat
-- 6 = Gift bunker
-- 7 = Toilet unclog
-- 8 = Pipe climbing
-- 9 = Tree outside
-- 10 = Basement door handle
-- 11 = Fridge key
-- 12 = Baking cookies
-- 13 = Pouring milk
-- 14 = Milk placement
-- 15 = Pachinko
-- 16 = Attic key
-- 17 = Meat somber
-- 18 = Attic maze
-- 19 = Saw main
-- 20 = Saw grenade puzzle
-- 21 = Credits
-- 22 = Basement trap door
-- 23 = Don't be pussy
-- 24 = Oven wait
-- 25 = Bunker
-- 26 = Christmas complete
-- 27 = Front door
-- 28 = Kitchen door
-- 29 = Feeding Meat
-- 30 = Higgs corridor
local HintAreas = {
	{
		'I give hints about the area when shook! Shake again!',
		'Each shake will give a more detailed hint.',
		'Put me in your wrist pocket\nI help make the game VineProof™'
	},

	{
		'There is a gift nearby...',
		'Check the closet',
		'Look at the top shelf of the bedroom closet'
	},
	{
		'There is a gift nearby...',
		'Check the cupboards',
		'Check the cupboard next to the cat clock'
	},
	{
		'There is a gift nearby...',
		'Vinny might have left one in the car while drunk'
	},
	{
		'There is a gift nearby...',
		'A horrid smell is rising into the air...',
		'Does Meat have a secret under his room?',
		'Move boxes and break the hidden boards'
	},
	{
		'There is a gift nearby...',
		'What\'s down that hole?',
		'Use the wheel to raise the bucket'
	},

	{
		'A useful tool could unclog the toilet',
		'Vinny keeps a plunger in one of the bathrooms',
		'It might take a few plunges'
	},

	{
		'How could you climb to the roof?',
		'The drain pipes seem sturdy',
		'There is a drain pipe near the front door',
		'Climb all the way to the top'
	},

	{
		'The tree needs an axe to be chopped down',
		'Where would Vinny keep an axe?',
		'Vinny keeps an axe in his shed',
		'Maybe someone buried the handle nearby',
		'A shovel could dig the dirt pit by the tree',
		'The handle from the pit might open the shed door',
		'The tree just needs to be hit in the right spots'
	},

	{
		'Meat will need to clean the door handle',
		'Meat should be brought down from his room',
		'Bring Meat back here after feeding him'
	},

	{
		'The fridge key is somewhere in the kitchen',
		'I can tell you all the places the key might be\nif you really don\'t want to look',
		'Under the sink',
		'Third drawer down next to the sink',
		'Third drawer down next to the fridge',
		'Bottom drawer of the big cupboard'
	},

	{
		'There are baking instructions near the oven',
		'3 ingredients are needed to bake cookies',
		'Find flour, sugar and butter',
		'They all need to be put in the oven',
		'The oven needs to be turned on'
	},

	{
		'Milk is typically found in a fridge',
		'Pour the milk into a glass',
		'Put glass of milk by the fireplace'
	},

	{
		'Don\'t make Santa drink out of the carton...'
	},

	{
		'Yes you do have to play Pachinko',
		'Pachinko is played by throwing balls over the top',
		'Pachinko isn\'t that hard',
		'Don\'t worry you\'ll get a free pass eventually'
	},

	{
		'The attic needs a key to open',
		'The attic key is probably somewhere deeper in the house',
	},

	{
		'Bringing a gherkin to meat\'s door might help',
		'Meat\'s gherkins are kept in the fridge'
	},

	{
		'One of these boxes up here has to be important right?',
		'Come on you love mazes!',
		'Just a bit of corner turning',
		'From ladder:\nR3,L2,R2,F,L2'
	},

	{
		'(つ◉益◉)つ Don\'t leave me here!',
		'(ง’̀-‘́)ง Put me back in your wrist pocket'
	},

	{
		'Grenades could be useful here',
		'Try throwing grenades in fence holes',
		'A switch needs to be blown into the air and caught',
		'A door needs to be blown open from behind',
		'The switch needs to be installed in the power mains'
	},

	{
		'Sorry you can\'t skip the credits :)',
		'You\'re a cool person for playing my game :)'
	},

	{
		'Something is holding these doors shut tight',
		'You\'ll need to examine it from the other side',
		'There might be a way through the kitchen'
	},

	{
		'Don\'t be a pussy'
	},

	{
		'If all the ingredients are in you just have to wait',
		'The cookies need time to bake'
	},

	{
		'It\'s so dark here, maybe there\'s a light you can use',
		'Looks like a way out next to the locker',
		'The barrels need to be pushed out of the way'
	},

	{
		'Everything is ready for Christmas tomorrow!',
		'Time to sit back and relax'
	},

	{
		'The code for the door must be kept somewhere in the house',
		'The door code has been put where no one will stick their hands',
		'Unclog the downstairs toilet to find the front door code'
	},

	{
		'The door appears to be blocked by barrels',
		'The door only opens outwards so the barrels need to be moved',
		'You will need to get to the other side to move the barrels'
	},

	{
		'Meat looks sad and hungry',
		'What does Meat like to eat?',
		'Feed Meat a gherkin from the fridge',
	},

	{
		'Return it',
		'He will return',
	}
}

---@class HintBall : EntityClass
local base, self = entity("HintBall")
if self.Initiated then return end

self.HintAreaIndexSave = {}
self.HintAreaStack = {}
self.HintReminderStack = {}
self.CurrentHintLine = 1
--LastHintArea = LastHintArea or ''
self.HaltAtEnd = false

local FORCE_THRESHOLD = 0.25

-- All shaking must be in this time frame
local SHAKE_TIMEOUT = 0.8
local SHAKE_COUNT = 5
-- Time between hints
local TIME_BETWEEN_HINTS = 4.5
local TIME_BETWEEN_SHAKES = 1.5

local fLastShake = 0
local fLastForce = 0
local iShakeCount = 0
local vLastDirectionVector = Vector(0,0,0)
local fLastDirectionSign = 0
-- local vLastPos = nil

function self:OnReady(loaded)
	-- vLastPos = thisEntity:GetAbsOrigin()
	-- Init index saving table (should save between loads using attributes?)
	for i = 1, #HintAreas do
		self.HintAreaIndexSave[i] = 0
	end
end


--#region Areas

function self:AddArea(index)
	self:RemoveArea(index)
		self.HintAreaStack[#self.HintAreaStack + 1] = index
end

function self:RemoveArea(index)
	for i=1, #self.HintAreaStack do
		if self.HintAreaStack[i] == index then
			table.remove(self.HintAreaStack, i)
			break
		end
	end
end

function self:HintAreaExistsInStack(index)
	for i=1, #self.HintAreaStack do
		if self.HintAreaStack[i] == index then
			return true
		end
	end
	return false
end

function self:GetAreaHint()
	-- Return blank if no area hints, so reminder can be shown
	if #self.HintAreaStack == 0 then return '' end

	local area = HintAreas[self.HintAreaStack[#self.HintAreaStack]]
	local line = self.HintAreaIndexSave[self.HintAreaStack[#self.HintAreaStack]]

	-- Increment hint line if not halting
	if not self.HaltAtEnd or line < #area then
		
		-- Reset if at end of hints
		if line >= #area then
			line = 0
		end

		line = line + 1
		self.HintAreaIndexSave[self.HintAreaStack[#self.HintAreaStack]] = line

	end

	return area[line]
end

--#endregion

--#region Reminders

function self:AddReminder(index)
	if not self:HintReminderExistsInStack(index) then
		self.HintReminderStack[#self.HintReminderStack + 1] = index
	end
end

function self:RemoveReminder(index)
	local found = nil
	for i=1, #self.HintReminderStack do
		if self.HintReminderStack[i] == index then
			found = i
			break
		end
	end

	if found ~= nil then
		table.remove(self.HintReminderStack, found)
	end
end

function self:HintReminderExistsInStack(index)
	for i=1, #self.HintReminderStack do
		if self.HintReminderStack[i] == index then
			return true
		end
	end
	return false
end

function self:GetReminderHint()
	-- Return if no area hints so fallback can be shown
	if #self.HintReminderStack == 0 then return '' end

	-- Re-shuffle and reset reminders if at end
	if self.CurrentHintLine >= #self.HintReminderStack then
		self:ShuffleReminderStack()
		self.CurrentHintLine = 0
	end

	-- Increment hint line and return hint text
	self.CurrentHintLine = self.CurrentHintLine + 1
	return HintReminders[self.HintReminderStack[self.CurrentHintLine]]
end

function self:ShuffleReminderStack()
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

function self:EnableHalt()
	self.HaltAtEnd = true
end
function self:DisableHalt()
	self.HaltAtEnd = false
end

--#endregion

--#region Thinking

function self:StartThinking()
	self:StopThink('ThinkFunc')
	-- self:SetThink(self.ThinkFunc, 'ThinkFunc', 0.1, self)
	self:ResumeThink()
	vLastPos = self:GetAbsOrigin()
	SendToConsole('sv_gameinstructor_disable 0')
end
function self:StopThinking()
	-- self:StopThink('ThinkFunc')
	self:PauseThink()
	SendToConsole('sv_gameinstructor_disable 1')

	-- Kill all built up dynamic hints
	-- (For some reason killing one hint makes the others end so we do it on drop)
	--print('Killing hints:',#Entities:FindAllByName('magic8ball_dynamic_hint'))
	DoEntFire('magic8ball_dynamic_hint', 'Kill', '', 0, nil, nil)
end

function self:Think()

	local now = Time()
	-- Time between hints
	if (now - fLastShake) < TIME_BETWEEN_SHAKES then
		return 0.5
	end

	if now - fLastForce > SHAKE_TIMEOUT then
		iShakeCount = 0
		fLastForce = now
		return 0.1
	end

	local vPos = self:GetAbsOrigin()
	local diff = vPos - vLastPos
	local forceVector = diff:Length()
	local directionSign = vLastDirectionVector:Dot(diff)
	if directionSign < 0 then directionSign = -1 else directionSign = 1 end

	if forceVector > FORCE_THRESHOLD and directionSign ~= fLastDirectionSign then
		iShakeCount = iShakeCount + 1
		if iShakeCount >= SHAKE_COUNT then
			fLastShake = now
			iShakeCount = 0

			local text = self:GetAreaHint()
			if text == '' then
				text = self:GetReminderHint()
			end
			if text == '' then
				text = 'No hints for this area'
			end

			self:ShowHint(text)
		end
	end

	fLastDirectionSign = directionSign
	vLastDirectionVector = diff
	-- vLastPos = vPos
	return 0
end

--#endregion

--#region Displaying

function self:ShowHint(text)
	local spawnKeys = {
		targetname = 'magic8ball_dynamic_hint',
		hint_caption = text,
		hint_start_sound = 'Instructor.StartLesson',
		hint_timeout = TIME_BETWEEN_HINTS..'',
		hint_vr_height_offset = '0',
		origin = thisEntity:GetAbsOrigin().x..' '..thisEntity:GetAbsOrigin().y..' '..thisEntity:GetAbsOrigin().z
	}

	local ent = SpawnEntityFromTableSynchronous('env_instructor_vr_hint', spawnKeys)
	--SendToConsole('sv_gameinstructor_disable 0')
	--thisEntity:StopThink('disable_hint')
	DoEntFire('!self', 'FireUser1', '', 0.1, self, self)
	DoEntFireByInstanceHandle(ent, 'ShowHint', '', 0, self, self)
	--DoEntFireByInstanceHandle(ent, 'EndHint', '', TIME_BETWEEN_HINTS, thisEntity, thisEntity)
	--DoEntFireByInstanceHandle(ent, 'Kill', '', TIME_BETWEEN_HINTS+2, thisEntity, thisEntity)
	--thisEntity:SetThink(function() SendToConsole('sv_gameinstructor_disable 1') end, 'disable_hint', TIME_BETWEEN_HINTS)
end

--#endregion
