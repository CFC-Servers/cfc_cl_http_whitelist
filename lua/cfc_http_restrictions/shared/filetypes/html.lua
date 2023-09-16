local HTML = {
    name = "HTML",
    extension = "html",
    maxFileSize = 0,
}
CFCHTTP.FileTypes.HTML = HTML

---@param _body string
---@return boolean
---@diagnostic disable-next-line: unused-local
function HTML.IsFileData( _body )
    return false
end

---@param body string
---@return string[] urls
---@return string|nil error
function HTML.GetURLSFromData( body )
    local urls = CFCHTTP.FindURLs( body )
    return urls, nil
end
