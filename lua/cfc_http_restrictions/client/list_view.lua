local function removeByValue( listView, value )
    for i, line in pairs( listView:GetLines() ) do
        if line:GetValue( 1 ) == value then
            listView:RemoveLine( i )
            return
        end
    end
end

local function populatePanel( form ) 
    local warning = vgui.Create( "DLabel"  )
    warning:SetText( "Adding a domain here could expose your ip to other players (and other vulnerabilities)" )
    warning:SetColor( Color(255, 0, 0) )
    warning:SetFont("GModToolHelp")
    warning:SetWrap( true )
    warning:SetSize(300, 100)

    form:AddItem( warning )

    form:CheckBox( "Log allowed requests", "cfc_http_restrictions_log_allows" )
    form:CheckBox( "Log blocked requests", "cfc_http_restrictions_log_blocks" )
    form:CheckBox( "Detailed logging", "cfc_http_restrictions_log_verbose" )

    local list = vgui.Create( "DListView")
    list:Dock( TOP )
    list:SetMultiSelect( false )
    list:AddColumn( "Address" )
    list:AddColumn( "Allowed" )
    list:SetTall(300)
    form:AddItem( list )

    for k, v in pairs( CFCHTTP.config.addresses ) do
        list:AddLine( k, v and "yes" or "no" )
    end

    local textEntry, _ = form:TextEntry( "Address" )

    list.OnRowSelected = function( self, index, pnl )
        textEntry:SetValue( pnl:GetColumnText( 1 ) )
    end

    local allow = form:Button("Allow")
    allow.DoClick = function()
        local v = textEntry:GetValue()
        if not CFCHTTP.allowAddress( v ) then return end
        removeByValue( list, v )

        list:AddLine( v, "yes" )
    end

    local block = form:Button("Block")
    block.DoClick = function()
        local v = textEntry:GetValue()
        if not CFCHTTP.blockAddress( v ) then return end
        removeByValue( list, v )

        list:AddLine( v, "no" )
    end

    -- TODO when a config is removed we should reload the default values from the lua based configs instead of just removing it from the entire list
    local remove = form:Button("Remove")
    remove.DoClick = function()
        local v = textEntry:GetValue()
        if not CFCHTTP.removeAddress( v ) then return end
        removeByValue( list, v )
    end

    local save = form:Button("Save")
    save.DoClick = function()
        local conf = CFCHTTP.copyConfig(CFCHTTP.config)
        for addr, options in pairs(conf.addresses) do
            if not options._edited then
                conf.addresses[addr] = nil
            end
        end
        CFCHTTP.saveFileConfig(conf)
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
