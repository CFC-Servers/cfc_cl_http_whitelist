local function wrapHTMLPanel( panelName )
    print( "Wrapping SetHTML and OpenURL for " .. panelName )
    local funcName = function( functionName )
        return "_" .. panelName .. "_" .. functionName
    end

    local controlTable = vgui.GetControlTable( panelName )

    local setHTML = funcName( "SetHTML" )
    local openURL = funcName( "OpenURL" )
    local runJavascript = funcName( "RunJavascript" )

    _G[setHTML] = _G[setHTML] or controlTable.SetHTML
    _G[openURL] = _G[openURL] or controlTable.OpenURL
    _G[runJavascript] = _G[runJavascript] or controlTable.RunJavascript

    controlTable.SetHTML = function( self, html, ... )
        local stack = string.Split( debug.traceback(), "\n" )

        local logUrls = {}
        html = CFCHTTP.ReplaceURLs( html, function( url )
            local options = CFCHTTP.GetOptionsForURL( url )
            local isAllowed = options and options.allowed

            local logUrl = { url = url, status = isAllowed and "allowed" or "replaced" }
            table.insert( logUrls, logUrl )

            if not isAllowed then
                return CFCHTTP.GetRedirectURL( url )
            end

            return url
        end )

        if #logUrls > 0 then
            CFCHTTP.LogRequest( {
                noisy = true,
                method = "GET",
                fileLocation = stack[3],
                urls = logUrls,
            } )
        end

        return _G[setHTML]( self, html, ... )
    end

    controlTable.RunJavascript = function( self, js )
        local stack = string.Split( debug.traceback(), "\n" )
        local logUrls = {}
        js = CFCHTTP.ReplaceURLs( js, function( url )
            local options = CFCHTTP.GetOptionsForURL( url )
            local isAllowed = options and options.allowed

            local logUrl = { url = url, status = isAllowed and "allowed" or "replaced" }
            table.insert( logUrls, logUrl )
            if not isAllowed then
                return CFCHTTP.GetRedirectURL( url )
            end

            return url
        end )

        if #logUrls > 0 then
            CFCHTTP.LogRequest( {
                noisy = true,
                method = "GET",
                fileLocation = stack[3],
                urls = logUrls,
            } )
        end

        return _G[runJavascript]( self, js )
    end

    controlTable.OpenURL = function( self, url, ... )
        local options = CFCHTTP.GetOptionsForURL( url )
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split( debug.traceback(), "\n" )
        CFCHTTP.LogRequest( {
            noisy = noisy,
            method = "GET",
            fileLocation = stack[3],
            urls = { { url = url, status = isAllowed and "allowed" or "blocked" } },
        } )

        if not isAllowed then
            url = CFCHTTP.GetRedirectURL( url )
        end

        return _G[openURL]( self, url, ... )
    end
end

wrapHTMLPanel( "DHTML" )
wrapHTMLPanel( "DPanel" )
wrapHTMLPanel( "DMediaPlayerHTML" )
