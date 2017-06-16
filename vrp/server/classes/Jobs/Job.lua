-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/Job.lua
-- *  PURPOSE:     Abstract job class
-- *
-- ****************************************************************************
Job = inherit(Singleton)
function Job:constructor()
	self.m_DontEndOnVehicleDestroy = false
	self.m_OnJobVehicleDestroyBind = bind(self.onJobVehicleDestroy, self)

end

function Job:getId()
	return self.m_Id
end

function Job:setId(Id)
	self.m_Id = Id
end

function Job:requireVehicle(player)
	return player:getJob() == self
end

function Job:registerJobVehicle(player, vehicle, countdown, stopJobOnDestroy)
	if isElement(player.jobVehicle) then
		destroyElement(player.jobVehicle)
	end
	player.jobVehicle = vehicle
	vehicle.jobPlayer = player

	addEventHandler("onVehicleStartEnter",vehicle, function(vehPlayer, seat)
		if seat==0 and vehPlayer ~= player then
			vehPlayer:sendError("Du kannst nicht in dieses Job-Fahrzeug!")
			cancelEvent()
		end
	end)

	if countdown then
		vehicle:addCountdownDestroy(10)
	end

	if stopJobOnDestroy then
		addEventHandler("onVehicleExplode", vehicle, self.m_OnJobVehicleDestroyBind)
		addEventHandler("onElementDestroy", vehicle, self.m_OnJobVehicleDestroyBind)
	end
end

function Job:onJobVehicleDestroy()
	for key, obj in pairs(source:getAttachedElements()) do
		if obj:getAttachedElements() then
			for key2, obj2 in pairs(obj:getAttachedElements()) do
				obj2:destroy()
			end
		end

		obj:destroy()
	end

	removeEventHandler("onElementDestroy", source, self.m_OnJobVehicleDestroyBind)
	removeEventHandler("onVehicleExplode", source, self.m_OnJobVehicleDestroyBind)
	local player = source.jobPlayer

	if not self.m_DontEndOnVehicleDestroy then
		nextframe( -- Workarround to avoid Stack Overflow
			function()
				if player and player.setJob then
					player:setJob(nil)
				end
			end
		)
	end
end

function Job:destroyJobVehicle(player)
	if player.jobVehicle and isElement(player.jobVehicle) then
		destroyElement(player.jobVehicle)
	end
end

function Job:sendMessage(message, ...)
	for k, player in pairs(getElementsByType("player")) do
		if player:getJob() == self then
			player:sendMessage(_("[JOB] ", player).._(message, player, ...), 0, 0, 255)
		end
	end
end

function Job:countPlayers()
	local count = 0
	for k, player in pairs(getElementsByType("player")) do
		if player:getJob() == self then
			count = count + 1
		end
	end

	return count
end

Job.start = pure_virtual

