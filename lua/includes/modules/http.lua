AddCSLuaFile()

-- file.Read is not available yet
local originalFile = file.Open( "garrysmod/lua/includes/modules/http.lua", "r", "BASE_PATH" )
local code = originalFile:Read( originalFile:Size() )
originalFile:Close()

local f = CompileString( code, "lua/includes/modules/http.lua", false )

ProtectedCall( include, "cfc_http_restrictions/wraps/http.lua" )

if CLIENT then
    ProtectedCall( include, "cfc_http_restrictions/wraps/playURL.lua" )
end

print( "Running wrapped http.lua" )
f()
