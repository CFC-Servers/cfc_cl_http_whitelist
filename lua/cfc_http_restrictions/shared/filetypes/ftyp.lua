-- https://www.ftyps.com/what.html
CFCHTTP.FileTypes.FTYP = {
    name = "ftyp",
}
local FTYP = CFCHTTP.FileTypes.FTYP

---@param body string
---@return boolean
function FTYP.IsFileData( body )
    body = string.sub( body, 5 ) -- discord size bytes
    if not string.StartsWith( body, "ftyp" ) then return false end

    return true
end

---@param _ string
---@return string[] urls
---@return string|nil error
function FTYP.GetURLSFromData( _ )
    -- we want to ignore urls in FTYP containers
    return {}, nil
end
