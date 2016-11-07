
Sun = {}

function Sun:constructor(parent)
	self.parent = parent
	self.player = getLocalPlayer()
		
	self.x = 0
	self.y = 0
	self.z = 0
	self.rx = 0
	self.ry = 0
	self.rz = 0
	self.height = 100
	
	self.rzOffset = 0
	self.heightCurrentOffset = 0
	self.heightMinOffset = 100
	self.heightMaxOffset = 250
	self.heightOffsetDirection = "up"

	self.m_Update = function() self:update() end
	addEventHandler("onClientRender", root, self.m_Update)
	
end

function Sun:update()
	self.px, self.py, self.pz = getElementPosition(self.player)
	self.x, self.y, self.z = getAttachedPosition(self.px, self.py, self.pz, self.rx, self.ry, self.rz + self.rzOffset, 1500, 0, self.height + self.heightCurrentOffset)

end

function Sun:getSunPosition()
	return self.x, self.y, self.z
end

function Sun:destructor()	
	removeEventHandler("onClientRender", root, self.m_Update)

end