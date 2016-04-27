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
	GUIForm.constructor(self, screenWidth/2-(screenWidth*0.6/2) / ASPECT_RATIO_MULTIPLIER, screenHeight/2-screenHeight*0.3, screenWidth*0.6, screenHeight*0.6)

	self.m_Rect = GUIRectangle:new(0, self.m_Width*0.06 , self.m_Width, self.m_Height - self.m_Width*0.06, tocolor(0, 0, 0, 200), self)
	self.m_Logo = GUIImage:new(self.m_Width/2-self.m_Width*0.25*0.5, self.m_Height*0.005, self.m_Width*0.275, self.m_Width*0.119, "files/images/LogoNoFont.png", self)


	self.m_Grid = GUIGridList:new(self.m_Width*0.05, self.m_Height*0.14, self.m_Width*0.9, self.m_Height*0.45, self.m_Rect)
	self.m_Grid:setColor(Color.Clear)
	self.m_Grid:addColumn(_"Name", 0.3)
	self.m_Grid:addColumn(_"Fraktion", 0.2)
	self.m_Grid:addColumn(_"Unternehmen", 0.2)
	self.m_Grid:addColumn(_"Gang/Firma", 0.2)
	self.m_Grid:addColumn(_"Karma", 0.1)

	self.m_Line = GUIRectangle:new(0, self.m_Height*0.65, self.m_Width, self.m_Height*0.05, tocolor(50, 200, 255, 255), self.m_Rect)
	self.m_PlayerCount = GUILabel:new(self.m_Width*0.05, self.m_Height*0.65, self.m_Width/2, self.m_Height*0.05, "", self.m_Rect)
	self.m_PlayerCount:setColor(Color.Black):setFont(VRPFont(self.m_Height*0.05))
	self.m_Ping = GUILabel:new(self.m_Width/2, self.m_Height*0.65, self.m_Width/2-self.m_Width*0.05, self.m_Height*0.05, "", self.m_Rect)
	self.m_Ping:setColor(Color.Black):setFont(VRPFont(self.m_Height*0.05)):setAlignX("right")

	self:refresh()
	setTimer(bind(self.refresh, self), 1000, 0)
end

function ScoreboardGUI:refresh()
	self.m_Grid:clear()
	self.m_Players = {}
	self.m_CompanyCount = {}
	self.m_FactionCount = {}

	for k, player in pairs(getElementsByType("player")) do
		local factionId = player:getFaction() and player:getFaction():getId() or 0
		table.insert(self.m_Players, {player, factionId})

		local companyId = player:getCompany() and player:getCompany():getId() or 0

		if factionId ~= 0 then
			if not self.m_FactionCount[factionId] then self.m_FactionCount[factionId] = 0 end
			self.m_FactionCount[factionId] = self.m_FactionCount[factionId] + 1
		end

		if companyId ~= 0 then
			if not self.m_CompanyCount[companyId] then self.m_CompanyCount[companyId] = 0 end
			self.m_CompanyCount[companyId] = self.m_CompanyCount[companyId] + 1
		end
	end

	table.sort(self.m_Players, function (a, b) return (a[2] > b[2]) end)
	self:insertPlayers()

	if not self.m_PlayerCountLabels then
		self.m_PlayerCountLabels = {}
	end
	self.m_CountRow = 0
	self.m_CountColumn = 0
	for id, faction in ipairs(FactionManager.Map) do
		local color = faction:getColor()
		self:addPlayerCount(faction:getShortName(), self.m_FactionCount[id] or 0, tocolor(color.r, color.g, color.b))
	end
	for id, company in ipairs(CompanyManager.Map) do
		self:addPlayerCount(company:getShortName(), self.m_CompanyCount[id] or 0)
	end

	self.m_PlayerCount:setText(_("Derzeit %d Spieler online", #getElementsByType("player")))
	self.m_Ping:setText(_("eigener Ping: %dms", localPlayer:getPing()))
end

function ScoreboardGUI:addPlayerCount(name, value, color)
	if self.m_CountRow >= 3 then
		self.m_CountRow = 0
		self.m_CountColumn =  self.m_CountColumn+1
	end
	if self.m_PlayerCountLabels[name] then
		self.m_PlayerCountLabels[name]:setText(("%s: %d"):format(name, value))
	else
		self.m_PlayerCountLabels[name] = GUILabel:new(self.m_Width*0.05 + (self.m_Width/4*self.m_CountColumn), self.m_Height*0.72 + (self.m_Height*0.05*self.m_CountRow), self.m_Width/4, self.m_Height*0.05, ("%s: %d"):format(name, value), self.m_Rect)
		if color then
			self.m_PlayerCountLabels[name]:setColor(color)
		end
	end
	self.m_CountRow = self.m_CountRow + 1

end

function ScoreboardGUI:insertPlayers()
	for index, data in ipairs(self.m_Players) do
		local player = data[1]
		local karma = math.floor(player:getKarma() or 0)
		local item = self.m_Grid:addItem(
			player:getName(),
			data[2] and player:getFaction():getShortName() or "- Keine -",
			player:getCompany():getShortName()  or "- Keine -",
			player:getGroupName(),
			karma >= 0 and "+"..karma or " "..tostring(karma)
		)

		if data[2] then
			local color = player:getFaction():getColor()
			item:setColumnColor(2, tocolor(color.r, color.g, color.b))
		end

		if karma >= 5 then
			item:setColumnColor(5, Color.Green)
		elseif karma <= -5 then
			item:setColumnColor(5, Color.Red)
		end
	end
end
