-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/RcVanExtension.lua
-- *  PURPOSE:     Vehicle rc van extension class
-- *
-- ****************************************************************************
RcVanExtension = inherit(Object) --gets inherited from vehicle to provide methods to vehicle object

RcVanExtensionLastUse = {}
RcVanExtensionLoadBatteryTimer = {}
RcVanExtensionBattery = {}

function RcVanExtension:initRcVanExtension()
	self.m_RcVehicle = {}
	self.m_RcVehicleRange = {}
	self.m_RcVehicleUser = {}
	self.m_RcVehicleBatteryTimer = {}
	self:setData("RcVehicleUser", self.m_RcVehicleUser, true)

	if not RcVanExtensionBattery[self:getId()] then
		RcVanExtensionBattery[self:getId()] = {}
	end
	if not RcVanExtensionLastUse[self:getId()] then
		RcVanExtensionLastUse[self:getId()] = {}
	end
	if not RcVanExtensionLoadBatteryTimer[self:getId()] then
		RcVanExtensionLoadBatteryTimer[self:getId()] = {}
	end

	for i, rc in pairs(self:getTunings().m_Tuning["RcVehicles"]) do
		if not RcVanExtensionBattery[self:getId()][rc] then
			RcVanExtensionBattery[self:getId()][rc] = 900
		else
			if RcVanExtensionBattery[self:getId()][rc] < 900 then
				if isTimer(RcVanExtensionLoadBatteryTimer[self:getId()][rc]) then
					killTimer(RcVanExtensionLoadBatteryTimer[self:getId()][rc])
				end
				RcVanExtensionLoadBatteryTimer[self:getId()][rc] = setTimer(function()
					if RcVanExtensionBattery[self:getId()][rc] < 900 then
						RcVanExtensionBattery[self:getId()][rc] = tonumber(RcVanExtensionBattery[self:getId()][rc]) + 5
					else
						RcVanExtensionBattery[self:getId()][rc] = 900
						killTimer(RcVanExtensionLoadBatteryTimer[self:getId()][rc])
					end
				end, 10000, 0)
			end
		end

		if not RcVanExtensionLastUse[self:getId()][rc] then
			RcVanExtensionLastUse[self:getId()][rc] = 0
		end
	end
end

function RcVanExtension:delRcVanExtension()
	for id, timer in pairs(RcVanExtensionLoadBatteryTimer[self:getId()]) do
		if isTimer(timer) then
			killTimer(timer) 
		end
	end
end

function RcVanExtension:toggleRC(player, rcVehicle, state, force, death)
	if isElement(rcVehicle) and rcVehicle.type == "vehicle" then rcVehicle = rcVehicle:getModel() end

	if state then
		if RcVanExtensionLastUse[self:getId()][rcVehicle] + RC_TOGGLE_COOLDOWN <= getRealTime().timestamp then
			self.m_RcVehicle[rcVehicle] = TemporaryVehicle.create(rcVehicle, self.position.x, self.position.y, self.position.z+1.5, self.rotation.z)
			self.m_RcVehicle[rcVehicle].isRcVehicle = true	
			self.m_RcVehicle[rcVehicle]:setPosition(self.matrix:transformPosition(Vector3(0, -4,0)))
			self.m_RcVehicle[rcVehicle]:setRotation(0, 0, self.matrix.rotation.z - 180)

			table.insert(self.m_RcVehicleUser, player)
			self:setData("RcVehicleUser", self.m_RcVehicleUser, true)
			player:setData("RcVehicle", self.m_RcVehicle[rcVehicle], true)
			player:setData("RCVan", self, true)
			player:setPublicSync("isInvisible", true)
			
			if isTimer(RcVanExtensionLoadBatteryTimer[self:getId()][rcVehicle]) then killTimer(RcVanExtensionLoadBatteryTimer[self:getId()][rcVehicle]) end
			player:triggerEvent("Countdown", RcVanExtensionBattery[self:getId()][rcVehicle] or 15*60, "Batterie")
			self.m_RcVehicleBatteryTimer[rcVehicle] = setTimer(bind(self.toggleRC, self), RcVanExtensionBattery[self:getId()][rcVehicle] and RcVanExtensionBattery[self:getId()][rcVehicle]*1000 or 15*60*1000, 1, player, rcVehicle, false, true)
			
			self.m_RcVehicleRange[rcVehicle] = createColSphere(0, 0, 0, 500)
			self.m_RcVehicleRange[rcVehicle]:attach(self)
			self.m_RcVehicleRange[rcVehicle].rcVehicle = self.m_RcVehicle[rcVehicle]

			player.m_RcVanSeat = player.vehicleSeat
			player:setAlpha(0)
			player:removeFromVehicle()
			player:warpIntoVehicle(self.m_RcVehicle[rcVehicle])
			player:buckleSeatBelt(self.m_RcVehicle[rcVehicle])
			player:triggerEvent("disableDamage", true)
			player:setCameraTarget() -- without, the camera target will still be the rc van, if the player minimize the window

			self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleDamage = bind(self.Event_rveVehicleDamage, self)
			self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleExplode = bind(self.Event_rveVehicleExplode, self)
			self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleStartEnter = bind(self.Event_rveVehicleStartEnter, self)
			self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleStartEnterVan = bind(self.Event_rveVehicleStartEnterVan, self)
			self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleStartExit = bind(self.Event_rveVehicleStartExit, self)
			self.m_RcVehicle[rcVehicle].m_RcVanExtensionColShapeHit = bind(self.Event_rveColShapeHit, self)
			self.m_RcVehicle[rcVehicle].m_RcVanExtensionColShapeLeave = bind(self.Event_rveColShapeLeave, self)
			addEventHandler("onVehicleExplode", self, self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleExplode)
			addEventHandler("onVehicleExplode", self.m_RcVehicle[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleExplode)
			addEventHandler("onVehicleDamage", self.m_RcVehicle[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleDamage)
			addEventHandler("onVehicleStartEnter", self.m_RcVehicle[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleStartEnter)
			addEventHandler("onVehicleStartEnter", self, self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleStartEnterVan)
			addEventHandler("onVehicleStartExit", self.m_RcVehicle[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleStartExit)
			addEventHandler("onVehicleExit", self.m_RcVehicle[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleStartExit)
			addEventHandler("onColShapeHit", self.m_RcVehicleRange[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionColShapeHit)
			addEventHandler("onColShapeLeave", self.m_RcVehicleRange[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionColShapeLeave)

		else
			player:sendError(_("Du kannst das RC Fahrzeug noch nicht wieder nutzen.", player))
		end
	else
		if force then
			RcVanExtensionLastUse[self:getId()][rcVehicle] = getRealTime().timestamp
			player:sendWarning(_("Dein RC Fahrzeug ist zerstört.", player))
		else
			RcVanExtensionLastUse[self:getId()][rcVehicle] = getRealTime().timestamp - RC_TOGGLE_COOLDOWN
		end

		removeEventHandler("onVehicleExplode", self, self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleExplode)
		removeEventHandler("onVehicleExplode", self.m_RcVehicle[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleExplode)
		removeEventHandler("onVehicleDamage", self.m_RcVehicle[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleDamage)
		removeEventHandler("onVehicleStartEnter", self.m_RcVehicle[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleStartEnter)
		removeEventHandler("onVehicleStartEnter", self, self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleStartEnter)
		removeEventHandler("onVehicleStartExit", self.m_RcVehicle[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleStartExit)
		removeEventHandler("onVehicleExit", self.m_RcVehicle[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionVehicleStartExit)
		removeEventHandler("onColShapeHit", self.m_RcVehicleRange[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionColShapeHit)
		removeEventHandler("onColShapeLeave", self.m_RcVehicleRange[rcVehicle], self.m_RcVehicle[rcVehicle].m_RcVanExtensionColShapeLeave)
		
		if not death then -- to prevent that the setted alpha from ExecutionPed will be changed
			player:setAlpha(255)
		end

		player:removeFromVehicle()
		player:warpIntoVehicle(self, player.m_RcVanSeat)
		player:triggerEvent("disableDamage", false)
		self.m_RcVehicle[rcVehicle]:destroy()
		self.m_RcVehicle[rcVehicle] = nil
		self.m_RcVehicleRange[rcVehicle]:destroy()
		self.m_RcVehicleRange[rcVehicle] = nil

		table.removevalue(self.m_RcVehicleUser, player)
		self:setData("RcVehicleUser", self.m_RcVehicleUser, true)
		player:setData("RcVehicle", nil, true)
		player:setData("RCVan", nil, true)
		player:setPublicSync("isInvisible", false)

		RcVanExtensionBattery[self:getId()][rcVehicle] = self.m_RcVehicleBatteryTimer[rcVehicle]:getDetails()/1000 
		if isTimer(self.m_RcVehicleBatteryTimer[rcVehicle]) then killTimer(self.m_RcVehicleBatteryTimer[rcVehicle]) end
		if isTimer(player.m_rveOutOfRangeTimer) then killTimer(player.m_rveOutOfRangeTimer) end
		player:triggerEvent("CountdownStop", "Batterie")
		player:triggerEvent("CountdownStop", "Connection lost")
		player:triggerEvent("RVE:withinRange")

		RcVanExtensionLoadBatteryTimer[self:getId()][rcVehicle] = setTimer(function()
			if RcVanExtensionBattery[self:getId()][rcVehicle] < 900 then
				RcVanExtensionBattery[self:getId()][rcVehicle] = tonumber(RcVanExtensionBattery[self:getId()][rcVehicle]) + 5
			else
				RcVanExtensionBattery[self:getId()][rcVehicle] = 900
				killTimer(RcVanExtensionLoadBatteryTimer[self:getId()][rcVehicle])
			end
		end, 10000, 0)
	end
end

function RcVanExtension:Event_rveVehicleDamage(loss)
	if source:getHealth() <= 260 and not source:isBlown() then
		self:toggleRC(source:getOccupant(), source:getModel(), false, true)
	end
end

function RcVanExtension:Event_rveColShapeHit(hitElement)
	if hitElement and hitElement.vehicle and source.rcVehicle == hitElement.vehicle then
		hitElement:triggerEvent("CountdownStop", "Connection lost")
		hitElement:triggerEvent("RVE:withinRange")
		if isTimer(hitElement.m_rveOutOfRangeTimer) then killTimer(hitElement.m_rveOutOfRangeTimer) end
	end
end

function RcVanExtension:Event_rveColShapeLeave(leaveElement)
	if leaveElement and leaveElement.vehicle and source.rcVehicle == leaveElement.vehicle then
		leaveElement:triggerEvent("RVE:outOfRange")
		leaveElement:triggerEvent("Countdown", 15, "Connection lost")
		leaveElement.m_rveOutOfRangeTimer = setTimer(function()
			self:toggleRC(leaveElement, leaveElement:getData("RcVehicle"), false, true)
			leaveElement:triggerEvent("RVE:withinRange")
		end, 15000, 1)
	end
end

function RcVanExtension:Event_rveVehicleStartEnter()
	cancelEvent()
end

function RcVanExtension:Event_rveVehicleStartEnterVan(player, seat)
	for i, rcPlayer in pairs(source.m_RcVehicleUser) do
		if seat == rcPlayer.m_RcVanSeat then
			cancelEvent()
			break
		end
	end
end

function RcVanExtension:Event_rveVehicleStartExit(player)
	self:toggleRC(player, player:getData("RcVehicle"), false, true)
end

function RcVanExtension:Event_rveVehicleExplode()
	if source == self then
		for i, player in pairs(self.m_RcVehicleUser) do
			self:toggleRC(player, player:getData("RcVehicle"), false, true)
		end
	elseif source == self.m_RcVehicle[source:getModel()] then
		local player = source:getOccupant()
		self:toggleRC(player, player:getData("RcVehicle"), false, true)
	end
end