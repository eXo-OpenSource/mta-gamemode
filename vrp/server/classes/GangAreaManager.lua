-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupManager.lua
-- *  PURPOSE:     Group manager class
-- *
-- ****************************************************************************
GangAreaManager = inherit(Singleton)

function GangAreaManager:constructor()
	self.Map = {}
	
	outputServerLog("Loading gangareas...")
	self:addAreas()
end

function GangAreaManager:addAreas()
	local data = {
		{0, 0, 100, 100},
	}
	
	for i, v in ipairs(data) do
		self.Map[i] = GangArea:new(unpack(v))
	end
end
