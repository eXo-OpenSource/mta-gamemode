GangwarPickGUI = inherit(GUIForm)
local width,height = screenWidth * 0.3 , screenHeight*0.4

function GangwarPickGUI:constructor( area, canModify, enablePick )
    GUIWindow.updateGrid()
	self.m_Width = grid("x", 16) 
    self.m_Height = grid("y", 12)
    
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Spielereinteilung - %s", area) , true, true, self)
    if enablePick then
        self.m_InfoLabel = GUIGridLabel:new(1, 1, 12, 1, _"Hier können die Teilnehmer des Gangwars eingeteilt werden!", self)
    else 
        self.m_InfoLabel = GUIGridLabel:new(1, 1, 12, 1, _"Die Gegner teilen ihre Spieler ein!", self)
    end
    self.m_ButtonRefresh = GUIGridButton:new(12, 1, 2, 1, FontAwesomeSymbols.Refresh, self):setFont(FontAwesome(15)):setFontSize(1):setBarEnabled(false)
    self.m_ButtonRefresh.onLeftClick = bind(self.Event_OnRefreshClick, self)

    self.m_ButtonAccept = GUIGridButton:new(14, 1, 2, 1, FontAwesomeSymbols.Accept, self):setFont(FontAwesome(15)):setFontSize(1):setBarEnabled(false):setBackgroundColor(tocolor(0, 120, 0, 255))
    self.m_ButtonAccept.onLeftClick = bind(self.Event_OnAcceptClick, self)

	self.m_OnlineList = GUIGridGridList:new(1, 2, 7, 10, self)
	self.m_OnlineList:addColumn(_"Online", 1)
	
	self.m_ButtonPick = GUIGridButton:new(8, 2, 1, 5, FontAwesomeSymbols.Right, self):setFont(FontAwesome(15)):setFontSize(1):setBarEnabled(false)
    self.m_ButtonPick:setBackgroundColor(tocolor(2, 45, 16, 255))
    self.m_ButtonPick.onLeftClick = bind(self.Event_OnPick, self)

    self.m_ButtonRemove = GUIGridButton:new(8, 7, 1, 5, FontAwesomeSymbols.Left, self):setFont(FontAwesome(15)):setFontSize(1):setBarEnabled(false)
    self.m_ButtonRemove:setBackgroundColor(tocolor(66, 3, 4, 255))
    self.m_ButtonRemove.onLeftClick = bind(self.Event_OnRemove, self)
    
	self.m_ParticipantList = GUIGridGridList:new(9, 2, 7, 10, self)
	self.m_ParticipantList:addColumn(_"Teilnehmer", 1)

    self.m_Window:deleteOnClose( false )
    self.m_ParticipantList:clear()

    self.m_UpdateBind = bind(self.Event_OnUpdateTick, self)
    self.m_UpdateTimer = setTimer( self.m_UpdateBind, 500, 0)

    self:fill()
    self:createMessage( enablePick )
    self:setModify( canModify )
    showCursor(false)
end

function GangwarPickGUI:fill()
    self.m_Online = {}
    self.m_Pick = {}
    self.m_RemotePick = {}
    self.m_Disqualified = {}
    self.m_Participants = {}
    self:refill()
end

function GangwarPickGUI:synchronize( participants, disqualified )
    self.m_Participants = participants
    self.m_Disqualified = disqualified 
    self:refill()
end

function GangwarPickGUI:refresh( )
    self.m_OnlineList:clear()
    local item
    for key, player in ipairs(self.m_Online) do 
        if player and isElement(player) then
            item = self.m_OnlineList:addItem(player:getName())
            item.m_Player = player
        else 
            local index = self:isInTable(self.m_Pick, player)
            if index then
                table.remove(self.m_Online, index)
            end
        end
    end
    self.m_ParticipantList:clear()
    for key, player in ipairs(self.m_Pick) do 
        if player and isElement(player)  then
            item = self.m_ParticipantList:addItem(("• %s  %s"):format(key, player:getName()))
            item.m_Player = player
        else 
            local index = self:isInTable(self.m_Pick, player)
            if index then
                table.remove(self.m_Pick, index)
            end
        end
    end
end

function GangwarPickGUI:check() 
    for _, player in ipairs(self.m_Pick) do
        for key, player2 in ipairs(self.m_Online) do
            if player == player2 then 
                table.remove(self.m_Online, key)
            end
        end
    end
    self:refresh()
end

function GangwarPickGUI:remove( player ) 
    local index = self:isInTable(self.m_Pick, player)
    if index then
        table.remove(self.m_Pick, index) 
        self:refill()
    end
end

function GangwarPickGUI:add( player ) 
    local index = self:isInTable(self.m_Pick, player)
    if not index then
        table.insert(self.m_Pick, player)
        self:refill()
    end
end

function GangwarPickGUI:createMessage( enablePick ) 
    if not self.m_PickMessage then 
        if enablePick then
            self.m_ClickBind = bind(self.onMessageClick, self)
            self.m_PickMessage = ShortMessage:new("", "Teilnehmer [Bearbeiten]", tocolor(140,40,0), -1, self.m_ClickBind, nil, nil, nil, true)
            self.m_PickMessage:setText("• Klicken um die Spieler einzuteilen (Sollte eine leere Liste eingereicht werden, machen alle mit)")
        else 
            self.m_PickMessage = ShortMessage:new("", "Teilnehmer der Gegner", tocolor(140,40,0), -1, self.m_ClickBind, nil, nil, nil, true)
            self.m_PickMessage:setText("• Die Gegner teilen zurzeit ihre Spieler ein!")
        end
    end
end

function GangwarPickGUI:updateMessage( list, updater, tick, isRemote )
    self:createMessage()
    self.m_Update = getTickCount()
    self.m_Creator = updater
    if not self:canModify() then
        self.m_Pick = list
        if isRemote then
            self.m_RemotePick = table.copy(list) -- this is the original list so we can compare if any changes have been done locally before we push the newer one
        end
    end
    self:writeMessage()
    self:refill()
end

function GangwarPickGUI:writeMessage()
    if self.m_Pick and self.m_Creator and self.m_Update then
        local updateTime = (getTickCount() - self.m_Update) / 1000
        local status = not self:compare() and "[ENTWURF]" or ""
        local text = ("Eingeteilt von %s vor %s Sek. %s"):format(self.m_Creator, math.floor(updateTime), status)
        if self.m_PickMessage then 
            if #self.m_Pick > 0 then
                for key, player in ipairs(self.m_Pick) do 
                    if player and isElement(player) then 
                        text = text .. "\n • " .. player:getName()
                    end
                end
            else 
                text = text .. "\n • Keiner eingeteilt! (Alle machen mit)"
            end
        end
        self.m_PickMessage:setText(_("%s", text))
    end
end

function GangwarPickGUI:compare( )
    for _, player in ipairs(self.m_RemotePick) do 
        if not self:isInTable(self.m_Pick, player) then
            return false
        end
    end
    for _, player in pairs(self.m_Pick) do 
        if not self:isInTable(self.m_RemotePick, player) then
            return false
        end
    end
    return true
end

function GangwarPickGUI:setModify(bool) 
    self.m_Modify = bool
    self.m_ButtonAccept:setEnabled(bool)
    self.m_ButtonRemove:setEnabled(bool)
    self.m_ButtonPick:setEnabled(bool)
end

function GangwarPickGUI:canModify() 
    return self.m_Modify
end

function GangwarPickGUI:isDisqualified( player )
    if player and isElement(player) then 
        for i = 1, #self.m_Disqualified do 
            if self.m_Disqualified[i] == player:getName() then 
                return true
            end
        end
    end
    return false
end

function GangwarPickGUI:refill()
    self.m_Online = {}
    for key, player in ipairs(self.m_Participants) do 
        if not self:isDisqualified(player) and not self:isInTable(self.m_Online, player) then
            table.insert(self.m_Online, player)
        end
    end
    self:check()
end

function GangwarPickGUI:isInTable( tbl, obj )
    for i = 1, #tbl do 
        if tbl[i] == obj then 
            return i
        end
    end
    return false
end

function GangwarPickGUI:onHide() 
    self.m_IsHidden = true
    self:toggleKeys(true)
end

function GangwarPickGUI:onMessageClick()
    if self.m_IsHidden then 
        self.m_IsHidden = false
        self:setVisible(true)
        self:toggleKeys(false)
    end
end

function GangwarPickGUI:Event_OnPick()
    if self:canModify() then
        local item = self.m_OnlineList:getSelectedItem()
        if item then 
            if item.m_Player and isElement(item.m_Player) and not self:isDisqualified(player) then 
                self:add( item.m_Player )
            end
        end
    end
end

function GangwarPickGUI:Event_OnUpdateTick()
    if self.m_PickMessage then 
        self:writeMessage()
    end
end

function GangwarPickGUI:Event_OnRemove()
    if self:canModify() then
        local item = self.m_ParticipantList:getSelectedItem()
        if item then 
            if item.m_Player and isElement(item.m_Player) then 
                self:remove( item.m_Player )
            end
        end
    end
end

function GangwarPickGUI:Event_OnRefreshClick(  )
    self.m_OnlineList:clear()
    for _, player in ipairs(self.m_Online) do 
        if player and isElement(player) and not self:isDisqualified(player) then
            item = self.m_OnlineList:addItem(player:getName())
            item.m_Player = player
        end
    end
    self.m_ParticipantList:clear()
    for key, player in ipairs(self.m_Pick) do 
        if player and isElement(player) and not self:isDisqualified(player) then
            item = self.m_ParticipantList:addItem(("• %s  %s"):format(key, player:getName()))
            item.m_Player = player
        end
    end
end

function GangwarPickGUI:Event_OnAcceptClick()
    if self:canModify() then
        self.m_RemotePick = table.copy(self.m_Pick) -- this is the original list so we can compare if any changes have been done locally before we push the newer one
        triggerServerEvent("GangwarPick:submit", localPlayer, self.m_Pick)
    end
end

function GangwarPickGUI:destructor()
    if isTimer( self.m_UpdateTimer ) then killTimer(self.m_UpdateTimer) end
    GUIForm.destructor(self)
    if self.m_PickMessage then 
        self.m_PickMessage:delete()
    end
end

