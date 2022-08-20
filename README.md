# cfc_cl_http_whitelist

## Configuring 
You can create files in lua/cfc_http_restrictions/configs to add your own default domains to your server

Configuration is loaded from lua files and a data file on in the clients data folder
Each config thats loaded will overwrite values in the previous config, unless permanent=true is set on that config option

Configuration load order on client
- lua/cfc_http_retrictions/default_config.lua
- lua/cfc_http_restrictions/configs/*.lua
- data/cfc_cl_http_whitelist_config.json

#### Configuration options
| name | type | description |
| ----- | ---- | --------------------------------------------------------------------------------------------------------------------------------- |
| noisy | bool | mark the domain as noisy, hiding it from logs, this can be used for internal domains that will be called frequently on the client |
| allowed|bool| Is the domain allowed, if false block the domain, if true allow the domain |
|permanent|bool|Is the domain permanent, if true the domain can not be removed by the users own config|
|_edited|bool|DO NOT SET, internal field used to track if a config option has been edited by the client|