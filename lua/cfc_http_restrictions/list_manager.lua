CFCHTTP = CFCHTTP or {}

CFCHTTP.alwaysAllowed = {
    ["*cfcservers.org"] = true,
    ["google.com"] = true,
}

CFCHTTP.allowedAddresses = {
    ["youtube.com"] = true,
    ["youtu.be"] = true,
}

local function getAddress( url )
    local pattern = "(%a+)://([%a%d%.-]+):?(%d*)/?.*"
    local  _,  _, protocol, addr, port  = string.find( url, pattern )
    return addr
end

-- escapes all lua pattern characters and allows the use of * as a wildcard
local escaped = {}
local function escapeAddr( addr )
    if escaped[addr] then return escaped[addr] end

    local split = string.Split( addr, "*" )
    for i=1, #split do
        split[i] = string.PatternSafe(split[i])
    end

    escaped[addr] = table.concat( split, ".*" )
    return escaped[addr]
end

function CFCHTTP.isAllowed( url )
    if not url then return end

    local address = getAddress( url )
    if not address then return end

    if CFCHTTP.allowedAddresses[address] then
        return CFCHTTP.allowedAddresses[address]
    end

    for allowed, isAllowed in pairs( CFCHTTP.allowedAddresses ) do
        local allowed = escapeAddr( allowed )
        if string.match( address, allowed ) then
            return isAllowed
        end
    end
end

function CFCHTTP.allowAddress( addr )
    if CFCHTTP.alwaysAllowed[addr] ~= nil then
         notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.allowedAddresses[addr] = true
    return true
end

function CFCHTTP.blockAddress( addr )
    if CFCHTTP.alwaysAllowed[addr] ~= nil then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.allowedAddresses[addr] = false
    return true
end

function CFCHTTP.removeAddress( addr )
    if CFCHTTP.alwaysAllowed[addr] ~= nil then
         notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.allowedAddresses[addr] = nil
    return true
end

function CFCHTTP.saveList()
    file.CreateDir( "cfc" )
    file.Write( "cfc/http_whitelist.json", util.TableToJSON( CFCHTTP.allowedAddresses ) )

    notification.AddLegacy( "Saved http whitelist", NOTIFY_GENERIC, 5 )
end

function CFCHTTP.readList()
    CFCHTTP.allowedAddresses = util.JSONToTable( file.Read( "cfc/http_whitelist.json" ) or "" ) or CFCHTTP.allowedAddresses

    table.Merge( CFCHTTP.allowedAddresses, CFCHTTP.alwaysAllowed )
end

CFCHTTP.readList()
