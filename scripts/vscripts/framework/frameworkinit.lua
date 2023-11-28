
if IsServer() then
    if not pcall(require, "core") then
        Warning("`scripts/vscripts/core.lua` was not found!")
    end
    require "vc.global"

    if IsInToolsMode() or Convars:GetInt("developer") > 0 then
        local debug_script = "debug." .. GetMapName()
        if not pcall(require, debug_script) then
            Warning("`"..debug_script.."` script was not found!")
        end
    end

    ---@type table<function,boolean|table>
    local map_shutdown_callbacks = {}
    ---Registers a function to be called just before the server is shut down.
    ---This will not execute if the game closes from a hard crash.
    ---@param func function # Function to call.
    ---@param context table # Any table data to send as first argument.
    function _G.RegisterMapShutdownCallback(func, context)
        map_shutdown_callbacks[func] = context or true
    end
    local function ServerShutdown()
        print("Server shutdown...")
        for func, context in pairs(map_shutdown_callbacks) do
            if context ~= true then
                func(context)
            else
                func()
            end
        end
    end
    ListenToGameEvent("server_shutdown", ServerShutdown, nil)

    if not pcall(require, "subtitles.init") then
        Warning("`scripts/vscripts/subtitles/init.lua` was not found!")
    end
end