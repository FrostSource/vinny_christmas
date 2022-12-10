
---comment
---@param io TypeIOInvoke
function HasMilk(_, io)
    -- Commented to allow for errors
    -- if io and io.activator then
        if io.activator:HasAttribute("has_milk") then
            io.caller:EntFire("FireUser1")
        end
    -- end
end
