
--60,300

---@class Phone : EntityClass
local base, self = entity("Phone")
if self.Initiated then return end


function base:OnReady(loaded)
end

---Amount of time before the quip plays after phone is answered
local QuipDelay = 0.7
local RingDelay = 0
local QuipLengthDefault = 2
local QuipIsPlaying = false

local PhoneRecieverName = 'phone_reciever'
local PhoneHangUpSoundName = 'phone_hangup_snd'
local PhoneRingSoundName = 'phone_ringing_snd'

local function GetQuipLength(name)
	return tonumber(name:match('_([%d%.]+)s$')) or QuipLengthDefault
end

function base:PickRandomQuip()
	local quip_ents = Entities:FindAllByName('phone_quip*')

	if #quip_ents == 0 then return '' end

	-- Randomize quips
	for i = #quip_ents, 2, -1 do
		local j = RandomInt(1, i)
		quip_ents[i], quip_ents[j] = quip_ents[j], quip_ents[i]
	end

	devprint("quips to choose from", #quip_ents)

	-- Pick first quip that hasn't been played
	for _,quip in pairs(quip_ents) do
		devprint("Trying to choose quip "..quip:GetName())
		-- print("What is? ", self:LoadBoolean(quip:GetName(), true))
		if self:LoadBoolean(quip:GetName(), true) then
			devprint("Chose quip "..quip:GetName())
			return quip:GetName()
		end
	end
	return nil
end

---Plays a random quip call.
function base:RandomCall()
	local quip = self:PickRandomQuip()
	if quip == nil or quip == '' then
		self:SaveString("NextQuip", '')
		return
	end
	self:DoCall(quip)
end

function EntityCall(name)
	self:DoCall(name)
end

---Queues up a given `quip` and starts ringing.
---@param quip string
function base:DoCall(quip)
	self:SaveString("NextQuip", quip)
	DoEntFire(PhoneRingSoundName, "StartSound", "", RingDelay, self, self)
	DoEntFire("!self", "FireUser1", "", RingDelay, self, self)
end

function base:PlayQuip()
	local quip_name = self:LoadString("NextQuip")
	if quip_name ==  nil or quip_name == "" then return	end

	if QuipIsPlaying then return end

	local length = GetQuipLength(quip_name)
	DoEntFire(PhoneRingSoundName, "StopSound", "", 0, self, self)
	DoEntFire(quip_name, "StartSound", "", QuipDelay, self, self)
	DoEntFire("phone_end_call", "Trigger", "", length + QuipDelay, self, self)
	QuipIsPlaying = true
	self:SaveBoolean(quip_name, false)
	devprint("Disabling "..quip_name, self:LoadBoolean(quip_name, true))
end

function base:EndCall(data)
	local quip_name = self:LoadString("NextQuip")
	if quip_name == nil or quip_name == "" then return end

	DoEntFire(PhoneRingSoundName, "StopSound", "", 0, self, self)
	DoEntFire(quip_name, "StopSound", "", 0, self, self)
	self:SaveString("NextQuip", "")
	QuipIsPlaying = false
end

function base:CancelCall()
	self:EndCall()
end


