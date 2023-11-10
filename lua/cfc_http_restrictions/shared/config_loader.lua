CFCHTTP.filenames = {
    defaultLuaConfig = "cfc_http_restrictions/default_config.lua",
    defaultJsonConfig = "cfc_cl_http_whitelist_config.json",
    serverClientJsonConfig = "cfchttp_client_config.json",
    sharedConfigsDir = "cfc_http_restrictions/configs/",
    serverConfigsDir = "cfc_http_restrictions/configs/server/",
    clientConfigsDir = "cfc_http_restrictions/configs/client/",
}

---@param sources (fun(): WhitelistConfig)[]
function CFCHTTP.LoadConfig( sources )
    CFCHTTP.config = include( CFCHTTP.filenames.defaultLuaConfig )
    for _, source in pairs( sources ) do
        local config = source()
        if config then
            CFCHTTP.config = CFCHTTP.mergeConfigs( CFCHTTP.config, config )
        end
    end
end

---@param filename string
---@return fun(): WhitelistConfig|nil
function CFCHTTP.FileSource( filename )
    return function()
        return CFCHTTP.ReadFileConfig( filename )
    end
end

---@param filename string
---@return fun(): WhitelistConfig
function CFCHTTP.LuaFileSource( filename )
    return function()
        return include( filename )
    end
end

---@param dir string
---@return fun(): WhitelistConfig[]
function CFCHTTP.LuaDirectorySources( dir )
    ---@type (fun(): WhitelistConfig)[]
    local funcs = {}
    local files = file.Find( dir .. "*.lua", "LUA" )

    for _, fil in pairs( files ) do
        table.insert( funcs, CFCHTTP.LuaFileSource( dir .. fil ) )
    end

    return funcs
end

---@param tbl WhitelistConfig
---@return fun(): WhitelistConfig
function CFCHTTP.LuaTableSources( tbl )
    return function()
        return tbl
    end
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
