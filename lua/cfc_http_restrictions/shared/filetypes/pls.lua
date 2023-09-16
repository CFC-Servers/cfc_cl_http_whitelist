CFCHTTP.FileTypes.PLS = {
    name = "PLS",
    extension = ".pls",
}
local PLS = CFCHTTP.FileTypes.PLS

---@param body string
---@return boolean
function PLS.IsFileData( body )
    if string.find( body, "[playlist]", 1, true ) then return true end
    return false
end

---@param _body string
---@return string[] urls
---@return string|nil error
---@diagnostic disable-next-line: unused-local
function PLS.GetURLSFromData( _body )
    return {}, "pls files are not allowed"
end

return PLS
