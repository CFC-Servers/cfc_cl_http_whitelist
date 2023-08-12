CFCHTTP = CFCHTTP or {}


local parsedAddressCache = {}
---@parm url string
---@return string
function CFCHTTP.getAddress( url )
    local cached = parsedAddressCache[url]
    if cached then return cached end

<<<<<<< HEAD:lua/cfc_http_restrictions/shared/list_manager.lua
    local pattern = "(%a+)://([^:/ \t]+):?(%d*)/?.*"
=======
    local pattern = "(%a+)://([%a%d%.-]+):?(%d*)/?.*"
>>>>>>> main:lua/cfc_http_restrictions/client/list_manager.lua
    local _, _, _, addr, _ = string.find( url, pattern )
    parsedAddressCache[url] = addr

    return addr
end

function CFCHTTP.isAssetURI( url )
    return string.StartWith( url, "asset://" )
end

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

-- TODO reimmplement caching
function CFCHTTP.GetOptionsForURL( url )
    if not url then return CFCHTTP.config.defaultOptions end

    if CFCHTTP.isAssetURI( url ) then return CFCHTTP.config.defaultAssetURIOptions end

    local address = CFCHTTP.getAddress( url )
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

--- Returns the options for a list of URLs
---@param urls string[]
---@return {options: table<string, table>, combined: table|nil, combinedUri: string|nil}
function CFCHTTP.GetOptionsForURLs( urls )
    local out = {
        combined = nil,
        options = {},
    }
    for _, url in pairs( urls ) do
        local options = CFCHTTP.GetOptionsForURL( url )
        out.options[url] = options
        if options and not options.allowed then
            out.combined = options
            out.combinedUri = url
        elseif not out.combined then
            out.combined = options
            out.combinedUri = url
        end
    end
    if out.combined == nil then
        out.combined = CFCHTTP.config.defaultOptions
    end

    return out
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
