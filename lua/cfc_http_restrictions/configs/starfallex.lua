---@diagnostic disable-next-line: undefined-global
if not SF then return end

AddCSLuaFile()

local config = {
    version = "1",
    addresses = {
        ["thegrb93.github.io"] = { allowed = true },
    }
}

return config
