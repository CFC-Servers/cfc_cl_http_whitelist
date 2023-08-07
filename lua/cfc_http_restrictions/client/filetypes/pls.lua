CFCHTTP.FileTypes.PLS = {
    name = "PLS",
    allowed = true,
    extension = ".pls",
    maxFileSize = 10000,
}
local PLS = CFCHTTP.FileTypes.PLS


---@param body string
---@return table data
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
---@return boolean
function PLS.IsFileData( body )
    if string.find( body, "%[playlist%]" ) then return true end
    return false
end

---@param url string
---@return boolean
function PLS.IsFileURL( url )
    if string.EndsWith( url, "." .. PLS.extension ) then return true end
    return false
end

---@param text string
---@return string[] urls
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
function PLS.GetURLSFromData( body )
    if #body > PLS.maxFileSize then return {}, "body too large" end
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

return PLS
