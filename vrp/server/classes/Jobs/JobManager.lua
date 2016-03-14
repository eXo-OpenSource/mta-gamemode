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
		JobTrashman:new();
		JobRoadSweeper:new();
		JobLumberjack:new();
		JobFarmer:new();
		JobServiceTechnician:new();
		JobPizza:new();
		JobHeliTransport:new();
		JobLogistician:new();
		JobForkLift:new();
	}
	for k, v in ipairs(self.m_Jobs) do
		v:setId(k)
	end

	addEvent("jobAccepted", true)
	addEvent("jobQuit", true)
	addEventHandler("jobAccepted", root, bind(self.Event_jobAccepted, self))
	addEventHandler("jobQuit", root, bind(self.Event_jobQuit, self))
end

function JobManager:getFromId(jobId)
	return self.m_Jobs[jobId]
end

function JobManager:startJobForPlayer(job, player)
	-- Stop old job if exists
	local currentJob = player:getJob()
	if currentJob then
		if currentJob == job then return end
		if currentJob.stop then
			currentJob:stop(player)
		end
	end

	-- We're ready to start the job :)
	job:start(player)

	-- Tell the client that we started the job
	player:triggerEvent("jobStart", job:getId())
end

function JobManager:stopJobForPlayer(player)
	local job = player:getJob()
	if not job then
		return false
	end

	if job.stop then
		job:stop(player)
	end

	player:triggerEvent("jobQuit")
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

function JobManager:Event_jobQuit()
	local job = client:getJob()
	if not job then return end

	client:setJob(nil)
end
