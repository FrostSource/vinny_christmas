-- If this script is attached to an entity then it will first require itself into global scope..
-- then add useful entity functions to the private script scope allowing for easier Hammer control.

require "core"
require "backpack_system.core"

-- print("DOING BACKPACK TRIGGER")
---@class BackpackTrigger : CBaseTrigger, EntityClass
local base, self = entity("BackpackTrigger")
if self and self.Initiated then return end

---Called automatically on spawn.
---@param spawnkeys CScriptKeyValues
function base:OnSpawn(spawnkeys)
end

---@type BackpackSystem
local bs

function base:BackpackInit(backpack)
end

---Called automatically on activate.
---Any self values set here are automatically saved.
---@param loaded boolean
function base:OnReady(loaded)
    -- print("BackpackTrigger OnReady SHOULD FIRE")
    -- Kill self if this trigger already exists (still needed?)
    if #Entities:FindAllByName(self:GetName()) > 1 then
        self:Kill()
        return
    end
    -- Create the backpack instance.
    bs = Backpack({})
    bs.InitCallback = function(backpack) self:BackpackInit(backpack) end
    -- if self:GetPrivateScriptScope().backpack_init then
    --     self:GetPrivateScriptScope().backpack_init(bs)
    -- end
end



--------------------
-- User Functions --
--------------------
--#region

---Enable backpack functionality.
function base:EnableBackpack()
    bs:Enable()
end

---Disable backpack functionality.
function base:DisableBackpack()
    bs:Disable()
end

---Disable backpack storage of any item, globally.
function base:DisableAllBackpackStorage()
    bs:SetStorageEnabled(false)
end

---Enable backpack storage of items. Specific items disabled will stay disabled.
function base:EnableAllBackpackStorage()
    bs:SetStorageEnabled(true)
end

---Disable retrieval of any item, globally.
function base:DisableAllBackpackRetrieval()
    bs:SetRetrievalEnabled(false)
end

---Enable retrieval of items. Specific items disabled will stay disabled.
function base:EnableAllBackpackRetrieval()
    bs:SetRetrievalEnabled(true)
end

---Give the base Alyx backpack to the player.
function base:GiveRealBackpack()
    bs:SetPlayerHasRealBackpack(true)
    bs:EnableRealBackpack()
end

---Remove the base Alyx backpack from the player.
function base:RemoveRealBackpack()
    bs:DisableRealBackpack()
    bs:SetPlayerHasRealBackpack(false)
end

function base:GetPropCount()
    thisEntity:FireOutput("OnUser4", thisEntity, thisEntity, tostring(bs:GetPropCount()), 0)
end

---Set the target entity where stored items will be teleported.
---
---If called using `CallScriptFunction` then the entity that called it is set as the target.
---
---If called using `RunScriptCode` the targetname of the entity must be supplied in single quotes, e.g.
---SetVirtualBackpackTarget('@virtual_backpack_target')
---DO NOT USE DOUBLE QUOTES IN YOUR OUTPUT/OVERRIDE, THIS MAY CORRUPT YOUR VMAP
---@param target string|IOParams
function base:SetVirtualBackpackTarget(target)
    if type(target) == "table" and target.caller then
        BackpackSystem:SetVirtualBackpackTarget(target.caller:GetName())
    elseif type(target) == 'string' then
        BackpackSystem:SetVirtualBackpackTarget(target)
    else
        Warning("Tried to set virtual backpack target with invalid type! ("..type(target)..")")
    end
end

--#endregion

return base