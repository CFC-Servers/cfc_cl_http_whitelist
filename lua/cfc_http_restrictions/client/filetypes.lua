CFCHTTP.FileTypes = CFCHTTP.FIleTypes or {}

local files, _ = file.Find( "cfc_http_restrictions/client/filetypes/*.lua", "LUA" )
for _, f in pairs( files ) do
    include( "cfc_http_restrictions/client/filetypes/" .. f )
    AddCSLuaFile( "cfc_http_restrictions/client/filetypes/" .. f )
end

---@param data string
---@return table|nil
function CFCHTTP.getFileType( data )
    for _, f in pairs( CFCHTTP.FileTypes ) do
        if f.IsFileData( data ) then
            return f
        end
    end
    return nil
end

---@param url string
---@param callback fun( urls: string[], err: string|nil)
function CFCHTTP.GetFileDataURLS( url, callback )
    http.Fetch( url, function( body, _, _, code )
        if code < 200 or code > 299 then
            callback( {}, "HTTP request returned status code " .. code )
            return
        end

        local filetype = CFCHTTP.getFileType( body )
        if filetype then
            local urls, err = filetype.GetURLSFromData( body )
            if err then
                callback( {}, err )
            else
                if #urls == 0 then
                    callback( {}, "No URLs found in file" )
                    return
                end
                callback( urls, nil )
            end
        else
            callback( {}, nil )
        end
    end )
end