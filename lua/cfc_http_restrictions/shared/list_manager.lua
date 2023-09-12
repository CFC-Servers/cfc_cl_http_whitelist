CFCHTTP = CFCHTTP or {}

-- escapes all lua pattern characters and allows the use of * as a wildcard
local escapedCache = {}
local function escapeAddr( addr )
    if escapedCache[addr] then return escapedCache[addr] end

    local split = string.Split( addr, "*" )
    for i = 1, #split do
        split[i] = string.PatternSafe( split[i] )
    end

    escapedCache[addr] = table.concat( split, ".*" )
    return escapedCache[addr]
end

---@param url string
---@return WhitelistAddressOption
function CFCHTTP.GetOptionsForURL( url )
    if not url then return CFCHTTP.config.defaultOptions end

    if CFCHTTP.IsAssetURI( url ) then return CFCHTTP.config.defaultAssetURIOptions end

    local address = CFCHTTP.GetAddress( url )
    if not address then return CFCHTTP.config.defaultOptions end

    local options = CFCHTTP.config.addresses[address]
    if options and not options.pattern then
        return options
    end

    for allowedAddr, optionsAddr in pairs( CFCHTTP.config.addresses ) do
        if not optionsAddr.pattern then
            allowedAddr = escapeAddr( allowedAddr )
        end

        if string.match( address, "^" .. allowedAddr .. "$" ) then
            return optionsAddr
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
        _edited = true,
        allowed = true,
    }

    return true
end

function CFCHTTP.blockAddress( addr )
    if CFCHTTP.config.addresses[addr] ~= nil and CFCHTTP.config.addresses[addr].permanent then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.config.addresses[addr] = {
        _edited = true,
        allowed = false,
    }

    return true
end

function CFCHTTP.removeAddress( addr )
    if CFCHTTP.config.addresses[addr] ~= nil and CFCHTTP.config.addresses[addr].permanent then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.config.addresses[addr] = nil

    return true
end
