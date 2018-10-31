QuestGUI = inherit(GUIForm)
inherit(Singleton, QuestGUI)

function QuestGUI:constructor(Id, Name, Description, Packages)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 25)
	self.m_Height = grid("y", 10)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Weihnachts-Quests", true, true, self)
	self.m_Window:deleteOnClose(true)

	self.m_NameLabel = GUIGridLabel:new(1, 7, 24, 1, _("Heutiger Quest: %d. Dezember - %s", Id, Name), self.m_Window)
	self.m_Description = GUIGridLabel:new(1, 8, 24, 1, _("Beschreibung: %s", Description), self.m_Window)
	self.m_Packages = GUIGridLabel:new(1, 9, 24, 1, _("Belohnung: %s Päckchen", Packages), self.m_Window)

	self.m_StartQuest = GUIGridButton:new(21, 8, 4, 1, "Quest starten", self.m_Window)
	self.m_StartQuest.onLeftClick = function()
		triggerServerEvent("questStartClick", localPlayer)
		delete(self)
	end

	self.m_Current = Id

	self.m_Day = {}
	for i=1, 24 do
		self:addDay(i)
	end



end

function QuestGUI:addDay(i)
	local x, y, img, statusColor, statusText, click
	if i > 12 then
		y = 4
		x = -1-12*2
	else
		x = -1
		y = 1
	end

	if self.m_Current == i then
		img = "files/images/Events/Christmas/Quest.png"
		statusColor = Color.Green
		statusText = "aktiv"
	elseif self.m_Current > i then
		img = "files/images/Events/Christmas/QuestGray.png"
		statusColor = Color.Red
		statusText = "abgelaufen"
	elseif self.m_Current < i then
		img = "files/images/Events/Christmas/QuestGray.png"
		statusColor = Color.Accent
		statusText = "demnächst"
	end
	self.m_Day[i] = GUIGridImage:new(x+(i*2), y, 2, 3, img, self.m_Window)
	GUIGridLabel:new(0.77, 0, 2, 2, tostring(i), self.m_Day[i]):setFont(VRPFont(40)):setAlignX("center"):setColor(Color.Black)

	GUIGridRectangle:new(0.77, 2.3, 2, 0.7, statusColor, self.m_Day[i])
	GUIGridLabel:new(0.77, 2.3, 2, 0.7, statusText, self.m_Day[i]):setAlignX("center"):setColor(Color.Black):setFont(VRPFont(16))

end
