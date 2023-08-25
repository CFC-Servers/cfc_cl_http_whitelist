local function wrapHTTP()
    _HTTP = _HTTP or HTTP
    print( "HTTP wrapped, original function at '_G._HTTP'" )

    HTTP = function( req )
        local options = CFCHTTP.GetOptionsForURL( req.url )
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split( debug.traceback(), "\n" )
        CFCHTTP.LogRequest( {
            noisy = noisy,
            method = req.method,
            fileLocation = stack[3],
            urls = { { url = req.url, status = isAllowed and "allowed" or "blocked" } },
        } )

        local onFailure = req.failed
        if not isAllowed then
            if onFailure then onFailure( "URL is not whitelisted" ) end
            return
        end
        _HTTP( req )
    end
end

local function wrapFetch()
    _http_Fetch = _http_Fetch or http.Fetch
    print( "http.Fetch wrapped, original function at '_http_Fetch'" )

    ---@diagnostic disable-next-line: duplicate-set-field
    http.Fetch = function( url, onSuccess, onFailure, headers )
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
            if onFailure then onFailure( "URL is not whitelisted" ) end
            return
        end

        _http_Fetch( url, onSuccess, onFailure, headers )
    end
end

local function wrapPost()
    _http_Post = _http_Post or http.Post
    print( "http.Post wrapped, original function at '_http_Post'" )

    ---@diagnostic disable-next-line: duplicate-set-field
    http.Post = function( url, params, onSuccess, onFailure, headers )
        local options = CFCHTTP.GetOptionsForURL( url )
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split( debug.traceback(), "\n" )
        CFCHTTP.LogRequest( {
            noisy = noisy,
            method = "POST",
            fileLocation = stack[3],
            urls = { { url = url, status = isAllowed and "allowed" or "blocked" } },
        } )

        if not isAllowed then
            if onFailure then onFailure( "URL is not whitelisted" ) end
            return
        end

        _http_Post( url, params, onSuccess, onFailure, headers )
    end
end

-- the URI was blocked because it was not in the whitelist
CFCHTTP.BASS_ERROR_BLOCKED_URI = 11001
-- unused: the request was blocked after inspecting the content
-- this is likely because the content could result in playing blocked URIs
CFCHTTP.BASS_ERROR_BLOCKED_CONTENT = 11002

local function wrapPlayURL()
    _sound_PlayURL = _sound_PlayURL or sound.PlayURL
    print( "sound.PlayURL wrapped, original function at _sound_PlayUrl" )

    ---@diagnostic disable-next-line: duplicate-set-field
    sound.PlayURL = function( url, flags, callback )
        local stack = string.Split( debug.traceback(), "\n" )

        local options = CFCHTTP.GetOptionsForURL( url )
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local logData = {
            noisy = noisy,
            method = "GET",
            fileLocation = stack[3],
            urls = { { url = url, status = isAllowed and "allowed" or "blocked" } },
        }

        if not isAllowed then
            CFCHTTP.LogRequest( logData )
            if callback then callback( nil, CFCHTTP.BASS_ERROR_BLOCKED_URI, "BASS_ERROR_BLOCKED_URI" ) end
            return
        end

        CFCHTTP.GetFileDataURLS( url, function( uris, err )
            if err ~= nil then
                print( "Error getting URLs: " .. err )
                if callback then callback( nil, CFCHTTP.BASS_ERROR_BLOCKED_CONTENT, "BASS_ERROR_BLOCKED_CONTENT" ) end
                return
            end

            if #uris == 0 then
                CFCHTTP.LogRequest( logData )
                _sound_PlayURL( url, flags, callback )
                return
            end

            local multiOptions = CFCHTTP.GetOptionsForURLs( uris )
            isAllowed = multiOptions.combined.allowed

            CFCHTTP.LogRequest( logData )
            if not isAllowed then
                if callback then callback( nil, CFCHTTP.BASS_ERROR_BLOCKED_CONTENT, "BASS_ERROR_BLOCKED_CONTENT" ) end
                return
            end

            _sound_PlayURL( url, flags, callback )
        end )
    end
end


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
        CFCHTTP.LogRequest( {
            noisy = true,
            method = "GET",
            fileLocation = stack[3],
            urls = logUrls,
        } )

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

        CFCHTTP.LogRequest( {
            noisy = true,
            method = "GET",
            fileLocation = stack[3],
            urls = logUrls,
        } )

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

hook.Add( "Initialize", "CFC_HttpWhitelist_WrapHTML", function()
    if CFCHTTP.config.wrapHTMLPanels then
        wrapHTMLPanel( "DHTML" )
        wrapHTMLPanel( "DPanel" )
        wrapHTMLPanel( "DMediaPlayerHTML" )
    end
end )

wrapHTTP()
wrapFetch()
wrapPost()
wrapPlayURL()
