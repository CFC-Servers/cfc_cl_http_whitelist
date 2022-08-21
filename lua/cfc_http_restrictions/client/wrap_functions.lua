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

    if isVerbose == false then
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
        local options = CFCHTTP.getOptionsForURI(req.url)
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split(debug.traceback(), "\n")
        logRequest( req.method, req.url, stack[3], isAllowed, noisy)
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
        local options = CFCHTTP.getOptionsForURI(url)
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split(debug.traceback(), "\n")
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
        local options = CFCHTTP.getOptionsForURI(url)
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split(debug.traceback(), "\n")
        logRequest( "POST", url, stack[3], isAllowed, noisy )
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
    print( "sound.PlayURL wrapped, original function at _sound_PlayUrl" )

    sound.PlayURL = function( url, flags, callback )
        local options = CFCHTTP.getOptionsForURI(url)
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split( debug.traceback(), "\n" )
        logRequest( "GET", url, stack[3], isAllowed, noisy )
        if not isAllowed then
            if callback then callback( nil, BASS_ERROR_ILLPARAM, "BASS_ERROR_ILLPARAM" ) end
            return
        end
        _sound_PlayURL( url, flags, callback )
    end
end

wrapHTTP()
wrapFetch()
wrapPost()
wrapPlayURL()
