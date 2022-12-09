-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/CookieClickerManager.lua
-- *  PURPOSE:     Cookie clicker manager class
-- *
-- ****************************************************************************
CookieClickerManager = inherit(Singleton)

CookieClickerManager.Upgrades = {
	[1] = {Price = 400, AddedClicks = 1},
	[2] = {Price = 1350, AddedClicks = 4},
	[3] = {Price = 2400, AddedClicks = 6},
	[4] = {Price = 4050, AddedClicks = 8},
	[5] = {Price = 6300, AddedClicks = 10},
	[6] = {Price = 9700, AddedClicks = 12},
}

function CookieClickerManager:constructor()
	self.m_PlayerCookies = {}
	self.m_PlayerCookieUpgrades = {}
	self.m_PlayerCookiesPlace = {}
	self.m_CookieClickerBans = {}
	self.m_IsActive = false

	local result = sql:queryFetch("SELECT UserId, BanReason FROM ??_cookie_clicker WHERE BanReason IS NOT NULL", sql:getPrefix())
	for i, data in pairs(result) do
		self.m_CookieClickerBans[data["UserId"]] = data["BanReason"]
	end

	if getRealTime().month + 1 == 12 and getRealTime().monthday <= 24 then
		if getRealTime().monthday == 24 then
			GlobalTimer:getSingleton():registerEvent(function()
				for key, player in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
					player:triggerEvent("CookieClicker:forceCloseGUI")
					player:sendInfo(_("Das Cookie Clicker Event ist nun beendet. \nInfos bezüglicher der Gewinner und Gewinne werden zeitnah im Forum bekannt gegeben.\nVielen Dank an alle Teilnehmer."))
					self.m_IsActive = false
				end
			end, "End Cookie Clicker Event", nil, 23, 59)
		end
		self.m_IsActive = true
	end

	addRemoteEvents{"CookieClicker:saveCookies", "CookieClicker:onUpgradeBuy", "CookieClicker:requestData"}
	addEventHandler("CookieClicker:saveCookies", root, bind(self.saveCookies, self))
	addEventHandler("CookieClicker:onUpgradeBuy", root, bind(self.onUpgradeBuy, self))
	addEventHandler("CookieClicker:requestData", root, bind(self.onDataRequest, self))
	addCommandHandler("addCCBan", bind(self.addCookieClickerBan, self))
end

function CookieClickerManager:addCookieClickerBan(player, cmd, playerToBan, ...)
	if player:getRank() > RANK.Administrator then
		if playerToBan then
			local args = table.concat({...}, " ")
			if Account.getIdFromName(playerToBan) then
				local userId = Account.getIdFromName(playerToBan)
				if not self.m_CookieClickerBans[userId] then
					local bPlayer = PlayerManager:getSingleton():getPlayerFromId(userId)
					self.m_CookieClickerBans[userId] = args
					sql:queryExec("UPDATE ??_cookie_clicker SET BanReason = ? WHERE UserId = ?", sql:getPrefix(), args or "", userId)
				
					if bPlayer then
						bPlayer:sendError(_("Du wurdest vom Cookie Clicker gesperrt! Grund: %s", bPlayer, args or ""))
						bPlayer:triggerEvent("CookieClicker:forceCloseGUI", false)
					end
				else
					player:sendError(_("Der Spieler hat bereits eine Sperre!", player))
				end
			else
				player:sendError(_("Fehler: Spieler nicht gefunden!", player))
			end
		else
			outputChatBox(_("Syntax: userId, reason", player), player, 200, 0,0)
		end
	end
end

function CookieClickerManager:destructor()
	for userId, cookies in pairs(self.m_PlayerCookies) do
		local upgrades = toJSON(self.m_PlayerCookieUpgrades[userId])
		sql:queryExec("INSERT INTO ??_cookie_clicker (UserId, Cookies, Upgrades) VALUES(?, ?, ?) ON DUPLICATE KEY UPDATE Cookies = ?, Upgrades = ?", sql:getPrefix(), userId, cookies, upgrades, cookies, upgrades)
	end
end

function CookieClickerManager:saveCookies(cookies)
	self.m_PlayerCookies[client:getId()] = cookies
end

function CookieClickerManager:onUpgradeBuy(id)
	local currentUpgrade = self.m_PlayerCookieUpgrades[client:getId()][tostring(id)]
	local price = math.floor(CookieClickerManager.Upgrades[id].Price + ((currentUpgrade + 1 * 0.1) * CookieClickerManager.Upgrades[id].Price) * 1.1)

	if price <= self.m_PlayerCookies[client:getId()] then
		self:takeCookies(client, price)
		self.m_PlayerCookieUpgrades[client:getId()][tostring(id)] = self.m_PlayerCookieUpgrades[client:getId()][tostring(id)] + 1
		self:sendCookieData(client)
	end
end

function CookieClickerManager:sendCookieData(player)
	if self.m_IsActive then 
		if not self.m_CookieClickerBans[player:getId()] then
			if not self.m_PlayerCookies[player:getId()] then
				local result, numRows = sql:queryFetch("SELECT * FROM ??_cookie_clicker WHERE UserId = ?", sql:getPrefix(), player:getId())
				if numRows >= 1 then
					for i, data in pairs(result) do
						self.m_PlayerCookies[data["UserId"]] = data["Cookies"]
						self.m_PlayerCookieUpgrades[data["UserId"]] = fromJSON(data["Upgrades"])
					end
				else
					if not self.m_PlayerCookies[player:getId()] then
						self.m_PlayerCookies[player:getId()] = 0
					end
					if not self.m_PlayerCookieUpgrades[player:getId()] then
						self.m_PlayerCookieUpgrades[player:getId()] = {["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0}
					end
				end
			end
			player:triggerEvent("CookieClicker:sendCookieData", self.m_PlayerCookies[player:getId()], self.m_PlayerCookieUpgrades[player:getId()], CookieClickerManager.Upgrades)
		else
			player:sendError(_("Du wurdest vom Cookie Clicker ausgeschlossen!\nGrund: %s", player, self.m_CookieClickerBans[player:getId()]))
			player:triggerEvent("CookieClicker:forceCloseGUI", true)
		end
	else
		player:sendError(_("Derzeit läuft kein Cookie Clicker Event!", player))
		player:triggerEvent("CookieClicker:forceCloseGUI", true)
	end
end

function CookieClickerManager:takeCookies(player, amount)
	if isElement(player) then player = player:getId() end
	self.m_PlayerCookies[player] = self.m_PlayerCookies[player] - amount
end

function CookieClickerManager:onDataRequest()
	self:sendCookieData(client)
end