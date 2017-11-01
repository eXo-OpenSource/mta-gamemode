-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AchievementGUI.lua
-- *  PURPOSE:     Achievement GUI class
-- *
-- ****************************************************************************

AchievementGUI = inherit(GUIForm)
inherit(Singleton, AchievementGUI)

function AchievementGUI:constructor(money)
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Achievements", true, true, self)
	self.m_Window:addBackButton(function () delete(self) SelfGUI:getSingleton():show() end)
	
	self.m_GridList = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.07, self.m_Width*0.39, self.m_Height*0.8, self)
	self.m_GridList:addColumn(_"Name", 0.6)
	self.m_GridList:addColumn(_"Erhalten", 0.4)


	GUILabel:new(self.m_Width*0.45, self.m_Height*0.07, self.m_Width*0.55, self.m_Height*0.08, _"Achievements", self.m_Window)
	GUILabel:new(self.m_Width*0.45, self.m_Height*0.15, self.m_Width*0.55, self.m_Height*0.05, _"Auf eXo-Reallife gibt es viele Achievements mit verschiedenen Belohnungen, die gefunden bzw. erledigt werden können. Einige davon sind vesteckt und tauchen erst in der Liste auf wenn du diese findest!", self.m_Window):setMultiline(true)
	self.m_SelectedTitle = GUILabel:new(self.m_Width*0.45, self.m_Height*0.45, self.m_Width*0.50, self.m_Height*0.07, " ", self.m_Window)
	self.m_SelectedDescription = GUILabel:new(self.m_Width*0.45, self.m_Height*0.53, self.m_Width*0.50, self.m_Height*0.05, " ", self.m_Window):setMultiline(true)
	self.m_SelectedGoten = GUILabel:new(self.m_Width*0.45, self.m_Height*0.82, self.m_Width*0.50, self.m_Height*0.05, " ", self.m_Window):setMultiline(true)

end

function AchievementGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
	self.m_PlayerAchievements = localPlayer:getAchievements()
	self:loadGridList()
end

function AchievementGUI:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end

function AchievementGUI:loadGridList()
	self.m_GridList:clear()
	self.m_GridList:addItemNoClick(_"Sichtbare  Ach.", "")
	local get, item
	for id, data in pairs(Achievement:getSingleton():getAchievements()) do
		if data["hidden"] == 0 then
			get = self.m_PlayerAchievements[id] and "Ja" or "Nein"
			item = self.m_GridList:addItem(string.short(utf8.escape(data["name"]), 15), get)
			item.onLeftClick = function() self:onAchievementClick(id) end
		end
	end
	self.m_GridList:addItemNoClick(_"Versteckte Ach.", "")
	for id, data in pairs(Achievement:getSingleton():getAchievements()) do
		if data["hidden"] == 1 then
			if self.m_PlayerAchievements[id] then
				item = self.m_GridList:addItem(string.short(utf8.escape(data["name"]), 15), "Ja")
				item.onLeftClick = function() self:onAchievementClick(id) end
			else
				item = self.m_GridList:addItem("???", "Nein")
				item.onLeftClick = function() self:onAchievementClick(id) end
			end
		end
	end
end

function AchievementGUI:onAchievementClick(id)
	local data = Achievement:getSingleton():getAchievements()[id]
	if self.m_PlayerAchievements[id] or data["hidden"] == 0 then
		self.m_SelectedTitle:setText(utf8.escape(data["name"]))
		self.m_SelectedDescription:setText(utf8.escape(data["desc"]))
		if self.m_PlayerAchievements[id] then
			self.m_SelectedGoten:setText(_"Erhalten: Ja"):setColor(Color.Green)
		else
			self.m_SelectedGoten:setText(_"Erhalten: Nein"):setColor(Color.Red)
		end
	else
		self.m_SelectedTitle:setText(_"Verstecktes Achievement")
		self.m_SelectedDescription:setText(_"Dieses Achievement wird dir erst angezeigt wenn du es findest bzw. erfüllst!")
		self.m_SelectedGoten:setText(_"Erhalten: Nein"):setColor(Color.Red)
	end
end
