CFCHTTP = CFCHTTP or {}
CFCHTTP.allowedAddresses = {
    ["youtube.com"] = {allowed=true},
    ["youtu.be"] = {allowed=true},
    ["*cfcservers.org"] = {allowed=true, isPermanent=true},
    ["google.com"] = {allowed=true, isPermanent=true},
}


local function getAddress( url )
    local pattern = "(%a+)://([%a%d%.-]+):?(%d*)/?.*"
    local  _,  _, protocol, addr, port = string.find( url, pattern )
    return addr
end

-- escapes all lua pattern characters and allows the use of * as a wildcard
local escaped = {}
local function escapeAddr( addr )
    if escaped[addr] then return escaped[addr] end

    local split = string.Split( addr, "*" )
    for i=1, #split do
        split[i] = string.PatternSafe( split[i] )
    end

    escaped[addr] = table.concat( split, ".*" )
    return escaped[addr]
end

function CFCHTTP.isAllowed( url )
    if not url then return end

    local address = getAddress( url )
    if not address then return end

    local allowedEntry = CFCHTTP.allowedAddresses[address]
    if allowedEntry and allowedEntry.allowed and not allowedEntry.isPattern then
        return allowedEntry.allowed
    end

    for allowedAddr, allowedEntry in pairs( CFCHTTP.allowedAddresses ) do
        if not allowedEntry.isPattern then
            allowedAddr = escapeAddr( allowedAddr )
        end
        print(address, allowedAddr)
        if string.match( address, allowedAddr ) then
            return allowedEntry.allowed
        end
    end
end

function CFCHTTP.allowAddress( addr, isPattern, isPermanent )
    if CFCHTTP.allowedAddresses[addr] ~= nil and CFCHTTP.allowedAddresses[addr].isPermanent then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.allowedAddresses[addr] = {
        allowed=true,
        isPattern=isPattern,
        isPermanent=isPermanent
    }
    return true
end

function CFCHTTP.blockAddress( addr )
   if CFCHTTP.allowedAddresses[addr] ~= nil and CFCHTTP.allowedAddresses[addr].isPermanent then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.allowedAddresses[addr] = {
        allowed=false,
        isPattern=isPattern,
        isPermanent=isPermanent
    }
    return true
end

function CFCHTTP.removeAddress( addr )
    if CFCHTTP.allowedAddresses[addr] ~= nil and CFCHTTP.allowedAddresses[addr].isPermanent then
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
end

CFCHTTP.readList()
