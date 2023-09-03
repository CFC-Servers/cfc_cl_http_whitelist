hook.Add( "WA_IsWhitelistedURL", "CFC_HTTP_ShouldAllow", function( url )
    local options = CFCHTTP.GetOptionsForURL( url )
    -- TODO log request if blocked
    return options.allowed
end )

hook.Add( "WA_ShouldCheckStreamContent", "CFC_HTTP_ShouldCheckStreamContent", function( url )
    return false
end )
