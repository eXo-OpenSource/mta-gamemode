
MostWanted = inherit(GUIForm3D)
inherit(Singleton, MostWanted)

function MostWanted:constructor()
	GUIForm3D.constructor(self, Vector3(1536.01, -1650.98, 13.55), 270, Vector3(20, 20, 5), Vector2(600,400), 5)
	self.m_Window = GUIWindow:new(0, 0, 500, 500, "Most Wanted", true, false, self)

end
