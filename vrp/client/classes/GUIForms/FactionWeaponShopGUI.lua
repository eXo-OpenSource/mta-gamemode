-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionWeaponShopGUI.lua
-- *  PURPOSE:     Faction Weapon Shop GUI class
-- *
-- ****************************************************************************
FactionWeaponShopGUI = inherit(GUIForm)
inherit(Singleton, FactionWeaponShopGUI)

function FactionWeaponShopGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-400, screenHeight/2-230, 800, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fraktions Waffenshop", true, true, self)
	
	--addRemoteEvents{"depotRetrieveInfo"}
	--addEventHandler("depotRetrieveInfo", root, bind(self.Event_depotRetrieveInfo, self))
end

function FactionWeaponShopGUI:destuctor()	
	--removeEventHandler("depotRetrieveInfo", root, bind(self.Event_depotRetrieveInfo, self))
end
