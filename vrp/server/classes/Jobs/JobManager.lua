-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobManager.lua
-- *  PURPOSE:     Job manager class
-- *
-- ****************************************************************************
JobManager = inherit(Singleton)

function JobManager:constructor()
	-- ATTENTION: Please use the same order server and clientside
	self.m_Jobs = {
		--JobLogistician:new();
		JobTrashman:new();
		JobRoadSweeper:new();
		JobLumberjack:new();
		JobPolice:new();
		
		JobPickpocket:new();
	}
	for k, v in ipairs(self.m_Jobs) do
		v:setId(k)
	end
	
	-- Events
	addEvent("jobAccepted", true)
	addEventHandler("jobAccepted", root, bind(self.Event_jobAccepted, self))
end

function JobManager:getFromId(jobId)
	return self.m_Jobs[jobId]
end

function JobManager:startJobForPlayer(job, player)
	-- Stop old job if exists
	if player:getJob() then
		if player:getJob().stop then
			player:getJob():stop(player)
		end
	end
	
	-- We're ready to start the job :)
	job:start(player)
	
	-- Tell the client that we started the job
	player:triggerEvent("jobStart", job:getId())
end

function JobManager:Event_jobAccepted(jobId)
	if not jobId then return end
	
	-- Get the job
	local job = self:getFromId(jobId)
	if not job then return end
	
	-- Check requirements
	if job.checkRequirements and not job:checkRequirements(client) then
		return
	end
	
	-- Start the job
	client:setJob(job)
end
