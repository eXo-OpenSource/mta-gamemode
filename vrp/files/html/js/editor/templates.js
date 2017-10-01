var templates = {
//constructor
newClass: `Classname = inherit(GUIForm)
inherit(Singleton, Classname)

function Classname:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 20) 	-- width of the window
	self.m_Height = grid("y", 14) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Window title", true, true, self)
\t
end

function Classname:destructor()
	GUIForm.destructor(self)
end
`,
//gridlist
gridlist: `self.m_Grid = GUIGridList:new(0, 0, 0, 0, self)
	self.m_Grid:addColumn(_"Column1", 1)
`,
//shortElements
window: 'self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "WindowTitle", true, true, self)\n\t',
label: 'GUILabel:new(0, 0, 0, 0, "LabelText", true, true, self)\n\t',
button: 'GUIButton:new(0, 0, 0, 0, "ButtonText", true, true, self)\n\t',
};
