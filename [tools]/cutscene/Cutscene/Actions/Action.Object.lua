Action.Object = inherit(Object)

-- Create Object
Action.Object.create = inherit(Object)
Action.Object.create.duration = false
Action.Object.create.constructor = function (self, data, scene)
	self.id = data.id
	self.model = data.model
	if data.pos then
		self.x, self.y, self.z = unpack(data.pos)
	end
	self.rotation = data.rot or 0
	self.cutscene = scene:getCutscene()
end

Action.Object.create.trigger = function (self)
	self.cutscene.m_Elements[self.id] = createObject(
		 self.model,
		 self.x, self.y, self.z,
		 0, 0, self.rotation,
		 false
	)

	setElementDimension(self.cutscene.m_Elements[self.id], PRIVATE_DIMENSION_CLIENT)
end
