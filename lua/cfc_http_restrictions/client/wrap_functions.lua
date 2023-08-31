hook.Add( "Initialize", "CFC_HttpWhitelist_WrapHTML", function()
    include( "cfc_http_restrictions/wraps/html.lua" )
end )
