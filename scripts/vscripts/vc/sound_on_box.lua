

local ThinkDelay = 0.1

function Spawn(spawnkeys)
	SoundName = '*'..spawnkeys:GetValue('soundentity')
	SourceName = '*'..spawnkeys:GetValue('sourceentity')
	-- This is important for loaded save files
	if SoundName ~= '*' then
		thisEntity:SetContext('soundname', SoundName, 0) end
	if SourceName ~= '*' then
		thisEntity:SetContext('sourcename', SourceName, 0) end
	
	thisEntity:Attribute_SetIntValue('IsPlaying', 0)
end

function Activate()
	-- This is important for loaded save files
	if thisEntity:GetContext('soundname') ~= '' then
		SoundName = thisEntity:GetContext('soundname')
	end
	if thisEntity:GetContext('sourcename') ~= '' then
		SourceName = thisEntity:GetContext('sourcename')
	end
	
	SoundEntity = Entities:FindByName(nil, SoundName)
	SourceEntity = Entities:FindByName(nil, SourceName)
	
	if thisEntity:Attribute_GetIntValue('IsPlaying', 0) == 1 then
		StartSound()
	end
end

function StartSound()
	thisEntity:SetThink(UpdateAudio, 'UpdateAudio', ThinkDelay)
	DoEntFireByInstanceHandle(SoundEntity, 'StartSound', '', 0, thisEntity, thisEntity)
	thisEntity:Attribute_SetIntValue('IsPlaying', 1)
end
function StopSound()
	thisEntity:StopThink('UpdateAudio')
	DoEntFireByInstanceHandle(SoundEntity, 'StopSound', '', 0, thisEntity, thisEntity)
	thisEntity:Attribute_SetIntValue('IsPlaying', 0)
end

function UpdateAudio()
	local pos = CalcClosestPointOnEntityOBB(SourceEntity, GetListenServerHost():EyePosition())
	thisEntity:SetOrigin(pos)
	return ThinkDelay
end
