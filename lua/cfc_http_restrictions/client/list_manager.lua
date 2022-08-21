CFCHTTP = CFCHTTP or {}


local parsedAddressCache = {}
function CFCHTTP.getAddress( url )
    local cached = parsedAddressCache[url]
    if cached then return cached end

    local pattern = "(%a+)://([%a%d%.-]+):?(%d*)/?.*"
    local  _,  _, protocol, addr, port = string.find( url, pattern )
    parsedAddressCache[url] = addr

    return addr
end

function CFCHTTP.isAssetURI(url)
    return string.StartWith(url, "asset://")
end

-- escapes all lua pattern characters and allows the use of * as a wildcard
local escapedCache = {}
local function escapeAddr( addr )
    if escapedCache[addr] then return escapedCache[addr] end

    local split = string.Split( addr, "*" )
    for i=1, #split do
        split[i] = string.PatternSafe( split[i] )
    end

    escapedCache[addr] = table.concat( split, ".*" )
    return escapedCache[addr]
end

function CFCHTTP.getOptionsForURI(url)
    if not url then return end

    if CFCHTTP.isAssetURI(url) then return CFCHTTP.config.defaultAssetURIConfig end

    local address = CFCHTTP.getAddress( url )
    if not address then return end

    local options = CFCHTTP.config.addresses[address]
    if options and not options.pattern then
        return options
    end

    for allowedAddr, options in pairs( CFCHTTP.config.addresses) do
        if not options.pattern then
            options = escapeAddr( allowedAddr )
        end

        if string.match( address, "^"..allowedAddr.."$" ) then
            return options
        end
    end
end

-- TODO reimmplement caching
function CFCHTTP.getOptionsForURI(url)
    if not url then return CFCHTTP.config.defaultOptions end

    if CFCHTTP.isAssetURI(url) then return CFCHTTP.config.defaultAssetURIOptions end

    local address = CFCHTTP.getAddress( url )
    if not address then return CFCHTTP.config.defaultOptions end

    local options = CFCHTTP.config.addresses[address]
    if options and not options.pattern then
        return options
    end

    for allowedAddr, options in pairs( CFCHTTP.config.addresses) do
        if not options.pattern then
            options = escapeAddr( allowedAddr )
        end

        if string.match( address, "^"..allowedAddr.."$" ) then
            return options
        end
    end

    return CFCHTTP.config.defaultOptions 
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

    return true
end

function CFCHTTP.removeAddress( addr )
    if CFCHTTP.adresses[addr] ~= nil and CFCHTTP.config.addresses[addr].permanent then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.config.addresses[addr] = nil

    return true
end