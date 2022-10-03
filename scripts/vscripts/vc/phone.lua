
--60,300

local QuipDelay = 1
local RingDelay = 0
local QuipLengthDefault = 2
local QuipIsPlaying = false

local PhoneRecieverName = 'phone_reciever'
local PhoneHangUpSoundName = 'phone_hangup_snd'
local PhoneRingSoundName = 'phone_ringing_snd'

function GetQuipLength(name)
	return tonumber(name:match('_([%d%.]+)s$')) or QuipLengthDefault
end

function PickRandomQuip()
	local quipEnts = Entities:FindAllByName('phone_quip*')
	
	if #quipEnts == 0 then return '' end
	for i = #quipEnts, 2, -1 do
		local j = RandomInt(1, i)
		quipEnts[i], quipEnts[j] = quipEnts[j], quipEnts[i]
	end
	
	for _,quip in pairs(quipEnts) do
		if thisEntity:Attribute_GetIntValue(quip:GetName(), 0) == 0 then
			return quip:GetName()
		end
	end
	return nil
end

function RandomCall()
	local quip = PickRandomQuip()
	if quip == nil then
		return
	end
	if quip == '' then
		return
	end
	DoCall(quip)
end

function EntityCall(name)
	DoCall(name)
end

function DoCall(quip)
	thisEntity:SetContext('NextQuip', quip, 0)
	DoEntFire(PhoneRingSoundName, 'StartSound', '', RingDelay, thisEntity, thisEntity)
	DoEntFire('!self', 'FireUser1', '', RingDelay, thisEntity, thisEntity)
end

function PlayQuip()
	local quip = thisEntity:GetContext('NextQuip')
	if quip ==  nil or quip == '' then
		return
	end
	
	if QuipIsPlaying then return end
	
	local length = GetQuipLength(quip)
	DoEntFire(PhoneRingSoundName, 'StopSound', '', 0, thisEntity, thisEntity)
	DoEntFire(quip, 'StartSound', '', QuipDelay, thisEntity, thisEntity)
	DoEntFire('phone_end_call', 'Trigger', '', length+QuipDelay, thisEntity, thisEntity)
	QuipIsPlaying = true
	thisEntity:Attribute_SetIntValue(quip, 1)
end

function EndCall(data)
	local quip = thisEntity:GetContext('NextQuip')
	
	if quip == nil or quip == '' then return end
	
	DoEntFire(PhoneRingSoundName, 'StopSound', '', 0, thisEntity, thisEntity)
	DoEntFire(quip, 'StopSound', '', 0, thisEntity, thisEntity)
	thisEntity:SetContext('NextQuip', '', 0)
	QuipIsPlaying = false
end

function CancelCall()
	EndCall()
end


