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
end

function InactivityManager:clearHouses()
	
	local rows = sql:queryFetch("SELECT hs.Id as HouseID, ac.Id as UserID FROM ??_houses hs INNER JOIN ??_account ac ON ac.Id = hs.owner WHERE ac.LastLogin < DATE_SUB(DATE(NOW()), INTERVAL 2 MONTH);", sql:getPrefix(), sql:getPrefix())

	if rows then
		for k, v in ipairs(rows) do
			local price = math.floor(HouseManager:getSingleton().m_Houses[v.HouseID].m_Price*0.75)

			HouseManager:getSingleton().m_Houses[v.HouseID]:clearHouse()

			sql:queryExec("UPDATE ??_character SET Money = Money + ? WHERE Id = ?;",
				sql:getPrefix(), price, v.UserID)

			sqlLogs:queryExec("INSERT INTO ??_HousesFreed (Date, UserID, HouseID) VALUES (Now(), ?, ?)",
				sqlLogs:getPrefix(), v.UserID, v.HouseID)
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
