# cfc_http_whitelist
Attempts to block HTTP requests to domains that are not in the defined whitelist.

## Default settings
By default, the HTTP whitelist runs on **Client only** _(Check out the [ConVars section](#ConVars) if you want to enable it Serverside)_.

The default domains are the same for both Client and Server.
 - You can find the default config [here](https://github.com/CFC-Servers/cfc_http_whitelist/blob/main/lua/cfc_http_restrictions/default_config.lua#L14)

## Configuring Domains
To add/modify your own domains, you can create a new file in one of the following directories:
 - For Clientside: `lua/cfc_http_restrictions/configs/`
 - For Serverside: `lua/cfc_http_restrictions/configs/server/`

(See [CFC's Whitelist config addon](https://github.com/CFC-Servers/cfc_http_whitelist_configs) for an example)

Configuration is loaded from Lua files in specific locations, and optionally, a data file.
Each config will overwrite values in the previous config (except for options with `permanent=true` set).

#### **Clientside Configuration load order**
- `lua/cfc_http_retrictions/default_config.lua`
- `lua/cfc_http_restrictions/configs/*.lua`
- `data/cfc_cl_http_whitelist_config.json`

#### **Serverside Configuration load order**
- `lua/cfc_http_retrictions/default_config.lua`
- `lua/cfc_http_restrictions/configs/server/*.lua`
- `data/cfc_sv_http_whitelist_config.json`

### Domain Configuration options
Here are the options available for a domain:

| name        | type   | description |
| -----       | ----   | --------------------------------------------------------------------------------------------------------------------------------- |
| `noisy`     | `bool` | mark the domain as noisy, hiding it from logs, this can be used for internal domains that will be called frequently on the client |
| `allowed`   | `bool` | Is the domain allowed, if false block the domain, if true allow the domain  |
| `permanent` | `bool` | Is the domain permanent, if true the domain can not be removed by the users own config |
| `_edited`   | `bool` | **DO NOT SET**, internal field used to handle changes  |

### ConVars
| name | default | description |
| ---- | ------- | ----------- |
| `cfc_http_restrictions_log_allows`  | 1 | Should log **allowed** requests? |
| `cfc_http_restrictions_log_blocks`  | 1 | Should log **blocked** requests? |
| `cfc_http_restrictions_log_verbose` | 0 | Should the logs include verbose messages? (Includes Noisy domains and full urls). |

### Server-only ConVars
| name | default | description |
| ---- | ------- | ----------- |
| `cfc_http_restrictions_sv_enabled` | 0 | Should the HTTP whitelist run serverside? |

## Shortcomings
Because this tool operates by wrapping the default functions, this addon won't work when a script loads before it and localizes one of the functions.

This is rare, but not unheard of, and we could possibly make code to fix those situations. Make an [Issue](https://github.com/CFC-Servers/cfc_http_whitelist/issues) if you find an example of this happening.
