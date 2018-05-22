GangwarPickGUI = inherit(GUIForm)
inherit(Singleton, GangwarPickGUI)
local width,height = screenWidth * 0.3 , screenHeight*0.4

function GangwarPickGUI:constructor( area )
    GUIWindow.updateGrid()			
	self.m_Width = grid("x", 16) 
    self.m_Height = grid("y", 12)
    
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Spielereinteilung - %s", area) , true, true, self)

	self.m_InfoLabel = GUIGridLabel:new(1, 1, 16, 1, "Hier können die Teilnehmer des Gangwars eingeteilt werden!", self)
	
	self.m_OnlineList = GUIGridGridList:new(1, 2, 7, 10, self)
	self.m_OnlineList:addColumn(_"Online", 1)
	
	self.m_ButtonPick = GUIGridButton:new(8, 2, 1, 5, FontAwesomeSymbols.Right, self):setFont(FontAwesome(15)):setFontSize(1):setBarEnabled(false)
    self.m_ButtonPick:setBackgroundColor(tocolor(2, 45, 16, 255))
    self.m_ButtonPickBind = bind(self.)
    self.m_ButtonPick.onLeftClick = 
    self.m_ButtonRemove = GUIGridButton:new(8, 7, 1, 5, FontAwesomeSymbols.Left, self):setFont(FontAwesome(15)):setFontSize(1):setBarEnabled(false)
    self.m_ButtonRemove:setBackgroundColor(tocolor(66, 3, 4, 255))
	
	self.m_ParticipantList = GUIGridGridList:new(9, 2, 7, 10, self)
	self.m_ParticipantList:addColumn(_"Teilnehmer", 1)

    self.m_Window:deleteOnClose( true )
    self.m_ParticipantList:clear()
    self:fill()
end

function GangwarPickGUI:fill()
    self.m_Online = {}
    self.m_Pick = {}
    self:refill()
end

function GangwarPickGUI:synchronize( ) 
    self:refill()
end

function GangwarPickGUI:refresh(  )
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

end

function GangwarPickGUI:Event_OnRemove()

end

function GangwarPickGUI:destructor()
    GUIForm.destructor(self)
end

