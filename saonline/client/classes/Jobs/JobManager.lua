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
		JobLogistician:new();
		JobTrashman:new();
	}
	for k, v in ipairs(self.m_Jobs) do
		v:setId(k)
	end
	
	addEvent("jobStart", true)
	addEventHandler("jobStart", root, bind(self.Event_jobStart, self))
end

function JobManager:getFromId(jobId)
	return self.m_Jobs[jobId]
end

function JobManager:Event_jobStart(jobId)
	local job = self:getFromId(jobId)
	if not job then return end
	
	if job.start then
		job:start()
	end
end
