-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobRoadSweeper.lua
-- *  PURPOSE:     Road sweeper job class
-- *
-- ****************************************************************************
JobRoadSweeper = inherit(Job)

function JobRoadSweeper:constructor()
	Job.constructor(self)

	self.m_VehicleSpawner = VehicleSpawner:new(205.7, -1442.8, 12.1, {"Sweeper"}, 315, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner:disable()

	addEvent("sweeperGarbageCollect", true)
	addEventHandler("sweeperGarbageCollect", root, bind(self.Event_sweeperGarbageCollect, self))
end

function JobRoadSweeper:onVehicleSpawn(player, vehicleModel, vehicle)
	if isElement(player.vehRoadSweeper) then
		destroyElement(player.vehRoadSweeper)
	end

	vehicle.m_SweeperOwner = player
	player.vehRoadSweeper = vehicle

	addEventHandler("onVehicleStartEnter",vehicle, function(vehPlayer, seat)
		if vehPlayer ~= player then
			vehPlayer:sendError("Du kannst nicht in dieses Job-Fahrzeug!")
			cancelEvent()
		end
	end)
	vehicle:addCountdownDestroy(10)
	self.m_OnVehicleAction = bind(self.onVehicleAction, self)
	addEventHandler("onVehicleExplode", vehicle, self.m_OnVehicleAction)
	addEventHandler("onElementDestroy", vehicle, self.m_OnVehicleAction)
end

function JobRoadSweeper:onVehicleAction()
	self:stop(source.m_SweeperOwner)

end

function JobRoadSweeper:start(player)
	player:giveAchievement(13)
	self.m_VehicleSpawner:toggleForPlayer(player, true)
end

function JobRoadSweeper:stop(player)
	self.m_VehicleSpawner:toggleForPlayer(player, false)
	if player.vehRoadSweeper and isElement(player.vehRoadSweeper) then destroyElement(player.vehRoadSweeper) end
	player:triggerEvent("jobQuit")
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

	client:giveMoney(3, "Straßenreiniger-Job", true)
	if chance(15) then
		client:givePoints(1)
	end
end
