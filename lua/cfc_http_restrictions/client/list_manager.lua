CFCHTTP = CFCHTTP or {}


local parsedAddressCache = {}
function CFCHTTP.getAddress( url )
    local cached = parsedAddressCache[url]
    if cached then return cached end

    local pattern = "(%a+)://([%a%d%.-]+):?(%d*)/?.*"
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
function CFCHTTP.getOptionsForURI( url )
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

local function getUrlsFromText( text )
    local pattern = "%a+://[%a%d%.-]+:?%d*/?[a-zA-Z0-9%.]*"

    local urls = {}
    for url in string.gmatch( text, pattern ) do
        table.insert( urls, url )
    end

    return urls
end

---@param url string
---@param callback fun( allowed: boolean, url: string )
function CFCHTTP.isPLSUrlAllowed( url, callback )
    _http_Fetch( url, function( body, _ )
        local allowed, reason = CFCHTTP.isPLSDataAllowed( body )
        callback( allowed, reason )
    end, function( err )
        callback( false, err )
    end )
end

function CFCHTTP.isHTMLAllowed( html )
    local urls = getUrlsFromText( html )
    for _, url in pairs( urls ) do
        local options = CFCHTTP.getOptionsForURI( url )

        if options and not options.allowed then
            return false, url
        end
    end

    return true, ""
end

local function loadPLSFile( body )
    body = string.Replace( body, "\r\n", "\n" )
    body = string.Replace( body, "\r", "\n" )

    local lines = string.Split( body, "\n" )
    local section;
    local data = {}

    for _, line in ipairs( lines ) do
        local tempSection = line:match( "^%[([^%[%]]+)%]$" );
        if tempSection then
            section = tonumber( tempSection ) and tonumber( tempSection ) or tempSection;
            data[section] = data[section] or {};
        end

        local param, value = line:match( "^([%w|_]+)%s-=%s-(.+)$" );
        if param and value ~= nil then
            if tonumber( value ) then
                value = tonumber( value );
            end
            data[section][param] = value;
        end
    end

    return data;
end

---@param body string
---@return string[] urls
---@return string|nil errror
local function getUrlsFromPls( body )
    if #body > 10000 then return {}, "body too large" end
    local urls = getUrlsFromText( body )

    local plsData = loadPLSFile( body )
    if not plsData.playlist then
        return urls, "no playlist section"
    end

    for i = 1, 150 do
        local f = plsData.playlist["File" .. i]
        if not f then
            return urls, nil
        end
        table.insert( urls, f )
    end
    return urls, "too many files"
end

---@param body string
---@return boolean allowed is it allowed
---@return string url url or or reason
function CFCHTTP.isPLSDataAllowed( body )
    local urls, reason = getUrlsFromPls( body )
    if reason ~= nil then return false, reason end
    for _, url in pairs( urls ) do
        local options = CFCHTTP.getOptionsForURI( url )

        if options and not options.allowed then
            return false, url
        end
    end

    return true, ""
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
