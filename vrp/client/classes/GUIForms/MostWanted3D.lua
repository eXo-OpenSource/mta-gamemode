
MostWanted = inherit(GUIForm3D)
inherit(Singleton, MostWanted)

function MostWanted:constructor()
	GUIForm3D.constructor(self, Vector3(1540.925, -1661.21, 15.28), Vector3(0, 0, 90), Vector2(3.74, 3.9), Vector2(600,650), 100)
end

function MostWanted:onStreamIn(surface)
	self.m_Window = GUIWindow:new(0, 0, 600, 400, "Most Wanted", true, false, surface)

	local button = GUIButton:new(20, 200, 500, 150, "A fancy button", self.m_Window)
	button.onClick = function() outputChatBox("Clicked 3D button") end
end
