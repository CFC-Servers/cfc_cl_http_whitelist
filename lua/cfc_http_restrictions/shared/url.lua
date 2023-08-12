---@class URLData
---@field protocol string
---@field address string
---@field port number
---@field path string


CFCHTTP.URLPattern = "(%a+)://([^:/ \t]+):?(%d*)/?.*"

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
    local pattern = CFCHTTP.URLPattern

    local urls = {}
    for url in string.gmatch( text, pattern ) do
        table.insert( urls, url )
    end

    return urls
end
