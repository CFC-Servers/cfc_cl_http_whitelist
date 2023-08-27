if not file.Exists("entities/starfall_processor", "LUA") then return end

AddCSLuaFile()

local config = {
    version = "1",
    addresses = {
        ["thegrb93.github.io"] = { allowed = true },
    }
}

return config
