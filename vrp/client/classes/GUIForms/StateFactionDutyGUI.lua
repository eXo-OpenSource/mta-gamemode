-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StateFactionDutyGUI.lua
-- *  PURPOSE:     House GUI class
-- *
-- ****************************************************************************
StateFactionDutyGUI = inherit(GUIForm)
inherit(Singleton, StateFactionDutyGUI)

addRemoteEvents{"showStateFactionDutyGUI"}

function StateFactionDutyGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(150/2), 300, 300)
	self.m_Window = GUIWindow:new(0,0,300,500,_"Duty-Menü",true,true,self)

	self.m_Duty = GUIButton:new(30, 50, self.m_Width-60, 35,_"In den Dienst gehen", self)
	self.m_Duty:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Duty.onLeftClick = bind(self.factionToggleDuty,self)

	self.m_Rearm = GUIButton:new(30, 95, self.m_Width-60, 35,_"Neu ausrüsten", self)
	self.m_Rearm:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Rearm.onLeftClick = bind(self.factionRearm,self)

	self.m_Swat = GUIButton:new(30, 140, self.m_Width-60, 35,_"Zum Swat-Modus wechseln", self)
	self.m_Swat:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_Swat.onLeftClick = bind(self.factionSwat,self)

	self.m_SkinChange = GUIButton:new(30, 185, self.m_Width-60, 35,_"Skin wechseln", self)
	self.m_SkinChange:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_SkinChange.onLeftClick = bind(self.factionChangeSkin,self)

	self.m_Close = GUIButton:new(30, 235, self.m_Width-60, 35,_"Schließen", self)
	self.m_Close:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
	self.m_Close.onLeftClick = function () self:hide() end
	
	--self:refresh()
end

function StateFactionDutyGUI:refresh()
	self.m_Rearm:setEnabled(false)
	self.m_Swat:setEnabled(false)
	self.m_SkinChange:setEnabled(false)
	
	if getLocalPlayer():getPublicSync("Faction:Duty") == true then
		self.m_Rearm:setEnabled(true)
		self.m_Swat:setEnabled(true)
		self.m_SkinChange:setEnabled(true)
	end

end

addEventHandler("showStateFactionDutyGUI", root,
		function()
			StateFactionDutyGUI:new()
		end
	)
	

function StateFactionDutyGUI:hide()
	GUIForm.destructor(self)
end

function StateFactionDutyGUI:factionToggleDuty()
	triggerServerEvent("playerToggleFactionDuty", getLocalPlayer())
end

function StateFactionDutyGUI:factionRearm()
	triggerServerEvent("factionRearm", getLocalPlayer())
end

function StateFactionDutyGUI:factionSwat()
	triggerServerEvent("factionSwat", getLocalPlayer())
end

function StateFactionDutyGUI:factionChangeSkin()
	triggerServerEvent("factionChangeSkin", getLocalPlayer())
end