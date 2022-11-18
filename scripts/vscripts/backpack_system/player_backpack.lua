
require "core"
require "backpack_system.core"

-- print("DOING PLAYER BACKPACK")
---@class PlayerBackpack : BackpackTrigger
local base, self = entity("PlayerBackpack", "backpack_system.trigger")
if self.Initiated then return end

---Backpack was initiated from trigger.lua
---@param backpack BackpackSystem
function base:BackpackInit(backpack)
    print("PLAYER BACKPACK INIT")
    backpack.UniqueName = "PlayerBackpack"
    backpack:SetBackpackTrigger(self)
    -- This has to be set every time because functions can't be saved.
    backpack.PreUpdateCallback = function(bs) return self:BackpackPreUpdate(bs) end
    ---Player class member for BackpackSystem.
    ---@type BackpackSystem
    Player.Backpack = backpack
    backpack:Enable()

    -- Custom for Vinny Almost Misses Christmas
    backpack:SetNameStorage("christmas_gift", true)
    backpack:SetNameRetrieval("christmas_gift", true)
end

---Pre update callback.
---@param backpack BackpackSystem
---@return boolean
function base:BackpackPreUpdate(backpack)
    -- Positioning the backpack trigger at player head.
    local head_forward = Player.HMDAvatar:GetForwardVector()
    local b_forward = Vector(head_forward.x, head_forward.y, 0)
    backpack.BackpackTrigger:SetForwardVector(b_forward)
    backpack.BackpackTrigger:SetOrigin(Player.HMDAvatar:GetOrigin() + b_forward * -3)
    return true
end
