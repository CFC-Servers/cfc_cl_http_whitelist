local COLORS = {
    RED = Color( 255, 0, 0 ),
    GREEN = Color( 0, 255, 0 ),
    GREY = Color( 136, 151, 158 ),
    WHITE = Color( 255, 255, 255 ),
    ORANGE = Color( 255, 165, 0 ),
    YELLOW = Color( 235, 226, 52 )
}

local shouldLogAllows = CreateConVar( "cfc_http_restrictions_log_allows", "1", FCVAR_ARCHIVE, "Should the HTTP restrictions log allowed HTTP requests?", 0, 1 )
local shouldLogBlocks = CreateConVar( "cfc_http_restrictions_log_blocks", "1", FCVAR_ARCHIVE, "Should the HTTP restrictions log blocked HTTP requests?", 0, 1 )
local verboseLogging = CreateConVar( "cfc_http_restrictions_log_verbose", "0", FCVAR_ARCHIVE, "Should the HTTP restrictions log include verbose messages?", 0, 1 )

local statusColors = {
    ALLOWED = COLORS.GREEN,
    BLOCKED = COLORS.RED,
    REPLACED = COLORS.ORANGE,
    UNKNOWN = COLORS.GREY
}

---@class CFCHTTPLogRequestInput
---@field method string
---@field urls { url: string, status: string, reason: string }[]
---@field fileLocation string
---@field noisy boolean|nil

---@param input CFCHTTPLogRequestInput
function CFCHTTP.LogRequest( input )
    if input.noisy and not verboseLogging:GetBool() then return end

    for _, v in ipairs( input.urls ) do
        if not verboseLogging:GetBool() then
            local url = CFCHTTP.GetAddress( v.url ) or v.url
            v.url = url
        end
    end

    if #input.urls == 1 then
        local url = input.urls[1].url
        local reason = input.urls[1].reason
        local requestStatus = string.upper( input.urls[1].status ) or "UNKNOWN"
        local requestColor = statusColors[requestStatus] or COLORS.GREY
        if not shouldLogAllows:GetBool() and requestStatus == "ALLOWED" then return end
        if not shouldLogBlocks:GetBool() and requestStatus == "BLOCKED" then return end

        MsgC(
            requestColor, requestStatus,
            COLORS.GREY, ": ",
            COLORS.YELLOW, string.upper( input.method ),
            COLORS.GREY, " - ",
            COLORS.YELLOW, url
        )
        if reason then
            MsgC( ": ", COLORS.WHITE, reason )
        end
        MsgC( "\n" )
        if verboseLogging:GetBool() then
            MsgC( COLORS.YELLOW, "  ", input.fileLocation, "\n" )
        end
        return
    end

    local msg = { COLORS.YELLOW, tostring( #input.urls ), " urs filtered:\n", COLORS.YELLOW, "  ", input.fileLocation, "\n" }
    for _, v in pairs( input.urls or {} ) do
        local url = v.url
        local reason = v.reason or ""
        local requestStatus = string.upper( v.status ) or "UNKNOWN"
        local requestColor = statusColors[requestStatus] or COLORS.GREY

        table.Add( msg,
            { requestColor, "\t", requestStatus, COLORS.GREY, ": ", COLORS.YELLOW, string.upper( input.method ), COLORS.GREY, " - ", COLORS.YELLOW, url, "  :  ", COLORS.WHITE, reason, "\n" } )
    end

    MsgC( unpack( msg ) )
end
