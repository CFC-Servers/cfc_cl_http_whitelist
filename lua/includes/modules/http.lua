AddCSLuaFile()

-- file.Read is not available yet
local originalFile = file.Open( "garrysmod/lua/includes/modules/http.lua", "r", "BASE_PATH" )
local code = originalFile:Read( originalFile:Size() )
originalFile:Close()

local f = CompileString( code, "lua/includes/modules/http.lua", false )

if SERVER then
    local svEnabled = CreateConVar( "cfc_http_restrictions_sv_enabled", "0", FCVAR_ARCHIVE, "Enable server-side HTTP whitelisting", 0, 1 )
    if svEnabled:GetBool() then
        ProtectedCall( include, "cfc_http_restrictions/wraps/http.lua" )
    end
end

if CLIENT then
    ProtectedCall( include, "cfc_http_restrictions/wraps/http.lua" )
    ProtectedCall( include, "cfc_http_restrictions/wraps/playURL.lua" )
end

f()
