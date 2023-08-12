---@package
function CFCHTTP.loadClientFileConfig()
    local fileConfig = CFCHTTP.ReadFileConfig()
    if fileConfig then
        CFCHTTP.config = CFCHTTP.mergeConfigs( CFCHTTP.config, fileConfig )
    end
end

---@package
---@param dir string|nil
function CFCHTTP.loadLuaConfigs( dir )
    dir = dir or "cfc_http_restrictions/configs/"
    local files = file.Find( dir .. "*.lua", "LUA" )
    for _, fil in pairs( files ) do
        local newConfig = include( dir .. fil )
        CFCHTTP.config = CFCHTTP.mergeConfigs( CFCHTTP.config, newConfig )
    end
end

---@package
---@param dir string|nil
function CFCHTTP.addCSLuaConfigs( dir )
    dir = dir or "cfc_http_restrictions/configs/"
    local files = file.Find( dir .. "*.lua", "LUA" )
    for _, fil in pairs( files ) do
        AddCSLuaFile( dir .. fil )
    end
end

---@package
---@param file string|nil
function CFCHTTP.loadDefaultConfg( file )
    file = file or "cfc_http_restrictions/default_config.lua"
    CFCHTTP.config = include( file )
end

function CFCHTTP.LoadConfigsClient()
    CFCHTTP.loadDefaultConfg()
    CFCHTTP.loadLuaConfigs()
    CFCHTTP.loadLuaConfigs( "cfc_http_restrictions/configs/client/" )
    CFCHTTP.loadClientFileConfig()
end

function CFCHTTP.LoadConfigsServer()
    CFCHTTP.loadDefaultConfg()
    CFCHTTP.loadLuaConfigs()
    CFCHTTP.loadLuaConfigs( "cfc_http_restrictions/configs/server/" )
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

function CFCHTTP.CopyConfig( cfg )
    return util.JSONToTable( util.TableToJSON( cfg ) )
end

function CFCHTTP.SaveFileConfig( config )
    file.Write( "cfc_cl_http_whitelist_config.json", util.TableToJSON( config, true ) )

    notification.AddLegacy( "Saved http whitelist", NOTIFY_GENERIC, 5 )
end

function CFCHTTP.ReadFileConfig()
    local fileData = file.Read( "cfc_cl_http_whitelist_config.json" )
    if not fileData then return end

    return util.JSONToTable( fileData )
end

if CLIENT then
    CFCHTTP.LoadConfigsClient()
else
    CFCHTTP.addCSLuaConfigs()
    CFCHTTP.addCSLuaConfigs( "cfc_http_restrictions/configs/client/" )

    CFCHTTP.LoadConfigsServer()
end
