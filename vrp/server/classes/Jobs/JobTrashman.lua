-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobTrashman.lua
-- *  PURPOSE:     Trashman job
-- *
-- ****************************************************************************
JobTrashman = inherit(Job)
local MONEY_PER_CAN = 40 --// 15 default

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

end

function JobTrashman:onVehicleSpawn(player,vehicleModel,vehicle)
	player.m_LastJobAction = getRealTime().timestamp
	self:registerJobVehicle(player, vehicle, true, true)
end

function JobTrashman:start(player)
	player:setData("Trashman:Cans", 0)
	player:giveAchievement(12)
	self.m_VehicleSpawner1:toggleForPlayer(player, true)
	self.m_VehicleSpawner2:toggleForPlayer(player, true)
	self.m_VehicleSpawner3:toggleForPlayer(player, true)
end

function JobTrashman:onVehicleAction()
	self:stop(source.m_TrashmanOwner)
	source.m_TrashmanOwner.vehTrashM = nil
	return
end

function JobTrashman:stop(player)
	if client and isElement(client) then player = client end

	self.m_VehicleSpawner1:toggleForPlayer(player, false)
	self.m_VehicleSpawner2:toggleForPlayer(player, false)
	self.m_VehicleSpawner3:toggleForPlayer(player, false)
	self:destroyJobVehicle(player)

end

function JobTrashman:checkRequirements(player)
	if not (player:getJobLevel() >= JOB_LEVEL_TRASHMAN) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel %d", player, JOB_LEVEL_TRASHMAN), 255, 0, 0)
		return false
	end
	return true
end

function JobTrashman:Event_stop()
	self:stop(source)
end


function JobTrashman:Event_trashcanCollect(containerNum)
	if not containerNum then return end
	if containerNum > 2 or containerNum < 1 then
		-- Possible cheat attempt | Todo: Add to anticheat
		return
	end
	if client.vehicle and client.vehicle:getModel() == 408 then
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
	else
		client:sendError(_("Du musst im Müll-Fahrzeug sitzen!", client), 255, 0, 0)
	end
end

function JobTrashman:dumpCans(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension and hitElement:getJob() == self then
		if hitElement.vehicle and hitElement.vehicle:getModel() == 408 then
			local numCans = hitElement:getData("Trashman:Cans")

			if numCans and numCans > 0 then
				local moneyAmount = numCans * MONEY_PER_CAN
				local duration = getRealTime().timestamp - hitElement.m_LastJobAction
				hitElement.m_LastJobAction = getRealTime().timestamp
				StatisticsLogger:getSingleton():addJobLog(hitElement, "jobTrashman", duration, moneyAmount)
				hitElement:addBankMoney(moneyAmount, "Müll-Job")
				hitElement:givePoints(math.floor(math.ceil(numCans/3)*JOB_EXTRA_POINT_FACTOR))

				hitElement:setData("Trashman:Cans", 0)
				hitElement:triggerEvent("trashcanReset")
				QuestionBox:new(hitElement, hitElement, _("Möchtest du weiter arbeiten?", hitElement), "JobTrashmanAgain", "JobTrashmanStop", hitElement)

			else
				hitElement:sendInfo(_("Du hast keinen Müll aufgeladen!", hitElement, moneyAmount))
			end
		else
			hitElement:sendError(_("Du musst im Müll-Fahrzeug sitzen!", hitElement), 255, 0, 0)
		end
	end
end
