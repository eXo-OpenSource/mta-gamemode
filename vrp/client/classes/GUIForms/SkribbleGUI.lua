-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
SkribbleGUI = inherit(GUIForm)
inherit(Singleton, SkribbleGUI)

function SkribbleGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 25)
	self.m_Height = grid("y", 15)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Skribble", true, true, self)

	self.m_Grid = GUIGridGridList:new(1, 1, 5, 14, self.m_Window)
	self.m_Grid:addColumn(_"Spieler", .6)
	self.m_Grid:addColumn(_"Punkte", .4)

	self.m_Grid:addItem("PewX", 1337)
	self.m_Grid:addItem("MasterM", 50)
	self.m_Grid:addItem("[eXo]Stumpy", 42)
	self.m_Grid:addItem("[eXo]xXKing", 0)

	--GUIGridRectangle:new(6, 1, 19, 13, Color.White, self.m_Window)
	self.m_Skribble = Skribble:new(Vector2(grid("d", 19), grid("d", 13)))
	self.m_SkribbleImage = GUIGridImage:new(6, 1, 19, 13, self.m_Skribble.m_RenderTarget, self.m_Window)

	for index, color in pairs({"Black", "Grey", "LightGrey", "White", "Red", "Orange", "Blue", "DarkBlue", "Brown", "Green", "LightRed", "Yellow"}) do
		local button = GUIGridRectangle:new(6 + (index - 1), 14, 1, 1, Color[color], self.m_Window)
		button.onLeftClick = function() Skribble:getSingleton().m_DrawColor = Color[color] end
	end
end

function SkribbleGUI:virtual_destructor()
	delete(self.m_Skribble)
	--GUIForm.destructor(self)
end

