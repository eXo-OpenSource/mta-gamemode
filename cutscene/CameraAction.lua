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

