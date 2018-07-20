Townhall = inherit(Singleton)

function Townhall:constructor()
	self.m_Blip = Blip:new("Stadthalle.png", 1788.389, -1297.811,root, 600)
	self.m_Blip:setDisplayText("Stadthalle")
	self.m_Blip:setOptionalColor({7, 161, 213})
	local elevator = Elevator:new()
	elevator:addStation("Ausgang", Vector3(1788.389, -1297.811, 13.375))
	elevator:addStation("Stadthalle", Vector3(1786.800, -1301.099, 120.300), 120)
	self:createGarage()
	self.m_EnterExit = InteriorEnterExit:new(Vector3(1481.09, -1770.12, 18.80), Vector3(2758.5, -2422.8994140625, 816), 0, 0, 5)

	self.m_EnterExit:addEnterEvent(function( player ) player:triggerEvent("Townhall:applyTexture") end)
	self.m_EnterExit:addExitEvent(function( player ) player:triggerEvent("Townhall:removeTexture") end)
end

function Townhall:createGarage()
	VehicleTeleporter:new(Vector3(1403.63, -1503.30, 13.57), Vector3(2108.466796875, 959.41778564453, 3398.7609863281), 270, 180, 9, 0, "cylinder" , 5, Vector3(0,0,3))
	InteriorEnterExit:new(Vector3(1397.12, -1571.02, 14.27), Vector3(2118.47, 909.90, 3389.54), 180, 0, 9, 0)

	local col = createColCuboid(2069.40, 886.28, 3388.49, 2169.50-2086.40+20, 964.03-886.28, 12)
	col:setInterior(9)
	ParkGarageZone:new(col)
end

function Townhall:destructor()
	delete(self.m_EnterExit)
	delete(self.m_Blip)
end
