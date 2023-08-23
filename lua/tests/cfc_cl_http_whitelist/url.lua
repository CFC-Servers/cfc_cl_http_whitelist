local testUrls = {
    { url = "http://лиса.рф/static/img/test.png", address = "лиса.рф" },
    { url = "https://store.fox.pics/0d875a97-2ab3-489c-b7db-d9d9f026504e.jpg", address = "store.fox.pics" },
    { url = "https://fox.pics:8080/0d875a97-2ab3-489c-b7db-d9d9f026504e.jpg", address = "fox.pics" },
    { url = "https://cfcservers.org", address = "cfcservers.org" },
    { url = "https://24.321.483.222", address = "24.321.483.222" },
    { url = "nil", address = nil },
    { url = nil, address = nil },
}

local htmlBlobs = [[
    <html>
        <head>
            <title>Test</title>
        </head>
        <body>
            <img src="%s" />
        </body>
    </html>
]]

---@type GLuaTestTestGroup
local group = {
    groupName = "CFC HTTP Whitelist Domains",
    cases = {
        {
            name = "Should get addresses from urls",
            func = function()
                for _, urlData in pairs( testUrls ) do
                    local html = htmlBlobs:format( urlData.url )
                    local urls = CFCHTTP.FileTypes.HTML.GetURLSFromData( html )
                    if urlData.address then
                        expect( #urls ).to.equal( 1 )
                        expect( urls[1] ).to.equal( urlData.url )
                    else
                        expect( #urls ).to.equal( 0 )
                    end
                end
            end
        },
        {
            name = "Get address should return expected data",
            func = function()
                for _, urlData in pairs( testUrls ) do
                    local address = CFCHTTP.GetAddress( urlData.url )
                    expect( address ).to.equal( urlData.address )
                end
            end
        },
    }
}

return group
