-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StateFactionNoteGUI.lua
-- *  PURPOSE:     PA/GWD Note GUI
-- *
-- ****************************************************************************
StateFactionNoteGUI = inherit(GUIForm)
inherit(Singleton, StateFactionNoteGUI)

function StateFactionNoteGUI:constructor(target)
	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(150/2), 300, 200)
	self.m_Target = target
	self.m_Window = GUIWindow:new(0,0,300,300,_"GWD-Note vergeben",true,true,self)
	GUILabel:new(30, 45, self.m_Width-60, 30, _("Spieler: %s", target:getName()), self):setColor(Color.LightBlue)
	GUILabel:new(30, 85, 100, 30, _"Note:", self)
	self.m_Note = GUIEdit:new(125, 85, 100, 30, self)
	self.m_Note:setNumeric(true, true)
	GUILabel:new(30, 115, self.m_Width-60, 20, _"(Zwischen 1 und 100 erlaubt)", self)

	self.m_Set = GUIButton:new(30, 145, self.m_Width-60, 35,_"Note vergeben", self)
	self.m_Set:setBackgroundColor(Color.LightBlue):setFont(VRPFont(28)):setFontSize(1)
	self.m_Set.onLeftClick = bind(self.setNote,self)
end

function StateFactionNoteGUI:setNote()
	if tonumber(self.m_Note:getText()) and tonumber(self.m_Note:getText()) <= 100 and tonumber(self.m_Note:getText()) > 0 then
		local note = tonumber(self.m_Note:getText())
		QuestionBox:new(
				_("Möchtest du dem Spieler %s eine GWD-Note von %d vergeben?", self.m_Target:getName(), note),
				function ()
					triggerServerEvent("factionStateGivePANote", root, self.m_Target, note)
				end)
	else
		ErrorBox:new(_"Ungültige GWD-Note!")
	end
end
