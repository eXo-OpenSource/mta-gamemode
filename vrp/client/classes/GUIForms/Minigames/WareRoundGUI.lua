-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/WareRoundGUI.lua
-- *  PURPOSE:     GUI at the end of Ware-Round
-- *
-- ****************************************************************************
WareRoundGUI = inherit(GUIForm)
inherit(Singleton, WareRoundGUI)

WareRoundGUI.Current = false

function WareRoundGUI:constructor(winner, loser, modeDesc)
	GUIForm.constructor(self, screenWidth-410, screenHeight-460, 400, 450, false)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _(modeDesc or "Rundenende"), true, false, self)

	self.m_WinnerGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.46, self.m_Height*0.8, self.m_Window)
	self.m_WinnerGrid:setFont(VRPFont(20))
	self.m_WinnerGrid:setItemHeight(20)
	self.m_WinnerGrid:addColumn(_"Gewinner", 1)

	self.m_LoserGrid = GUIGridList:new(self.m_Width*0.52, self.m_Height*0.1, self.m_Width*0.46, self.m_Height*0.8, self.m_Window)
	self.m_LoserGrid:setFont(VRPFont(20))
	self.m_LoserGrid:setItemHeight(20)
	self.m_LoserGrid:addColumn(_"Verlierer", 1)

	self.m_LeaveButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.9, self.m_Width*0.96, self.m_Height*0.08, _"Lobby verlassen", self.m_Window)
	self.m_LeaveButton.onLeftClick = bind(self.leaveLobby, self)

	self:refresh(winner, loser)
end

function WareRoundGUI:leaveLobby()
	triggerServerEvent("Ware:tryLeaveLobby", localPlayer)
end

function WareRoundGUI:refresh(winner, loser)
	if winner then
		for index, value in ipairs(winner) do
			local item = self.m_WinnerGrid:addItem(getPlayerName(value))
			item:setFont(VRPFont(20))
		end
	end
	if loser then
		for index, value in ipairs(loser) do
			local item = self.m_LoserGrid:addItem(getPlayerName(value))
			item:setFont(VRPFont(20))
		end
	end
end
