CFCHTTP = CFCHTTP or {}

AddressCache = {}
ParsedAddressCache = {}

function CFCHTTP.getAddress( url )
    local cached = ParsedAddressCache[url]
    if cached then return cached end

    local pattern = "(%a+)://([%a%d%.-]+):?(%d*)/?.*"
    local  _,  _, protocol, addr, port = string.find( url, pattern )
    ParsedAddressCache[url] = addr

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

function CFCHTTP.checkAllowed( url )
    if not url then return end

    local address = CFCHTTP.getAddress( url )
    if not address then return end

    local options = CFCHTTP.config.addresses[address]
    if options and not options.pattern then
        return options.allowed
    end

    for allowedAddr, options in pairs( CFCHTTP.config.addresses) do
        if not options.pattern then
            options = escapeAddr( allowedAddr )
        end

        if string.match( address, "^"..allowedAddr.."$" ) then
            return options.allowed
        end
    end
end

function CFCHTTP.isAllowed( url )
    local cached = AddressCache[url]
    if cached ~= nil then return cached end

    local isAllowed = CFCHTTP.checkAllowed( url )
    AddressCache[url] = isAllowed

    return isAllowed
end

-- file based config functions
function CFCHTTP.allowAddress( addr )
    if CFCHTTP.config.addresses[addr] ~= nil and CFCHTTP.config.addresses[addr].permanent then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.config.addresses[addr] = {
        _edited=true,
        allowed=true,
    }

    AddressCache = {}

    return true
end

function CFCHTTP.blockAddress( addr )
    if CFCHTTP.config.addresses[addr] ~= nil and CFCHTTP.config.addresses[addr].permanent then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.config.addresses[addr] = {
        _edited=true,
        allowed=false,
    }

    AddressCache = {}

    return true
end

function CFCHTTP.removeAddress( addr )
    if CFCHTTP.adresses[addr] ~= nil and CFCHTTP.config.addresses[addr].permanent then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.config.addresses[addr] = nil
    AddressCache = {}

    return true
end