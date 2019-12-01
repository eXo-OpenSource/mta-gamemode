AdventCalenderGUI = inherit(GUIForm)
inherit(Singleton, AdventCalenderGUI)

function AdventCalenderGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 25)
	self.m_Height = grid("y", 10)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Adventskalender", true, true, self)
	self.m_Window:deleteOnClose(true)

	self.m_NameLabel = GUIGridLabel:new(1, 7, 24, 1, _("Heutiges Türchen: %d. Dezember", getRealTime().monthday), self.m_Window)
	self.m_Packages = GUIGridLabel:new(1, 8, 24, 1, _("Belohnung: 5 Päckchen"), self.m_Window)

	self.m_StartQuest = GUIGridButton:new(21, 8, 4, 1, "Türchen Öffnen", self.m_Window)
	self.m_StartQuest.onLeftClick = function()
		triggerServerEvent("Christmas:openDoor", localPlayer)
		delete(self)
	end

	self.m_Day = {}
	for i=1, 24 do
		self:addDay(i)
	end



end

function AdventCalenderGUI:addDay(i)
	local x, y, img, statusColor, statusText, click
	if i > 12 then
		y = 4
		x = -1-12*2
	else
		x = -1
		y = 1
	end

	if getRealTime().monthday == i then
		img = "files/images/Events/Christmas/Door.png"
		statusColor = Color.Green
		statusText = "aktiv"
	elseif getRealTime().monthday > i then
		img = "files/images/Events/Christmas/DoorGray.png"
		statusColor = Color.Red
		statusText = "abgelaufen"
	elseif getRealTime().monthday < i then
		img = "files/images/Events/Christmas/DoorGray.png"
		statusColor = Color.Accent
		statusText = "demnächst"
	end
	self.m_Day[i] = GUIGridImage:new(x+(i*2), y, 2, 3, img, self.m_Window)
	GUIGridLabel:new(0.77, 0, 2, 2, tostring(i), self.m_Day[i]):setFont(VRPFont(40)):setAlignX("center"):setColor(Color.Black)

	GUIGridRectangle:new(0.77, 2.3, 2, 0.7, statusColor, self.m_Day[i])
	GUIGridLabel:new(0.77, 2.3, 2, 0.7, statusText, self.m_Day[i]):setAlignX("center"):setColor(Color.Black):setFont(VRPFont(16))

end
