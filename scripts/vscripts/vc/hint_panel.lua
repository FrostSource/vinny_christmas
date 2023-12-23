--[[
	This is a class script, not an entity script!
]]
---@class HintPanel : EntityClass
local base, self = entity("HintPanel")
if self and self.Initiated then return end

---@type EntityHandle
base.TextPanel = nil

---@type boolean
base.PanelIsOpen = false

---Seconds that a hint is shown before disappearing.
base.HintTimeout = 5.5

-- ---Called automatically on spawn.
-- ---@param spawnkeys CScriptKeyValues
-- function base:OnSpawn(spawnkeys)
-- end

---Called automatically on activate.
---Any self values set here are automatically saved.
---@param loaded boolean
function base:OnReady(loaded)
    if not loaded then
        if self:GetClassname() == "point_clientui_world_text_panel" then
            self.TextPanel = self
        else
    		self.TextPanel = self:FindInPrefab("hint_panel")--[[@as EntityHandle]]
        end
	else
		self.PanelIsOpen = false
		self.TextPanel:EntFire("RemoveCSSClass", "Open")
		self.TextPanel:EntFire("RemoveCSSClass", "NewHint")
	end
end

---Shows the hint and optionally sets the text.
---@param text? string
function base:ShowHint(text)
	if self.PanelIsOpen then
		self.TextPanel:EntFire("RemoveCSSClass", "Open")
		self.TextPanel:EntFire("RemoveCSSClass", "NewHint")
		self.TextPanel:EntFire("AddCSSClass", "NewHint")
	else
		self.PanelIsOpen = true
		self.TextPanel:EntFire("RemoveCSSClass", "Close")
		self.TextPanel:EntFire("AddCSSClass", "Open")
	end
	self:EmitSound("vinny.hint_popup")
    if type(text) == "string" then
    	self.TextPanel:EntFire("SetMessage", text)
    end
    if self.HintTimeout > -1 then
        self:SetContextThink("CloseHint", function()
            self:HideHint()
        end, self.HintTimeout)
    end
end

function base:HideHint()
	if self.PanelIsOpen then
		self.TextPanel:EntFire("RemoveCSSClass", "NewHint")
		self.TextPanel:EntFire("RemoveCSSClass", "Open")
		self.TextPanel:EntFire("AddCSSClass", "Close")
		self.PanelIsOpen = false
        self:FireOutput("OnUser2", self, self, nil, 0)
	end
end

function base:DisableTimeout()
    self.HintTimeout = -1
end
function base:EnableTimeout()
    self.HintTimeout = 5.5
end

function base:ForceHide(hidden)
	if hidden then
		self.TextPanel:EntFire("AddCSSClass", "ForceHide")
	else
		self.TextPanel:EntFire("RemoveCSSClass", "ForceHide")
	end
end

---
---Parent the entity to the I/O caller passed in.
---
---@param io TypeIOInvoke
function base:AttachToCaller(io)
    self:SetOrigin(io.caller:GetCenter() + Vector(0, 0, 5))
    self:SetParent(io.caller, "")
end

return base