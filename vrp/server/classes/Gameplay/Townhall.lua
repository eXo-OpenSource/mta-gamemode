Townhall = inherit(Singleton)

function Townhall:constructor()
	self.m_Blip = Blip:new("Stadthalle.png", 1788.389, -1297.811,root, 600)
	self.m_EnterExit = InteriorEnterExit:new(Vector3(1788.389, -1297.811, 13.375), Vector3(1786.800, -1301.099, 120.300), -360, 360, 0, 0, false)
end

function Townhall:destructor()
	delete(self.m_EnterExit)
	delete(self.m_Blip)
end
