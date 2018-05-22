GangwarPickGUI = inherit(GUIForm)
inherit(Singleton, GangwarPickGUI)
local width,height = screenWidth * 0.3 , screenHeight*0.4

function GangwarPickGUI:constructor( area, canModify )
    GUIWindow.updateGrid()
	self.m_Width = grid("x", 16) 
    self.m_Height = grid("y", 12)
    
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Spielereinteilung - %s", area) , true, true, self)

    self.m_InfoLabel = GUIGridLabel:new(1, 1, 12, 1, _"Hier können die Teilnehmer des Gangwars eingeteilt werden!", self)
    
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

    self.m_Window:deleteOnClose( true )
    self.m_ParticipantList:clear()
    self:fill()
    self:createMessage()
    self:setModify(canModify)
end

function GangwarPickGUI:fill()
    self.m_Online = {}
    self.m_Pick = {}
    self:refill()
end

function GangwarPickGUI:synchronize( ) 
    self:refill()
end

function GangwarPickGUI:refresh( )
    self.m_OnlineList:clear()
    local item
    for player, _ in pairs(self.m_Online) do 
        item = self.m_OnlineList:addItem(player:getName())
        item.m_Player = player
    end
    self.m_ParticipantList:clear()
    for player, _ in pairs(self.m_Pick) do 
        item = self.m_ParticipantList:addItem(player:getName())
        item.m_Player = player
    end
end

function GangwarPickGUI:check() 
    for player, _ in pairs(self.m_Pick) do
        for player2, _ in pairs(self.m_Online) do
            if player == player2 then 
                self.m_Online[player] = nil
            end
        end
    end
    self:refresh()
end

function GangwarPickGUI:remove( player ) 
    self.m_Pick[player] = nil 
    self:refill()
end

function GangwarPickGUI:add( player ) 
    self.m_Pick[player] = player 
    self:refill()
end

function GangwarPickGUI:createMessage() 
    if not self.m_PickMessage then 
        self.m_PickMessage = ShortMessage:new("", "Teilnehmer", Color.Orange, -1)
    end
end

function GangwarPickGUI:updateMessage( list, updater, tick )
    if list and updater and tick then
        local text = ""
        for player, _ in pairs(list) do 
            if player and isElement(player) then 
                if self.m_PickMessage then 
                    text = text .. "\n" .. player:getName()
                end
            end
        end
        self.m_PickMessage:setText(_("%s", text))
    end
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

function GangwarPickGUI:refill()
    self.m_Online = {}
    for key, player in ipairs(getElementsByType("player")) do 
        if player:getFactionId() == localPlayer:getFactionId() then
            self.m_Online[player] = true
        end
    end
    self:check()
end

function GangwarPickGUI:Event_OnPick()
    if self:canModify() then
        local item = self.m_OnlineList:getSelectedItem()
        if item then 
            if item.m_Player and isElement(item.m_Player) then 
                self:add( item.m_Player )
            end
        end
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
    for player, _ in pairs(self.m_Online) do 
        if player and isElement(player) then
            item = self.m_OnlineList:addItem(player:getName())
            item.m_Player = player
        end
    end
    self.m_ParticipantList:clear()
    for player, _ in pairs(self.m_Pick) do 
        if player and isElement(player) then
            item = self.m_ParticipantList:addItem(player:getName())
            item.m_Player = player
        end
    end
end

function GangwarPickGUI:Event_OnAcceptClick()
    if self:canModify() then
        triggerServerEvent("GangwarPick:submit", localPlayer, self.m_Online, self.m_Pick)
    end
end

function GangwarPickGUI:destructor()
    GUIForm.destructor(self)
end

