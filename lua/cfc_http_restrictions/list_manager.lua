CFCHTTP = CFCHTTP or {}

CFCHTTP.noisyDomains = {
    ["nanny.cfcservers.org"] = true,
    ["google.com"] = true,
    ["www.google.com"] = true,
    ["cdn.cfcservers.org"] = true,
    ["api.mixpanel.com"] = true,
    ["paste.cfcservers.org"] = true
}

CFCHTTP.allowedAddresses = {
    ["steamcommunity.com"] = {allowed=true},
    ["api.github.com"] = {allowed=true},
    ["github.com"] = {allowed=true},
    ["thegrb93.github.io"] = {allowed=true},

    -- dropbox
    ["dl.dropboxusercontent.com"] = {allowed=true},
    ["dl.dropbox.com"] = {allowed=true},
    ["www.dropbox.com"] = {allowed=true},

    -- onedrive
    ["onedrive.live.com"] = {allowed=true},
    ["api.onedrive.com"] = {allowed=true},

    -- google drive
    ["docs.google.com"] = {allowed=true},
    ["drive.google.com"] = {allowed=true},

    -- youtube
    ["youtube.com"] = {allowed=true},
    ["youtu.be"] = {allowed=true},

    ["raw.githubusercontent.com"] = {allowed=true},
    ["gist.githubusercontent.com"] = {allowed=true},

    ["gitlab.com"] = {allowed=true},

    ["bitbucket.org"] = {allowed=true},

    ["u.teknik.io"] = {allowed=true},

    ["i.imgur.com"] = {allowed=true},

    ["pastebin.com"] = {allowed=true},

    ["p.teknik.io"] = {allowed=true},

    ["paste.ee"] = {allowed=true},

    ["hastebin.com"] = {allowed=true},
    ["hastebin.nl"] = {allowed=true},

    ["puu.sh"] = {allowed=true},

    ["images.akamai.steamusercontent.com"] = {allowed=true},

    ["steamcdn-a.akamaihd.net"] = {allowed=true},

    ["i.redditmedia.com"] = {allowed=true},
    ["i.redd.it"] = {allowed=true},
    ["api.wolframalpha.com"] = {allowed=true},
    ["text-to-speech-demo.ng.bluemix.net"] = {allowed=true},
    ["translate.google.com"] = {allowed=true},
    ["api.foxorsomething.net"] = {allowed=true},

    ["cdn[%w-_]*.discordapp%.com"] = {allowed=true, isPattern=true},
    ["images-([%w%-]+)%.discordapp%.net"] = {allowed=true, isPattern=true},
    ["i([%w-_]+)%.tinypic%.com"] = {allowed=true, isPattern=true},


    ["api.mixpanel.com"] = {allowed=true},
    ["*.cfcservers.org"] = {allowed=true, isPermanent=true},
    ["cfcservers.org"] = {allowed=true, isPermanent=true},
    ["google.com"] = {allowed=true, isPermanent=true},
    ["www.google.com"] = {allowed=true, isPermanent=true},
}

AddressCache = {}
ParsedAddressCache = {}

function CFCHTTP.getAddress( url )
    local cached = ParsedAddressCache[url]
    if cached then return cached end

    local pattern = "(%a+)://([%a%d%.-]+):?(%d*)/?.*"
    local  _,  _, protocol, addr, port = string.find( url, pattern )
    ParsedAddressCache[url] = addr

    return addr
end

-- escapes all lua pattern characters and allows the use of * as a wildcard
local escaped = {}
local function escapeAddr( addr )
    if escaped[addr] then return escaped[addr] end

    local split = string.Split( addr, "*" )
    for i=1, #split do
        split[i] = string.PatternSafe( split[i] )
    end

    escaped[addr] = table.concat( split, ".*" )
    return escaped[addr]
end

function CFCHTTP.checkAllowed( url )
    if not url then return end

    local address = CFCHTTP.getAddress( url )
    if not address then return end

    local allowedEntry = CFCHTTP.allowedAddresses[address]
    if allowedEntry and allowedEntry.allowed and not allowedEntry.isPattern then
        return allowedEntry.allowed
    end

    for allowedAddr, allowedEntry in pairs( CFCHTTP.allowedAddresses ) do
        if not allowedEntry.isPattern then
            allowedAddr = escapeAddr( allowedAddr )
        end

        if string.match( address, "^"..allowedAddr.."$" ) then
            return allowedEntry.allowed
        end
    end
end

function CFCHTTP.isAllowed( url )
    local cached = AddressCache[url]
    if cached ~= nil then return cached end

    local isAllowed = CFCHTTP.checkAllowed( url )
    AddressCache[url] = isAllowed

    return isAllowed
end

function CFCHTTP.allowAddress( addr, isPattern, isPermanent )
    if CFCHTTP.allowedAddresses[addr] ~= nil and CFCHTTP.allowedAddresses[addr].isPermanent then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.allowedAddresses[addr] = {
        allowed=true,
        isPattern=isPattern,
        isPermanent=isPermanent
    }

    AddressCache = {}

    return true
end

function CFCHTTP.blockAddress( addr )
   if CFCHTTP.allowedAddresses[addr] ~= nil and CFCHTTP.allowedAddresses[addr].isPermanent then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.allowedAddresses[addr] = {
        allowed=false,
        isPattern=isPattern,
        isPermanent=isPermanent
    }

    AddressCache = {}

    return true
end

function CFCHTTP.removeAddress( addr )
    if CFCHTTP.allowedAddresses[addr] ~= nil and CFCHTTP.allowedAddresses[addr].isPermanent then
        notification.AddLegacy( "You cant change this address", NOTIFY_ERROR, 5 )
        return false
    end

    CFCHTTP.allowedAddresses[addr] = nil
    AddressCache = {}

    return true
end

function CFCHTTP.saveList()
    file.CreateDir( "cfc" )
    file.Write( "cfc/http_whitelist.json", util.TableToJSON( CFCHTTP.allowedAddresses ) )

    notification.AddLegacy( "Saved http whitelist", NOTIFY_GENERIC, 5 )
end

function CFCHTTP.readList()
    local fileData = file.Read( "cfc/http_whitelist.json" )
    if not fileData then return end

    local loadedWhitelist = util.JSONToTable( fileData )

    for address, entryData in pairs( CFCHTTP.allowedAddresses ) do
        if entryData.isPermanent then
            loadedWhitelist[address] = entryData
        end
    end

    CFCHTTP.allowedAddresses = loadedWhitelist
end

CFCHTTP.readList()
