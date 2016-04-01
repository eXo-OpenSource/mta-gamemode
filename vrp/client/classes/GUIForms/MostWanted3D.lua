
MostWanted = inherit(GUIForm3D)
inherit(Singleton, MostWanted)

function MostWanted:constructor()
	self.m_Normal = Vector3(1,0,0)

	GUIForm3D.constructor(self, Vector3(1553.8, -1654.5, 21.7), Vector3(0, 0, 90), Vector2(6, 4), Vector2(600,400), 100)
	self.m_Window = GUIWindow:new(0, 0, 600, 400, "Most Wanted", true, false, self)

	local button = GUIButton:new(20, 200, 500, 150, "A fancy button", self.m_Window)
	button.onClick = function() outputChatBox("Clicked 3D button") end
end
