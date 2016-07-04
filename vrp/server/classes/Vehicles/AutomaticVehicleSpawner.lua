-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/´Vehicles/AutomaticVehicleSpawner.lua
-- *  PURPOSE:     AutomaticVehicleSpawner class
-- *
-- ****************************************************************************
AutomaticVehicleSpawner = inherit(Object)
AutomaticVehicleSpawner.sPulse = TimedPulse:new(6000)

function AutomaticVehicleSpawner:constructor(model, x, y, z, rx, ry, rz, createfunc, forjob, checkRequirements)
	self.m_Model = model
	self.m_X, self.m_Y, self.m_Z = x,y,z
	self.m_RX, self.m_RY, self.m_RZ = rx,ry,rz
	self.m_Createfunc = createfunc
	self.m_LastVehicle = false
	self.m_ForJob = forjob
	self.m_OnEnter = checkRequirements

	local w, h = 3.5, 8

	if rz < 0 then rz = -rz end
	if rz > 45 and rz < 135 or rz > 225 and rz < 315 then
		local a, b = w, h
		h, w = a, b
	end

	self.m_ColShape = createColCuboid(x-w/2, y-h/2, z-1, w, h, 4)

	AutomaticVehicleSpawner.sPulse:registerHandler(bind(AutomaticVehicleSpawner.maybeSpawnVehicle, self))
	self.m_VehicleEnterHandler = bind(AutomaticVehicleSpawner.VehicleEnterHandler, self)
end

function AutomaticVehicleSpawner:destructor()
	AutomaticVehicleSpawner.sPulse:removeHandler(bind(AutomaticVehicleSpawner.maybeSpawnVehicle, self))
end

function AutomaticVehicleSpawner:maybeSpawnVehicle()
	if self.m_LastVehicle then
		return
	end

	if #getElementsWithinColShape(self.m_ColShape, "vehicle") ~= 0 then
		-- ToDo: maybe respawn vehicles in the colshape if unoccupied?
		return
	end

	self.m_LastVehicle = TemporaryVehicle.create(self.m_Model, self.m_X, self.m_Y, self.m_Z, self.m_RZ)
	setElementFrozen(self.m_LastVehicle, true)
	setVehicleDamageProof(self.m_LastVehicle, true)

	addEventHandler("onVehicleStartEnter", self.m_LastVehicle, self.m_VehicleEnterHandler)

	if self.m_Createfunc then
		self.m_Createfunc(self.m_LastVehicle, self)
	end
end

function AutomaticVehicleSpawner:VehicleEnterHandler(player)
	-- Cancel if the player does not have the correct job
	
	if self.m_ForJob and player:getJob() ~= self.m_ForJob then
		player:sendWarning(_("Du kannst dieses Fahrzeug nicht fahren!", player))
		cancelEvent()
		return
	end
	if self.m_OnEnter and type(self.m_OnEnter) == "function" then
		if self.m_OnEnter(player, vehicle) == false then
			cancelEvent()
			return
		end
	end

	local vehicle = source
	setElementFrozen(vehicle, false)
	setVehicleDamageProof(vehicle, false)
	self.m_LastVehicle = false

	-- Do we require to remove it?
	--removeEventHandler("onVehicleStartEnter", vehicle, self.m_VehicleEnterHandler)
end
