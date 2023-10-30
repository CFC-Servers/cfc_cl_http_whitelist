AddCSLuaFile()

CFCHTTP = CFCHTTP or {}

local function includeClient( f )
    if SERVER then
        AddCSLuaFile( f )
    else
        include( f )
    end
end

local function includeServer( f )
    if SERVER then
        include( f )
    end
end

local function includeShared( f )
    AddCSLuaFile( f )
    include( f )
end

local function runOnDir( dir, action )
    local files = file.Find( dir .. "/*.lua", "LUA" )
    for _, filename in pairs( files ) do
        action( dir .. "/" .. filename )
    end
end

includeShared( "cfc_http_restrictions/shared/netmiddleware.lua" )
includeShared( "cfc_http_restrictions/shared/logging.lua" )
includeShared( "cfc_http_restrictions/shared/config_loader.lua" )
includeShared( "cfc_http_restrictions/shared/filetypes.lua" )
includeShared( "cfc_http_restrictions/shared/list_manager.lua" )
includeShared( "cfc_http_restrictions/shared/url.lua" )

includeClient( "cfc_http_restrictions/client/list_view.lua" )
includeClient( "cfc_http_restrictions/client/wrap_functions.lua" )
includeClient( "cfc_http_restrictions/client/config_loader.lua" )
includeClient( "cfc_http_restrictions/client/integrations.lua")

runOnDir( "cfc_http_restrictions/wraps", AddCSLuaFile )
includeServer( "cfc_http_restrictions/server/config_loader.lua" )
