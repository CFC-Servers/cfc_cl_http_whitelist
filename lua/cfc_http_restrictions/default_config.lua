AddCSLuaFile()

return {
    version = "1", -- this field allows backwards compatibility if the config structure is ever updated

    -- if this is true html panel functions will be wrapped and checked for potential urls
    wrapHTMLPanels = true,

    defaultAssetURIOptions = {
        allowed = true
    },
    defaultOptions = {
        allowed = false,
    },
    addresses = {
        -- google
        ["google.com"] = { allowed = true, noisy = true },
        ["www.google.com"] = { allowed = true, noisy = true },

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

        -- github
        ["github.com"] = { allowed = true },
        ["api.github.com"] = { allowed = true },
        ["raw.githubusercontent.com"] = { allowed = true },
        ["gist.githubusercontent.com"] = { allowed = true },

        ["gitlab.com"] = { allowed = true },

        ["bitbucket.org"] = { allowed = true },

        ["i.imgur.com"] = { allowed = true },

        ["paste.ee"] = { allowed = true },

        ["pastebin.com"] = { allowed = true },

        ["hastebin.com"] = { allowed = true },

        ["hastebin.nl"] = { allowed = true },

        ["puu.sh"] = { allowed = true },

        -- steam
        ["api.steampowered.com"] = { allowed = true },
        ["steamcommunity.com"] = { allowed = true },
        ["images.akamai.steamusercontent.com"] = { allowed = true },
        ["steamuserimages-a.akamaihd.net"] = { allowed = true, permanent = true },
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
        ["i([%w-_]+)%.tinypic%.com"] = { allowed = true, pattern = true },

        ["(%w+)%.keybase.pub"] = { allowed = true, pattern = true },
        ["tts.cyzon.us"] = { allowed = true },

        -- domains starfall docs have
        ["npms.io"] = { allowed = true },
        ["fb.me"] = { allowed = true },
        ["reactjs.org"] = { allowed = true },
        ["www.w3.org"] = { allowed = true },
        ["thegrb93.github.io"] = { allowed = true },
    }
}
