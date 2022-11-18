--[[
    v2.0.0
    Base logic script for the custom backpack System.

    Add 'maps\prefabs\backpack_system\backpack_system_logic.vmap' to your map for this script to initiate on map load.


]]
require'core'

local debug_printing_allowed = true

local function dprint(...)
    if debug_printing_allowed or IsInToolsMode() then
        print(...)
    end
end

BACKPACK_EVENT =
{
    ITEM_STORED = "ITEM_STORED";
    ITEM_RETRIEVED = "ITEM_RETRIEVED";
}

---@class BackpackSystem
BackpackSystem = {

    -- Storage properties in order of importance.

    ---Items can be put in backpack.
    StorageEnabled = true;
    ---Max items allowed in backpack.
    ---If you want a different max for each class you should control this in a separate script.
    MaxItems = -1;
    ---Maximum mass the object can be for storage. Use -1 to disable.
    LimitMass = -1;
    ---Maximum size/volume of an object (length x width x height). Use -1 to disable.
    LimitSize = -1;
    ---Entity classes that can be put in backpack.
    ---Use false or don't add to exclude a class.
    ---If table is empty then any class can be stored.
    StorableClasses =
    {
        -- ["prop_physics"] = 1,
        -- ["prop_physics_override"] = 1,
        -- ["func_physbox"] = 1,
    };
    ---Entity names that can be put in backpack.
    ---Use false or don't add to exclude a name.
    ---If table is empty then any name can be stored.
    StorableNames =
    {
    };
    ---Entity models that can be put in backpack.
    ---Use false or don't add to exclude a model.
    ---If table is empty then any model can be stored.
    StorableModels =
    {
    };

    -- Retrieval properties in order of importance.
    -- Retrieval tables are used to retrieve generic props instead of specifically designated props.

    ---Items can be taken from backpack.
    RetrievalEnabled = true;
    ---Player must have no weapon equipped to retrieve items.
    RequireNoWeapon = false;
    ---Player's weapon must have no ammo in backpack to retrieve items. Use in conjunction with `RequireNoWeapon`.
    RequireNoAmmo = false;
    ---If true then all items can be retrieved regardless of the retrieval properties set.
    OverrideAllowAllRetrieval = false;
    ---Classes that can be retrieved from the backpack in order of importance.
    RetrievalClassInventory = {};
    ---Names that can be retrieved from the backpack in order of importance.
    RetrievalNameInventory = {};
    ---Models that can be retrieved from the backpack in order of importance.
    RetrievalModelInventory = {};

    -- Other properties

    ---Seconds a prop can attempt to enter backpack after being dropped/thrown.
    DepositWaitTime = 1.0;
    ---Strength of the vibration when a hand is interacting with the backpack.
    ---@type 0|1|2
    HapticStrength = 2;
    ---Default sound that plays when storing an entity. Can be overridden per entity.
    SoundStore = "Inventory.Close";--"Inventory.DepositItem";
    ---Default sound that plays when retrieving an entity. Can be overridden per entity.
    SoundRetrieve = "Inventory.Open";--"Inventory.ClipGrab";
    --Seconds between each update function (0 is every frame).
    UpdateInterval = 0;
    ---Disables the real backpack if it exists when retrieving so player won't accidentally grab ammo.
    DisableRealBackpackWhenRetrieving = true;
    ---Player has real backpack equipped. Used for proper enabling/disabling during retrieval.
    PlayerHasRealBackpack = false;
    ---Function called just before every update.
    ---@type function
    PreUpdateCallback = nil;
    ---Function called when backpack initiates.
    ---@type function
    InitCallback = nil;

    -- Following members should not be edited unless you know what you are doing!

    ---Items stored in backpack will be pulled out in the opposite order they were stored.
    StorageStack = Stack();
    ---If the backpack is enabled and will accept prop input.
    Enabled = false;
    ---Trigger entity.
    ---@type CBaseTrigger
    BackpackTrigger = nil;
    ---Target where stored entities are Teleported.
    ---@type EntityHandle
    VirtualBackpackTarget = nil;

    ---Function that gets called for backpack events like storage and retrieval.
    ---@type function
    EventCallback = nil;

    ---Entity where data is saved for game loads. If nil on `Init` the player will be used.
    ---@type EntityHandle
    StorageEntity = Player;

    _handflags = {};

    ---@type table<EntityHandle,boolean>
    ItemsLookingForBackpack = {};

    ---Unique name is used to save data on an entity without conflicting names.
    UniqueName = "BackpackSystem"
}
BackpackSystem.__index = BackpackSystem

---Create a new backpack instance.
---@param defaults? table # Default parameters the backpack will start with.
---@return BackpackSystem
function Backpack(defaults)
    -- Any object values need to be created as new so they don't
    -- affect the base class table.
    local b = setmetatable(vlua.tableadd({
        StorableClasses = {};
        StorableNames = {};
        StorableModels = {};
        RetrievalClassInventory = {};
        RetrievalNameInventory = {};
        RetrievalModelInventory = {};
        StorageStack = Stack();
        _handflags = {};
        ItemsLookingForBackpack = {};
        UniqueName = DoUniqueString("BackpackSystem");
    }, defaults or {}), BackpackSystem)
    RegisterPlayerEventCallback("vr_player_ready", b.Init, b)
    -- RegisterPlayerEventCallback("item_pickup", b.ItemGrabbedFromBackpack, b)
    RegisterPlayerEventCallback("item_released", b.ItemReleasedForBackpack, b)
    return b
end


--#region Entity extension functions.
--================================== Entity extension functions. ==================================
--
-- Entity functions to control what can[not] interact with backpack.
--
--=================================================================================================

-- Storage

---Add this entity's class to the list of storable classes.
---@param data TypeIOInvoke
function CEntityInstance:EnableClassStorage(data)
    -- if data.caller then
        BackpackSystem:SetClassStorage(self:GetClassname(), true)
        -- BackpackSystem.StorableClasses:Add(data.caller:GetClassname())
    -- end
end
---Remove this entity's class from the list of storable classes.
---@param data TypeIOInvoke
function CEntityInstance:DisableClassStorage(data)
    -- if data.caller then
        BackpackSystem:SetClassStorage(self:GetClassname(), nil)
        -- BackpackSystem.StorableClasses:Remove(data.caller:GetClassname())
    -- end
end

---Add this entity's name to the list of storable names.
---@param data TypeIOInvoke
function CEntityInstance:EnableNameStorage(data)
    -- if data.caller then
        BackpackSystem:SetNameStorage(self:GetName(), true)
        -- BackpackSystem.StorableNames:Add(data.caller:GetName())
    -- end
end
---Remove this entity's name from the list of storable names.
---@param data TypeIOInvoke
function CEntityInstance:DisableNameStorage(data)
    -- if data.caller then
        BackpackSystem:SetNameStorage(self:GetName(), nil)
        -- BackpackSystem.StorableNames:Remove(data.caller:GetName())
    -- end
end

---Add this entity's model to the list of storable models.
---@param data TypeIOInvoke
function CEntityInstance:EnableModelStorage(data)
    -- if data.caller then
        BackpackSystem:SetModelStorage(self:GetModelName(), true)
        -- BackpackSystem.StorableModels:Add(data.caller:GetModelName())
    -- end
end
---Remove this entity's model from the list of storable models.
---@param data TypeIOInvoke
function CEntityInstance:DisableModelStorage(data)
    -- if data.caller then
        BackpackSystem:SetModelStorage(self:GetModelName(), nil)
        -- BackpackSystem.StorableModels:Remove(data.caller:GetModelName())
    -- end
end

---Enable storage for this specific entity.
---@param data TypeIOInvoke
function CEntityInstance:EnableStorage(data)
    -- if data.caller then
        -- self:EnableClassStorage(data)
        -- self:EnableNameStorage(data)
        -- self:EnableModelStorage(data)
        dprint(self:GetName(), self:GetClassname(), self:GetModelName())
        if self:GetClassname() == "prop_ragdoll" then dprint("ENABLE STORAGE ON RAGDOLL") end
        self:SaveBoolean("BackpackItem.EnableStorage", true)
    -- end
end
CEntityInstance.EnableBackpackStorage = CEntityInstance.EnableStorage
---Remove this entity's properties from the storable tables as a catch-all.
---@param data TypeIOInvoke
function CEntityInstance:DisableStorage(data)
    -- if data.caller then
        -- self:DisableClassStorage(data)
        -- self:DisableNameStorage(data)
        -- self:DisableModelStorage(data)
        self:SaveBoolean("BackpackItem.DisableStorage", true)
    -- end
end
CEntityInstance.DisableBackpackStorage = CEntityInstance.DisableStorage

-- Retrieval

---Add this entity's class to the list of retrieval classes.
---@param data TypeIOInvoke
function CEntityInstance:EnableClassRetrieval(data)
    BackpackSystem:SetClassRetrieval(self:GetClassname(), true)
end
---Remove this entity's class from the list of retrieval classes.
---@param data TypeIOInvoke
function CEntityInstance:DisableClassRetrieval(data)
    -- if data.caller then
    --     BackpackSystem.RetrievalClassInventory:Remove(data.caller:GetClassname())
    -- end
    BackpackSystem:SetClassRetrieval(self:GetClassname(), nil)
end

---Add this entity's name to the list of retrieval names.
---@param data TypeIOInvoke
function CEntityInstance:EnableNameRetrieval(data)
    BackpackSystem:SetNameRetrieval(self:GetName(), true)
end
---Remove this entity's name from the list of retrieval names.
---@param data TypeIOInvoke
function CEntityInstance:DisableNameRetrieval(data)
    BackpackSystem:SetNameRetrieval(self:GetName(), nil)
end

---Add this entity's model to the list of retrieval models.
---@param data TypeIOInvoke
function CEntityInstance:EnableModelRetrieval(data)
    BackpackSystem:SetModelRetrieval(self:GetModelName(), true)
end
---Remove this entity's model from the list of retrieval models.
---@param data TypeIOInvoke
function CEntityInstance:DisableModelRetrieval(data)
    BackpackSystem:SetModelRetrieval(self:GetModelName(), nil)
end

---Enable retrieval for this entity and make it a priority.
---@param data TypeIOInvoke
function CEntityInstance:EnableRetrieval(data)
    self:SaveBoolean("BackpackItem.EnableRetrieval", true)
    -- Moving to the top means the most recently enabled will be pulled out first
    BackpackSystem:MovePropToTop(self)
end
CEntityInstance.EnableBackpackRetrieval = CEntityInstance.EnableRetrieval
---Remove this entity's properties from the retrieval tables as a catch-all.
---@param data TypeIOInvoke
function CEntityInstance:DisableRetrieval(data)
    self:SaveBoolean("BackpackItem.EnableRetrieval", false)
end
CEntityInstance.DisableBackpackRetrieval = CEntityInstance.DisableRetrieval


---Set the sound that plays when this entity is stored.
---
---To call from Hammer use RunScriptCode with the name of the sound in single quotes, e.g.
---```
---SetStoreSound('Inventory.DepositItem')
---```
---
---@param sound string
function CEntityInstance:SetStoreSound(sound)
    SetStoreSound(self, sound)
end

---Global function for CEntityInstance:SetStoreSound.
---Makes setting in Hammer easier.
---@param handle EntityHandle|string # If a sound event then the handle will be the entity that called this function.
---@param sound? string
function SetStoreSound(handle, sound)
    if type(handle) == "string" then
        local fenv = getfenv(2)
        if not fenv.thisEntity then
            return
        end
        sound = handle
        handle = fenv.thisEntity
    end
    if type(sound) == "string" then
        handle:SaveString("BackpackItem.StoreSound", sound)
    end
end

---Set the sound that plays when this entity is retrieved.
---@param sound string
function CEntityInstance:SetRetrieveSound(sound)
    SetRetrieveSound(self, sound)
end

---Global function for CEntityInstance:SetRetrieveSound.
---Makes setting in Hammer easier.
---@param handle EntityHandle|string # If a sound event then the handle will be the entity that called this function.
---@param sound? string
function SetRetrieveSound(handle, sound)
    if type(handle) == "string" then
        local fenv = getfenv(2)
        if not fenv.thisEntity then
            return
        end
        sound = handle
        handle = fenv.thisEntity
    end
    if type(sound) == 'string' then
        handle:SaveString("BackpackItem.RetrieveSound", sound)
    end
end



---Set the angle the prop will be rotated to relative to the hand retrieving it.
---Format: 'Pitch Yaw Roll' e.g. '90 180 0'
---@param angle QAngle|string
function CEntityInstance:SetGrabAngle(angle)
    if type(angle) == "string" then
        local t = angle:split()
        angle = QAngle(tonumber(t[1]) or 0, tonumber(t[2]) or 0, tonumber(t[3]) or 0)
    end
    self:SaveQAngle("BackpackProp.GrabAngle", angle)
end

---Sets the offset the item will be positioned relative to the hand retrieving it.
---Format: 'x y z' e.g. '-1 3.5 0'
---@param offset Vector|string
function CEntityInstance:SetGrabOffset(offset)
    if type(offset) == "string" then
        local t = offset:split()
        offset = Vector(tonumber(t[1]) or -3, tonumber(t[2]) or 3, tonumber(t[3]) or -2)
    end
    self:SaveVector("BackpackProp.GrabOffset", offset)
end

---Get the backpack grab QAngle for this entity.
---@return QAngle
function CEntityInstance:GetGrabAngle()
    return self:LoadQAngle("BackpackProp.GrabAngle", QAngle())
end

---Get the backpack grab offset for this entity.
---@return Vector
function CEntityInstance:GetGrabOffset()
    return self:LoadVector("BackpackProp.GrabOffset", Vector())
end

---Put this entity into the backpack.
function CEntityInstance:PutInBackpack()
    BackpackSystem:PutPropInBackpack(self)
end

--#endregion

--------------------------------------------------
-- System functions
--------------------------------------------------
--#region System functions

--#region Local functions

---Entity classes that have 'Use' input.
---If more exist, please let me know.
CLASSES_THAT_CAN_USE =
{
    "prop_physics",
    "prop_physics_override",
    "prop_physics_interactive",
    "prop_animinteractable",
    "prop_dry_erase_marker",
    "item_healthvial",
    "item_hlvr_health_station_vial",
    "item_item_crate",
    "item_hlvr_prop_battery",
    "item_hlvr_crafting_currency_large",
    "item_hlvr_crafting_currency_small",
    "item_hlvr_clip_energygun",
    "item_hlvr_clip_energygun_multiple",
    "item_hlvr_clip_rapidfire",
    "item_hlvr_clip_shotgun_single",
    "item_hlvr_clip_shotgun_multiple",
    "item_hlvr_clip_generic_pistol",
    "item_hlvr_clip_generic_pistol_multiple",
    "prop_russell_headset",
    "func_physbox",
    "item_hlvr_weapon_energygun",
    "item_hlvr_weapon_shotgun",
    "item_hlvr_weapon_rapidfire",
    "item_hlvr_weapon_generic_pistol",
}

---Initiating values.
local function init(data)
    ---Used as a fix for props not transitioning outside PVS.
    ---This re-enables vis to avoid performance loss.
    if Player:LoadBoolean("EnableVisAfterTransition") then
        -- dprint("\nEnabling vis after transition\n")
        SendToConsole("vis_enable 1")
        Player:SaveBoolean("EnableVisAfterTransition", false)
    end
end
RegisterPlayerEventCallback("vr_player_ready", init)


---Used as a fix for props not transitioning outside of PVS.
local function onMapTransition()
    if not Player:LoadBoolean("EnableVisAfterTransition") then
        -- dprint("\n\nON MAP TRANSITION", IsClient())
        SendToConsole("vis_enable 0")
        Player:SaveBoolean("EnableVisAfterTransition", true)
        -- dprint("\n\n")
    end
end
ListenToGameEvent("change_level_activated", function() onMapTransition() end, nil)

--#endregion Local functions

--#region BackpackSystem class functions

--#region BackpackSystem property setters
--=============================== BackpackSystem property setters. ================================
--
-- Using these functions instead of setting the table properties directly ensures that the values
-- will be saved and restored on a game load.
--
--=================================================================================================

-- ---Enable backpack storage of items. Items that aren't set as allowed will still stay disallowed.
-- function BackpackSystem:EnableAllStorage()
--     self.StorageEnabled = true
--     Storage.SaveBoolean(self._BackpackTrigger, 'BackpackSystem.StorageEnabled', true)
-- end

-- ---Disable backpack storage of all items, globally.
-- function BackpackSystem:DisableAllStorage()
--     self.StorageEnabled = false
--     Storage.SaveBoolean(self._BackpackTrigger, 'BackpackSystem.StorageEnabled', false)
-- end

---Set if storage of props is enabled. Specific items disabled will stay disabled.
---@param enabled? boolean # Default is true.
function BackpackSystem:SetStorageEnabled(enabled)
    if enabled == nil then enabled = true end
    self.StorageEnabled = enabled
    Storage.SaveBoolean(self.StorageEntity, self.UniqueName..".RetrievalEnabled", self.RetrievalEnabled)
end

---Set maximum items allowed in backpack. Use negative number to disable.
---@param maxItems integer|-1
function BackpackSystem:SetMaxItems(maxItems)
    self.MaxItems = math.floor(maxItems)
    Storage.SaveNumber(self.StorageEntity, self.UniqueName..".MaxItems", self.MaxItems)
end

---Set maximum mass limit a prop can be to be stored in backpack. Use negative number to disable.
---@param mass number|-1
function BackpackSystem:SetMassLimit(mass)
    self.LimitMass = mass
    Storage.SaveNumber(self.StorageEntity, self.UniqueName..".LimitMass", self.LimitMass)
end

---Set maximum size a prop can be to be stored in backpack. Use negative number to disable.
---Size is `volume = width * depth * height`
---@param size number|-1
function BackpackSystem:SetSizeLimit(size)
    self.LimitSize = size
    Storage.SaveNumber(self.StorageEntity, self.UniqueName..".LimitSize", self.LimitSize)
end

---Set a specific class or table of classes as storable.
---@param class string # The name of the class
---@param enabled boolean|nil # If the class is storable.
---@overload fun(self: BackpackSystem, classes: table<string, boolean>)
function BackpackSystem:SetClassStorage(class, enabled)
    if type(class) == "table" then
        self.StorableClasses = vlua.tableadd(self.StorableClasses, class)
    else
        self.StorableClasses[class] = enabled
    end
    Storage.SaveTable(self.StorageEntity, self.UniqueName..".StorableClasses", self.StorableClasses)
end

---Set a specific targetname or table of targetnames as storable.
---@param name string # The targetname.
---@param enabled boolean|nil # If the name is storable.
---@overload fun(self: BackpackSystem, names: table<string, boolean>)
function BackpackSystem:SetNameStorage(name, enabled)
    if type(name) == "table" then
        self.StorableNames = vlua.tableadd(self.StorableNames, name)
    else
        self.StorableNames[name] = enabled
    end
    Storage.SaveTable(self.StorageEntity, self.UniqueName..".StorableNames", self.StorableNames)
end

---Set a specific model or table of models as storable.
---@param model string # The model asset path.
---@param enabled boolean|nil # If the model is storable.
---@overload fun(self: BackpackSystem, models: table<string, boolean>)
function BackpackSystem:SetModelStorage(model, enabled)
    if type(model) == "table" then
        self.StorableModels = vlua.tableadd(self.StorableModels, model)
    else
        self.StorableModels[model] = enabled
    end
    Storage.SaveTable(self.StorageEntity, self.UniqueName..".StorableModels", self.StorableModels)
end

---Set if retrieval of props is enabled. Specific items disabled will stay disabled.
---@param enabled? boolean # Default is true.
function BackpackSystem:SetRetrievalEnabled(enabled)
    if enabled == nil then enabled = true end
    self.RetrievalEnabled = enabled
    Storage.SaveBoolean(self.StorageEntity, self.UniqueName..".RetrievalEnabled", self.RetrievalEnabled)
end

---Set if player must have no weapon equipped to retrieve a prop.
---@param requireNoWeapon? boolean # Default is false.
function BackpackSystem:SetRequireNoWeapon(requireNoWeapon)
    if requireNoWeapon == nil then requireNoWeapon = false end
    self.RequireNoWeapon = requireNoWeapon
    Storage.SaveBoolean(self.StorageEntity, self.UniqueName..".RequireNoWeapon", self.RequireNoWeapon)
end

---Set if player must have no weapon equipped to retrieve a prop.
---@param requireNoAmmo? boolean # Default is false.
function BackpackSystem:SetRequireNoAmmo(requireNoAmmo)
    if requireNoAmmo == nil then requireNoAmmo = false end
    self.RequireNoAmmo = requireNoAmmo
    Storage.SaveBoolean(self.StorageEntity, self.UniqueName..".RequireNoAmmo", self.RequireNoAmmo)
end

---Set if all items can be retrived regardless of individual settings.
---@param overrideEnabled? boolean # Default is false.
function BackpackSystem:SetOverrideAllowAllRetrieval(overrideEnabled)
    if overrideEnabled == nil then overrideEnabled = false end
    self.OverrideAllowAllRetrieval = overrideEnabled
    Storage.SaveBoolean(self.StorageEntity, self.UniqueName..".OverrideAllowAllRetrieval", self.OverrideAllowAllRetrieval)
end



---Set a specific class or table of classes as retrievable.
---@param class string # The name of the class.
---@param enabled boolean|nil # If the class is retrievable.
---@overload fun(self: BackpackSystem, classes: table<string, boolean>)
function BackpackSystem:SetClassRetrieval(class, enabled)
    if type(class) == "table" then
        self.RetrievalClassInventory = vlua.tableadd(self.RetrievalClassInventory, class)
    else
        self.RetrievalClassInventory[class] = enabled
    end

    Storage.SaveTable(self.StorageEntity, self.UniqueName..".RetrievalClassInventory", self.RetrievalClassInventory)
end

---Set a specific name or table of names as retrievable.
---@param name string # The targetname.
---@param enabled boolean|nil # If the targetname is retrievable.
---@overload fun(self: BackpackSystem, names: table<string, boolean>)
function BackpackSystem:SetNameRetrieval(name, enabled)
    if type(name) == "table" then
        self.RetrievalNameInventory = vlua.tableadd(self.RetrievalNameInventory, name)
    else
        self.RetrievalNameInventory[name] = enabled
    end
    Storage.SaveTable(self.StorageEntity, self.UniqueName..".RetrievalNameInventory", self.RetrievalNameInventory)
end

---Set a specific model or table of models as retrievable.
---@param model string # The model asset path.
---@param enabled boolean|nil # If the model is retrievable.
---@overload fun(self: BackpackSystem, models: table<string, boolean>)
function BackpackSystem:SetModelRetrieval(model, enabled)
    if type(model) == "table" then
        self.RetrievalModelInventory = vlua.tableadd(self.RetrievalModelInventory, model)
    else
        self.RetrievalModelInventory[model] = enabled
    end
    Storage.SaveTable(self.StorageEntity, self.UniqueName..".RetrievalModelInventory", self.RetrievalModelInventory)
end

---Set the number of seconds a prop can attempt to be stored after being thrown.
---@param seconds number
function BackpackSystem:SetDepositWaitTime(seconds)
    self.DepositWaitTime = seconds or BackpackSystem.DepositWaitTime
    Storage.SaveNumber(self.StorageEntity, self.UniqueName..".DepositWaitTime", self.DepositWaitTime)
end

---Set the strength of the vibration when a hand is interacting with the backpack.
---@param strength 0|1|2
function BackpackSystem:SetHapticStrength(strength)
    self.HapticStrength = strength or BackpackSystem.HapticStrength
    Storage.SaveNumber(self.StorageEntity, self.UniqueName..".HapticStrength", self.HapticStrength)
end

---Set the default store sound for the backpack.
---Specific entity sounds will still be prioritized.
---@param sound string # Sound event name.
function BackpackSystem:SetStoreSound(sound)
    self.SoundStore = sound or BackpackSystem.SoundStore
    Storage.SaveString(self.StorageEntity, self.UniqueName..".SoundStore", self.SoundStore)
end

---Set the default retrieve sound for the backpack.
---Specific entity sounds will still be prioritized.
---@param sound string # Sound event name.
function BackpackSystem:SetRetrieveSound(sound)
    self.SoundRetrieve = sound or BackpackSystem.SoundStore
    Storage.SaveString(self.StorageEntity, self.UniqueName..".SoundRetrieve", self.SoundRetrieve)
end

---Set seconds between each update function (0 is every frame).
---@param interval number
function BackpackSystem:SetUpdateInterval(interval)
    self.UpdateInterval = interval or BackpackSystem.UpdateInterval
    Storage.SaveNumber(self.StorageEntity, self.UniqueName..".UpdateInterval", self.UpdateInterval)
end

---Set if the real backpack is disabled if it exists when retrieving so player won't accidentally grab ammo.
---@param disableWhenRetrieving boolean
function BackpackSystem:SetDisableRealBackpackWhenRetrieving(disableWhenRetrieving)
    self.DisableRealBackpackWhenRetrieving = disableWhenRetrieving or BackpackSystem.DisableRealBackpackWhenRetrieving
    Storage.SaveBoolean(self.StorageEntity, self.UniqueName..".DisableRealBackpackWhenRetrieving", self.DisableRealBackpackWhenRetrieving)
end

---Set if the player currently has the base alyx backpack enabled.
---@param hasBackpack boolean
function BackpackSystem:SetPlayerHasRealBackpack(hasBackpack)
    self.PlayerHasRealBackpack = hasBackpack or BackpackSystem.PlayerHasRealBackpack
    Storage.SaveBoolean(self.StorageEntity, self.UniqueName..".PlayerHasRealBackpack", self.PlayerHasRealBackpack)
end

---Set the trigger used for storing props and hand interaction.
---@param trigger CBaseTrigger
function BackpackSystem:SetBackpackTrigger(trigger)
    self.BackpackTrigger = trigger or BackpackSystem.BackpackTrigger
    Storage.SaveEntity(self.StorageEntity, self.UniqueName..".BackpackTrigger", self.BackpackTrigger)
end

---Set the target entity where stored items will be teleported.
---@param targetname string
function BackpackSystem:SetVirtualBackpackTarget(targetname)
    local target = Entities:FindByName(nil, targetname)
    if not target then
        Warning("Could not set backpack virtual target: No entity with name '"..targetname.."' found!")
        return
    end
    self.VirtualBackpackTarget = target
    Storage.SaveEntity(self.StorageEntity, self.UniqueName..".VirtualBackpackTarget", self.VirtualBackpackTarget)
end

---Enable the backpack to accept prop input and positioning.
function BackpackSystem:Enable()
    -- Player:SetThink(BackpackUpdate, "BackpackUpdate", 0)
    dprint("BackpackSystem:", "Enable")
    Player:SetContextThink(self.UniqueName..".Think", function() return self.Update( self ) end, 0)
    self.Enabled = true
    self.BackpackTrigger:Enable()
    Storage.SaveBoolean(self.StorageEntity, self.UniqueName..".Enabled", self.Enabled)
end

---Disable the backpack to stop prop input and positioning.
function BackpackSystem:Disable()
    Player:SetContextThink(self.UniqueName..".Think", nil, 0)
    self.Enabled = false
    self.BackpackTrigger:Disable()
    Storage.SaveBoolean(self.StorageEntity, self.UniqueName..".Enabled", self.Enabled)
end

--#endregion BackpackSystem property setters

---Initiation function automatically called on vr player activate.
function BackpackSystem:Init()
    -- If nothing else to this function, merge Load here.
    if not self.StorageEntity then
        self.StorageEntity = Player
    end
    if self.InitCallback then
        self.InitCallback(self)
    end
    self:Load()
end

function BackpackSystem:Load()
    self:SearchForBackpack()
    -- Search for map trigger after a short amount of time if not immediately found
    if not self.BackpackTrigger then
        dprint("BackpackSytem:", "Backpack wasn't found, searching after delay...")
        Player:SetContextThink("SearchForBackpack", function()
            self:SearchForBackpack()
        end, 1)
    end

    self.VirtualBackpackTarget = Storage.LoadEntity(self.StorageEntity, self.UniqueName..".VirtualBackpackTarget",
        Entities:FindByName(nil, "@backpack_system_target"))
    if not IsEntity(self.VirtualBackpackTarget, true) then
        self.VirtualBackpackTarget = SpawnEntityFromTableSynchronous("info_target",{
            targetname = "@backpack_system_target_SPAWNED",
            origin = "16000 16000 16000",
        })
    end
    -- Saved variables should probably have unique setting functions to do the saving for users.

    self.MaxItems = Storage.LoadNumber(self.StorageEntity, self.UniqueName..".MaxItems", self.MaxItems)
    self.LimitMass = Storage.LoadNumber(self.StorageEntity, self.UniqueName..".LimitMass", self.LimitMass)
    self.LimitSize = Storage.LoadNumber(self.StorageEntity, self.UniqueName..".LimitSize", self.LimitSize)
    self.DepositWaitTime = Storage.LoadNumber(self.StorageEntity, self.UniqueName..".DepositWaitTime", self.DepositWaitTime)
    self.SoundStore = Storage.LoadString(self.StorageEntity, self.UniqueName..".SoundStore", self.SoundStore)
    self.SoundRetrieve = Storage.LoadString(self.StorageEntity, self.UniqueName..".SoundRetrieve", self.SoundRetrieve)
    self.DisableRealBackpackWhenRetrieving = Storage.LoadBoolean(self.StorageEntity, self.UniqueName..".DisableRealBackpackWhenRetrieving", self.DisableRealBackpackWhenRetrieving)
    self.PlayerHasRealBackpack = Storage.LoadBoolean(self.StorageEntity, self.UniqueName..".PlayerHasRealBackpack", self.PlayerHasRealBackpack)
    self.UpdateInterval = Storage.LoadNumber(self.StorageEntity, self.UniqueName..".UpdateInterval", self.UpdateInterval)
    self.HapticStrength = Storage.LoadNumber(self.StorageEntity, self.UniqueName..".HapticStrength", self.HapticStrength)
    self.RetrievalEnabled = Storage.LoadBoolean(self.StorageEntity, self.UniqueName..".RetrievalEnabled", self.RetrievalEnabled)
    self.RequireNoWeapon = Storage.LoadBoolean(self.StorageEntity, self.UniqueName..".RequireNoWeapon", self.RequireNoWeapon)
    self.RequireNoAmmo = Storage.LoadBoolean(self.StorageEntity, self.UniqueName..".RequireNoAmmo", self.RequireNoAmmo)

    self.StorableClasses = Storage.LoadTable(self.StorageEntity, self.UniqueName..".StorableClasses", self.StorableClasses)
    self.StorableNames = Storage.LoadTable(self.StorageEntity, self.UniqueName..".StorableNames", self.StorableNames)
    self.StorableModels = Storage.LoadTable(self.StorageEntity, self.UniqueName..".StorableModels", self.StorableModels)

    self.RetrievalClassInventory = Storage.LoadTable(self.StorageEntity, self.UniqueName..".RetrievalClassInventory", self.RetrievalClassInventory)
    self.RetrievalNameInventory = Storage.LoadTable(self.StorageEntity, self.UniqueName..".RetrievalClassInventory", self.RetrievalNameInventory)
    self.RetrievalModelInventory = Storage.LoadTable(self.StorageEntity, self.UniqueName..".RetrievalClassInventory", self.RetrievalModelInventory)

    self.StorageStack = Storage.LoadStack(self.StorageEntity, self.UniqueName..".StorageStack", self.StorageStack)
    self:PrintPropsInBackpack()
    for _, prop in ipairs(self.StorageStack.items) do
        self:MovePropToBackpack(prop)
    end

    self.Enabled = Storage.LoadBoolean(self.StorageEntity, self.UniqueName..".Enabled", self.Enabled)
    if self.Enabled then
        dprint("BackpackSystem:", "Backpack start enabled")
        self:Enable()
    end

    -- this is debug
    -- BackpackSystem:EnableRealBackpack()
end

---Update function positions backpack behind the player at head height.
---@return number?
function BackpackSystem:Update()
    -- Consider removing the the StartTouch EndTouch functions and
    -- do all the checking in here to avoid console message pollution.

    -- Early exit
    if not self.Enabled then
        return nil
    end

    -- User defined pre update callback.
    -- If false return, skip this update.
    if self.PreUpdateCallback then
        if not self.PreUpdateCallback(self) then
            return self.UpdateInterval
        end
    end

    -- Check props being thrown into backpack

    -- dprint("Checking", Time())
    for item in pairs(self.ItemsLookingForBackpack) do
        if self.BackpackTrigger:IsTouching(item) then
            self.ItemsLookingForBackpack[item] = nil
            self:PutInBackpackEvent(item)
        end
    end

    -- Grab tracking for retrieval

    for _, hand in pairs(Player.Hands) do
        if self.BackpackTrigger:IsTouching(hand) then

            if hand:IsHoldingItem() then
                -- dprint("BackpackSystem:", "hand is holding")
                -- If item held on backpack is storable then prompt player with vibrate.
                -- if type(hand.ItemHeld) == "string" then dprint('string was in OnBackpackTriggerTouch') end
                if not self._handflags[hand] and self:CanStoreProp(hand.ItemHeld) then
                    -- dprint("BackpackSystem:", "hand touched backpack while holding")
                    hand:FireHapticPulse(self.HapticStrength)
                    self._handflags[hand] = true
                end

            else -- Not holding item
                -- dprint('not holding item behind head', Time())
               -- If allowed to retrieve and backpack has at least 1 prop...
                if self.RetrievalEnabled and not self.StorageStack:IsEmpty()
                and (not Player:HasWeaponEquipped() or not self.RequireNoWeapon)
                and (Player:GetCurrentWeaponReserves() == 0 or not self.RequireNoAmmo)
                then
                    -- dprint('inside')
                    -- Make sure at least 1 prop is allowed to be retrieved...
                    local retrieval_item = self:GetTopProp()
                    -- dprint(retrieval_item)
                    if retrieval_item then
                        -- dprint('found retrieval item', retrieval_item)
                        if not self._handflags[hand] then
                            -- print('doing haptic')
                            self._handflags[hand] = true
                            hand:FireHapticPulse(self.HapticStrength)
                            if self.DisableRealBackpackWhenRetrieving then
                                self:DisableRealBackpack()
                            end
                        end

                        if Player:IsDigitalActionOnForHand(hand.Literal, 3) then
                            -- probably don't need to use this function since retrieval_item is given above
                            retrieval_item = self:RemovePropFromBackpack()
                            -- Move item to hand and send 'Use' input.
                            if retrieval_item then
                                StartSoundEventFromPosition(
                                    Storage.LoadString(retrieval_item, "BackpackItem.RetrieveSound", self.SoundRetrieve),
                                    hand:GetOrigin()
                                )
                                self:MovePropToHand(retrieval_item, hand)
                                DoEntFireByInstanceHandle(retrieval_item, "Use", tostring(hand:GetHandID()), 0, Player, Player)
                                self:TryEnableRealBackpack()
                                -- Send outputs
                                DoEntFireByInstanceHandle(retrieval_item, "FireUser2", "", 0, Player, Player)
                                DoEntFireByInstanceHandle(self.BackpackTrigger, "FireUser2", "", 0, Player, Player)
                                -- Event Callback
                                if self.EventCallback then
                                    self.EventCallback({
                                        type = BACKPACK_EVENT.ITEM_RETRIEVED;
                                        item = retrieval_item;
                                    })
                                end
                            end
                        end

                    end
                end
            end

        else
            self._handflags[hand] = false
        end
    end

    return self.UpdateInterval
end


function BackpackSystem:ItemReleasedForBackpack(data)
    -- dprint("RELEASED", data.item, data.item_class, BackpackSystem:CanStoreProp(data.item))
    -- if vlua.find(BackpackSystem.StorableClasses, data.item_class) then
    ---@type EntityHandle
    local prop = data.item

    -- THIS IS DEBUG STUFF
    -- dprint("itemreleased in backpack system")
    if type(data.item) == "string" then dprint('string was in itemReleasedForBackpack') end
    -- dprint(BackpackSystem:CanStoreProp(prop))
    if not self:CanStoreProp(prop) then self:PrintCanStoreProp(prop) end
    -- DELETE ABOVE DEBUG

    if self:CanStoreProp(prop) then
        dprint("BackpackSystem", "item released for backpack", prop:GetModelName())

        -- Put released prop immediately in backpack if touching.
        if self:IsPropTouchingBackpack(prop) then
            dprint("Putting prop in backpack")
            -- for some reason this needs to be delayed,
            -- possibly because prop hasn't fully detached from hand yet
            prop:SetContextThink(DoUniqueString(""), function()
                self:PutInBackpackEvent(prop)
            end, 0)
            return
        end

        -- Otherwise prop is being thrown into backpack...
        self.ItemsLookingForBackpack[prop] = true
        Player:SetContextThink(DoUniqueString("remove_backpack_wait"),
            function()
                self.ItemsLookingForBackpack[prop] = nil
            end
        ,self.DepositWaitTime)
    end
end

function BackpackSystem:PutInBackpackEvent(prop)
    StartSoundEventFromPosition(
        Storage.LoadString(prop, "BackpackItem.StoreSound", self.SoundStore),
        prop:GetOrigin()
    )
    -- prop:Drop()
    self:PutPropInBackpack(prop)
    -- dprint("Immediately put in backpack because touching")
    -- Send outputs
    DoEntFireByInstanceHandle(prop, "FireUser1", "", 0, prop, Player)
    DoEntFireByInstanceHandle(self.BackpackTrigger, "FireUser1", "", 0, prop, Player)
end


---Get a list of estimated props near the backpack target regardless of their status in the backpack.
---@return EntityHandle[]
function BackpackSystem:GetPropsNearBackpackTarget()
    local props = {}
    for _, prop in ipairs(Entities:FindAllInSphere(self.VirtualBackpackTarget:GetOrigin(), 150)) do
        -- if self:CanStoreProp(prop) then
            props[#props+1] = prop
        -- end
    end
    return props
end

function BackpackSystem:PrintPropsNearBackpackTarget()
    dprint("Props near backpack:")
    for k, prop in ipairs(self:GetPropsNearBackpackTarget()) do
        dprint(k, prop, prop:GetClassname(), prop:GetModelName())
    end
end

---Attempt to find an existing backpack trigger in the map.
---Otherwise a new one is created.
function BackpackSystem:SearchForBackpack()
    dprint("BackpackSystem:", "Backpack triggers found", #Entities:FindAllByName("@backpack_system_trigger"))
    local backpack = Storage.LoadEntity(self.StorageEntity, self.UniqueName..".BackpackTrigger",
        Entities:FindByName(nil, "@backpack_system_trigger"))
    -- Assign newly found backpack if one was found
    if backpack then
        BackpackSystem.BackpackTrigger = backpack--[[@as CBaseTrigger]]
        dprint("BackpackSystem:", "Found backpack trigger is", BackpackSystem.BackpackTrigger)
        return
    end
    dprint("BackpackSystem:", "No backpack trigger was found in map...")
end



---Get the real backpack if it exists.
---@return EntityHandle
function BackpackSystem:GetRealBackpack()
    return Entities:FindByClassname(nil, "player_backpack")
end

---Enable base Alyx backpack.
function BackpackSystem:EnableRealBackpack()
    local b = self:GetRealBackpack()
    if b and self.PlayerHasRealBackpack then
        -- dprint("ENABLING REAL BACKPACK")
        -- b:SetAbsScale(1)
        local e = SpawnEntityFromTableSynchronous("info_hlvr_equip_player",{
            equip_on_mapstart = "0",
            itemholder = Player:HasItemHolder(),
            inventory_enabled = "0",
            backpack_enabled = "1",
        })
        DoEntFireByInstanceHandle(e, "EquipNow", "", 0, Player, Player)
    end
end
---Disable base Alyx backpack.
function BackpackSystem:DisableRealBackpack()
    local b = self:GetRealBackpack()
    if b and self.PlayerHasRealBackpack then
        -- dprint("DISABLING REAL BACKPACK")
        -- b:SetAbsScale(0.01)
        local e = SpawnEntityFromTableSynchronous("info_hlvr_equip_player",{
            equip_on_mapstart = "0",
            itemholder = Player:HasItemHolder(),
            inventory_enabled = "0",
            backpack_enabled = "0",
        })
        DoEntFireByInstanceHandle(e, "EquipNow", "", 0, Player, Player)
    end
end

---Enable the base Alyx backpack if no hands are touching or no props waiting for retrieval.
function BackpackSystem:TryEnableRealBackpack()
    -- dprint("TRYING TO ENABLE REAL BACKPACK")
    local touching = 0
    for id = 1, 2 do
        if self:IsPropTouchingBackpack(Player.Hands[id]) then
            touching = touching + 1
        end
    end
    if touching == 0 or not self:GetTopProp() then
        self:EnableRealBackpack()
    end
end



---Print all props in backpack.
function BackpackSystem:PrintPropsInBackpack()
    dprint("In Backpack:")
    dprint("{")
    for key, value in pairs(self.StorageStack.items) do
        dprint("", key, value, value:GetName(), value:GetClassname(), value:GetModelName())
    end
    dprint("}")
end

---Get a list of supported prop classes.
---@return string[]
function BackpackSystem:GetSupportedProps()
    return vlua.clone(CLASSES_THAT_CAN_USE)
end

---Get the size of a prop.
---@param prop EntityHandle
---@return number
function BackpackSystem:GetPropSize(prop)
    local size = prop:GetBoundingMaxs() - prop:GetBoundingMins()
    return size.x * size.y * size.z
end

function BackpackSystem:PrintCanStoreProp(prop)
    dprint("\nPrinting Debug Storage Check\n")
    -- local size = prop:GetBoundingMaxs() - prop:GetBoundingMins()
    -- dprint("Checking can store for:", prop:GetName(), prop:GetClassname(), prop:GetModelName())
    -- dprint("self.StorageEnabled", self.StorageEnabled)
    -- dprint("self.StorageStack:Length() < self.MaxItems or self.MaxItems < 0", self.StorageStack:Length() < self.MaxItems or self.MaxItems < 0)
    -- dprint('prop:LoadBoolean("BackpackItem.EnableStorage")', prop:LoadBoolean("BackpackItem.EnableStorage"))
    -- dprint('self.StorableClasses[prop:GetClassname()]', self.StorableClasses[prop:GetClassname()])
    -- dprint('self.StorableNames[prop:GetName()]', self.StorableNames[prop:GetName()])
    -- dprint('self.StorableModels[prop:GetModelName()]', self.StorableModels[prop:GetModelName()])
    -- dprint('self.LimitMass < 0 or prop:GetMass() <= self.LimitMass', self.LimitMass < 0 or prop:GetMass() <= self.LimitMass)
    -- dprint('self.LimitSize < 0 or (size.x*size.y*size.z) <= self.LimitSize', self.LimitSize < 0 or (size.x*size.y*size.z) <= self.LimitSize)

    local reason = nil--"Unknown reason"
    -- if not self.StorageEnabled then reason = "Storage disabled"
    -- elseif self.MaxItems >= 0 and self.StorageStack:Length() >= self.MaxItems then reason = "Backpack full"
    -- elseif not prop:LoadBoolean("BackpackItem.EnableStorage")
    --         and not self.StorableClasses[prop:GetClassname()]
    --         and not self.StorableNames[prop:GetName()]
    --         and not self.StorableModels[prop:GetModelName()] then reason = "Prop not enabled for storage"
    -- elseif self.LimitMass >= 0 and prop:GetMass() > self.LimitMass then reason = "Prop is too heavy"
    -- elseif self.LimitSize >= 0 and self:GetPropSize(prop) > self.LimitSize then reason = "Prop is too big"
    -- end

    -- local load_store = prop:LoadBoolean("BackpackItem.EnableStorage")
    -- if self.StorageEnabled
    -- and (self.StorageStack:Length() < self.MaxItems or self.MaxItems < 0)
    -- -- If prop store property is true then ignore storable tables.
    -- and (load_store
    --     -- If prop store property is default or true..
    --     or (load_store ~= false
    --         -- ..can store if entity property is allowed
    --         and (self.StorableClasses[prop:GetClassname()]
    --             or self.StorableNames[prop:GetName()]
    --             or self.StorableModels[prop:GetModelName()]
    --         )
    --         -- ..but make sure it's not disallowed
    --         -- parenthesis after 'not' is required, Lua has bad language semantics!
    --         and not (self.StorableClasses[prop:GetClassname()] == false)
    --         and not (self.StorableNames[prop:GetName()] == false)
    --         and not (self.StorableModels[prop:GetModelName()] == false)
    --     ))
    -- -- -- Also check other properties like size.
    -- and (self.LimitMass < 0 or prop:GetMass() <= self.LimitMass)
    -- and (self.LimitSize < 0 or self:GetPropSize(prop) <= self.LimitSize)
    -- then
    --     dprint("\n\nGIVE ME TRUE\n\n")
    --     return true
    -- else
    --     dprint("\n\nFALSE FALSE FALSE\n\n")
    --     dprint('normal')
    --     dprint(not (self.StorableClasses[prop:GetClassname()] == false))
    --     dprint(not (self.StorableNames[prop:GetName()] == false))
    --     dprint(not (self.StorableModels[prop:GetModelName()] == false))
    --     dprint('inverse')
    --     dprint(self.StorableClasses[prop:GetClassname()] == false)
    --     dprint(self.StorableNames[prop:GetName()] == false)
    --     dprint(self.StorableModels[prop:GetModelName()] == false)
    --     dprint('actual')
    --     dprint(self.StorableClasses[prop:GetClassname()])
    --     dprint(self.StorableNames[prop:GetName()])
    --     dprint(self.StorableModels[prop:GetModelName()])
    --     dprint()
    -- end

    -- Printing raw storage values directly
    -- dprint("IsValidEntity(prop)",IsValidEntity(prop))
    -- dprint("self.StorageEnabled",self.StorageEnabled)
    -- dprint("(self.StorageStack:Length() < self.MaxItems or self.MaxItems < 0)",(self.StorageStack:Length() < self.MaxItems or self.MaxItems < 0))
    -- dprint("load_store",prop:LoadBoolean("BackpackItem.EnableStorage"))
    -- dprint("self.StorableClasses[prop:GetClassname()]",self.StorableClasses[prop:GetClassname()])
    -- dprint("self.StorableNames[prop:GetName()]",self.StorableNames[prop:GetName()])
    -- dprint("self.StorableModels[prop:GetModelName()]",self.StorableModels[prop:GetModelName()])
    -- dprint("(self.LimitMass < 0 or prop:GetMass() <= self.LimitMass)",(self.LimitMass < 0 or prop:GetMass() <= self.LimitMass))
    -- dprint("(self.LimitSize < 0 or self:GetPropSize(prop) <= self.LimitSize)",(self.LimitSize < 0 or self:GetPropSize(prop) <= self.LimitSize))

    local load_store = prop:LoadBoolean("BackpackItem.EnableStorage")
    if not IsValidEntity(prop) then reason = "Invalid entity"
    elseif not self.StorageEnabled then reason = "Storage not enabled"
    elseif not (self.StorageStack:Length() < self.MaxItems or self.MaxItems < 0) then reason = "Too many items ("..self.StorageStack:Length().."/"..self.MaxItems..")"
    -- If prop store property is true then ignore storable tables.
    elseif load_store == false then reason = "Prop storage is set to false"
        -- If prop store property is default..
    elseif load_store == nil then
        -- ..can store if entity property is allowed
        if not self.StorableClasses[prop:GetClassname()]
            and not self.StorableNames[prop:GetName()]
            and not self.StorableModels[prop:GetModelName()] then reason = "Not in a storable table"
        -- ..but make sure it's not disallowed
        elseif self.StorableClasses[prop:GetClassname()] == false
            or self.StorableNames[prop:GetName()] == false
            or self.StorableModels[prop:GetModelName()] == false then reason = "Set to false in a storable table"
        end
    -- Also check other properties like size.
    elseif (self.LimitMass > 0 and prop:GetMass() > self.LimitMass) then reason = "Mass is too large ("..prop:GetMass().."/"..self.LimitMass..")"
    elseif (self.LimitSize > 0 and self:GetPropSize(prop) > self.LimitSize) then reason = "Size is too large ("..self:GetPropSize(prop).."/"..self.LimitSize..")"
    end

    if reason == nil then
        dprint("("..prop:GetClassname()..","..prop:GetName()..","..prop:GetModelName()..") passed storage check!")
    else
        dprint("("..prop:GetClassname()..","..prop:GetName()..","..prop:GetModelName()..") can't be stored in backpack because: "..reason)
    end
    dprint()
end

---Check if a prop is able to be stored at this time.
---@param prop EntityHandle
---@return boolean
function BackpackSystem:CanStoreProp(prop)
    -- if type(prop) == "string" then dprint(type(prop), prop) end
    if IsValidEntity(prop) then
        local load_store = prop:LoadBoolean("BackpackItem.EnableStorage")
        if self.StorageEnabled
        and (self.StorageStack:Length() < self.MaxItems or self.MaxItems < 0)
        -- If prop store property is true then ignore storable tables.
        and (load_store
            -- If prop store property is default or true..
            or (load_store ~= false
                -- ..can store if entity property is allowed
                and (self.StorableClasses[prop:GetClassname()]
                    or self.StorableNames[prop:GetName()]
                    or self.StorableModels[prop:GetModelName()]
                )
                -- ..but make sure it's not disallowed
                -- parenthesis after 'not' is required, Lua has bad language semantics!
                and not (self.StorableClasses[prop:GetClassname()] == false)
                and not (self.StorableNames[prop:GetName()] == false)
                and not (self.StorableModels[prop:GetModelName()] == false)
            ))
        -- Also check other properties like size.
        and (self.LimitMass < 0 or prop:GetMass() <= self.LimitMass)
        and (self.LimitSize < 0 or self:GetPropSize(prop) <= self.LimitSize)
        then
            return true
        end
    else
        dprint("For some reason CanStoreProp got invalid entity", prop)
    end
    return false
end

function BackpackSystem:PrintCanRetrieveProp(prop)
    print("\nPRINTING CAN RETRIEVE PROP")
    dprint("self.RetrievalEnabled", self.RetrievalEnabled)
    dprint("not Player:HasWeaponEquipped() or not self.RequireNoWeapon",not Player:HasWeaponEquipped() or not self.RequireNoWeapon)
    dprint("Player:GetCurrentWeaponReserves() == 0 or not self.RequireNoAmmo",Player:GetCurrentWeaponReserves() == 0 or not self.RequireNoAmmo)
    dprint("self.StorageStack:Contains(prop)", self.StorageStack:Contains(prop))
    dprint("self.OverrideAllowAllRetrieval",self.OverrideAllowAllRetrieval)
    dprint('prop:LoadBoolean("BackpackItem.EnableRetrieval")',prop:LoadBoolean("BackpackItem.EnableRetrieval"))
    dprint("self.RetrievalClassInventory[prop:GetClassname()]",self.RetrievalClassInventory[prop:GetClassname()])
    dprint("self.RetrievalNameInventory[prop:GetName()]",self.RetrievalNameInventory[prop:GetName()])
    dprint("self.RetrievalModelInventory[prop:GetModelName()]",self.RetrievalModelInventory[prop:GetModelName()])
    dprint("not (self.RetrievalClassInventory[prop:GetClassname()] == false)",not (self.RetrievalClassInventory[prop:GetClassname()] == false))
    dprint("not (self.RetrievalNameInventory[prop:GetName()] == false)",not (self.RetrievalNameInventory[prop:GetName()] == false))
    dprint("not (self.RetrievalModelInventory[prop:GetModelName()] == false)",not (self.RetrievalModelInventory[prop:GetModelName()] == false))
    print()
end

---Check if a prop is able to be retrieved at this time.
---@param prop EntityHandle
---@return boolean
function BackpackSystem:CanRetrieveProp(prop)
    if self.RetrievalEnabled
    -- and not self.StorageStack:IsEmpty()
    and (not Player:HasWeaponEquipped() or not self.RequireNoWeapon)
    and (Player:GetCurrentWeaponReserves() == 0 or not self.RequireNoAmmo)
    and self.StorageStack:Contains(prop)
    and (self.OverrideAllowAllRetrieval
        or (prop:LoadBoolean("BackpackItem.EnableRetrieval")
            or self.RetrievalClassInventory[prop:GetClassname()]
            or self.RetrievalNameInventory[prop:GetName()]
            or self.RetrievalModelInventory[prop:GetModelName()])
            -- parenthesis after 'not' is required, Lua has bad language semantics!
        and not (self.RetrievalClassInventory[prop:GetClassname()] == false)
        and not (self.RetrievalNameInventory[prop:GetName()] == false)
        and not (self.RetrievalModelInventory[prop:GetModelName()] == false)
        )
    then
        return true
    end
    return false
end

---Move a prop to the top of the storage stack if it exists in backpack.
---@param prop EntityHandle
function BackpackSystem:MovePropToTop(prop)
    self.StorageStack:MoveToTop(prop)
end

---Get the top item waiting to be retrieved.
---Takes into account valid classes and orders and any retrieval properties set.
---Will remove any encountered invalid props.
---
---Can be used instead of CanRetrieveProp for greater safety.
---@return EntityHandle?
function BackpackSystem:GetTopProp()

    local best_prop = nil
    local markedForDeletion = {}

    for i = 1, #self.StorageStack.items do
        local prop = self.StorageStack.items[i]
        --  Invalid props need to be removed after finding the best one
        if not IsValidEntity(prop) then
            markedForDeletion[#markedForDeletion+1] = prop
        else
            -- print("CAN RETRIVE?", self:CanRetrieveProp(prop))
            if self:CanRetrieveProp(prop) then
                best_prop = prop
                break
            end
        end
    end

    -- Delete any encountered invalid props.
    for _, prop in ipairs(markedForDeletion) do
        self.StorageStack:Remove(prop)
    end

    return best_prop
end

---Move a prop to the virtual backpack target.
---@param prop EntityHandle
function BackpackSystem:MovePropToBackpack(prop)
    prop:SetOrigin(self.VirtualBackpackTarget:GetOrigin())
    -- dprint("Moved", prop:GetModelName(), prop:GetOrigin())
    prop:SetParent(nil, "")
end

---Put a prop in the backpack.
---If it already exists in the backpack then it is just warped back to the virtual target.
---@param prop EntityHandle
function BackpackSystem:PutPropInBackpack(prop)
    -- prop:SetParent(self._VirtualBackpackTarget, "")
    -- prop:SetLocalOrigin(Vector())
    -- prop:SetParent(Player, "")
    -- prop:SetLocalOrigin(Vector(128,0,64))
    -- prop:SetAbsScale(0)
    if not self.StorageStack:Contains(prop) then

        -- THIS IS DEBUG REMOVE!!
        -- if prop:GetName() == "" then
        --     prop:SetEntityName(DoUniqueString("prop_stored_in_backpack"))
        -- end

        self:MovePropToBackpack(prop)
        self:SetPropProperties(prop, true)
        for _, child in ipairs(prop:GetChildren()) do
            self:SetPropProperties(child, true)
        end
        self.StorageStack:Push(prop)
        Storage.SaveStack(self.StorageEntity, self.UniqueName..".StorageStack", self.StorageStack)

        -- THIS IS DEBUG REMOVE!!
        -- self:PrintPropsInBackpack()
        -- dprint("\n\nPRINTING STORED ITEMS TEST")
        -- print(self.StorageEntity:GetClassname())
        -- local t = Storage.LoadTable(self.StorageEntity, self.UniqueName..".StorageStack.items", nil)
        -- dprint(type(t))
        -- if type(t) == "table" then Debug.PrintTable(t) end

        -- Event Callback
        if self.EventCallback then
            self.EventCallback({
                type = BACKPACK_EVENT.ITEM_STORED;
                item = prop;
            })
        end
    end
end

---Remove a prop from the backpack, or the top prop.
---@param prop? EntityHandle
---@return EntityHandle?
function BackpackSystem:RemovePropFromBackpack(prop)
    -- dprint("Removing prop from backpack")
    if prop then
        local i = vlua.find(self.StorageStack.items, prop)
        if i then
            table.remove(self.StorageStack.items, i)
        end
    else
        prop = self:GetTopProp()
        self.StorageStack:Pop()
    end
    if prop then
        -- dprint("Prop that is being removed is", prop, prop:GetModelName())
        prop:SetParent(nil, "")
        self:SetPropProperties(prop, false)
        for _, child in ipairs(prop:GetChildren()) do
            self:SetPropProperties(child, false)
        end
        Storage.SaveStack(self.StorageEntity, self.UniqueName..".StorageStack", self.StorageStack)
        return prop
    end
    return nil
end

---Set the properties of a prop for in or out of backpack.
---@param prop EntityHandle
---@param inBackpack boolean
function BackpackSystem:SetPropProperties(prop, inBackpack)
    if inBackpack then
        -- dprint('set inside', prop:GetModelName())
        -- if prop.SetRenderAlpha then prop:SaveNumber("BackpackItem.SavedAlpha", prop:GetRenderAlpha()) prop:SetRenderAlpha(0) end
        if prop.SetHealth then prop:SaveNumber("BackpackItem.SavedHealth", prop:GetHealth()) prop:SetHealth(99999) end
        -- if prop.DisableMotion then prop:DisableMotion() end
    else
        -- dprint('set outside', prop:GetModelName())
        -- if prop.SetRenderAlpha then prop:SetRenderAlpha(prop:LoadNumber("BackpackItem.SavedAlpha", 255)) end
        if prop.SetHealth then prop:SetHealth(prop:LoadNumber("BackpackItem.SavedHealth", prop:GetMaxHealth())) end
        -- if prop.EnableMotion then prop:EnableMotion() end
    end
end

-- Returns if the given entity is touching the backpack.
---@param prop EntityHandle
function BackpackSystem:IsPropTouchingBackpack(prop)
    return self.BackpackTrigger:IsTouching(prop)
end

-- Attach a given entity to a given hand with a predefined offset.
---@param prop EntityHandle # The prop to move.
---@param hand CPropVRHand # The hand to move to.
---@param attach? boolean # If the prop should also be parented.
function BackpackSystem:MovePropToHand(prop, hand, attach)
    local side = hand:GetHandID()
    local offset = prop:LoadVector("BackpackItem.GrabOffset", Vector())
    -- Mirror offset if it's left hand
    if side == 0 then
        local axis = Vector(0, 1, 0)
        offset = offset - 2 * offset:Dot(axis) * axis
    end
    prop:SetOrigin(hand:TransformPointEntityToWorld(offset))
    -- Rotate hand angle by grab angle to keep angle consistent every time
    -- Angle is not mirrored to the left hand like offset above, how can this be done?
    local angle = RotateOrientation(hand:GetAngles(), prop:LoadQAngle("BackpackItem.GrabAngle", QAngle()))
    prop:SetAngles(angle.x,angle.y,angle.z)
    if attach then
        prop:SetParent(hand, "")
    end
end

---Destroys all props in backpack.
function BackpackSystem:ClearBackpack()
    for _, prop in ipairs(self.StorageStack.items) do
        prop:Kill()
    end
    self.StorageStack.items = {}
end

---Get the number of props currently stored in the backpack.
function BackpackSystem:GetPropCount()
    return self.StorageStack:Length()
end

--#endregion BackpackSystem class functions

--#endregion System functions
