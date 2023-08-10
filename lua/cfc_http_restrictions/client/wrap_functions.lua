local shouldLogAllows = CreateConVar( "cfc_http_restrictions_log_allows", 1, FCVAR_ARCHIVE, "Should the HTTP restrictions log allowed HTTP requests?", 0, 1 )
local shouldLogBlocks = CreateConVar( "cfc_http_restrictions_log_blocks", 1, FCVAR_ARCHIVE, "Should the HTTP restrictions log blocked HTTP requests?", 0, 1 )
local verboseLogging = CreateConVar( "cfc_http_restrictions_log_verbose", 0, FCVAR_ARCHIVE, "Should the HTTP restrictions log include verbose messages?", 0, 1 )

local COLORS = {
    RED = Color( 255, 0, 0 ),
    GREEN = Color( 0, 255, 0 ),
    GREY = Color( 136, 151, 158 ),
    YELLOW = Color( 235, 226, 52 )
}

local function logRequest( method, url, fileLocation, allowed, noisy )
    if allowed and not shouldLogAllows:GetBool() then return end
    if not shouldLogBlocks:GetBool() then return end

    local isVerbose = verboseLogging:GetBool()
    local requestStatus = allowed and "ALLOWED" or "BLOCKED"
    local requestColor = allowed and COLORS.GREEN or COLORS.RED

    if not url then
        url = "unknown"
    elseif isVerbose == false then
        local address = CFCHTTP.getAddress( url )
        if noisy then return end

        url = address
    end

    MsgC(
        requestColor, requestStatus,
        COLORS.GREY, ": ",
        COLORS.YELLOW, method,
        COLORS.GREY, " - ",
        COLORS.YELLOW, url, "\n"
    )

    if isVerbose then
        MsgC( COLORS.YELLOW, "    ", fileLocation, "\n" )
    end
end

local function wrapHTTP()
    _HTTP = _HTTP or HTTP
    print( "HTTP wrapped, original function at '_G._HTTP'" )

    HTTP = function( req )
        local options = CFCHTTP.GetOptionsForURL( req.url )
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split( debug.traceback(), "\n" )
        logRequest( req.method, req.url, stack[3], isAllowed, noisy )
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

    http.Fetch = function( url, onSuccess, onFailure, headers )
        local options = CFCHTTP.GetOptionsForURL( url )
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split( debug.traceback(), "\n" )
        logRequest( "GET", url, stack[3], isAllowed, noisy )
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

    http.Post = function( url, params, onSuccess, onFailure, headers )
        local options = CFCHTTP.GetOptionsForURL( url )
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split( debug.traceback(), "\n" )
        logRequest( "POST", url, stack[3], isAllowed, noisy )
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

        if not isAllowed then
            logRequest( "GET", url, stack[3], isAllowed, noisy )
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
                logRequest( "GET", url, stack[3], isAllowed, noisy )
                _sound_PlayURL( url, flags, callback )
                return
            end

            options = CFCHTTP.GetOptionsForURLs( uris )
            isAllowed = options.combined.allowed

            logRequest( "GET", url, stack[3], isAllowed, noisy )
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
        local urls, err = CFCHTTP.FileTypes.HTML.GetURLSFromData( html )
        local options = CFCHTTP.GetOptionsForURLs( urls )

        local isAllowed
        if #urls == 0 then
            isAllowed = true
        else
            isAllowed = err == nil and options.combined and options.combined.allowed
        end

        local stack = string.Split( debug.traceback(), "\n" )
        logRequest( "GET", options.combinedUri, stack[3], isAllowed )

        if not isAllowed then
            html = [[<h1> BLOCKED </h1>]]
        end

        _G[setHTML]( self, html, ... )
    end

    controlTable.RunJavascript = function( self, js )
        print( js )
        local urls, err = CFCHTTP.FileTypes.HTML.GetURLSFromData( js )
        local options = CFCHTTP.GetOptionsForURLs( urls )

        local isAllowed
        if #urls == 0 then
            isAllowed = true
        else
            isAllowed = err == nil and options.combined and options.combined.allowed
        end

        local stack = string.Split( debug.traceback(), "\n" )
        logRequest( "GET", options.combinedUri, stack[3], isAllowed )

        if not isAllowed then
            return
        end

        _G[runJavascript]( self, js )
    end

    controlTable.OpenURL = function( self, url, ... )
        local options = CFCHTTP.GetOptionsForURL( url )
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split( debug.traceback(), "\n" )
        logRequest( "GET", url, stack[3], isAllowed, noisy )

        if not isAllowed then return end

        _G[openURL]( self, url, ... )
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
