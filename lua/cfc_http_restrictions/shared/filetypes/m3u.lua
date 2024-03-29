CFCHTTP.FileTypes.M3U = {
    name = "M3U",
    extension = "m3u",
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

---@param _ string
---@return string[] urls
---@return string|nil error
function M3U.GetURLSFromData( _ )
    return {}, "m3u files are not allowed"
end

return M3U
