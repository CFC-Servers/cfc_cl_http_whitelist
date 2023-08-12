CFCHTTP.version = "1.0.0"

local messages = {}
hook.Add( "PlayerInitialSpawn", "myAddonName/Load", function( ply )
    if ply:IsSuperAdmin() then
        timer.Simple( 30, function()
            for _, msg in ipairs( messages ) do
                ply:ChatPrint( msg )
            end
        end )
    end
end )

local function notify( msg )
    table.insert( messages, msg )
end

---@param v string
---@param v2 string
---@return boolean
--- returns true if v is newer than v2
local function isVersionNewer( v, v2 )
    local splitNewVersion = string.Split( v, "." )
    local newMajor, newMinor, newPatch = tonumber( splitNewVersion[1] ), tonumber( splitNewVersion[2] ), tonumber( splitNewVersion[3] )
    local splitOldVersion = string.Split( v2, "." )
    local oldMajor, oldMinor, oldPatch = tonumber( splitOldVersion[1] ), tonumber( splitOldVersion[2] ), tonumber( splitOldVersion[3] )

    if newMajor ~= oldMajor then
        return newMajor > oldMajor
    end

    if newMinor ~= oldMinor then
        return newMinor > oldMinor
    end

    if newPatch ~= oldPatch then
        return newPatch > oldPatch
    end

    return false
end

hook.Add( "Think", "CFCHTTP_UpdateCheck", function()
    hook.Remove( "Think", "CFCHTTP_UpdateCheck" )

    local http = _HTTP or HTTP
    http {
        url = "https://raw.githubusercontent.com/CFC-Servers/cfc_cl_http_whitelist/main/update.json",
        method = "GET",
        success = function( code, body, headers )
            local data = util.JSONToTable( body )
            if not data then return end
            if not data.version then
                return
            end
            if data.version == CFCHTTP.version then
                return
            end
            if not isVersionNewer( data.minimumVersion, CFCHTTP.version ) then
                return
            end
            notify( "\n" )
            notify( "Your version of CFC HTTP Whitelist is bellow the minimum safe version." )
            notify( "Please update to the latest version." )
            notify( "\n" )
        end

    }
end )
