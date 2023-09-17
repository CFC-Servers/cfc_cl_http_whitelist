-- loads data file based configs on the client
---@package
function CFCHTTP.loadClientFileConfig()
    local fileConfig = CFCHTTP.ReadFileConfig( "cfc_cl_http_whitelist_config.json" )
    if fileConfig then
        CFCHTTP.config = CFCHTTP.mergeConfigs( CFCHTTP.config, fileConfig )
    end
end

-- loads data file based configs on the server
---@package
function CFCHTTP.loadServerFileConfig()
    local fileConfig = CFCHTTP.ReadFileConfig( "cfchttp_server_config.json" )
    if fileConfig then
        CFCHTTP.config = CFCHTTP.mergeConfigs( CFCHTTP.config, fileConfig )
    end

    -- networkedClientConfig is a config structure meant to be networked to clients
    CFCHTTP.networkedClientConfig = CFCHTTP.ReadFileConfig( "cfchttp_client_config.json" )
end

-- loads a tbl into the config if it is not nil
---@package
---@param tbl WhitelistConfig|nil
function CFCHTTP.loadTableConfig( tbl )
    if tbl then
        CFCHTTP.config = CFCHTTP.mergeConfigs( CFCHTTP.config, tbl )
    end
end

---@package
---@param dir string|nil
function CFCHTTP.loadLuaConfigs( dir )
    dir = dir or "cfc_http_restrictions/configs/"
    local files = file.Find( dir .. "*.lua", "LUA" )
    for _, fil in pairs( files ) do
        local newConfig = include( dir .. fil )
        if newConfig then
            CFCHTTP.config = CFCHTTP.mergeConfigs( CFCHTTP.config, newConfig )
        end
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
---@param configFile string|nil
function CFCHTTP.loadDefaultConfg( configFile )
    configFile = configFile or "cfc_http_restrictions/default_config.lua"
    CFCHTTP.config = include( configFile )
end

function CFCHTTP.LoadConfigsClient()
    CFCHTTP.loadDefaultConfg()
    CFCHTTP.loadLuaConfigs()
    CFCHTTP.loadLuaConfigs( "cfc_http_restrictions/configs/client/" )
    CFCHTTP.loadNetworkedConfigs()
    CFCHTTP.loadClientFileConfig()
end

function CFCHTTP.LoadConfigsServer()
    CFCHTTP.loadDefaultConfg()
    CFCHTTP.loadLuaConfigs()
    CFCHTTP.loadLuaConfigs( "cfc_http_restrictions/configs/server/" )
    CFCHTTP.loadServerFileConfig()
end

---@param old any
---@param new WhitelistConfig
---@return WhitelistConfig
function CFCHTTP.mergeConfigs( old, new )
    if new.version == "1" then
        if new.wrapHTMLPanels ~= nil then old.wrapHTMLPanels = new.wrapHTMLPanels end
        if new.defaultOptions ~= nil then old.defaultOptions = new.defaultOptions end
        if new.defaultAssetURIOptions ~= nil then old.defaultAssetURIOptions = new.defaultAssetURIOptions end

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

---@param cfg WhitelistConfig
---@return WhitelistConfig
function CFCHTTP.CopyConfig( cfg )
    return util.JSONToTable( util.TableToJSON( cfg ) )
end

---@param filename string
---@param config WhitelistConfig
function CFCHTTP.SaveFileConfig( filename, config )
    file.Write( filename, util.TableToJSON( config, true ) )

    if CLIENT then
        notification.AddLegacy( "Saved http whitelist", NOTIFY_GENERIC, 5 )
    end
end

---@param filename string
---@return WhitelistConfig|nil
function CFCHTTP.ReadFileConfig( filename )
    local fileData = file.Read( filename )
    if not fileData then return nil end

    return util.JSONToTable( fileData )
end

util.AddNetworkString( "CFCHTTP_ConfigUpdate" )
function CFCHTTP.SendClientConfig( ply )
    local data = util.Compress( util.TableToJSON( CFCHTTP.networkedClientConfig ) )
    net.Start( "CFCHTTP_ConfigUpdate" )
    net.WriteDouble( #data )
    net.WriteString( data )
    net.Send( ply )
end

if CLIENT then
    net.Receive( "CFCHTTP_ConfigUpdate", function()
        local l = net.ReadDouble()
        local config = util.JSONToTable( util.Decompress( net.ReadData( l ) ) )
        CFCHTTP.networkedConfig = config

        CFCHTTP.LoadConfigsClient()
    end )
end

if CLIENT then
    CFCHTTP.LoadConfigsClient()
else
    CFCHTTP.addCSLuaConfigs()
    CFCHTTP.addCSLuaConfigs( "cfc_http_restrictions/configs/client/" )

    CFCHTTP.LoadConfigsServer()
end
