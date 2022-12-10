
if thisEntity:GetClassname() ~= "prop_door_rotating_physics" then return end

---@class ShedDoor : EntityClass
local base, self = entity("ShedDoor")
if self.Initiated then return end

---@type EntityHandle[]
base.handles = {}

function base:OnReady(loaded)
	local handlepos = self:GetAttachmentOrigin(self:ScriptLookupAttachment("handle"))
	local handles = Entities:FindAllByClassnameWithin('prop_animinteractable', handlepos, 32)
	for i,handle in ipairs(handles) do
		self.handles[i] = handle
		handle:SaveVector("StartPos", handle:GetLocalOrigin())
	end
end

function base:HideHandles()
	local offset = Vector(0,-500,0)
	for _,handle in ipairs(self.handles) do
		handle:SetLocalOrigin(offset)
	end
end

function base:RestoreHandles()
	for _,handle in ipairs(self.handles) do
		handle:SetLocalOrigin(handle:LoadVector("StartPos"))
	end
end