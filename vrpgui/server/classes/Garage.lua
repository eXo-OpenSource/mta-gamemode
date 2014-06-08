Garage = inherit(Object)

function Garage:constructor(px, py, pz, rx, ry, rz)
	-- Check whether the data are valid
	assert((type(px) == 'number'), 'Bad argument @ \'Garage.constructor\' [Expected number at argument 1, got '..type(px)..']')
	assert((type(py) == 'number'), 'Bad argument @ \'Garage.constructor\' [Expected number at argument 2, got '..type(py)..']')
	assert((type(pz) == 'number'), 'Bad argument @ \'Garage.constructor\' [Expected number at argument 3, got '..type(pz)..']')
	assert((type(rx) == 'number'), 'Bad argument @ \'Garage.constructor\' [Expected number at argument 4, got '..type(rx)..']')
	assert((type(ry) == 'number'), 'Bad argument @ \'Garage.constructor\' [Expected number at argument 5, got '..type(ry)..']')
	assert((type(rz) == 'number'), 'Bad argument @ \'Garage.constructor\' [Expected number at argument 6, got '..type(rz)..']')
	
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
	return ( self.m_State )
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