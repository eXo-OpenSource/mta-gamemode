FactoryGUI = inherit(GUIForm)
inherit(Singleton, FactoryGUI)

function FactoryGUI:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 15) 	-- width of the window
	self.m_Height = grid("y", 10) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2+400, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Window title", true, true, self)
	self.m_ItemsGrid = GUIGridGridList:new(1, 1, 6, 9, self.m_Window)
	self.m_ItemName = GUIGridLabel:new(7, 0.5, 4, 2, "schneller Motor", self.m_Window):setHeader()
	self.m_ItemName = GUIGridLabel:new(7, 1.2, 4, 2, "Benötigte Zeit: 5h", self.m_Window)
	self.m_Header = GUIGridLabel:new(7, 2.7, 4, 2, "Benötigte Items:", self.m_Window):setHeader("sub")
	self.m_Items = {}
	self.m_Items[1] = GUIGridRectangle:new(7, 4, 4, 2, Color.Orange, self.m_Window)
	self.m_Items[2] = GUIGridRectangle:new(11, 4, 4, 2, Color.Orange, self.m_Window)
	self.m_Items[3] = GUIGridRectangle:new(7, 6, 4, 2, Color.Orange, self.m_Window)
	self.m_Items[4] = GUIGridRectangle:new(11, 6, 4, 2, Color.Orange, self.m_Window)
	self.m_Items[5] = GUIGridRectangle:new(7, 8, 4, 2, Color.Orange, self.m_Window)
	self.m_Items[6] = GUIGridRectangle:new(11, 8, 4, 2, Color.Orange, self.m_Window)
end

function FactoryGUI:destructor()
	GUIForm.destructor(self)
end
