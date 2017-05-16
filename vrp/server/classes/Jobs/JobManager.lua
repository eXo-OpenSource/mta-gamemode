-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobManager.lua
-- *  PURPOSE:     Job manager class
-- *
-- ****************************************************************************
JobManager = inherit(Singleton)
local BONUS_MAX_PLAYT = 50 -- < 50 Spielstunden = Bonus beim Jobben
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
	}
	for k, v in ipairs(self.m_Jobs) do
		v:setId(k)
	end

	addEvent("jobAccepted", true)
	addEvent("jobQuit", true)
	addRemoteEvents{"jobDecline", "jobAccepted", "jobQuit"}
	addEventHandler("jobAccepted", root, bind(self.Event_jobAccepted, self))
	addEventHandler("jobDecline", root, bind(self.Event_jobDecline, self))

	addEventHandler("jobQuit", root, bind(self.Event_jobQuit, self))

	PlayerManager:getSingleton():getQuitHook():register(
		function(player)
			self:stopJobForPlayer(player)
		end
	)

	PlayerManager:getSingleton():getWastedHook():register(
		function(player)
			self:stopJobForPlayer(player)
		end
	)
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
	player:giveAchievement(75)
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

	if client:isFactionDuty() then
		client:sendError(_("Du darfst nicht im Dienst jobben! (Fraktion)", client))
		return
	end

	if client:isCompanyDuty() then
		client:sendError(_("Du darfst nicht im Dienst jobben! (Unternehmen)", client))
		return
	end
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

function JobManager:Event_jobDecline(jobId)
	if not jobId then return end

	-- Get the job
	local job = self:getFromId(jobId)
	if not job then return end

	local currentJob = client:getJob()
	if currentJob == job then
		client:setJob(nil)
	end
end

function JobManager:Event_jobQuit()
	local job = client:getJob()
	if not job then return end

	client:setJob(nil)
end

function JobManager.getBonusForNewbies( player , payout)
	local playtime = player:getPlayTime()
	local bonus = 0
	if playtime then 
		if playtime <= BONUS_MAX_PLAYT then 
			bonus = ( 1- ( (playtime/60) / BONUS_MAX_PLAYT) ) * (payout*0.25)
			return bonus
		end
	end
	return bonus
end