-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/SprayWall.lua
-- *  PURPOSE:     Spray Wall class
-- *
-- ****************************************************************************
SprayWall = inherit(Object)

function SprayWall:constructor(Id, wallPosition, resourcesPerDistribution)
	self.m_Id = Id
	local result = sql:queryFetchSingle("SELECT Owner, State FROM ??_SprayWalls WHERE Id = ?", sql:getPrefix(), self.m_Id)

	self.m_ColShape = createColSphere(wallPosition.x, wallPosition.y, wallPosition.z, 20)

	if not result then
		self.m_OwnerGroup = false
	else
		self.m_OwnerGroup = GroupManager:getSingleton():getFromId(result.Owner)
		if self.m_OwnerGroup then -- May fail due to a deleted group
			setElementData(self.m_ColShape, "OwnerName", self.m_OwnerGroup:getName())
		end
	end

	-- Sync some data to the client | that's probably a bit hacky
	setElementID(self.m_ColShape, "SprayWall"..Id)

	self.m_ResourcesPerDistribution = resourcesPerDistribution
	self.m_BankAccountServer = BankServer.get("group.spraywall")
end

function SprayWall:destructor()
	self.m_ColShape:destroy()
	delete(self.m_RadarArea)
end

function SprayWall:getOwnerGroup()
	return self.m_OwnerGroup
end

function SprayWall:setOwner(client, newOwner)
	self.m_OwnerGroup = newOwner
	setElementData(self.m_ColShape, "OwnerName", self.m_OwnerGroup and self.m_OwnerGroup:getName() or "")

	if self.m_OwnerGroup then
		sql:queryExec("INSERT INTO ??_SprayWalls (Id, Owner) VALUES(?, ?) ON DUPLICATE KEY UPDATE Owner = ?", sql:getPrefix(), self.m_Id, self.m_OwnerGroup:getId(), self.m_OwnerGroup:getId())
	else
		sql:queryExec("DELETE FROM ??_SprayWalls WHERE Id = ?", sql:getPrefix(), self.m_Id)
	end
end

function SprayWall:distributeResources()
	-- Do we have an owner?
	if not self.m_OwnerGroup then
		return false
	end

	-- Do not distribute resources if noone is online
	if #self.m_OwnerGroup:getOnlinePlayers() == 0 then
		return false
	end

	self.m_OwnerGroup:distributeMoney(self.m_BankAccountServer, self.m_ResourcesPerDistribution, "Spray Wall", "Group", "SprayWall")
	return true
end

function SprayWall:canBeSprayed()
	-- Check if the gang area has no owner
	if not self.m_OwnerGroup then
		return true
	end

	-- Check if noone was playing (use MySQL statement directly instead of loading all data)
	for playerId in pairs(self.m_OwnerGroup:getPlayers(true)) do
		local row = sql:queryFetchSingle("SELECT DATE_ADD(LastLogin, INTERVAL 24 HOUR) > NOW() AS WasOnline FROM ??_account WHERE Id = ?", sql:getPrefix(), playerId)
		if row.WasOnline == 1 then
			return false
		end
	end

	return true
end
