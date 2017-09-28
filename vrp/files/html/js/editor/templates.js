var templates = {
//constructor
constructor: `NewGUI = inherit(GUIForm)
inherit(Singleton, NewGUI)

function NewGUI:constructor()
	GUIForm.constructor(self, screenWidth*0.5-(500/2), screenHeight*0.5-(500/2), 500, 500, true, true)
\t
end
`,
//destructor
destructor: `function NewGUI:destructor()
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
