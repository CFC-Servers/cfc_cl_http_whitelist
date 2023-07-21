local HTML = {
    name = "HTML",
    allowed = true,
    extension = "html",
    maxFileSize = 0,
}
CFCHTTP.FileTypes.HTML = HTML

-- Not implemented
---@param body string
---@return boolean
function HTML.IsFileData( body )
    return false
end

---@param url string
---@return boolean
function HTML.IsFileURL( url )
    if string.EndsWith( url, "." .. HTML.extension ) then return true end
    return false
end

local function getUrlsFromText( text )
    local pattern = "%a+://[%a%d%.-]+:?%d*/?[a-zA-Z0-9%.]*"

    local urls = {}
    for url in string.gmatch( text, pattern ) do
        table.insert( urls, url )
    end

    return urls
end

---@param body string
---@return string[] urls
---@return string|nil error
function HTML.GetURLSFromData( body )
    local urls = getUrlsFromText( body )
    return urls, nil
end
