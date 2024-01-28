---@diagnostic disable-next-line: undefined-global
if not file.Exists( "entities/starfall_processor/cl_init.lua", "LUA" ) then return end

AddCSLuaFile()

local config = {
    version = "1",
    addresses = {
        ["thegrb93.github.io"] = { allowed = true },
    }
}

return config
