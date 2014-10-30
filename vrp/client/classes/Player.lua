-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Player = inherit(MTAElement)

function Player:virtual_constructor()
	self.m_PublicSync = {}
	self.m_PrivateSync = {}
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
	end
	for k, v in pairs(public or {}) do
		self.m_PublicSync[k] = v
	end
end

function Player:getXP()
	return self:getPublicSync("XP")
end

function Player:getKarma()
	return self:getPublicSync("Karma")
end

function Player:getGroupName()
	--return self:getPublicSync("GroupName")
	return getElementData(self, "GroupName")
end

function Player:getJobName()
	local job = JobManager:getSingleton():getFromId(self:getPublicSync("JobId"))
	if job then
		return job:getName()
	else
		return "-"
	end
end

addEventHandler("PlayerPrivateSync", root, function(private) source:onUpdateSync(private, nil) end)
addEventHandler("PlayerPublicSync", root, function(public) source:onUpdateSync(nil, public) end)
