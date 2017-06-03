-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobRoadSweeper.lua
-- *  PURPOSE:     Road sweeper job class
-- *
-- ****************************************************************************
JobRoadSweeper = inherit(Job)
local SWEEPER_LOAN = 8

function JobRoadSweeper:constructor()
	Job.constructor(self)

	self.m_VehicleSpawner = VehicleSpawner:new(205.7, -1442.8, 12.1, {"Sweeper"}, 315, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner:disable()

	addEvent("sweeperGarbageCollect", true)
	addEventHandler("sweeperGarbageCollect", root, bind(self.Event_sweeperGarbageCollect, self))
end

function JobRoadSweeper:onVehicleSpawn(player, vehicleModel, vehicle)
	player.m_LastJobAction = getRealTime().timestamp
	self:registerJobVehicle(player, vehicle, true, true)
end

function JobRoadSweeper:start(player)
	player:sendInfo(_("Job angenommen! Gehe zum roten Marker um ein Fahrzeug zu erhalten!", player))
	player:giveAchievement(13)
	self.m_VehicleSpawner:toggleForPlayer(player, true)
end

function JobRoadSweeper:stop(player)
	self:destroyJobVehicle(player)
	self.m_VehicleSpawner:toggleForPlayer(player, false)
end

function JobRoadSweeper:Event_sweeperGarbageCollect()
	if client:getJob() ~= self then
		return
	end

	-- Prevent the player from calling this event too often per specified interval -> Anticheat
	-- Note: It's bad to create the huge amount of trashcans on the server - but...we should do it probably?
	local lastTime = client:getData("Sweeper:Last") or -math.huge
	if getTickCount() - lastTime < 400 then
		AntiCheat:getSingleton():report(client, "RoadSweeper:TooMuchTrashCollected", CheatSeverity.Low)
		return
	end
	client:setData("Sweeper:Last", getTickCount())
	local bonus = JobManager.getBonusForNewbies( client, SWEEPER_LOAN)
	if not bonus then bonus = 0 end
	local duration = getRealTime().timestamp - client.m_LastJobAction
	client.m_LastJobAction = getRealTime().timestamp
	StatisticsLogger:getSingleton():addJobLog(client, "jobRoadSweeper", duration, SWEEPER_LOAN, bonus)
	client:giveMoney(SWEEPER_LOAN+bonus, "Straßenreiniger-Job", true)
	if chance(15) then
		client:givePoints(math.floor(1*JOB_EXTRA_POINT_FACTOR))
	end	
end
