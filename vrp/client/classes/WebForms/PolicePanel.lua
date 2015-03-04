-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebForms/PolicePanel.lua
-- *  PURPOSE:     PolicePanel form class
-- *
-- ****************************************************************************
PolicePanel = inherit(VRPWebWindow)
inherit(Singleton, PolicePanel)
addEvent("policePanelListRetrieve", true)

function PolicePanel:constructor()
	local size = Vector2(screenWidth*0.6, screenHeight*0.6)
	VRPWebWindow.constructor(self, screenSize/2-size/2, size, "files/html/PolicePanel/PolicePanel.html", false)
	self:setTitle(_"Polizeicomputer")

	self.m_ListRetrieveFunc = bind(self.setCrimes, self)
	addEventHandler("policePanelListRetrieve", root, self.m_ListRetrieveFunc)
end

function PolicePanel:destructor()
	removeEventHandler("policePanelListRetrieve", root, self.m_ListRetrieveFunc)

	VRPWebWindow.destructor(self)
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
	return self:callEvent("setCrimes", crimeInfo)
end

function PolicePanel:onDocumentReady(url)
	triggerServerEvent("policePanelListRequest", resourceRoot)
end
