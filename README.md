# cfc_cl_http_whitelist
Attempts to block any http request on clients that are not in the defined whitelist

* [Configuring](#configuring)
  * [How it works](#how-it-works)
  * [Configuring your server](#configuring-your-server)
  * [Client convars](#clientside-convars)

# Configuring 
## How it works
Clients are allowed to allow or deny urls for their clientside whitelist using the options menu in sandbox. Before loading the clientside editable config defaults are loaded from lua files or networked from the server.
Configs are layered so one config doesnt not completely overwrite an earlier config, just adds to it and overwrites any conflicting addresses (unless they are set to permanent)

Configuration load order on client
- Loads default config from `lua/cfc_http_retrictions/default_config.lua`
- Loads additional configs from `lua/cfc_http_restrictions/configs/*.lua`
- Loads additional configs from `lua/cfc_http_restrictions/configs/client/*.lua`
- Loads networked config if it exists
- Loads clientside config from `data/cfc_cl_http_whitelist_config.json`

## Configuring your server
The best way to configure your server is using lua files. 
- do NOT edit default_config.lua or any other file in this addon to change the config, this will make updating to get bug fixes and security fixes more difficult 
- Fork or copy the template repo found here https://github.com/cfc-servers/cfc_http_whitelist_config_template
- Modify the repo to allow or deny any domains you need. See [Configuration Options] for a list of options you can use in your address config 
- Put that repo in the addons folder on your server


## Configuration options
| name | type | description |
| ----- | ---- | --------------------------------------------------------------------------------------------------------------------------------- |
| noisy | bool | mark the domain as noisy, hiding it from logs, this can be used for internal domains that will be called frequently on the client |
| allowed|bool| Is the domain allowed, if false block the domain, if true allow the domain |
|permanent|bool|Is the domain permanent, if true the domain can not be removed from the config| 
|pattern|bool|Should the address be treated as a lua pattern|

## Clientside Convars
| name | default | description |
| ---- | ------- | ----------- |
| cfc_http_restrictions_log_allows | 1 | Should log allowed HTTP requests? |
| cfc_http_restrictions_log_blocks | 1 | Should log blocked HTTP requests |
| cfc_http_restrictions_log_verbose | 0 | Should the logs include verbose messages? noisy domains and full urls. |
