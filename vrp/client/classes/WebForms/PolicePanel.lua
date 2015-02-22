-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebForms/PolicePanel.lua
-- *  PURPOSE:     PolicePanel form class
-- *
-- ****************************************************************************
PolicePanel = inherit(VRPWebWindow)
inherit(Singleton, PolicePanel)

function PolicePanel:constructor()
	local size = Vector2(screenWidth*0.6, screenHeight*0.6)
	VRPWebWindow.constructor(self, screenSize/2-size/2, size, "files/html/PolicePanel/PolicePanel.html", false)
	self:setTitle(_"Polizeicomputer")
	
end