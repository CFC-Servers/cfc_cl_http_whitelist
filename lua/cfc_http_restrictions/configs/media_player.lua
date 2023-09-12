if not file.Exists("entities/mediaplayer_tv", "LUA") then return end

AddCSLuaFile()

local config = {
    version = "1",
    addresses = {
        ["samuelmaddock.github.io"] = { allowed = true },
    }
}

return config
