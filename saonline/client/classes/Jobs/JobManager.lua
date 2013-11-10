-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/Jobs/JobManager.lua
-- *  PURPOSE:     Job manager class
-- *
-- ****************************************************************************
JobManager = inherit(Singleton)

function JobManager:constructor()
	-- ATTENTION: Please use the same order server and clientside
	self.m_Jobs = {
		JobLogistician:new()
	}
	for k, v in ipairs(self.m_Jobs) do
		v:setId(k)
	end
end

function JobManager:getFromId(jobId)
	return self.m_Jobs[jobId]
end
