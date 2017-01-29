-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/KartGUI.lua
-- *  PURPOSE:     KartGUI class
-- *
-- ****************************************************************************
KartGUI = inherit(GUIForm)
inherit(Singleton, KartGUI)

addRemoteEvents{"showKartGUI", "KartReceiveToptimes"}

function KartGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-540/2, screenHeight/2-230, 540, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Kart", true, true, self)
	self.m_TabPanel = GUITabPanel:new(0, 40, self.m_Width, self.m_Height-50, self)

	local tabTimeRace = self.m_TabPanel:addTab(_("Zeitrennen"))
	local tabToptimes = self.m_TabPanel:addTab(_("Toptimes"))

	local buttonStart = GUIButton:new(self.m_Width*0.1, self.m_Height*0.1, self.m_Width*0.4, self.m_Height*0.1, _"GO GO GO", tabTimeRace):setBackgroundColor(Color.Red)
	buttonStart.onLeftClick = function() triggerServerEvent("startKartTimeRace", localPlayer) end

	self.m_GridList = GUIGridList:new(10, 10, self.m_Width-20, self.m_Height-30, tabToptimes)
	self.m_GridList:addColumn("Rank", .1)
	self.m_GridList:addColumn("Zeit", .4)
	self.m_GridList:addColumn("Spieler", .5)

	self.m_fnReceiveToptimes = bind(KartGUI.receiveToptimes, self)
	addEventHandler("KartReceiveToptimes", root, self.m_fnReceiveToptimes)

	triggerServerEvent("requestKartToptimes", localPlayer)
end

function KartGUI:virtual_destructor()
	removeEventHandler("KartReceiveToptimes", root, self.m_fnReceiveToptimes)
end

function KartGUI:receiveToptimes(mapname, toptimes)
	self.m_Window:setTitleBarText(mapname)
	self.m_GridList:clear()

	for k, v in ipairs(toptimes) do
		self.m_GridList:addItem(("%d."):format(k), timeMsToTimeText(v.time), v.name)
	end
end

addEventHandler("showKartGUI", root,
	function()
		KartGUI:new()
	end
)
