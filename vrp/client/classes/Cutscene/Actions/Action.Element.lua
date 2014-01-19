Action.Element = inherit(Object)

-- Attach
Action.Element.attach = inherit(Object)
Action.Element.attach.duration = false;
Action.Element.attach.constructor = function(self, data, scene)
	self.id = data.id
	self.other = data.other
	if data.pos then
		self.x, self.y, self.z = unpack(data.pos)
	end
	if data.rot then
		self.rx, self.ry, self.rz = unpack(data.rot)
	end
	self.cutscene = scene:getCutscene()
end

Action.Element.attach.trigger = function(self)
	local e1 = self.cutscene.m_Elements[self.id]
	local e2 = self.cutscene.m_Elements[self.other]
	attachElements(e1, e2, self.x or 0, self.y or 0, self.z or 0, self.rx or 0, self.ry or 0, self.rz or 0)
end

-- Destroy
Action.Element.destroy = inherit(Object)
Action.Element.destroy.duration = false;
Action.Element.destroy.constructor = function(self, data, scene)
	self.id = data.id
	self.cutscene = scene:getCutscene()
end

Action.Element.destroy.trigger = function(self)
	local e1 = self.cutscene.m_Elements[self.id]
	destroyElement(e1)
	self.cutscene.m_Elements[self.id] = nil
end

-- Set Position
Action.Element.position = inherit(Object)
Action.Element.position.duration = false;
Action.Element.position.constructor = function(self, data, scene)
	self.id = data.id
	if data.pos then
		self.x, self.y, self.z = unpack(data.pos)
	end
	if data.rot then
		self.rx, self.ry, self.rz = unpack(data.rot)
	end
	self.cutscene = scene:getCutscene()
end

Action.Element.position.trigger = function(self)
	local e1 = self.cutscene.m_Elements[self.id]
	if self.x then
		setElementPosition(e1, self.x, self.y, self.z)
	end
	if self.rx then
		setElementRotation(e1, self.rx, self.ry, self.rz)
	end
end
