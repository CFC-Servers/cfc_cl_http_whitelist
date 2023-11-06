util.AddNetworkString( "CFCHTTP_ConfigUpdate" )
util.AddNetworkString( "CFCHTTP_RequestConfig" )

local function sendClientConfig( ply )
    if not CFCHTTP.networkedClientConfig then
        net.Start( "CFCHTTP_ConfigUpdate" )
        net.WriteDouble( 0 )
        net.Send( ply )
    end

    local data = util.Compress( util.TableToJSON( CFCHTTP.networkedClientConfig ) )
    net.Start( "CFCHTTP_ConfigUpdate" )
    net.WriteDouble( #data )
    net.WriteData( data, #data )
    net.Send( ply )
end

CFCHTTP.Net.receiveWithMiddleware( "CFCHTTP_RequestConfig", function( _, ply )
    sendClientConfig( ply )
end, CFCHTTP.Net.rateLimit( "CFCHTTP_RequestConfig", 2, 10 ) )

local function loadConfigsServer()
    CFCHTTP.LoadConfig( {
        CFCHTTP.LuaDirectorySources( CFCHTTP.filenames.sharedConfigsDir ),
        CFCHTTP.LuaDirectorySources( CFCHTTP.filenames.serverConfigsDir ),
        CFCHTTP.FileSource( CFCHTTP.filenames.defaultJsonConfig ),
    } )

    local data = file.Read( CFCHTTP.filenames.serverClientJsonConfig, "DATA" )
    CFCHTTP.networkedClientConfig = data and util.JSONToTable( data )
end

local function addCSLuaConfigs( dir )
    local files = file.Find( dir .. "*.lua", "LUA" )
    for _, fil in pairs( files ) do
        AddCSLuaFile( dir .. fil )
    end
end


AddCSLuaFile( CFCHTTP.filenames.defaultLuaConfig )
addCSLuaConfigs( CFCHTTP.filenames.sharedConfigsDir )
addCSLuaConfigs( CFCHTTP.filenames.clientConfigsDir )
loadConfigsServer()
