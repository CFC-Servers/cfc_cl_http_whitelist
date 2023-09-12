AddCSLuaFile()

-- file.Read is not available yet
local originalFile = file.Open( "lua/includes/modules/http.lua", "rb", "MOD" )
local code = originalFile:Read( originalFile:Size() )
originalFile:Close()

local f = CompileString( code, "lua/includes/modules/http.lua", false )

if CLIENT then
    ProtectedCall( function()
        include( "cfc_http_restrictions/wraps/http.lua" )
    end )
    ProtectedCall( function()
        include( "cfc_http_restrictions/wraps/playURL.lua" )
    end )
end

print( "Running wrapped http.lua" )
f()
