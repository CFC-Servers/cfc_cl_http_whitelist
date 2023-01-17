AddCSLuaFile()

CFCHTTP = CFCHTTP or {}
CFCHTTP.config = include( "cfc_http_restrictions/default_config.lua" )

if SERVER then
    CFCHTTP.svEnabled = CreateConVar( "cfc_http_restrictions_enabled", 0, FCVAR_ARCHIVE + FCVAR_PROTECTED, "Should the HTTP restrictions be enabled?", 0, 1 )
end

function CFCHTTP.LoadConfigs()
    CFCHTTP.config = include( "cfc_http_restrictions/default_config.lua" )
    CFCHTTP.loadLuaConfigs()

    CFCHTTP.readFileConfig( function( fileConfig )
        CFCHTTP.config = CFCHTTP.mergeConfigs( CFCHTTP.config, fileConfig )
    end )
end

-- loadLuaConfigs loads the default config and then any lua files in the cfc_http_restrictions/configs/ and cfc_http_restrictions/configs/server/ directories
function CFCHTTP.loadLuaConfigs()
    local configDir = "cfc_http_restrictions/configs/"

    local clFiles = file.Find( configDir .. "*.lua", "LUA" )
    for _, fileName in ipairs( clFiles ) do
        local filePath = configDir .. fileName
        AddCSLuaFile( filePath )

        if CLIENT then
            local newConfig = include( filePath )
            CFCHTTP.config = CFCHTTP.mergeConfigs( CFCHTTP.config, newConfig )
        end
    end

    if CLIENT then return end

    local svFiles = file.Find( configDir .. "server/*.lua", "LUA" )
    for _, fileName in ipairs( svFiles ) do
        local filePath = configDir .. "server/" .. fileName
        local newConfig = include( filePath )
        CFCHTTP.config = CFCHTTP.mergeConfigs( CFCHTTP.config, newConfig )
    end
end

function CFCHTTP.mergeConfigs( old, new )
    if new.version == "1" then
        if new.wrapHTMLPanels ~= nil then old.wrapHTMLPanels = new.wrapHTMLPanels end
        if new.defaultOptions ~= nil then old.defaultOptions = new.defaultOptions end
        if new.defaultAssetURIOption ~= nil then old.defaultAssetURIOption = new.defaultAssetURIOption end

        for domain, options in pairs( new.addresses ) do
            local currentOptions = old.addresses[domain]
            if currentOptions and currentOptions.permanent then
                print( "[CFC HTTP Restrictions] Skipping " .. domain .. " because it is permanent" )
            else
                old.addresses[domain] = options
            end
        end
    else
        ErrorNoHalt( "[CFC HTTP Restrictions] Invalid config version: " .. tostring( new.version ) )
    end

    return old
end

function CFCHTTP.getConfigFileName()
    return string.format( "cfc_%s_http_whitelist_config.json", SERVER and "sv" or "cl" )
end

function CFCHTTP.readFileConfig( cb )
    local fileName = CFCHTTP.getConfigFileName()
    file.AsyncRead( fileName, "DATA", function( _, _, _, contents )
        if not contents then return end

        local config = util.JSONToTable( contents )
        if not config then return end

        cb( config )
    end )
end

function CFCHTTP.copyConfig( cfg )
    return util.JSONToTable( util.TableToJSON( cfg ) )
end

function CFCHTTP.saveFileConfig( config )
    local fileName = CFCHTTP.getConfigFileName()
    file.Write( fileName, util.TableToJSON( config, true ) )

    notification.AddLegacy( "Saved http whitelist", NOTIFY_GENERIC, 5 )
end
