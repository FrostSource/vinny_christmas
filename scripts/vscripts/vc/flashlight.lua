---@class Flashlight : EntityClass
local base, self = entity("Flashlight")
print("FHASLIGHTL")
if self and self.Initiated then return end

---@type EntityHandle?
base.Light = nil

---@type EntityHandle?
base.Toggler = nil

local BUTTON_SOUND = "Grabbity.CalibrationClick"

---Called automatically on activate.
---Any self values set here are automatically saved
---@param loaded boolean
function base:OnReady(loaded)
    if not loaded then
        self.Light = Entities:FindInPrefab(self, "light")
        self.Toggler = Entities:FindInPrefab(self, "flashlight_is_on")
    end
end

function base:Toggle()
    self.Toggler:EntFire("ToggleTest")
end

Input:TrackButton(16)
Input:RegisterCallback("press", -1, 16, 1, function(data)
    ---@cast data INPUT_PRESS_CALLBACK
    print(data.hand, data.hand.ItemHeld, self, data.hand.ItemHeld:GetClassname(), self:GetClassname())
    if data.hand.ItemHeld == self then
        self:EmitSound(BUTTON_SOUND)
        self:Toggle()
    end
end)

---Main entity think function. Think state is saved between loads
function base:Think()
    return 0
end

---@param context CScriptPrecacheContext
function Precache(context)
    PrecacheResource("sound", BUTTON_SOUND, context)
end

--Used for classes not attached directly to entities
return base