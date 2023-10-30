AddCSLuaFile()

---@alias WhitelistAddressOption { allowed: boolean|nil, noisy: boolean|nil, permanent: boolean|nil, pattern: boolean|nil, _edited: boolean|nil }

---@class WhitelistConfig
---@field version string
---@field wrapHTMLPanels boolean|nil
---@field defaultAssetURIOptions WhitelistAddressOption
---@field defaultOptions WhitelistAddressOption
---@field addresses table<string, WhitelistAddressOption>
local config = {
    version = "1", -- this field allows backwards compatibility if the config structure is ever updated

    wrapHTMLPanels = false,

    defaultAssetURIOptions = {
        allowed = true
    },
    defaultOptions = {
        allowed = false,
    },
    addresses = {
        -- this is used internally by this addon, removing it could cause issues
        ["gmhttp.pages.dev"] = { allowed = true, noisy = true, permanent = true },

        ["google.com"] = { allowed = true, noisy = true },
        ["www.google.com"] = { allowed = true, noisy = true },

        ["api.steampowered.com"] = { allowed = true },
        ["steamcommunity.com"] = { allowed = true },
        ["developer.valvesoftware.com"] = { allowed = true },
        ["avatars.cloudflare.steamstatic.com"] = { allowed = true },
        ["avatars.akamai.steamstatic.com"] = { allowed = true },

        ["api.github.com"] = { allowed = true },
        ["github.com"] = { allowed = true },

        -- dropbox
        ["dl.dropboxusercontent.com"] = { allowed = true },
        ["dl.dropbox.com"] = { allowed = true },
        ["www.dropbox.com"] = { allowed = true },

        -- onedrive
        ["onedrive.live.com"] = { allowed = true },
        ["api.onedrive.com"] = { allowed = true },

        -- google drive
        ["docs.google.com"] = { allowed = true },
        ["drive.google.com"] = { allowed = true },

        -- youtube
        ["youtube.com"] = { allowed = true },
        ["youtu.be"] = { allowed = true },

        ["raw.githubusercontent.com"] = { allowed = true },
        ["gist.githubusercontent.com"] = { allowed = true },

        ["gitlab.com"] = { allowed = true },

        ["bitbucket.org"] = { allowed = true },

        ["i.imgur.com"] = { allowed = true },

        ["pastebin.com"] = { allowed = true },

        ["paste.ee"] = { allowed = true },

        ["hastebin.com"] = { allowed = true },
        ["hastebin.nl"] = { allowed = true },

        ["puu.sh"] = { allowed = true },

        ["images.akamai.steamusercontent.com"] = { allowed = true },

        ["steamcdn-a.akamaihd.net"] = { allowed = true },

        ["facepunch.com"] = { allowed = true },
        ["*.facepunch.com"] = { allowed = true },

        ["i.redditmedia.com"] = { allowed = true },
        ["i.redd.it"] = { allowed = true },
        ["api.wolframalpha.com"] = { allowed = true },
        ["text-to-speech-demo.ng.bluemix.net"] = { allowed = true },
        ["translate.google.com"] = { allowed = true },

        ["cdn[%w-_]*.discordapp%.com"] = { allowed = true, pattern = true },
        ["images-([%w%-]+)%.discordapp%.net"] = { allowed = true, pattern = true },
        ["media.discordapp.net"] = { allowed = true },
        ["i([%w-_]+)%.tinypic%.com"] = { allowed = true, pattern = true },

        ["(%w+)%.keybase.pub"] = { allowed = true, pattern = true },
        ["tts.cyzon.us"] = { allowed = true },

        ["wiki.garrysmod.com"] = { allowed = true },
        ["en.wikipedia.org"] = { allowed = true },
        ["developer.mozilla.org"] = { allowed = true },
    },
}

return config
