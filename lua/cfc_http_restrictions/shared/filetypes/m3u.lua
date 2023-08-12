CFCHTTP.FileTypes.M3U = {
    name = "M3U",
    allowed = false,
    extension = "m3u",
    maxFileSize = 0,
}
local M3U = CFCHTTP.FileTypes.M3U

---@param body string
---@return boolean
function M3U.IsFileData( body )
    local endPos = string.find( body, "\n" )
    local firstLine = string.sub( body, 1, endPos )
    if string.find( firstLine, "#EXTM3U" ) then return true end
    return false
end

---@param url string
---@return boolean
function M3U.IsFileURL( url )
    if string.EndsWith( url, "." .. M3U.extension ) then return true end
    return false
end

---@param _ string
---@return string[] urls
---@return string|nil error
function M3U.GetURLSFromData( _ )
    return {}, "m3u parsing not implemented"
end

return M3U
