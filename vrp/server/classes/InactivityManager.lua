-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/InactivityManager.lua
-- *  PURPOSE:     Inactivity manager class
-- *
-- ****************************************************************************
InactivityManager = inherit(Singleton)

function InactivityManager:constructor()
	self:clearHouses()
	self:clearProperties()
end

function InactivityManager:clearHouses()
	
	local rows = sql:queryFetch("SELECT hs.Id as HouseID, ac.Id as UserID FROM ??_houses hs INNER JOIN ??_account ac ON ac.Id = hs.owner WHERE ac.LastLogin < DATE_SUB(DATE(NOW()), INTERVAL 1 MONTH);", sql:getPrefix(), sql:getPrefix())

	if rows then
		for k, v in ipairs(rows) do
			local house = HouseManager:getSingleton().m_Houses[v.HouseID]
			local price = math.floor(house.m_BuyPrice*0.75)

			BankServer.get("server.house"):transferMoney({"player", v.UserID, true}, price, "Hausräumung durch Inaktivität", "House", "Cleared")
			house.m_BankAccount:transferMoney({"player", v.UserID, true}, house.m_BankAccount:getMoney(), "Auszahlung der Hauskasse", "House", "Cleared")
			house:clearHouse()

			sqlLogs:queryExec("INSERT INTO ??_HousesFreed (Date, UserID, HouseID) VALUES (Now(), ?, ?)",
				sqlLogs:getPrefix(), v.UserID, v.HouseID)
		end
	end
end

function InactivityManager:isGroupInactive(id)
	local result, numrows = sql:queryFetch("SELECT ac.LastLogin FROM ??_character ch INNER JOIN ??_account ac ON ac.Id = ch.Id AND ch.GroupId = ? WHERE ac.LastLogin > DATE_SUB(DATE(NOW()), INTERVAL 1 MONTH)", sql:getPrefix(), sql:getPrefix(), id)
	if numrows == 0 then
		return true
	else
		return false
	end
end

function InactivityManager:clearProperties()
	local result = sql:queryFetch("SELECT Id, GroupId, Price FROM ??_group_property", sql:getPrefix())
	for _, row in ipairs(result) do
		if row.GroupId ~= 0 then
			if self:isGroupInactive(row.GroupId) then
				GroupPropertyManager:getSingleton():clearProperty(row.Id, row.GroupId, row.Price)
			end
		end
	end
end

function InactivityManager:destructor ()
end

--[[
CREATE TABLE `vrplogs_HousesFreed`  (
  `Id` int(0) NOT NULL AUTO_INCREMENT,
  `Date` datetime(0),
  `UserID` int(0),
  `HouseID` int(0),
  PRIMARY KEY (`Id`)
);
]]
