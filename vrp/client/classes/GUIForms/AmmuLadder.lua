-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AmmuLadder.lua
-- *  PURPOSE:     AmmuLadder GUI class
-- *
-- ****************************************************************************

AmmuLadder = inherit(GUIForm)
inherit(Singleton, AmmuLadder)

addRemoteEvents {"reciveLadderRating"}

local TOTAL_BUTTONS = 3
local TITLEBAR_HEIGHT = 30
local TOTAL_LADDERS = 4

function AmmuLadder:constructor()
	
	local sw,sh = guiGetScreenSize()
	
	GUIForm.constructor(self,sw/2-sw*0.33/2,sh/2-sh*0.5/2,sw*0.33,sh*0.5)
	
	self.m_Kind = "1vs1"
	self.m_Data = false
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Ammu-Ladder", true, true, self)
	self.m_Window.m_TitlebarDummy.m_Color = tocolor(0x3F, 0x7F, 0xBF, 255)
	
	self.m_FoundTeamButton = VRPButton:new(0, TITLEBAR_HEIGHT, self.m_Width/TOTAL_BUTTONS, self.m_Height*0.06, "Team", false, self)
	self.m_SearchButton     = VRPButton:new(self.m_Width/TOTAL_BUTTONS, TITLEBAR_HEIGHT, self.m_Width/TOTAL_BUTTONS, self.m_Height*0.06, "Search", false, self)
	self.m_LadderButton    = VRPButton:new(self.m_Width/TOTAL_BUTTONS*2, TITLEBAR_HEIGHT, self.m_Width/TOTAL_BUTTONS, self.m_Height*0.06, "Ladder", false, self)
	
	self.m_FoundTeamButton.onLeftClick = bind(self.FoundTeamButtonClick,self)
	self.m_SearchButton.onLeftClick     = bind(self.SearchButtonClick,self)
	self.m_LadderButton.onLeftClick    = bind(self.LadderButtonClick,self)
	
	self.m_OneButton   = VRPButton:new(0, self.m_Height-self.m_Height*0.06, self.m_Width/TOTAL_LADDERS, self.m_Height*0.06, "1vs1", true, self)
	self.m_TwoButton   = VRPButton:new(self.m_Width/TOTAL_LADDERS, self.m_Height-self.m_Height*0.06, self.m_Width/TOTAL_LADDERS, self.m_Height*0.06, "2vs2", true, self)
	self.m_ThreeButton = VRPButton:new(self.m_Width/TOTAL_LADDERS*2, self.m_Height-self.m_Height*0.06, self.m_Width/TOTAL_LADDERS, self.m_Height*0.06, "3vs3", true, self)
	self.m_FiveButton  = VRPButton:new(self.m_Width/TOTAL_LADDERS*3, self.m_Height-self.m_Height*0.06, self.m_Width/TOTAL_LADDERS, self.m_Height*0.06, "5vs5", true, self)
	
	self.m_OneButton.onLeftClick = bind(self.ChangeKind, self, "1vs1")
	self.m_TwoButton.onLeftClick = bind(self.ChangeKind, self, "2vs2")
	self.m_ThreeButton.onLeftClick = bind(self.ChangeKind, self, "3vs3")
	self.m_FiveButton.onLeftClick = bind(self.ChangeKind, self, "5vs5")
	
	self.m_FoundTab  = GUIRectangle:new(0,TITLEBAR_HEIGHT+self.m_Height*0.06, self.m_Width, self.m_Height-(TITLEBAR_HEIGHT+self.m_Height*0.06*2),tocolor(0,0,0,125), self)
	self.m_SearchTab  = GUIRectangle:new(0,TITLEBAR_HEIGHT+self.m_Height*0.06, self.m_Width, self.m_Height-(TITLEBAR_HEIGHT+self.m_Height*0.06*2),tocolor(0,0,0,125), self)
	self.m_LadderTab = GUIRectangle:new(0,TITLEBAR_HEIGHT+self.m_Height*0.06, self.m_Width, self.m_Height-(TITLEBAR_HEIGHT+self.m_Height*0.06*2),tocolor(0,0,0,125), self)
	
	-- Found Tab
		-- general administration
			self.m_FoundTab.Kind = GUILabel:new(self.m_Width*0.03, self.m_Height*0.1, self.m_Width, self.m_Height*0.04, "Type: X", self.m_FoundTab)
			self.m_FoundTab.Name = GUILabel:new(self.m_Width*0.03, self.m_Height*0.16, self.m_Width, self.m_Height*0.04, "Name: X", self.m_FoundTab)
			self.m_FoundTab.Rating = GUILabel:new(self.m_Width*0.03, self.m_Height*0.22, self.m_Width, self.m_Height*0.04, "Rating: X", self.m_FoundTab)
	-- Search Tab
		-- Queue/rating display
	-- Ladder Tab
		-- ToDo: CEF
	-- Switch to main tab
	self:FoundTeamButtonClick()
	
	self:close()
	
	addCommandHandler("ammuladderdemo", bind(self.openLadder,self))
	addEventHandler("reciveLadderRating", root, bind(self.reciveRating,self))
end

function AmmuLadder:reciveRating(data)
	self.m_Data = data
	self:ChangeKind(self.m_Kind)
end

function AmmuLadder:openLadder()
	triggerServerEvent("getLadderRating",localPlayer)
	self:open()
end

function AmmuLadder:ChangeKind(kind)
	self.m_Kind = kind
	if self.m_Data[kind] then
		local data = self.m_Data[kind]
		self.m_FoundTab.Kind:setText("Type: "..kind)
		self.m_FoundTab.Name:setText("Name: "..data.NAME)
		self.m_FoundTab.Rating:setText("Rating: "..data.RATING)
	else
		local data = self.m_Data[kind]
		self.m_FoundTab.Kind:setText("Type: "..kind)
		self.m_FoundTab.Name:setText("Name: n/s")
		self.m_FoundTab.Rating:setText("Rating: n/s")		
	end
end

function AmmuLadder:FoundTeamButtonClick()
	self.m_LadderTab:setVisible(false)
	self.m_SearchTab:setVisible(false)
	self.m_FoundTab:setVisible(true)
end

function AmmuLadder:SearchButtonClick()
	self.m_FoundTab:setVisible(false)
	self.m_LadderTab:setVisible(false)
	self.m_SearchTab:setVisible(true)
end

function AmmuLadder:LadderButtonClick()
	self.m_SearchTab:setVisible(false)
	self.m_FoundTab:setVisible(false)	
	self.m_LadderTab:setVisible(true)
end

function AmmuLadder:destructor()

end