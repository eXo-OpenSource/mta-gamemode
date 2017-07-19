Townhall = inherit(Singleton)

function Townhall:constructor()
	self.m_Blip = Blip:new("Stadthalle.png", 1788.389, -1297.811,root, 600)
	self.m_Blip:setDisplayText("Stadthalle")
	self.m_Blip:setOptionalColor({63,81,181})
	local elevator = Elevator:new()
	elevator:addStation("Ausgang", Vector3(1788.389, -1297.811, 13.375))
	elevator:addStation("Stadthalle", Vector3(1786.800, -1301.099, 120.300), 120)
end

function Townhall:destructor()
	delete(self.m_EnterExit)
	delete(self.m_Blip)
end
