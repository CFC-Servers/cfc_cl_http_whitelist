CFCHTTP.FileTypes.ID3 = {
    name = "ID3",
}
local ID3 = CFCHTTP.FileTypes.ID3

---@param body string
---@return boolean
function ID3.IsFileData( body )
    if not string.StartsWith( body, "ID3" ) then return false end

    return true
end

---@param _ string
---@return string[] urls
---@return string|nil error
function ID3.GetURLSFromData( _ )
    -- we want to ignore urls in ID3 container metadata
    return {}, nil
end

return ID3
