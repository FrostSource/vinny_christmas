
local FORCE_THRESHOLD = 0.25

-- All shaking must be in this time frame
local SHAKE_TIMEOUT = 0.8
local SHAKE_COUNT = 5
-- Time between hints
local TIME_BETWEEN_HINTS = 4.5

local fLastShake = 0
local fLastForce = 0
local iShakeCount = 0
local vLastDirectionVector = Vector(0,0,0)
local fLastDirectionSign = 0
local vLastPos = nil

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
local HintAreas = {
	{
		'I give nearby hints when shook!',
		'Put me in your wrist pocket\nI help make the game VineProof™'
	},

	{
		'There is a gift nearby...',
		'Check the closet'
	},
	{
		'There is a gift nearby...',
		'Check the cupboards'
	},
	{
		'There is a gift nearby...',
		'Vinny might have left one in the car while drunk'
	},
	{
		'There is a gift nearby...',
		'Does Meat have a secret under his room?'
	},
	{
		'There is a gift nearby...',
		'What\'s down that hole?'
	},

	{
		'A useful tool could unclog the toilet',
		'Vinny keeps a plunger in one of the bathrooms',
		'It might take a few pumps'
	},

	{
		'Maybe you should climb the drain pipe nearby',
		'Climb the pipe all the way to the top'
	},

	{
		'The tree needs an axe to be chopped down',
		'Vinny keeps an axe in his shed',
		'Maybe someone buried the handle nearby',
		'A shovel would be needed to dig the dirt pit by the tree',
		'The handle from the pit might open the shed door',
		'The tree just needs to be hit in the right spots'
	},

	{
		'Meat will need to clean the door handle',
		'Meat should be brought down from his room'
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
}

HintAreaIndexSave = HintAreaIndexSave or {}
HintAreaStack = HintAreaStack or {}
HintReminderStack = HintReminderStack or {}
CurrentHintLine = CurrentHintLine or 1
--LastHintArea = LastHintArea or ''
HaltAtEnd = HaltAtEnd or false

function Activate()
	vLastPos = thisEntity:GetAbsOrigin()
	-- Init index saving table (should save between loads using attributes?)
	for i = 1, #HintAreas do
		HintAreaIndexSave[i] = 0
	end
end


--#region Areas

function AddArea(index)
	RemoveArea(index)
		HintAreaStack[#HintAreaStack + 1] = index
end

function RemoveArea(index)
	for i=1, #HintAreaStack do
		if HintAreaStack[i] == index then
			table.remove(HintAreaStack, i)
			break
		end
	end
end

function HintAreaExistsInStack(index)
	for i=1, #HintAreaStack do
		if HintAreaStack[i] == index then
			return true
		end
	end
	return false
end

function GetAreaHint()
	-- Return blank if no area hints, so reminder can be shown
	if #HintAreaStack == 0 then return '' end

	local area = HintAreas[HintAreaStack[#HintAreaStack]]
	local line = HintAreaIndexSave[HintAreaStack[#HintAreaStack]]

	-- Increment hint line if not halting
	if not HaltAtEnd or line < #area then
		
		-- Reset if at end of hints
		if line >= #area then
			line = 0
		end

		line = line + 1
		HintAreaIndexSave[HintAreaStack[#HintAreaStack]] = line

	end

	return area[line]
end

--#endregion

--#region Reminders

function AddReminder(index)
	if not HintReminderExistsInStack(index) then
		HintReminderStack[#HintReminderStack + 1] = index
	end
end

function RemoveReminder(index)
	local found = nil
	for i=1, #HintReminderStack do
		if HintReminderStack[i] == index then
			found = i
			break
		end
	end

	if found ~= nil then
		table.remove(HintReminderStack, found)
	end
end

function HintReminderExistsInStack(index)
	for i=1, #HintReminderStack do
		if HintReminderStack[i] == index then
			return true
		end
	end
	return false
end

function GetReminderHint()
	-- Return if no area hints so fallback can be shown
	if #HintReminderStack == 0 then return '' end

	-- Re-shuffle and reset reminders if at end
	if CurrentHintLine >= #HintReminderStack then
		ShuffleReminderStack()
		CurrentHintLine = 0
	end

	-- Increment hint line and return hint text
	CurrentHintLine = CurrentHintLine + 1
	return HintReminders[HintReminderStack[CurrentHintLine]]
end

function ShuffleReminderStack()
	-- Just return if not enough reminders to shuffle
	if #HintReminderStack < 2 then return false end

	for i = #HintReminderStack, 2, -1 do
		local j = RandomInt(1, i)
		HintReminderStack[i], HintReminderStack[j] = HintReminderStack[j], HintReminderStack[i]
	end

	return true
end

--#endregion

--#region Other

function EnableHalt()
	HaltAtEnd = true
end
function DisableHalt()
	HaltAtEnd = false
end

--#endregion

--#region Thinking

function StartThinking()
	thisEntity:StopThink('ThinkFunc')
	thisEntity:SetThink(ThinkFunc, 'ThinkFunc', 0.1)
	vLastPos = thisEntity:GetAbsOrigin()
end
function StopThinking()
	thisEntity:StopThink('ThinkFunc')
end

function ThinkFunc()
	
	local now = Time()
	-- Time between hints
	if (now - fLastShake) < TIME_BETWEEN_HINTS then
		return TIME_BETWEEN_HINTS
	end
	
	if now - fLastForce > SHAKE_TIMEOUT then
		iShakeCount = 0
		fLastForce = now
		return 0.1
	end
	
	local vPos = thisEntity:GetAbsOrigin()
	local diff = vPos - vLastPos
	local forceVector = diff:Length()
	local directionSign = vLastDirectionVector:Dot(diff)
	if directionSign < 0 then directionSign = -1 else directionSign = 1 end
	
	if forceVector > FORCE_THRESHOLD and directionSign ~= fLastDirectionSign then
		iShakeCount = iShakeCount + 1
		if iShakeCount >= SHAKE_COUNT then
			fLastShake = now
			iShakeCount = 0
			
			local text = GetAreaHint()
			if text == '' then
				text = GetReminderHint()
			end
			if text == '' then
				text = 'No hints for this area'
			end

			ShowHint(text)
		end
	end

	fLastDirectionSign = directionSign
	vLastDirectionVector = diff
	vLastPos = vPos
	return 0
end

--#endregion

--#region Displaying

function ShowHint(text)
	local spawnKeys = {
		hint_caption = text,
		hint_start_sound = 'Instructor.StartLesson',
		hint_timeout = TIME_BETWEEN_HINTS..'',
		hint_vr_height_offset = '0',
		origin = thisEntity:GetAbsOrigin().x..' '..thisEntity:GetAbsOrigin().y..' '..thisEntity:GetAbsOrigin().z
	}

	local ent = SpawnEntityFromTableSynchronous('env_instructor_vr_hint', spawnKeys)
	SendToConsole('sv_gameinstructor_disable 0')
	DoEntFire('!self', 'FireUser1', '', 0.1, thisEntity, thisEntity)
	DoEntFireByInstanceHandle(ent, 'ShowHint', '', 0.1, thisEntity, thisEntity)
	DoEntFireByInstanceHandle(ent, 'Kill', '', TIME_BETWEEN_HINTS, thisEntity, thisEntity)
	thisEntity:SetThink(function() SendToConsole('sv_gameinstructor_disable 1') end, '', TIME_BETWEEN_HINTS)
end

--#endregion
