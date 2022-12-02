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
	
	addRemoteEvents{"CookieClicker:saveCookies", "CookieClicker:onUpgradeBuy", "CookieClicker:requestData"}
	addEventHandler("CookieClicker:saveCookies", root, bind(self.saveCookies, self))
	addEventHandler("CookieClicker:onUpgradeBuy", root, bind(self.onUpgradeBuy, self))
	addEventHandler("CookieClicker:requestData", root, bind(self.onDataRequest, self))
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
end

function CookieClickerManager:takeCookies(player, amount)
	if isElement(player) then player = player:getId() end
	self.m_PlayerCookies[player] = self.m_PlayerCookies[player] - amount
end

function CookieClickerManager:onDataRequest()
	self:sendCookieData(client)
end