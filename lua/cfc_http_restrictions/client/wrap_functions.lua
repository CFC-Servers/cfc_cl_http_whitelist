hook.Add( "Initialize", "CFC_HttpWhitelist_WrapHTML", function()
    ProtectedCall( include, "cfc_http_restrictions/wraps/dhtml.lua" )
end )
