Action.Ped = inherit(Object)

-- Create Ped
Action.Ped.create = inherit(Object)
Action.Ped.create.duration = false;
Action.Ped.create.constructor = function(self, data, scene)
	self.id = data.id
	self.model = data.model
	if data.pos then
		self.x, self.y, self.z = unpack(data.pos)
	end
	self.rotation = data.rot or 0
	self.cutscene = scene:getCutscene()
end

Action.Ped.create.trigger = function(self)
	self.cutscene.m_Elements[self.id] = createPed(
		self.model,
		self.x, self.y, self.z,
		self.rotation)

	self.cutscene.m_Elements[self.id]:setDimension(self.cutscene.m_Dimension)
	self.cutscene.m_Elements[self.id]:setInterior(self.cutscene:getInterior())
end

-- Warp ped into vehicle
Action.Ped.warpIntoVehicle = inherit(Object)
Action.Ped.warpIntoVehicle.duration = false;
Action.Ped.warpIntoVehicle.constructor = function(self, data, scene)
	self.id = data.id
	self.vehicle = data.vehicle
	self.cutscene = scene:getCutscene()
end

Action.Ped.warpIntoVehicle.trigger = function(self)
	local ped = self.cutscene.m_Elements[self.id]
	local vehicle = self.cutscene.m_Elements[self.vehicle]
	warpPedIntoVehicle(ped, vehicle)
end

-- setControlState
Action.Ped.setControlState = inherit(Object)
Action.Ped.setControlState.duration = false;
Action.Ped.setControlState.constructor = function(self, data, scene)
	self.id = data.id
	self.control = data.control
	self.state = data.state
	self.cutscene = scene:getCutscene()
end

Action.Ped.setControlState.trigger = function(self)
	local ped = self.cutscene.m_Elements[self.id]
	setPedControlState(ped, self.control, self.state)
end

Action.Ped.setAnimation = inherit(Object)
Action.Ped.setAnimation.constructor = function(self, data, scene)
	self.id = data.id
	self.animBlock = data.animBlock
	self.anim = data.anim
	self.duration = data.duration
	self.looped = data.looped or false
	self.cutscene = scene:getCutscene()
end
Action.Ped.setAnimation.destructor = function(self)
	local ped = self.cutscene.m_Elements[self.id]
	if ped then
		setPedAnimation(ped, nil, nil)
	end
end
Action.Ped.setAnimation.trigger = function(self)
	local ped = self.cutscene.m_Elements[self.id]
	setPedAnimation(ped, self.animBlock, self.anim, self.duration, self.looped)
end
