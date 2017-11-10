-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplayer/Ware/minigames/WareDraw.lua
-- *  PURPOSE:     WareDraw
-- *
-- ****************************************************************************
WareDraw = inherit(Singleton)

addRemoteEvents{"setWareDrawListenerOn","setWareDrawListenerOff"}
function WareDraw:constructor()
	addEventHandler("setWareDrawListenerOn", localPlayer, bind(self.Event_ListenerOn,self))
	addEventHandler("setWareDrawListenerOff", localPlayer, bind(self.Event_ListenerOff,self))
end

function WareDraw:Event_ListenerOn(amount)
	self.m_Form = WareDrawGUI:new(amount)
end

function WareDraw:Event_ListenerOff()
	if self.m_Form then delete(self.m_Form) end
end

WareDrawGUI = inherit(GUIForm)
inherit(Singleton, WareDrawForm)

function WareDrawGUI:constructor(amount)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 21)
	self.m_Height = grid("y", 12)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/3-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Male in %d verschiedenen Farben!", amount), true, true, self)

	self.m_DrawColors = {}

	self.m_Skribble = GUIGridSkribble:new(1, 1, 20, 10, self.m_Window)
	self.m_Skribble:setDrawingEnabled(true)
	self.m_Skribble:setDrawSize(50)
	self.m_Skribble:addDrawHook(function(data)
		if not table.find(self.m_DrawColors, data.color) then
			table.insert(self.m_DrawColors, data.color)
			if #self.m_DrawColors >= amount then
				triggerServerEvent("Ware:onDrawColor", localPlayer, self.m_DrawColors)
			end
		end
	end)

	local predefinedColors = {"Black", "Brown", "Red", "Orange", "Yellow", "Green", "LightBlue", "Blue", "Purple"}
	for i, color in pairs(predefinedColors) do
		local colorButton = GUIGridRectangle:new(i, 11, 1, 1, Color[color], self.m_Window)
		colorButton.onLeftClick =
			function()
				self.m_Skribble:setDrawColor(Color[color])
			end

		GUIGridEmptyRectangle:new(i, 11, 1, 1, 1, Color.Black, self.m_Window)
	end
end

function WareDrawGUI:destructor()
	GUIForm.destructor(self)
end
