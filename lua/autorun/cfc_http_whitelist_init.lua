AddCSLuaFile()

CFCHTTP = CFCHTTP or {}

local function includeClient( f )
    if SERVER then
        AddCSLuaFile( f )
    else
        include( f )
    end
end

local function includeShared( f )
    AddCSLuaFile( f )
    include( f )
end

includeShared( "cfc_http_restrictions/shared/logging.lua" )
includeShared( "cfc_http_restrictions/shared/config_loader.lua" )
includeShared( "cfc_http_restrictions/shared/filetypes.lua" )
includeShared( "cfc_http_restrictions/shared/list_manager.lua" )
includeShared( "cfc_http_restrictions/shared/url.lua" )

includeClient( "cfc_http_restrictions/client/list_view.lua" )
includeClient( "cfc_http_restrictions/client/wrap_functions.lua" )

AddCSLuaFile( "cfc_http_restrictions/wraps/http.lua" )
AddCSLuaFile( "cfc_http_restrictions/wraps/html.lua" )
AddCSLuaFile( "cfc_http_restrictions/wraps/playURL.lua" )
