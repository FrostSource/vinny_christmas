

---@class SoundOnBox : EntityClass
local base, self = entity("SoundOnBox")
if self.Initiated then return end

---@type EntityHandle
base.SoundEntity = nil
---@type string
base.Sound = ""

---Called automatically on activate.
---Any self values set here are automatically saved.
---@param loaded boolean
function base:OnReady(loaded)
	if not loaded then
		self.SoundEntity = SpawnEntityFromTableSynchronous("prop_dynamic_override",
		{
			model="models/props/zoo/tiger_toy.vmdl";
			rendermode = "kRenderNone";
			solid = "0";
			disableshadows = "1";
		})
	end
end
---Called automatically on spawn.
---Any self values set here are automatically saved.
---@param spawnkeys CScriptKeyValues
function base:OnSpawn(spawnkeys)
	self.Sound = spawnkeys:GetValue('sound')
	-- print(self.Sound)
end

--TODO: Consider saving sound state.

function base:StartSound()
	-- print("Playing", self.Sound)
	self.SoundEntity:EmitSound(self.Sound)
	self:ResumeThink()
end
function base:EndSound()
	-- print(self.Sound)
	-- print(type(self.Sound))
	self.SoundEntity:StopSound(self.Sound)
	self:PauseThink()
end

function base:Think()
	local pos = CalcClosestPointOnEntityOBB(self, Player:EyePosition())
	self.SoundEntity:SetOrigin(pos)
	return 0
end

---@param context CScriptPrecacheContext
function Precache(context)
	PrecacheModel("models/props/zoo/tiger_toy.vmdl", context)
end
