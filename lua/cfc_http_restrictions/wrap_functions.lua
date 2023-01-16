AddCSLuaFile()

local shouldLogAllows = CreateConVar( "cfc_http_restrictions_log_allows", 1, FCVAR_ARCHIVE, "Should the HTTP restrictions log allowed HTTP requests?", 0, 1 )
local shouldLogBlocks = CreateConVar( "cfc_http_restrictions_log_blocks", 1, FCVAR_ARCHIVE, "Should the HTTP restrictions log blocked HTTP requests?", 0, 1 )
local verboseLogging = CreateConVar( "cfc_http_restrictions_log_verbose", 0, FCVAR_ARCHIVE, "Should the HTTP restrictions log include verbose messages?", 0, 1 )

CFCHTTP.Originals = CFCHTTP.Originals or {}
local originals = CFCHTTP.Originals

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
    local og = originals.HTTP or HTTP
    originals.HTTP = originals.HTTP or og
    print( "HTTP wrapped, original function at 'CFCHTTP.Originals.HTTP'" )

    HTTP = function( req )
        local options = CFCHTTP.getOptionsForURI( req.url )
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split( debug.traceback(), "\n" )
        logRequest( req.method, req.url, stack[3], isAllowed, noisy )
        local onFailure = req.failed
        if not isAllowed then
            if onFailure then onFailure( "URL is not whitelisted" ) end
            return
        end

        og( req )
    end
end

local function wrapFetch()
    local og = originals.http_Fetch or http.Fetch
    orignals.http_Fetch = originals.http_Fetch or og
    print( "http.Fetch wrapped, original function at 'CFCHTTP.Originals.http_Fetch'" )

    http.Fetch = function( url, onSuccess, onFailure, headers )
        local options = CFCHTTP.getOptionsForURI( url )
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split( debug.traceback(), "\n" )
        logRequest( "GET", url, stack[3], isAllowed, noisy )
        if not isAllowed then
            if onFailure then onFailure( "URL is not whitelisted" ) end
            return
        end

        og( url, onSuccess, onFailure, headers )
    end
end

local function wrapPost()
    local og = originals.http_Post or http.Post
    originals.http_Post = originals.http_Post or og
    print( "http.Post wrapped, original function at 'CFCHTTP.Originals.http_Post'" )

    http.Post = function( url, params, onSuccess, onFailure, headers )
        local options = CFCHTTP.getOptionsForURI( url )
        local isAllowed = options and options.allowed
        local noisy = options and options.noisy

        local stack = string.Split( debug.traceback(), "\n" )
        logRequest( "POST", url, stack[3], isAllowed, noisy )
        if not isAllowed then
            if onFailure then onFailure( "URL is not whitelisted" ) end
            return
        end

        og( url, params, onSuccess, onFailure, headers )
    end
end

if CLIENT then
    local function wrapPlayURL()
        local BASS_ERROR_ILLPARAM = 20

        local og = originals.sound_PlayURL or sound.PlayURL
        originals.sound_PlayURL = originals.sound_PlayURL or og
        print( "sound.PlayURL wrapped, original function at CFCHTTP.Originals.sound_PlayURL" )

        sound.PlayURL = function( url, flags, callback )
            local options = CFCHTTP.getOptionsForURI( url )
            local isAllowed = options and options.allowed
            local noisy = options and options.noisy

            local stack = string.Split( debug.traceback(), "\n" )
            logRequest( "GET", url, stack[3], isAllowed, noisy )
            if not isAllowed then
                if callback then callback( nil, BASS_ERROR_ILLPARAM, "BASS_ERROR_ILLPARAM" ) end
                return
            end

            og( url, flags, callback )
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

        local ogSetHTML = originals[setHTML] or controlTable.SetHTML
        local ogOpenURL = originals[openURL] or controlTable.OpenURL
        originals[setHTML] = originals[setHTML] or ogSetHTML
        originals[openURL] = originals[openURL] or ogOpenURL

        controlTable.SetHTML = function( self, html, ... )
            local isAllowed, url = CFCHTTP.isHTMLAllowed( html )

            local stack = string.Split( debug.traceback(), "\n" )
            logRequest( "GET", url, stack[3], isAllowed )

            if not isAllowed then
                html = [[<h1> BLOCKED </h1>]]
            end

            ogSetHTML( self, html, ... )
        end

        controlTable.OpenURL = function( self, url, ... )
            local options = CFCHTTP.getOptionsForURI( url )
            local isAllowed = options and options.allowed
            local noisy = options and options.noisy

            local stack = string.Split( debug.traceback(), "\n" )
            logRequest( "GET", url, stack[3], isAllowed, noisy )

            if not isAllowed then return end

            ogOpenURL( self, url, ... )
        end
    end

    hook.Add( "Initialize", "CFC_HttpWhitelist_WrapHTML", function()
        if CFCHTTP.config.wrapHTMLPanels then
            wrapHTMLPanel( "DHTML" )
            wrapHTMLPanel( "DPanel" )
            wrapHTMLPanel( "DMediaPlayerHTML" )
        end
    end )

    wrapPlayURL()
end

wrapHTTP()
wrapFetch()
wrapPost()
