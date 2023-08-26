---@diagnostic disable-next-line: undefined-global
if not MediaPlayer then return end

AddCSLuaFile()

local config = {
    version = "1",
    addresses = {
        ["samuelmaddock.github.io"] = { allowed = true },
    }
}

return config
