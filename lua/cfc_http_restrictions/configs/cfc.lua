AddCSLuaFile()

-- TODO this should be in its own repo

return {
    version="1", -- this field allows backwards compatibility if the config structure is ever updated

    wrapHTMLPanels = true,

    addresses = {
        -- TODO can we delete these, we have *.cfcservers.org?
        ["nanny.cfcservers.org"] = {allowed=true, noisy=true, permanent=true},
        ["paste.cfcservers.org"] = {allowed=true, noisy=true, permanent=true},
        ["cdn.cfcservers.org"] = {allowed=true, noisy=true, permanent=true},   
        
        ["*.cfcservers.org"] = {allowed=true, permanent=true},
        ["cfcservers.org"] = {allowed=true, permanent=true},

        ["google.com"] = {allowed=true, permanent=true},
        ["www.google.com"] = {allowed=true, permanent=true}, 

        ["api.mixpanel.com"] = {allowed=true},

        -- fox pictures
        ["fox.pics"] = {allowed=true},
        ["*.fox.pics"] = {allowed=true},

        -- media player
        ["samuelmaddock.github.io"] = {allowed=true, isPermanent=true} -- Media player
    }
}