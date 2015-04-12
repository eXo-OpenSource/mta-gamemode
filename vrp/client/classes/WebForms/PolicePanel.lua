-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebForms/PolicePanel.lua
-- *  PURPOSE:     PolicePanel form class
-- *
-- ****************************************************************************
PolicePanel = inherit(GUIWebForm)
inherit(Singleton, PolicePanel)
addEvent("policePanelListRetrieve", true)

function PolicePanel:constructor()
	local width, height = screenWidth*0.6, screenHeight*0.6
	GUIWebForm.constructor(self, screenWidth/2-width/2, screenHeight/2-height/2, width, height)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Polizeicomputer", true, true, self)
	self.m_WebView = GUIWebView:new(0, 30, self.m_Width, self.m_Height-30, "files/html/PolicePanel/PolicePanel.html", false, self.m_Window)

	self.m_ListRetrieveFunc = bind(self.setCrimes, self)
	addEventHandler("policePanelListRetrieve", root, self.m_ListRetrieveFunc)
end

function PolicePanel:destructor()
	removeEventHandler("policePanelListRetrieve", root, self.m_ListRetrieveFunc)

	GUIWebForm.destructor(self)
end

function PolicePanel:setCrimes(crimeInfo)
	--[[

		Expected crimeInfo layout (pseudo Lua code):
		crimeInfo = {{player = "Player1", wanted = 5, crimes = {"Injury", "Saying hello"}}, {player = "Player2", wanted = 3, crimes = {"Saying goodbye"}}}

	]]

	-- Replace crime IDs by descriptions
	for k, info in pairs(crimeInfo) do
		for j, crimeId in pairs(info.crimes) do
			crimeInfo[k].crimes[j] = tostring((getCrimeById(crimeId) or {}).text)
		end
	end

	-- Pass data to CEF
	return self.m_WebView:callEvent("setCrimes", crimeInfo)
end

function PolicePanel:onDocumentReady(url)
	triggerServerEvent("policePanelListRequest", resourceRoot)
end
