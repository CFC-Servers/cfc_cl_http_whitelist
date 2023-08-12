local testUrls = {
    { url = "http://лиса.рф/static/img/paykeeper.png", address = "лиса.рф" },
    { url = "https://store.fox.pics/0d875a97-2ab3-489c-b7db-d9d9f026504e.jpg", address = "store.fox.pics" },
    { url = "https://fox.pics:8080/0d875a97-2ab3-489c-b7db-d9d9f026504e.jpg", address = "fox.pics" },
    { url = "https://cfcservers.org", address = "cfcservers.org" },
    { url = "https://24.321.483.222", address = "24.321.483.222" },
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

return {
    groupName = "CFC HTTP Whitelist Domains",
    cases = {
        {
            timeout = 3,
            async = false,
            name = "Should get addresses from urls",
            func = function()
                for _, urlData in pairs( testUrls ) do
                    local html = htmlBlobs:format( urlData.url )
                    local urls = CFCHTTP.FileTypes.HTML.GetURLSFromData( html )

                    expect( urls ).to.equal( { urlData.url } )
                end
            end
        },
        {
            timeout = 3,
            async = false,
            name = "Get address should return expected data",
            func = function()
                for _, urlData in pairs( testUrls ) do
                    local address = CFCHTTP.getAddress( urlData.url )
                    expect( address ).to.equal( urlData.address )
                end
            end
        },
    }
}
