local function logRequest( method, url, fileLocation, allowed )
    local blockedColor, blockedText
    if allowed then
        blockedText = "ALLOWED"
        blockedColor = Color(0, 255, 0)
    else
        blockedText = "BLOCKED"
        blockedColor = Color(255, 0, 0)
    end
    MsgC(
        blockedColor, blockedText,
        Color(136, 151, 158), ": ",
        Color(235, 226, 52), method,
        Color(136, 151, 158), " - ",
        Color(235, 226, 52), url,
        Color(235, 226, 52), "\n    ", fileLocation, "\n"
    )
end

local function wrapHTTP()
    _HTTP = _HTTP or HTTP
    print("HTTP wrapped, original function at '_G._HTTP'")

    HTTP = function( req )
        local isAllowed = CFCHTTP.isAllowed( url )
        local stack = string.Split(debug.traceback(), "\n")
        logRequest(req.method, req.url, stack[3], isAllowed )
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
    print("http.Fetch wrapped, original function at '_http_Fetch'")

    http.Fetch = function( url, onSuccess, onFailure, headers )
        local isAllowed = CFCHTTP.isAllowed( url )
        local stack = string.Split(debug.traceback(), "\n")
        logRequest( "GET", url, stack[3], isAllowed )
        if not isAllowed then
            if onFailure then onFailure( "URL is not whitelisted" ) end
            return
        end

        _http_Fetch( url, onSuccess, onFailure, headers )
    end
end

local function wrapPost()
    _http_Post = _http_Post or http.Post
    print("http.Post wrapped, original function at '_http_Post'")

    http.Post = function( url, params, onSuccess, onFailure, headers )
        local isAllowed = CFCHTTP.isAllowed( url )
        local stack = string.Split(debug.traceback(), "\n")
        logRequest( "POST", url, stack[3], isAllowed )
        if not isAllowed then
            if onFailure then onFailure( "URL is not whitelisted" ) end
            return
        end

        _http_Post( url, params, onSuccess, onFailure, headers )
    end
end

local function wrapPlayURL()
    local BASS_ERROR_ILLPARAM = 20
    _sound_PlayURL = _sound_PlayURL or sound.PlayURL
    print("sound.PlayURL wrapped, original function at _sound_PlayUrl")

    sound.PlayURL = function( url, flags, callback )
         local isAllowed = CFCHTTP.isAllowed( url )
        local stack = string.Split(debug.traceback(), "\n")
        logRequest( "GET", url, stack[3], isAllowed )
        if not isAllowed then
            if callback then callback( nil, BASS_ERROR_ILLPARAM, "BASS_ERROR_ILLPARAM" ) end
            return
        end
        sound.PlayURL( url, flags, callback )
    end
end

wrapHTTP()
wrapFetch()
wrapPost()
wrapPlayURL()
