Action.Camera = inherit(Object)

-- Set the camera's position
Action.Camera.set = inherit(Object)
Action.Camera.set.duration = false;
Action.Camera.set.constructor = function(self, data)
	if data.pos then
		self.x, self.y, self.z = unpack(data.pos)
	end
	
	if data.lookat then
		self.lx, self.ly, self.lz = unpack(data.lookat) 
	end
	
	if data.r then self.r = data.r end
	if data.fov then self.fov = data.fov end
end

Action.Camera.set.trigger = function(self)
	updateCameraMatrix(self.x, self.y, self.z, 
						self.lx, self.ly, self.lz,
						self.r, self.fov)
end

-- Move the camera smoothly
Action.Camera.move = inherit(Object)
Action.Camera.move.constructor = function(self, data)
	if data.pos 		then self.x, self.y, self.z = unpack(data.pos) end
	if data.targetpos 	then self.tx, self.ty, self.tz = unpack(data.targetpos) end
	
	if data.lookat then self.lx, self.ly, self.lz = unpack(data.lookat) end
	if data.targetlookat then self.tlx, self.tly, self.tlz = unpack(data.targetlookat) end
	
end

Action.Camera.move.start = function(self)
	self.m_Begin = getTickCount()
	local x,y,z,lx,ly,lz,r,f = getCameraMatrix()
	self.x = self.x or x
	self.y = self.y or y
	self.z = self.z or z
	self.lx = self.lx or lx
	self.ly = self.ly or ly
	self.lz = self.lz or lz
	self.r = self.r or r
	self.fov = self.fov or f
end

Action.Camera.move.preRender = function(self)
	local progress = (getTickCount() - self.m_Begin) / self.duration
	
	local x, y, z, lx, ly, lz, r, fov = getCameraMatrix()
	if self.tx then
		x, y, z = interpolateBetween(self.x, self.y, self.z,
										self.tx, self.ty, self.tz, 
										progress, "Linear")
	else
		x, y, z = self.x, self.y, self.z
	end
	
	if self.tlx then
		lx, ly, lz =  interpolateBetween(self.lx, self.ly, self.lz,
										self.tlx, self.tly, self.tlz, 
										progress, "Linear")
	end
	
	r, fov = interpolateBetween(self.r, self.fov, 0,
								self.tr or r, self.tfov or fov, 0,
								progress, "Linear")
	
	setCameraMatrix(x, y, z, lx, ly, lz, r, fov)
end
