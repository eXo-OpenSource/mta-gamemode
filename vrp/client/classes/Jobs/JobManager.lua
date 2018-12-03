-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobManager.lua
-- *  PURPOSE:     Job manager class
-- *
-- ****************************************************************************
JobManager = inherit(Singleton)

function JobManager:constructor()
	-- ATTENTION: Please use the same order server and clientside
	self.m_Jobs = {
		JobTrashman:new();
		JobRoadSweeper:new();
		JobLumberjack:new();
		JobFarmer:new();
		--JobServiceTechnician:new();
		JobPizza:new();
		JobHeliTransport:new();
		JobLogistician:new();
		JobForkLift:new();
		JobTreasureSeeker:new();
		JobGravel:new();
		JobBoxer:new();
	}
	for k, v in ipairs(self.m_Jobs) do
		v:setId(k)
	end

	addEvent("jobStart", true)
	addEvent("jobQuit", true)
	addEventHandler("jobStart", root, bind(self.Event_jobStart, self))
	addEventHandler("jobQuit", root, bind(self.Event_jobQuit, self))
end

function JobManager:getFromId(jobId)
	return self.m_Jobs[jobId]
end

function JobManager:Event_jobStart(jobId)
	local job = self:getFromId(jobId)
	if not job then return end

	-- Stop old job if exists
	if localPlayer:getJob() then
		if localPlayer:getJob().stop then
			localPlayer:getJob():stop()
		end
	end

	-- We're ready to start the job :)
	localPlayer:setJob(job)
	job:start()
end

function JobManager:Event_jobQuit()
	local job = localPlayer:getJob()
	if not job then return end

	if job.stop then
		job:stop()
	end
	localPlayer:setJob(nil)
end
