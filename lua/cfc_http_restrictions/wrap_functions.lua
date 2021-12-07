local shouldLogAllows = CreateConVar( "cfc_http_restrictions_log_allows", 1, FCVAR_ARCHIVE, "Should the HTTP restrictions log allowed HTTP requests?", 0, 1 )
local shouldLogBlocks = CreateConVar( "cfc_http_restrictions_log_blocks", 1, FCVAR_ARCHIVE, "Should the HTTP restrictions log blocked HTTP requests?", 0, 1 )
local verboseLogging = CreateConVar( "cfc_http_restrictions_log_verbose", 0, FCVAR_ARCHIVE, "Should the HTTP restrictions log include verbose messages?", 0, 1 )
local getAddress = CFCHTTP.getAddress
local noisyDomains = CFCHTTP.noisyDomains

local COLORS = {
    RED = Color( 255, 0, 0 ),
    GREEN = Color( 0, 255, 0 ),
    GREY = Color( 136, 151, 158 ),
    YELLOW = Color( 235, 226, 52 )
}

local function logRequest( method, url, fileLocation, allowed )
    if allowed and not shouldLogAllows:GetBool() then return end
    if not shouldLogBlocks:GetBool() then return end

    local isVerbose = verboseLogging:GetBool()
    local requestStatus = allowed and "ALLOWED" or "BLOCKED"
    local requestColor = allowed and COLORS.GREEN or COLORS.RED

    if isVerbose == false then
        local address = getAddress( url )
        if noisyDomains[address] then return end

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
        local isAllowed = CFCHTTP.isAllowed( req.url )
        local stack = string.Split(debug.traceback(), "\n")
        logRequest( req.method, req.url, stack[3], isAllowed )
        local onFailure = req.failed
        if not isAllowed then
            if onFailure then onFailure( "URL is not whitelisted" ) end
            return
        end
        _HTTP( req )
    end
end

local function wrapFetch()
    http._Fetch = _http._Fetch or http.Fetch
    print( "http.Fetch wrapped, original function at 'http._Fetch'" )

    http.Fetch = function( url, onSuccess, onFailure, headers )
        local isAllowed = CFCHTTP.isAllowed( url )
        local stack = string.Split(debug.traceback(), "\n")

        logRequest( "GET", url, stack[3], isAllowed )

        if not isAllowed then
            if onFailure then onFailure( "URL is not whitelisted" ) end
            return
        end

        return http._Fetch( url, onSuccess, onFailure, headers )
    end
end

local function wrapPost()
    http._Post = http._Post or http.Post
    print( "http.Post wrapped, original function at 'http._Post'" )

    http.Post = function( url, params, onSuccess, onFailure, headers )
        local isAllowed = CFCHTTP.isAllowed( url )
        local stack = string.Split(debug.traceback(), "\n")

        logRequest( "POST", url, stack[3], isAllowed )

        if not isAllowed then
            if onFailure then onFailure( "URL is not whitelisted" ) end
            return
        end

        return http._Post( url, params, onSuccess, onFailure, headers )
    end
end

local function wrapPlayURL()
    local BASS_ERROR_ILLPARAM = 20
    sound._PlayURL = sound._PlayURL or sound.PlayURL
    print( "sound.PlayURL wrapped, original function at sound._PlayUrl" )

    sound.PlayURL = function( url, flags, callback )
        local isAllowed = CFCHTTP.isAllowed( url )
        local stack = string.Split( debug.traceback(), "\n" )

        logRequest( "GET", url, stack[3], isAllowed )

        if not isAllowed then
            if callback then callback( nil, BASS_ERROR_ILLPARAM, "BASS_ERROR_ILLPARAM" ) end

            return
        end

        return sound._PlayURL( url, flags, callback )
    end
end

local function wrapGUIOpenURL()
    gui._OpenURL = gui._OpenURL or gui.OpenURL
    print( "gui.OpenURL wrapped, original function at gui._OpenURL" )

    gui.OpenURL = function( url )
        local isAllowed = CFCHTTP.isAllowed( url )
        local stack = string.Split( debug.traceback(), "\n" )

        logRequest( "GET", url, stack[3], isAllowed )
        if not isAllowed then return end

        return gui._OpenURL( url )
    end
end

local function wrapPanelOpenURL()
end

wrapHTTP()
wrapFetch()
wrapPost()
wrapPlayURL()
