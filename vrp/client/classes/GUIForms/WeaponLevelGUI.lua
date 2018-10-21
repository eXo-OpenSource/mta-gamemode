-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/WeaponLevelGUI.lua
-- *  PURPOSE:     WeaponLevelGUI class
-- *
-- ****************************************************************************
WeaponLevelGUI = inherit(GUIForm)
inherit(Singleton, WeaponLevelGUI)

addRemoteEvents{"openWeaponLevelGUI"}

function WeaponLevelGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(310/2), 300, 310)

	local currentLevel = localPlayer:getWeaponLevel()
	local nextLevel = currentLevel+1

	GUIWindow:new(0, 0, 300, 500, _"Waffenlevel", true, true, self)
	GUILabel:new(10, 40, 280, 20, _"Hier kannst du dein Waffenlevel verbessern.\nEin besseres Waffenlevel wird benötigt um bessere Waffen zu kaufen und bessere Waffenskills zu erhalten!",self):setMultiline(true)
	GUILabel:new(10, 125, 280, 25, _"Aktuelles Level:", self)
	self.m_ProgressBar = GUIProgressBar:new(10, 150, 280, 20, self)
	self.m_ProgressBar:setProgress(currentLevel*10)
	self.m_ProgressBar:setForegroundColor(tocolor(50,200,255))
	self.m_ProgressBar:setBackgroundColor(tocolor(180,240,255))
	GUILabel:new(10, 150, 280, 20, _("%d/10", currentLevel), self):setAlignX("center"):setColor(Color.Black)
	if nextLevel <= 10 then
		GUILabel:new(10, 185, 280, 25, _("Nächstes Level:", nextLevel), self)
		GUILabel:new(10, 210, 280, 20, _("Kosten: %d$", WEAPON_LEVEL[nextLevel]["costs"]), self)
		GUILabel:new(10, 230, 280, 20, _("Benötigte Spielstunden: %d", WEAPON_LEVEL[nextLevel]["hours"]), self)
		self.m_TrainButton = GUIButton:new(10, 260, 280, 30, "Trainieren", self):setBackgroundColor(Color.Accent)
		self.m_TrainButton.onLeftClick = function()
			triggerServerEvent("startWeaponLevelTraining", localPlayer)
			delete(self)
		end
	else
		GUILabel:new(10, 285, 280, 25, _"Du hast das maximale Waffenlevel bereits erreicht!", self):setMultiline(true)
	end

end

addEventHandler("openWeaponLevelGUI", root, function()
	WeaponLevelGUI:new()
end)
