local function removeByValue( listView, value )
    for i, line in ipairs( listView:GetLines() ) do
        if line:GetValue( 1 ) == value then
            listView:RemoveLine( i )
            return
        end
    end
end

local function populatePanel( form )
    local list = vgui.Create( "DListView")
    list:Dock( TOP )
    list:SetMultiSelect( false )
    list:AddColumn( "Address" )
    list:AddColumn( "Allowed" )
    list:SetTall(300)
    form:AddItem( list )

    for k, v in pairs( CFCHTTP.allowedAddresses ) do
        list:AddLine(k, v and "yes" or "no" )
    end

    local textEntry, _ = form:TextEntry( "Address" )

    local allow = form:Button("Allow")
    allow.DoClick = function()
        local v = textEntry:GetValue()
        removeByValue( list, v )

        CFCHTTP.allowAddress( v )
        list:AddLine(v, "yes")
    end

    local block = form:Button("Block")
    block.DoClick = function()
        local v = textEntry:GetValue()
        removeByValue( list, v )

        CFCHTTP.blockAddress( v )
        list:AddLine(v, "no")
    end

    local save = form:Button("Save")
    save.DoClick = function()
        CFCHTTP.saveList()
    end

end

hook.Add( "AddToolMenuCategories", "CFC_HTTP_ListManager", function()
    spawnmenu.AddToolCategory( "Options", "HTTP", "HTTP" )
end )


hook.Add( "PopulateToolMenu", "CFC_HTTP_ListManager", function()
    spawnmenu.AddToolMenuOption( "Options", "HTTP", "allowed_domains", "Allowed Domains", "", "", function( panel )
        populatePanel( panel )
    end )
end )
