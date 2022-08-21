CFCHTTP = CFCHTTP or {}
CFCHTTP.config = include("default_config.lua")

function CFCHTTP.LoadConfigs()
    CFCHTTP.config = include("default_config.lua")
    CFCHTTP.loadLuaConfigs()

    if CLIENT then
        local fileConfig = CFCHTTP.readFileConfig()
        if fileConfig then
            CFCHTTP.config = CFCHTTP.mergeConfigs(CFCHTTP.config, fileConfig)
        end
    end
end

-- LoadLuaConfigs loads the default config and then any lua files in the cfc_http_restrictions/configs directory
function CFCHTTP.loadLuaConfigs() 
    local files = file.Find("cfc_http_restrictions/configs/*.lua", "LUA")
    for _, file in pairs(files) do
        AddCSLuaFile("cfc_http_restrictions/configs/" .. file)
        local newConfig = include("cfc_http_restrictions/configs/" .. file)
        CFCHTTP.config = CFCHTTP.mergeConfigs(CFCHTTP.config, newConfig)
    end
end

function CFCHTTP.mergeConfigs(old, new)
    if new.version == "1" then
        old.wrapHTMLPanels = new.wrapHTMLPanels
        for domain, options in pairs(new.addresses) do
            local currentOptions = old.addresses[domain]
            if currentOptions and currentOptions.permanent then
                print("[CFC HTTP Restrictions] Skipping " .. domain .. " because it is permanent")
            else
                old.addresses[domain] = options
            end
        end
    else
        ErrorNoHalt("[CFC HTTP Restrictions] Invalid config version: " .. new.version)
    end

    return old
end

function CFCHTTP.copyConfig(cfg)
    return util.JSONToTable(util.TableToJSON(cfg))
end

function CFCHTTP.saveFileConfig(config)
    file.Write( "cfc_cl_http_whitelist_config.json", util.TableToJSON( config, true ) )

    notification.AddLegacy( "Saved http whitelist", NOTIFY_GENERIC, 5 )
end

function CFCHTTP.readFileConfig()
    local fileData = file.Read( "cfc_cl_http_whitelist_config.json" )
    if not fileData then return end

    return util.JSONToTable( fileData )
end

CFCHTTP.LoadConfigs()