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

CFCHTTP.LoadConfigs()

if SERVER then
    local enabledCvar = CFCHTTP.svEnabled

    cvars.AddChangeCallback( enabledCvar:GetName(), function( _, _, new )
        if new == "1" then
            CFCHTTP.WrapFunctions()
        else
            CFCHTTP.UnwrapFunctions()
        end
    end, "CFC_HTTP_Restrictions" )

    local enabled = enabledCvar:GetBool()
    if not enabled then return end

    CFCHTTP.WrapFunctions()
else
    CFCHTTP.WrapFunctions()
end
