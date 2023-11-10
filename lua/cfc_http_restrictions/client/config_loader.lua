local function requestNetworkedConfig()
    net.Start( "CFCHTTP_RequestConfig" )
    net.SendToServer()
end

local function loadConfigsClient()
    ---@type (fun(): WhitelistConfig)[]
    local configSources = {}
    table.Add(configSources, CFCHTTP.LuaDirectorySources( CFCHTTP.filenames.sharedConfigsDir ))
    table.Add(configSources, CFCHTTP.LuaDirectorySources( CFCHTTP.filenames.clientConfigsDir ))
    table.insert(configSources, CFCHTTP.LuaTableSources( CFCHTTP.networkedConfig ) )
    table.insert(configSources, CFCHTTP.FileSource( CFCHTTP.filenames.defaultJsonConfig ))

    CFCHTTP.LoadConfig( configSources )
end

net.Receive( "CFCHTTP_ConfigUpdate", function()
    local l = net.ReadDouble()
    if l > 0 then
        local config = util.JSONToTable( util.Decompress( net.ReadData( l ) ) )
        CFCHTTP.networkedConfig = config
        loadConfigsClient()
        CFCHTTP.repopulateListPanel()
    end
end )

loadConfigsClient()
hook.Add("InitPostEntity", "CFCHTTP_Init_Config", requestNetworkedConfig)
