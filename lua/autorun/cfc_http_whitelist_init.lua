AddCSLuaFile()

local function includeClient( f )
    if SERVER then
        AddCSLuaFile( f )
    else
        include( f )
    end
end

includeClient( "cfc_http_restrictions/list_manager.lua" )
includeClient( "cfc_http_restrictions/list_view.lua" )
includeClient( "cfc_http_restrictions/wrap_functions.lua" )
