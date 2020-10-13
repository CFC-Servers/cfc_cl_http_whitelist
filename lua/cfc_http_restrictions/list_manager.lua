CFCHTTP = CFCHTTP or {}

CFCHTTP.allowedAddresses = {}

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
    CFCHTTP.allowedAddresses[addr] = true
end

function CFCHTTP.blockAddress( addr )
    CFCHTTP.allowedAddresses[addr] = false
end

function CFCHTTP.removeAddress( addr )
    CFCHTTP.allowedAddresses[addr] = nil
end

function CFCHTTP.saveList()
    file.CreateDir( "cfc" )
    file.Write( "cfc/http_whitelist.json", util.TableToJSON( CFCHTTP.allowedAddresses ) )
end

function CFCHTTP.readList()
    CFCHTTP.allowedAddresses = util.JSONToTable( file.Read( "cfc/http_whitelist.json" ) or "{}" ) or {}
end

CFCHTTP.readList()
