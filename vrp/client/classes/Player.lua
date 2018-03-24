-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Player = inherit(MTAElement)
registerElementClass("player", Player)

function Player:virtual_constructor()
	self.m_Karma = 0
	self.m_GarageType = 0

	self.m_PublicSync = {}
	self.m_PrivateSync = {}
	self.m_PrivateSyncChangeHandler = {}
	self.m_PublicSyncChangeHandler = {}
end

function Player:getPublicSync(key)
	return self.m_PublicSync[key]
end

function Player:getPrivateSync(key)
	return self.m_PrivateSync[key]
end

function Player:onUpdateSync(private, public)
	for k, v in pairs(private or {}) do
		self.m_PrivateSync[k] = v

		local f = self.m_PrivateSyncChangeHandler[k]
		if f then f(v) end
	end
	for k, v in pairs(public or {}) do
		self.m_PublicSync[k] = v

		local f = self.m_PublicSyncChangeHandler[k]
		if f then f(v) end
	end
end

function Player:setPrivateSyncChangeHandler(key, handler)
	self.m_PrivateSyncChangeHandler[key] = handler
end

function Player:setPublicSyncChangeHandler(key, handler)
	self.m_PublicSyncChangeHandler[key] = handler
end

function Player:getXP()
	return self:getPublicSync("XP") or 0
end

function Player:getLevel()
	return calculatePlayerLevel(self:getXP())
end

function Player:getWanteds()
	return self:getPublicSync("Wanteds") or 0
end

function Player:isPremium()
	return self:getPublicSync("Premium") or false
end

function Player:getKarma()
	return self:getPublicSync("Karma") or 0
end

function Player:getGroupId()
	return self:getPublicSync("GroupId") or 0
end

function Player:getGroupName()
	return self:getPublicSync("GroupName") or ""
end

function Player:getSTVO_NEW(category)
	return self:getPublicSync("STVO_NEW")[category]
end

function Player:getSTVO()
	return self:getPublicSync("STVO") or 0
end

function Player:getGroupType()
	return self:getPublicSync("GroupType") or false
end

function Player:getFactionId()
	return self:getPublicSync("FactionId") or 0
end

function Player:getCompanyId()
	return self:getPublicSync("CompanyId") or 0
end

function Player:isAFK()
	return self:getPublicSync("AFK") or false
end

function Player:isInJail()
	return self:getData("inJail") or false
end

function Player:getFaction()
	if self:getPublicSync("FactionId") and self:getPublicSync("FactionId") > 0 then
		return FactionManager:getSingleton():getFromId(self:getPublicSync("FactionId"))
	else
		return false
	end
end

function Player:getCompany()
	if self:getPublicSync("CompanyId") and self:getPublicSync("CompanyId") > 0 then
		return CompanyManager:getSingleton():getFromId(self:getPublicSync("CompanyId"))
	else
		return false
	end
end

function Player:getPlayTime()
	return getElementData(self, "playingTime") or 0
end

function Player:getJobName()
	local job = JobManager:getSingleton():getFromId(self:getPublicSync("JobId"))
	if job then
		return job:getName()
	else
		return "-"
	end
end

function Player:getGarageType ()
	return self.m_GarageType
end

function Player:giveAchievement (...)
	if Achievement:isInstantiated() then
		Achievement:getSingleton():giveAchievement(self, ...)
	else
		outputDebug("Achievement hasn't been instantiated yet!")
	end
end

function Player:setTempMatchID (id)
	self.m_tempMatchID = id
	setTimer(function ()
		self.m_tempMatchID = 0
	end, 1000, 1)
end

function Player:getMatchID ()
	return (
		(
			self:getPublicSync("DMMatchID") and
			self:getPublicSync("DMMatchID") > 0 and
			self:getPublicSync("DMMatchID")
		) or (
			self.m_tempMatchID and
			self.m_tempMatchID > 0 and
			self.m_tempMatchID
		) or (0)
	)
end

function Player:getSurfingCar()
	local result = {processLineOfSight(localPlayer.position, localPlayer.matrix:transformPosition(Vector3(0, 0, -1.5)), false, true, false, false, false, false, false, false, localPlayer, false, true)}
	return result[5]
end

function Player:isSurfOnCar(vehicle)
	return self:getSurfingCar() == vehicle
end

addRemoteEvents{"PlayerPrivateSync", "PlayerPublicSync"}
addEventHandler("PlayerPrivateSync", root, function(private) source:onUpdateSync(private, nil) end)
addEventHandler("PlayerPublicSync", root, function(public) source:onUpdateSync(nil, public) end)
