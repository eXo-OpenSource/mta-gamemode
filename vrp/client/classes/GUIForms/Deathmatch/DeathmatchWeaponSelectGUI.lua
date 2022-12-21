-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DeathmatchWeaponSelectGUI.lua
-- *  PURPOSE:     Deathmatch Weapon Select GUI
-- *
-- ****************************************************************************
DeathmatchWeaponSelectGUI = inherit(GUIForm)
inherit(Singleton, DeathmatchWeaponSelectGUI)

addRemoteEvents{"DeathmatchWeaponSelectGUI:open", "DeathmatchWeaponSelectGUI:close", "DeathmatchWeaponSelectGUI:forceClose"}
function DeathmatchWeaponSelectGUI:constructor(weapons, lastWeapons, rangeElement)
	GUIWindow.updateGrid()			
	self.m_Width = grid("x", 11)
	self.m_Height = grid("y", 12)
	
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, rangeElement)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Waffenauswahl", true, false, self)
	
	self.m_InfoLabel= GUIGridLabel:new(1, 1, 10 , 1, _"INFO: Solltest du nichts auswählen, werden dir zufällige Waffen gegeben", self.m_Window):setColor(Color.Red)

	self.m_Grid = GUIGridGridList:new(1, 2, 10, 9, self.m_Window)
	self.m_Grid:addColumn(_"Waffe", 0.6)
	self.m_Grid:addColumn(_"Ausgewählt", 0.4)
	
	self.m_SubmitButton = GUIGridButton:new(1, 11, 10, 1, _"Auswahl bestätigen", self.m_Window)
	self.m_SubmitButton.onLeftClick = function()
		triggerServerEvent("deathmatchSendPlayerSelectedWeapons", localPlayer, self.m_SelectedWeapons)
		delete(self) 
	end

	self.m_SelectedWeapons = lastWeapons or {}
	for __, weaponId in pairs(weapons) do
		local item = self.m_Grid:addItem(WEAPON_NAMES[tonumber(weaponId)], "")
		item:setColumnText(2, table.find(lastWeapons, weaponId) and "✘" or "")
		
		item.onLeftDoubleClick = function()
			if not table.find(self.m_SelectedWeapons, weaponId) then
				table.insert(self.m_SelectedWeapons, weaponId)
			else
				table.removevalue(self.m_SelectedWeapons, weaponId)
			end 
			item:setColumnText(2, table.find(self.m_SelectedWeapons, weaponId) and "✘" or "")
		end
	end
end

addEventHandler("DeathmatchWeaponSelectGUI:open", localPlayer, function(weapons, lastWeapons, rangeElement)
	if DeathmatchWeaponSelectGUI:isInstantiated() then delete(DeathmatchWeaponSelectGUI:getSingleton()) end
	DeathmatchWeaponSelectGUI:new(weapons, lastWeapons, rangeElement)
end)

addEventHandler("DeathmatchWeaponSelectGUI:forceClose", localPlayer, function()
	if DeathmatchWeaponSelectGUI:isInstantiated() then delete(DeathmatchWeaponSelectGUI:getSingleton()) end
end)

addEventHandler("DeathmatchWeaponSelectGUI:close", localPlayer, function()
	if DeathmatchWeaponSelectGUI:isInstantiated() then
		triggerServerEvent("deathmatchSendPlayerSelectedWeapons", localPlayer, DeathmatchWeaponSelectGUI:getSingleton().m_SelectedWeapons)
		delete(DeathmatchWeaponSelectGUI:getSingleton()) 
	end
end)