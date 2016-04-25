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
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.25 / ASPECT_RATIO_MULTIPLIER, screenHeight/2-screenHeight*0.3, screenWidth*0.6, screenHeight*0.6)

	self.m_Rect = GUIRectangle:new(0, self.m_Width*0.06 , self.m_Width, self.m_Height - self.m_Width*0.06, tocolor(0, 0, 0, 200), self)
	self.m_Logo = GUIImage:new(self.m_Width/2-self.m_Width*0.25*0.5, self.m_Height*0.005, self.m_Width*0.275, self.m_Width*0.119, "files/images/LogoNoFont.png", self)


	self.m_Grid = GUIGridList:new(self.m_Width*0.05, self.m_Height*0.14, self.m_Width*0.9, self.m_Height*0.55, self.m_Rect)
	self.m_Grid:setColor(Color.Clear)
	self.m_Grid:addColumn(_"Name", 0.3)
	self.m_Grid:addColumn(_"Fraktion", 0.2)
	self.m_Grid:addColumn(_"Unternehmen", 0.2)
	self.m_Grid:addColumn(_"Gang/Firma", 0.2)
	self.m_Grid:addColumn(_"Karma", 0.1)

	self.m_Line = GUIRectangle:new(0, self.m_Height*0.75, self.m_Width, self.m_Height*0.05, tocolor(50, 200, 255, 255), self.m_Rect)
	self.m_PlayerCount = GUILabel:new(self.m_Width*0.05, self.m_Height*0.75, self.m_Width/2, self.m_Height*0.05, "", self.m_Rect)
	self.m_PlayerCount:setColor(Color.Black):setFont("default-bold"):setFontSize(1.4)
	self.m_Ping = GUILabel:new(self.m_Width/2, self.m_Height*0.75, self.m_Width/2-self.m_Width*0.05, self.m_Height*0.05, "", self.m_Rect)
	self.m_Ping:setColor(Color.Black):setFont("default-bold"):setFontSize(1.4):setAlignX("right")

	self:refresh()

	setTimer(bind(self.refresh, self), 1000, 0)
end

function ScoreboardGUI:refresh()
	self.m_Grid:clear()
	local count = 0
	for k, player in pairs(getElementsByType("player")) do
		local karma = math.floor(player:getKarma() or 0)
		local item = self.m_Grid:addItem(
			player:getName(),
			player:getFaction():getShortName() or "- Keine -",
			player:getShortCompanyName()  or "- Keine -",
			player:getGroupName(),
			karma >= 0 and "+"..karma or " "..tostring(karma)
		)

		if karma >= 5 then
			item:setColumnColor(3, Color.Green)
		elseif karma <= -5 then
			item:setColumnColor(3, Color.Red)
		end
		count = count +1
	end
	self.m_PlayerCount:setText(_("Derzeit %d Spieler online", #getElementsByType("player")))
	self.m_Ping:setText(_("eigener Ping: %dms", localPlayer:getPing()))
end
