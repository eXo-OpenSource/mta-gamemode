-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobTrashman.lua
-- *  PURPOSE:     Trashman job
-- *
-- ****************************************************************************
JobTrashman = inherit(Job)
local MONEY_PER_CAN = 15

function JobTrashman:constructor()
	Job.constructor(self)

	local availableVehicles = {"Trashmaster"}
	self.m_VehicleSpawner1 = VehicleSpawner:new(2118.38, -2076.78, 12.5, availableVehicles, 135, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner2 = VehicleSpawner:new(2127.3, -2083.91, 12.5, availableVehicles, 135, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner3 = VehicleSpawner:new(2134.1, -2091.1, 12.5, availableVehicles, 135, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner1.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner2.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner3.m_Hook:register(bind(self.onVehicleSpawn,self))
	
	self.m_VehicleSpawner1:disable()
	self.m_VehicleSpawner2:disable()
	self.m_VehicleSpawner3:disable()

	self.m_DumpArea = createColRectangle(2096.9, -2081.6, 9.8, 10.5) -- 2096.9, -2071.1, 9.8, -10.5
	addEventHandler("onColShapeHit", self.m_DumpArea, bind(JobTrashman.dumpCans, self))

	addRemoteEvents{"trashcanCollect", "JobTrashmanAgain", "JobTrashmanStop"}
	addEventHandler("trashcanCollect", root, bind(self.Event_trashcanCollect, self))
	addEventHandler("JobTrashmanStop", root, bind(self.Event_stop, self))
	addEventHandler("onPlayerDisconnect", root, bind(JobTrashman.onPlayerDisconnect, self) )

end

function JobTrashman:onPlayerDisconnect(  )
	if isElement(source.vehTrashM) then
		destroyElement( source.vehTrashM )
	end
	if isTimer(source.m_EndTrashJobTimer) then
		killTimer( source.m_EndTrashJobTimer )
	end
end


function JobTrashman:onVehicleSpawn(player,vehicleModel,vehicle)
	addEventHandler("onVehicleStartEnter",vehicle, function(vehPlayer, seat)
		if vehPlayer ~= player then
			vehPlayer:sendError("Du kannst nicht in dieses Job-Fahrzeug!")
			cancelEvent()
		end
	end)
	if isElement(player.vehTrashM) then 
		destroyElement(player.vehTrashM)
		if isTimer(player.m_EndTrashJobTimer) then 
			killTimer(player.m_EndTrashJobTimer)
		end
	end
	addEventHandler("onVehicleExit",vehicle, function(vehPlayer, seat)
		if vehPlayer == player then
			player.vehTrashM = source
			player:sendWarning(_("Du hast noch 20 Sekunden um wieder in den Müllwagen einzusteigen!" , player ))
			player.m_EndTrashJobTimer = setTimer( bind(JobTrashman.endShift,self),20000,1, player )
		end
	end)
end

function JobTrashman:endShift( player )
	if isElement(player) then
		if isElement(player.vehTrashM) then 
			destroyElement(player.vehTrashM)
			player:sendInfo("Dein Müllwagen wurde entfernt!")
		end
	end
end

function JobTrashman:start(player)
	player:setData("Trashman:Cans", 0)
	player:giveAchievement(12)
	self.m_VehicleSpawner1:toggleForPlayer(player, true)
	self.m_VehicleSpawner2:toggleForPlayer(player, true)
	self.m_VehicleSpawner3:toggleForPlayer(player, true)
end

function JobTrashman:stop(player)
	self.m_VehicleSpawner1:toggleForPlayer(player, false)
	self.m_VehicleSpawner2:toggleForPlayer(player, false)
	self.m_VehicleSpawner3:toggleForPlayer(player, false)
end

function JobTrashman:checkRequirements(player)
	if not (player:getJobLevel() >= 1) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel 1", player), 255, 0, 0)
		return false
	end
	return true
end

function JobTrashman:Event_stop()
	if client:getOccupiedVehicle() and client:getOccupiedVehicle():getModel() == 408 then
		client:getOccupiedVehicle():destroy()
	end
	client:triggerEvent("jobTrashManStop")
	client:setJob(nil)
end


function JobTrashman:Event_trashcanCollect(containerNum)
	if not containerNum then return end
	if containerNum > 2 or containerNum < 1 then
		-- Possible cheat attempt | Todo: Add to anticheat
		return
	end

	-- Prevent the player from calling this event too often per specified interval -> Anticheat
	-- Note: It's bad to create the huge amount of trashcans on the server - but...we should do it probably?
	local lastTime = client:getData("Trashman:LastCan") or -math.huge
	if getTickCount() - lastTime < 2500 then
		AntiCheat:getSingleton():report("Trashman:TooMuchTrash", CheatSeverity.Low)
		return
	end
	client:setData("Trashman:LastCan", getTickCount())

	-- Increment the can counter now
	client:setData("Trashman:Cans", client:getData("Trashman:Cans") + containerNum)
end

function JobTrashman:dumpCans(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension and hitElement:getJob() == self then
		local numCans = hitElement:getData("Trashman:Cans")

		if numCans and numCans > 0 then
			local moneyAmount = numCans * MONEY_PER_CAN

			hitElement:giveMoney(moneyAmount, "Müll-Job")
			hitElement:givePoints(math.ceil(numCans/3))

			hitElement:sendInfoTimeout(_("Dein Lohn: %d$", hitElement, moneyAmount), 5000)

			hitElement:setData("Trashman:Cans", 0)
			hitElement:triggerEvent("trashcanReset")
			hitElement:triggerEvent("questionBox", _("Möchtest du weiter arbeiten?", hitElement), "JobTrashmanAgain", "JobTrashmanStop")

		else
			hitElement:sendInfoTimeout(_("Du hast keinen Müll aufgeladen!", hitElement, moneyAmount), 5000)
		end
	end
end
