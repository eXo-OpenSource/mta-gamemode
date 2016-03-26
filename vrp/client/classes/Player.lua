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
	self.m_AFKCheckCount = 0
	self.m_LastPositon = Vector3(0, 0, 0)
	self.m_AFKTimer = setTimer ( bind(self.checkAFK, self), 20000, 0)
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
	end
end

function Player:setPrivateSyncChangeHandler(key, handler)
	self.m_PrivateSyncChangeHandler[key] = handler
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

function Player:getKarma()
	return self:getPublicSync("Karma") or 0
end

function Player:getGroupName()
	return self:getPublicSync("GroupName") or ""
end

function Player:getFactionId()
	return self:getPublicSync("FactionId") or 0
end

function Player:getCompanyId()
	return self:getPublicSync("CompanyId") or 0
end

function Player:getFactionName()
	return self:getPublicSync("FactionName") or "-"
end

function Player:getShortFactionName()
	return self:getPublicSync("ShortFactionName") or "-"
end

function Player:getCompanyName()
	return self:getPublicSync("CompanyName") or "-"
end

function Player:getShortCompanyName()
	return self:getPublicSync("ShortCompanyName") or "-"
end

function Player:getPlayTime()
	return (self:getPrivateSync("LastPlayTime") and self.m_JoinTime and math.floor(self:getPrivateSync("LastPlayTime") + (getTickCount()-self.m_JoinTime)/1000/60)) or 0
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

function Player:getAchievements ()
	return self:getPrivateSync("Achievements") or {[0] = false}
end

function Player:setTempMatchID (id)
	self.m_tempMatchID = id
	setTimer(function ()
		self.m_tempMatchID = 0
	end, 1000, 1)
end

function Player:checkAFK()
	if not self:getPublicSync("AFK") == true then
		local pos = self:getPosition()
		self.m_AFKCheckCount = self.m_AFKCheckCount + 1
		if getDistanceBetweenPoints3D(pos, self.m_LastPositon) > 3 then
			self.m_AFKCheckCount = 0
			triggerServerEvent("toggleAFK", localPlayer, false)
			removeEventHandler ( "onClientPedDamage", localPlayer, function() cancelEvent() end)
		end
		if self.m_AFKCheckCount == 27 then
			outputChatBox ( "WARNUNG: Du wirst in einer Minute zum AFK-Cafe befördert!", 255, 0, 0 )
			self:generateAFKCode()
		elseif self.m_AFKCheckCount == 30 then
			self.m_AFKCode = false
			triggerServerEvent("toggleAFK", localPlayer, true)
			addEventHandler ( "onClientPedDamage", localPlayer, function() cancelEvent() end)
		end
		self.m_LastPositon = pos
	end
end

function Player:generateAFKCode()
	local char = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z","0","1","2","3","4","5","6","7","8","9"}
	local code = {}
	for z = 1,4 do
		a = math.random(1,#char)
		x=string.lower(char[a])
		table.insert(code, x)
	end
	local fcode = table.concat(code)
	self.m_AFKCode = fcode
	outputChatBox("Um nicht ins AFK-Cafe zu kommen, gib folgenden Befehl ein: /noafk "..fcode,255,0,0)
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

addRemoteEvents{"PlayerPrivateSync", "PlayerPublicSync"}
addEventHandler("PlayerPrivateSync", root, function(private) source:onUpdateSync(private, nil) end)
addEventHandler("PlayerPublicSync", root, function(public) source:onUpdateSync(nil, public) end)
