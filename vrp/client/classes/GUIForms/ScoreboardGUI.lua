-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ScoreboardGUI.lua
-- *  PURPOSE:     Scoreboard class
-- *
-- ****************************************************************************
ScoreboardGUI = inherit(GUIForm)
inherit(Singleton, ScoreboardGUI)

function ScoreboardGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.25 / ASPECT_RATIO_MULTIPLIER, screenHeight/2-screenHeight*0.3, screenWidth*0.5, screenHeight*0.6)
	
	self.m_Rect = GUIRoundedRect:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_Logo = GUIImage:new(self.m_Width/2-self.m_Width*0.25*0.5, -self.m_Width*0.03, self.m_Width*0.25, self.m_Width*0.25, "files/images/Logo.png", self.m_Rect)
	
	self.m_Grid = GUIGridList:new(self.m_Width*0.05, self.m_Height*0.27, self.m_Width*0.9, self.m_Height*0.75, self.m_Rect)
	self.m_Grid:setColor(Color.Clear)
	self.m_Grid:addColumn(_"Name", 0.35)
	self.m_Grid:addColumn(_"Karma", 0.1)
	self.m_Grid:addColumn(_"Gang", 0.35)
	self.m_Grid:addColumn(_"Job", 0.2)
	
	setTimer(bind(self.refresh, self), 1000, 0)
end

function ScoreboardGUI:refresh()
	self.m_Grid:clear()
	
	for k, player in pairs(getElementsByType("player")) do
		local karma = math.floor(player:getKarma() or 0)
		self.m_Grid:addItem(player:getName(), tostring(math.floor(player:getXP() or 0)), karma >= 0 and "+"..karma or tostring(karma), player:getGroupName(), player:getJobName())
	end
end
