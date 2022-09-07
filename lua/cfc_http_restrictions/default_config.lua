AddCSLuaFile()

return {
    version = "1", -- this field allows backwards compatibility if the config structure is ever updated

    wrapHTMLPanels = false,

    defaultAssetURIOptions = {
        allowed = true
    },
    defaultOptions = {
        allowed = false,
    },
    addresses = {
        ["google.com"] =  { allowed = true },
        ["www.google.com"] = { allowed = true },

        ["steamcommunity.com"] = { allowed = true },
        ["api.github.com"] = { allowed = true },
        ["github.com"] = { allowed = true },
        ["thegrb93.github.io"] = { allowed = true },

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

        ["u.teknik.io"] = { allowed = true },

        ["i.imgur.com"] = { allowed = true },

        ["pastebin.com"] = { allowed = true },

        ["p.teknik.io"] = { allowed = true },

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
        ["i([%w-_]+)%.tinypic%.com"] = { allowed = true, pattern = true },

        -- domains starfall docs have
        ["npms.io"] = {allowed = true},
        ["fb.me"] = {allowed = true},
        ["reactjs.org"] = {allowed = true},
        ["www.w3.org"] = {allowed = true},

         -- fox pictures
        ["fox.pics"] = {allowed = true},
        ["*.fox.pics"] = {allowed = true},

        -- media player
        ["samuelmaddock.github.io"] = {allowed=true}
    }
}
