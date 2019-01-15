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
	GUIForm.constructor(self, screenWidth/2-(screenWidth*0.65/2), screenHeight/2-screenHeight*0.3, screenWidth*0.65, screenHeight*0.6, false, true)

	self.m_Rect = GUIRectangle:new(0, self.m_Width*0.06 , self.m_Width, self.m_Height - self.m_Width*0.06, tocolor(0, 0, 0, 200), self)
	self.m_Logo = GUIImage:new(self.m_Width-self.m_Width*0.18, self.m_Height*0.83, self.m_Width*0.180, self.m_Width*0.078, "files/images/LogoNoFont.png", self)

	self.m_Grid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.96, self.m_Height*0.62, self.m_Rect)
	self.m_Grid:setFont(VRPFont(24))
	self.m_Grid:setItemHeight(24)
	self.m_Grid:setColor(Color.Clear)
	self.m_Grid:setColumnBackgroundColor(Color.Clear)
	self.m_Grid:addColumn(_"VIP", 0.05)
	self.m_Grid:addColumn(_"Name", 0.2)
	self.m_Grid:addColumn(_"Fraktion", 0.14)
	self.m_Grid:addColumn(_"Unternehmen", 0.15)
	self.m_Grid:addColumn(_"Gang/Firma", 0.19)
	self.m_Grid:addColumn(_"Spielzeit", 0.08)
	self.m_Grid:addColumn(_"Karma", 0.08)
	self.m_Grid:addColumn(_"Ping", 0.11)
	self.m_Grid:setSortable{"VIP", "Name", "Fraktion", "Unternehmen", "Gang/Firma", "Spielzeit"} --We can't sort Ping and Karma (Ping can be a number and also a string; karma is a numeric string eg. "+123" which will be not sort properly)
	self.m_Grid:setSortColumn(_"Fraktion")

	self.m_Line = GUIRectangle:new(0, self.m_Height*0.65, self.m_Width, self.m_Height*0.05, Color.Accent, self.m_Rect)
	self.m_PlayerCount = GUILabel:new(self.m_Width*0.05, self.m_Height*0.65, self.m_Width/2, self.m_Height*0.05, "", self.m_Rect)
	self.m_PlayerCount:setColor(Color.White):setFont(VRPFont(self.m_Height*0.05))
	self.m_Ping = GUILabel:new(self.m_Width/2, self.m_Height*0.65, self.m_Width/2-self.m_Width*0.05, self.m_Height*0.05, "", self.m_Rect)
	self.m_Ping:setColor(Color.White):setFont(VRPFont(self.m_Height*0.05)):setAlignX("right")

	self.m_OldWeaponSlot = localPlayer:getWeaponSlot()

	self.m_ScrollBind = bind(self.onScoreBoardScroll, self)
end

function ScoreboardGUI:onShow()
	toggleControl("next_weapon", false)
	toggleControl("previous_weapon", false)
	toggleControl("action", false)
	setPedControlState("action", false)
	self.m_OldWeaponSlot = localPlayer:getWeaponSlot()
	self:refresh()
	self.m_Timer = setTimer(bind(self.refresh, self), 15000, 0)
	self.m_Showing = true
	bindKey("mouse_wheel_up", "down", self.m_ScrollBind)
	bindKey("mouse_wheel_down", "down", self.m_ScrollBind)

	RadioGUI:getSingleton():setControlEnabled(false)
end

function ScoreboardGUI:onHide()
	if self.m_Timer and isTimer(self.m_Timer) then killTimer(self.m_Timer) end
	if not NoDm:getSingleton().m_NoDm then
		toggleControl("next_weapon", true)
		toggleControl("previous_weapon", true)
		toggleControl("action", true)
	end
	unbindKey("mouse_wheel_up", "down", self.m_ScrollBind)
	unbindKey("mouse_wheel_down", "down", self.m_ScrollBind)
	RadioGUI:getSingleton():setControlEnabled(true)
	self.m_Showing = false
end

function ScoreboardGUI:onScoreBoardScroll(key)
	if key == "mouse_wheel_up" then
		self.m_Grid.m_ScrollArea:onInternalMouseWheelUp()
	elseif key == "mouse_wheel_down" then
		self.m_Grid.m_ScrollArea:onInternalMouseWheelDown()
	end
end

function ScoreboardGUI:refresh()
	local scrollPosX, scrollPosY = self.m_Grid.m_ScrollArea:getScrollPosition()
	local scrollAreaDocumentSize_old = self.m_Grid.m_ScrollArea.m_DocumentHeight
	local scrollAreaHeight = self.m_Grid.m_ScrollArea.m_Height

	self.m_Grid:clear()
	self.m_Players = {}
	self.m_CompanyCount = {}
	self.m_CompanyAFKCount = {}
	self.m_FactionCount = {}
	self.m_FactionAFKCount = {}

	for k, player in pairs(getElementsByType("player")) do
		local factionId = player:getFaction() and player:getFaction():getId() or 0
		local companyId = player:getCompany() and player:getCompany():getId() or 0
		table.insert(self.m_Players, player)

		if factionId ~= 0 then
			if not self.m_FactionCount[factionId] then self.m_FactionCount[factionId] = 0 end
			if not self.m_FactionAFKCount[factionId] then self.m_FactionAFKCount[factionId] = 0 end

			self.m_FactionCount[factionId] = self.m_FactionCount[factionId] + 1
			if player:isAFK() then
				self.m_FactionAFKCount[factionId] = self.m_FactionAFKCount[factionId] + 1
			end
		end

		if companyId ~= 0 then
			if not self.m_CompanyCount[companyId] then self.m_CompanyCount[companyId] = 0 end
			if not self.m_CompanyAFKCount[companyId] then self.m_CompanyAFKCount[companyId] = 0 end

			self.m_CompanyCount[companyId] = self.m_CompanyCount[companyId] + 1
			if player:isAFK() then
				self.m_CompanyAFKCount[companyId] = self.m_CompanyAFKCount[companyId] + 1
			end
		end
	end

	self:insertPlayers()

	local scrollAreaDocumentSize_new = self.m_Grid.m_ScrollArea.m_DocumentHeight
	if scrollPosY ~= 0 and scrollAreaDocumentSize_old > scrollAreaDocumentSize_new and math.abs(scrollPosY) > scrollAreaDocumentSize_new - scrollAreaHeight then
		scrollPosY = (scrollPosY / (scrollAreaDocumentSize_old - scrollAreaHeight) * scrollAreaDocumentSize_new) + scrollAreaHeight
		if math.abs(scrollPosY) < scrollAreaHeight or scrollPosY > 0 then
			scrollPosY = 0
		end
	end

	self.m_Grid.m_ScrollArea:setScrollPosition(scrollPosX, scrollPosY)

	if not self.m_PlayerCountLabels then
		self.m_PlayerCountLabels = {}
	end
	self.m_CountRow = 0
	self.m_CountColumn = 0
	for id, faction in pairs(FactionManager.Map) do
		local color = faction:getColor()
		self:addPlayerCount(faction:getShortName(), self.m_FactionCount[id] or 0, self.m_FactionAFKCount[id] or 0, tocolor(color.r, color.g, color.b))
	end
	for id, company in ipairs(CompanyManager.Map) do
		self:addPlayerCount(company:getShortName(), self.m_CompanyCount[id] or 0, self.m_CompanyAFKCount[id] or 0)
	end

	self.m_PlayerCount:setText(_("Derzeit sind %d Spieler online", #getElementsByType("player")))
	self.m_Ping:setText(_("eigener Ping: %dms", localPlayer:getPing()))
end

function ScoreboardGUI:addPlayerCount(name, value, valueAFK, color)
	if self.m_CountRow >= 3 then
		self.m_CountRow = 0
		self.m_CountColumn =  self.m_CountColumn+1
	end
	if not self.m_PlayerCountLabels[name] then
		self.m_PlayerCountLabels[name] = GUILabel:new(self.m_Width*0.05 + (self.m_Width/6*self.m_CountColumn), self.m_Height*0.72 + (self.m_Height*0.05*self.m_CountRow), self.m_Width/4, self.m_Height*0.05, "", self.m_Rect)
		if color then
			self.m_PlayerCountLabels[name]:setColor(color)
		end
	end

	if valueAFK ~= 0 then
		self.m_PlayerCountLabels[name]:setText(("%s: %d (%d AFK)"):format(name, value, valueAFK))
	else
		self.m_PlayerCountLabels[name]:setText(("%s: %d"):format(name, value))
	end

	self.m_CountRow = self.m_CountRow + 1
end

function ScoreboardGUI:insertPlayers()
	local gname
	for index, player in ipairs(self.m_Players) do
		local karma = math.floor(player:getKarma() or 0)
		local hours, minutes = math.floor(player:getPlayTime()/60), (player:getPlayTime() - math.floor(player:getPlayTime()/60)*60)
		local ping
		if player:isAFK() then
			ping = "AFK"
		elseif player:isInJail() then
			ping = "Knast"
		else
			ping = player:getPing().."ms"
		end

		gname = player:getGroupName()
		if gname == "" or #gname == 0 then
			gname = "-Keine-"
		end
		local item = self.m_Grid:addItem(
			player:isPremium() and "files/images/Nametag/premium.png" or "files/images/Textures/Other/trans.png",
			player:getName(),
			player:getFaction() and player:getFaction():getShortName() or "- Keine -",
			player:getCompany() and player:getCompany():getShortName()  or "- Keins -",
			string.short(gname, 16),
			("%d:%.2d"):format(hours, minutes), --hours..":"..minutes,
			("%s%d"):format(karma >= 0 and "+" or "-", math.abs(karma)), --karma >= 0 and "+"..karma or " "..tostring(karma),
			ping or " - "
		)
		item:setColumnToImage(1, true, item.m_Height)
		item:setFont(VRPFont(24))
		if player:getFaction() then
			local color = player:getFaction():getColor()
			item:setColumnColor(3, tocolor(color.r, color.g, color.b))
		end

		if player:getGroupType() then
			if player:getGroupType() == "Gang" then
				item:setColumnColor(5, Color.Red)
			elseif player:getGroupType() == "Firma" then
				item:setColumnColor(5, Color.Accent)
			end
		end

		if ping == "AFK" then
			item:setColumnColor(8, Color.Red)
		elseif ping == "Knast" then
			item:setColumnColor(8, Color.Yellow)
		end

		if karma >= 5 then
			item:setColumnColor(7, Color.Green)
		elseif karma <= -5 then
			item:setColumnColor(7, Color.Red)
		end
	end

	if DEBUG and add then
		local rndFaction = {"SAPD", "FBI", "SASF", "Rescue", "LCN", "Yakuzza", "Grove", "Ballas", "Outlaws", "Aztecas", "Kartell", "- Keine -"}
		local rndCompany = {"Fahrschule", "M & T", "San News", "EPT", "- Keins -" }

		for i = 1, 50 do
			local faction = rndFaction[math.random(1, #rndFaction)]
			local company = rndCompany[math.random(1, #rndCompany)]
			local karma = math.random(-150, 150)
			local ping = math.random(1,3) == 1 and (math.random(1,5) == 1 and "Knast" or "AFK") or math.random(15, 200)

			local item = self.m_Grid:addItem(
				math.random(1,2) == 1 and "files/images/Nametag/premium.png" or "files/images/Textures/Other/trans.png",
				getRandomUniqueNick(),
				faction,
				company,
				"- Keine -",
				("%d:%.2d"):format(math.random(1, 1337), math.random(0, 59)),
				("%s%d"):format(karma >= 0 and "+" or "-", math.abs(karma)),
				ping or " - "
			)
			item:setColumnToImage(1, true, item.m_Height)
			item:setFont(VRPFont(24))

			if FactionManager:getSingleton():getFromName(faction) then
				local color = FactionManager:getSingleton():getFromName(faction):getColor()
				item:setColumnColor(3, tocolor(color.r, color.g, color.b))
			end

			if ping == "AFK" then
				item:setColumnColor(8, Color.Red)
			elseif ping == "Knast" then
				item:setColumnColor(8, Color.Yellow)
			end

			if karma >= 5 then
				item:setColumnColor(7, Color.Green)
			elseif karma <= -5 then
				item:setColumnColor(7, Color.Red)
			end
		end
	end
end
