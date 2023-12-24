
local limit = 50

---comment
---@param io IOParams
local function CheckAxe(io)
    -- local blade = io.activator:ScriptLookupAttachment("blade")
    -- io.activator:GetAttachmentOrigin(blade)
    -- Is there a way to get if a point is inside entity OBB?
    if IsInToolsMode() then
        print("Linear:", GetPhysVelocity(io.activator):Length())
        print("Angular:", GetPhysAngularVelocity(io.activator):Length())
    end
    if GetPhysVelocity(io.activator):Length() > limit
    or GetPhysAngularVelocity(io.activator):Length() > limit
    then
        thisEntity:FireOutput("OnUser1", io.activator, io.caller, nil, 0)
    end
end
Expose(CheckAxe)
