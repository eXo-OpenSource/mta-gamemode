Action.Vehicle = inherit(Object)

-- Create a vehicle
Action.Vehicle.create = inherit(Object)
Action.Vehicle.create.duration = false;
Action.Vehicle.create.constructor = function(self, data, scene)
	self.id = data.id
	self.model = data.model
	if data.pos then
		self.x, self.y, self.z = unpack(data.pos)
	end
	if data.rot then
		self.rx, self.ry, self.rz = unpack(data.rot)
	end
	
	self.cutscene = scene:getCutscene()
end

Action.Vehicle.create.trigger = function(self)
	self.cutscene.m_Elements[self.id] = createVehicle(
		self.model,
		self.x, self.y, self.z,
		self.rx, self.ry, self.rz)
		
	setElementDimension(self.cutscene.m_Elements[self.id], PRIVATE_DIMENSION_CLIENT)
end

-- Switch the engine
Action.Vehicle.setEngine = inherit(Object)
Action.Vehicle.setEngine.duration = false;
Action.Vehicle.setEngine.constructor = function(self, data, scene)
	self.id = data.id
	self.state = data.state
	self.cutscene = scene:getCutscene()
end

Action.Vehicle.setEngine.trigger = function(self)
	local veh = self.cutscene.m_Elements[self.id] 
	setVehicleEngineState(veh, self.state)
end