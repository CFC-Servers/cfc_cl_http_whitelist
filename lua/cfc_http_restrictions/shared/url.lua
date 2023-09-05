---@class URLData
---@field protocol string
---@field address string
---@field port number
---@field path string


CFCHTTP.URLPattern = "(%a+)://([^:/ \t]+):?(%d*)/?.*"
CFCHTTP.URLPatternNoGroups = "%a+://[^:/ \t\"]+:?%d*/?[^\n\" \\]*"

---@param url string
---@return URLData
function CFCHTTP.ParseURL( url )
    local pattern = CFCHTTP.URLPattern
    local _, _, protocol, address, port, remainder = string.find( url, pattern )
    return {
        protocol = protocol,
        address = address,
        port = tonumber( port ),
        path = remainder
    }
end

---@param text string
---@return string[]
function CFCHTTP.FindURLs( text )
    local pattern = CFCHTTP.URLPatternNoGroups

    local urls = {}
    for url in string.gmatch( text, pattern ) do
        table.insert( urls, url )
    end

    return urls
end

---@param url string
---@return string
function CFCHTTP.URLEncode( url )
    url = url:gsub( "[^%w ]", function( c )
        return string.format( "%%%02X", string.byte( c ) )
    end )
    return url
end

function CFCHTTP.GetRedirectURL( url )
    url = string.Replace( url, "\n", "" )
    url = string.Trim( url )
    local b64 = CFCHTTP.URLEncode( url )

    return "https://gmhttp.pages.dev/redirect?url=" .. b64
end

---@param text string
---@param f fun( url:string ):string
---@return string
function CFCHTTP.ReplaceURLs( text, f )
    local html = string.gsub( text, CFCHTTP.URLPatternNoGroups, f )
    return html
end

local parsedAddressCache = CFCHTTP.LimitedCache.New( 1000, 60 * 60 )
---@param url string
---@return string|nil
function CFCHTTP.GetAddress( url )
    if not url then return end
    local cached = parsedAddressCache:Get( url )
    if cached then return cached end

    local data = CFCHTTP.ParseURL( url )
    parsedAddressCache:Set( url, data.address )

    return data.address
end

function CFCHTTP.IsAssetURI( url )
    return string.StartWith( url, "asset://" )
end
