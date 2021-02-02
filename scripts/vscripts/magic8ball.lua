
local FORCE_THRESHOLD = 0.25

--local TIME_THRESHOLD = 100/1000
-- All shaking must be in this time frame
local SHAKE_TIMEOUT = 0.8
--local SHAKE_THROTTLE = 1000/1000
local SHAKE_COUNT = 6
-- Time between hints
local TIME_BETWEEN_HINTS = 4

local fLastTime = 0
local fLastShake = 0
local fLastForce = 0
local iShakeCount = 0
local vLastDirectionVector = Vector(0,0,0)
local fLastDirectionSign = 0
local vLastPos = nil
local bRandomHintsEnabled = true

-- Hint variables
-- 1 = Explore
-- 2 = Hint intro
-- 3 = Milk
-- 4 = Cookies
-- 5 = gifts
-- 6 = Tree
-- 7 = Fridge key
-- 8 = Meat Somber
-- 9 = Meat basement door
-- 10 = Attic
-- 11 = Attic Tree
-- 12 = Pachinko
-- 13 = Credits
-- 14 = Saw
-- 15 = Cookie placement
-- 16 = Milk placement
-- 17 = Digging
-- 18 = Attic tree placement
-- 19 = Gift placement
local Hint = {
	{
		'Explore the house',
		'There are still places you haven\'t explored'
	},
	{
		'I give vague hints when shook!',
		'I help make the game VineProof™!'
	},
	{
		'Santa needs milk to wash down the cookies',
		'Typically milk is found in a fridge'
	},
	{
		'Cookies need to be baked in an oven',
		'Vinny\'s oven can bake ingredients raw'
	},
	{
		'There are 5 gifts hidden in the house',
		'Look in every room for 5 hidden gifts'
	},
	{
		'There is a tree outside to be chopped down',
		'An axe could chop down the tree outside'
	},
	{
		'The fridge key could be anywhere in the kitchen!',
		'Check every kitchen cupboard for a key'
	},
	{
		'Meat\'s gherkins are kept in the fridge',
		'Bringing a gherkin to meat\'s door might help'
	},
	{
		'The basement door can\'t be cleaned without Meat',
		'Meat needs to be brought down to the basement door'
	},
	{
		'A key is needed to open the attic',
		'A key is needed to open the attic'
	},
	{
		'There is one Christmas tree box left in the attic',
		'The attic should have a nice Christmas tree'
	},
	{
		'Yes you do have to play Pachinko',
		'Pachinko isn\'t that hard'
	},
	{
		'Sorry you can\'t skip the credits :)',
		'You\'re a cool person for playing my game :)'
	},
	{
		'(つ◉益◉)つ Don\'t leave me here!',
		'(ง’̀-‘́)ง Put me back in your wrist pocket'
	},
	{
		'Cookies need to be put next to the Christmas tree',
		'You can\'t leave the cookies just anywhere'
	},
	{
		'Don\'t make Santa drink out of the carton...',
		'Put the milk in a glass'
	},
	{
		'That shovel could be useful',
		'Maybe someone was playing in that sandpit outside'
	},
	{
		'The Christmas tree box can be set up near the fireplace',
		'There is a good spot for the Christmas tree box in the living room'
	},
	{
		'Gifts should be put next to the Christmas tree!',
		'A Christmas tree isn\'t complete without gifts'
	}
}
-- Hint layer is a list of numbers which correspond to each index in Hint
local HintLayer = {}
local CurrentHintLayer = 1
local CurrentHintLine = 1


function Activate()
	vLastPos = thisEntity:GetAbsOrigin()
	--print('magic8ball - Activate')
end

function StartThinking()
	thisEntity:StopThink('ThinkFunc')
	thisEntity:SetThink(ThinkFunc, 'ThinkFunc', 0.1)
	vLastPos = thisEntity:GetAbsOrigin()
	print('magic8ball - Start thinking')
end
function StopThinking()
	thisEntity:StopThink('ThinkFunc')
	print('magic8ball - Stop thinking')
end

function AddHintLayer(section)
	--table.insert(HintLayer, section)
	HintLayer[#HintLayer + 1] = section
	CurrentHintLayer = #HintLayer
end
function SetHintLayer(section)
	-- Set hint layer only if has already been added
	for i=1, #HintLayer do
		if HintLayer[i] == section then CurrentHintLayer = section return end
	end
end
function RemoveHintLayer(section)
	--print(#HintLayer, 'hints layers, removing', section)
	local found = nil
	for i=1, #HintLayer do
		if HintLayer[i] == section then
			--print('found hint layer', i)
			found = i
			--HintLayer[i] = nil
			if CurrentHintLayer == i then CurrentHintLayer = #HintLayer - 1 end
			--return
			break
		end
	end
	if found ~= nil then
		--print('removing hint layer', found, 'which is', HintLayer[found])
		table.remove(HintLayer, found)
	end
end
function RemoveTopHintLayer()
	if CurrentHintLayer == #HintLayer then CurrentHintLayer = #HintLayer - 1 end
	HintLayer[#HintLayer] = nil
end
function ShowHint(text)
	--if #HintLayer < 1 then return end
	--print('magic8ball - Showing hint: '..Hint[HintLayer[CurrentHintLayer]][RandomInt(1,2)])
	
	local spawnKeys = {
		hint_caption = text, --string.upper(Hint[HintLayer[CurrentHintLayer]][RandomInt(1,2)])
		hint_start_sound = 'Instructor.StartLesson',
		hint_timeout = TIME_BETWEEN_HINTS..'',
		hint_vr_height_offset = '0',
		--hint_target = 'magic8ball',
		--hint_vr_panel_type = '3'
		origin = thisEntity:GetAbsOrigin().x..' '..thisEntity:GetAbsOrigin().y..' '..thisEntity:GetAbsOrigin().z
	}
	--origin = "115.313 3145.43 0"

	print('magic8ball - showing hint',text)

	local ent = SpawnEntityFromTableSynchronous('env_instructor_vr_hint', spawnKeys)
	SendToConsole('sv_gameinstructor_disable 0')
	DoEntFire('!self', 'FireUser1', '', 0.1, thisEntity, thisEntity)
	DoEntFireByInstanceHandle(ent, 'ShowHint', '', 0.1, thisEntity, thisEntity)
	DoEntFireByInstanceHandle(ent, 'Kill', '', TIME_BETWEEN_HINTS+1, thisEntity, thisEntity)
	thisEntity:SetThink(function() SendToConsole('sv_gameinstructor_disable 1') end, '', TIME_BETWEEN_HINTS+1)
	--DoEntFire('magic8ball_text', 'SetMessage', , 0, thisEntity, thisEntity)
end

function RandomHint()
	local text = 'No hint available'
	if #HintLayer > 0 then
		local r = RandomInt(1,#HintLayer)
		text = Hint[HintLayer[r]][CurrentHintLine]
	end
	ShowHint(string.upper(text))
end

function EnableRandomHints()
	bRandomHintsEnabled = true
end
function DisableRandomHints()
	bRandomHintsEnabled = false
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
		--if iShakeCount >= SHAKE_COUNT and (now - fLastShake) > SHAKE_THROTTLE then
		if iShakeCount >= SHAKE_COUNT then
			fLastShake = now
			iShakeCount = 0
			
			--DoEntFire('!self', 'FireUser1', '', 0, thisEntity, thisEntity)
			print('magic8ball - Shakes completed, resetting')
			--ShowHint()
			if (bRandomHintsEnabled) then
				print('magic8ball - doing random hint')
				RandomHint()
			else
				print('magic8ball - doing top hint')
				ShowHint(string.upper(Hint[HintLayer[CurrentHintLayer]][CurrentHintLine]))
			end
			CurrentHintLine = (CurrentHintLine == 1) and 2 or 1
		end
	end
	fLastDirectionSign = directionSign
	vLastDirectionVector = diff
	vLastPos = vPos
	--fLastTime = now
	return 0.01
end

