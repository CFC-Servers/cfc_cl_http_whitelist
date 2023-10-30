local function requestNetworkedConfig()
    net.Start( "CFCHTTP_RequestConfig" )
    net.SendToServer()
end

local function loadConfigsClient()
    CFCHTTP.LoadConfig( {
        CFCHTTP.LuaDirectorySources( CFCHTTP.filenames.sharedConfigsDir ),
        CFCHTTP.LuaDirectorySources( CFCHTTP.filenames.clientConfigsDir ),
        CFCHTTP.LuaTableSources( CFCHTTP.networkedConfig ),
        CFCHTTP.FileSource( CFCHTTP.filenames.defaultJsonConfig ),
    } )
end

net.Receive( "CFCHTTP_ConfigUpdate", function()
    local l = net.ReadDouble()
    local config = util.JSONToTable( util.Decompress( net.ReadData( l ) ) )
    CFCHTTP.networkedConfig = config

    loadConfigsClient()
    CFCHTTP.repopulateListPanel()
end )

loadConfigsClient()
hook.Add("InitPostEntity", "CFCHTTP_Init_Config", requestNetworkedConfig)
