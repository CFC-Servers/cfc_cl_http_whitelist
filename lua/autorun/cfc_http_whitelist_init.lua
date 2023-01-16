AddCSLuaFile()

local function includeClient( f )
    if SERVER then
        AddCSLuaFile( f )
    else
        include( f )
    end
end

include( "cfc_http_restrictions/config_loader.lua" )
include( "cfc_http_restrictions/list_manager.lua" )
include( "cfc_http_restrictions/wrap_functions.lua" )

includeClient( "cfc_http_restrictions/client/list_view.lua" )
