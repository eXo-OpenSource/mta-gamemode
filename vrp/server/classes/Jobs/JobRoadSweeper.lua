-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobRoadSweeper.lua
-- *  PURPOSE:     Road sweeper job class
-- *
-- ****************************************************************************
JobRoadSweeper = inherit(Job)
local SWEEPER_LOAN = 28
local SWEEPER_MAX_LOAD = 50

function JobRoadSweeper:constructor()
	Job.constructor(self)
	self.m_BankAccount = BankServer.get("job.road_sweeper")

	self.m_VehicleSpawner = VehicleSpawner:new(205.7, -1442.8, 12.1, {"Sweeper"}, 315, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner:disable()

	addEvent("sweeperGarbageCollect", true)
	addEventHandler("sweeperGarbageCollect", root, bind(self.Event_sweeperGarbageCollect, self))

	self.m_DeliveryMarker = createMarker(191.18, -1440.59, 12.1, "cylinder", 2, 255, 255, 0)
	setElementVisibleTo(self.m_DeliveryMarker, root, false)
	addEventHandler("onMarkerHit", self.m_DeliveryMarker, bind(self.onDeliveryHit, self))
end

function JobRoadSweeper:onVehicleSpawn(player, vehicleModel, vehicle)
	player.m_LastJobAction = getRealTime().timestamp
	vehicle.Garbage = 0
	self:registerJobVehicle(player, vehicle, true, true)
end

function JobRoadSweeper:start(player)
	player:sendInfo(_("Job angenommen! Gehe zum roten Marker um ein Fahrzeug zu erhalten!", player))
	player:giveAchievement(13)
	self.m_VehicleSpawner:toggleForPlayer(player, true)
	setElementVisibleTo(self.m_DeliveryMarker, player, true)

end

function JobRoadSweeper:stop(player)
	self:destroyJobVehicle(player)
	self.m_VehicleSpawner:toggleForPlayer(player, false)
	setElementVisibleTo(self.m_DeliveryMarker, player, false)
end

function JobRoadSweeper:onDeliveryHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if hitElement.vehicle and hitElement.vehicle.model == 574 and hitElement:getJob() == self then
			if hitElement.vehicle.Garbage and hitElement.vehicle.Garbage > 0 then
				local garbage = hitElement.vehicle.Garbage
				local loan = garbage*SWEEPER_LOAN * JOB_PAY_MULTIPLICATOR
				hitElement.vehicle.Garbage = 0
				hitElement:sendShortMessage(_("%d Abfälle abgegeben!\nAbfallbehälter: %d/%d", hitElement, garbage, hitElement.vehicle.Garbage, SWEEPER_MAX_LOAD))

				local duration = getRealTime().timestamp - hitElement.m_LastJobAction
				hitElement.m_LastJobAction = getRealTime().timestamp
				self.m_BankAccount:transferMoney({hitElement, true}, loan, "Straßenreiniger-Job", "Job", "RoadSweeper")
				local points = 0
				for i = 0, garbage do
					if chance(15) then
						points = points + math.floor(1*JOB_EXTRA_POINT_FACTOR)
					end
				end
				hitElement:givePoints(points)

				StatisticsLogger:getSingleton():addJobLog(hitElement, "jobRoadSweeper", duration, loan, nil, nil, points)
			else
				hitElement:sendError(_("Du musst erst den Abfall auf den Straßen einsammeln!", hitElement))
			end
		end
	end
end

function JobRoadSweeper:Event_sweeperGarbageCollect()
	if client:getJob() ~= self then
		return
	end
	if client.vehicle and client.vehicle.model == 574 and client.vehicle.Garbage then
		if client.vehicle.Garbage < SWEEPER_MAX_LOAD then
			local lastTime = client:getData("Sweeper:Last") or -math.huge
			-- Prevent the player from calling this event too often per specified interval -> Anticheat
			-- Note: It's bad to create the huge amount of trashcans on the server - but...we should do it probably?
			if getTickCount() - lastTime < 400 then
				AntiCheat:getSingleton():report(client, "RoadSweeper:TooMuchTrashCollected", CheatSeverity.Low)
				return
			end
			client:setData("Sweeper:Last", getTickCount())
			client.vehicle.Garbage = client.vehicle.Garbage + 1
			client:sendShortMessage(_("Abfallbehälter: %d/%d", client, client.vehicle.Garbage, SWEEPER_MAX_LOAD))
		else
			client:sendError(_("Dein Abfallbehälter ist voll! Entleere ihn an der Müllstation!", client))
		end
	end
end
