Garage = inherit(Object)

function Garage:constructor(px, py, pz, rx, ry, rz)
	-- Calculation of the coordinates
	local gx = px+4.3*math.cos(math.rad(rz+90))
	local gy = py+4.3*math.sin(math.rad(rz+90))
	
	self.m_State = false
	self.m_Positions = {garage = {px, py, pz}, gate = {gx, gy, pz-0.4}}
	self.m_Rotations = {garage = {rx, ry, rz}, gate = {rx, ry, rz+90}}
	self.m_Garage = createObject(17950, px, py, pz, rx, ry, rz)
	self.m_Gate = createObject(17951, gx, gy, pz-0.4, rx, ry, rz+90)
	setObjectScale(self.m_Gate, 1.02)
	
end

function Garage:destructor()
	destroyElement( self.m_Garage )
	destroyElement( self.m_Gate )
end

function Garage:isOpen()
	return self.m_State
end

function Garage:setOpen(state)
	if state == self.m_State then
		return false
	end
	
	local x, y, z = unpack(self.m_Positions.gate)
	local rz = self.m_Rotations.gate[3]
	self.m_State = state
		
	if not state then
		moveObject(self.m_Gate, 2500, x, y, z, 0, 90, 0)
	else
		local x = x - 1 * math.cos(math.rad(rz))
		local y = y - 1 * math.sin(math.rad(rz))
		moveObject(self.m_Gate, 2500, x, y, z+1.8, 0, -90, 0)
	end
end