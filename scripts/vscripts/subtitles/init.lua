--[[
    This is cannibalization of a custom FFI file system specifically for Vinny Almost Misses Christmas.
    FFI is DANGEROUS if used without explicit understanding of the code.
    
    Do NOT use this code in your own project without consulting and gaining permission from FrostEpex:
    GitHub: https://github.com/FrostSource
    Discord: FrostEpex#0001
]]
---@diagnostic disable: undefined-field

print("Initiating custom subtitles...")

local _ = 0x666ULL
local ffi = require"ffi"
local __msvcrt = ffi.load("msvcrt")
ffi.cdef[[
    typedef void* FILE;
    void *malloc(size_t size);
    int _access(const char *path, int mode);
    FILE *fopen(const char *filename, const char *mode);
    size_t fwrite(const void *buffer,size_t size,size_t count,FILE *stream);
    int fclose(FILE *stream);
    int remove(const char *path);
    ]]
local exists = function(path)
    return __msvcrt._access(path, 0) == 0
end
-- local subtitles_path = Path("../../hlvr/resource/subtitles/")
local subtitles_path = "../../hlvr/resource/subtitles/"
local subtitles_path2 = "../../core/resource/subtitles/"
if not exists(subtitles_path) then
    Warning("Subtitles folder not found. Custom subtitles will not work.")
end

ifrequire("subtitles.data", function(subtitles_data)
    local function write_all_bytes(filepath, bytes)
        local len = #bytes
        local cbytes = ffi.cast("char*",__msvcrt.malloc(len))
        for i = 1, len do
            cbytes[i-1] = bytes[i]
        end
        local f = __msvcrt.fopen(filepath, "wb")
        __msvcrt.fwrite(cbytes, 1, len, f)
        __msvcrt.fclose(f)
    end

    local lang = Convars:GetStr("cl_language")
    if not subtitles_data.languages[lang] then
        print(lang .. " is not supported for Vinny Almost Misses Christmas subtitles")
        return
    end

    local cc_format = subtitles_path .. "closecaption_%s_"..subtitles_data.mod..".dat"
    local cc_format2 = subtitles_path2 .. "closecaption_%s_"..subtitles_data.mod..".dat"
    local fname = cc_format:format(lang)
    local fname2 = cc_format2:format(lang)

    -- local should_delete_file = true

    -- Can just load captions
    if exists(fname) then
        RegisterPlayerEventCallback("player_activate", function()
            print("Setting cc_lang", lang.."_"..subtitles_data.mod)
            SendToConsole("cc_lang "..lang.."_"..subtitles_data.mod)
        end, nil)
    else
        -- Requires write and reload
        -- should_delete_file = false

        -- written_files[#written_files+1] = f
        print("Writing subtitle file: "..fname)
        write_all_bytes(fname, subtitles_data.languages[lang])
        write_all_bytes(fname2, subtitles_data.languages[lang])
        -- ---@param params PLAYER_EVENT_PLAYER_ACTIVATE
        -- RegisterPlayerEventCallback("player_activate", function(params)
        --     if not params.game_loaded then
        --         print("Restarting map")
        --         SendToConsole("addon_play vinny_house")
        --     else
        --         Warning("\n\nSubtitles will not function until map is reloaded!\n\n\n")
        --     end
        -- end, nil)

        RegisterPlayerEventCallback("player_activate", function()
            print("Setting cc_lang", lang.."_"..subtitles_data.mod)
            SendToConsole("cc_lang "..lang.."_"..subtitles_data.mod)
        end, nil)
    end



    -- local written_files = {}

    

    -- For when vinny_christmas supports multiple languages
    -- for language, bytes in pairs(subtitles_data.languages) do
    --     local f = cc_format:format(language, subtitles_data.mod)
    --     print("Writing subtitle file: "..f)
    --     written_files[#written_files+1] = f
    --     -- local f = subtitles_path .. "closecaption_" .. language .. "_" .. subtitles_data.mod .. ".dat"
    --     write_all_bytes(f, bytes)
    -- end
    -- ListenToGameEvent("player_activate", function()
    --     print("Setting cc_lang", lang.."_"..subtitles_data.mod)
    --     SendToConsole("cc_lang "..lang.."_"..subtitles_data.mod)
    -- end, nil)

    -- RegisterMapShutdownCallback(function()
    --     for _, file in ipairs(written_files) do
    --         print("Deleting subtitle file: "..file)
    --         if exists(file) then
    --             __msvcrt.remove(file)
    --         end
    --     end
    -- end)

end)



