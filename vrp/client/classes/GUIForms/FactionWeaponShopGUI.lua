-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionWeaponShopGUI.lua
-- *  PURPOSE:     Faction Weapon Shop GUI class
-- *
-- ****************************************************************************
FactionWeaponShopGUI = inherit(GUIForm)
inherit(Singleton, FactionWeaponShopGUI)

addRemoteEvents{"showFactionWeaponShopGUI","updateFactionWeaponShopGUI"}

function FactionWeaponShopGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-225, screenHeight/2-230, 450, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fraktions Waffenshop", true, true, self)
	
	self.m_WeaponsImage = {}
	self.m_WeaponsName = {}
	self.m_WeaponsMenge = {}
	self.m_WeaponsMunition = {}
	self.m_WeaponsBuyGun = {}
	self.m_WeaponsBuyMunition = {}
	self.m_WaffenAnzahl = 0
	self.m_WaffenRow = 0
	self.m_WaffenColumn = 0
	
	self:factionReceiveWeaponShopInfos()
	
	--addRemoteEvents{"depotRetrieveInfo"}
	--addEventHandler("depotRetrieveInfo", root, bind(self.Event_depotRetrieveInfo, self))
	addEventHandler("updateFactionWeaponShopGUI", root, bind(self.Event_updateFactionWeaponShopGUI, self))

end

function FactionWeaponShopGUI:Event_updateFactionWeaponShopGUI(validWeapons,depotWeapons)
	for k,v in pairs(validWeapons) do
			if v == true then
				self:addWeaponToGUI(k,depotWeapons[k]["Waffe"],depotWeapons[k]["Munition"])
			end
	end
end

function FactionWeaponShopGUI:addWeaponToGUI(weaponID,Waffen,Munition)
	self.m_WeaponsName[weaponID] = GUILabel:new(25+self.m_WaffenRow*150, 35+self.m_WaffenColumn*200, 100, 25, getWeaponNameFromID(weaponID), self.m_Window)
	self.m_WeaponsName[weaponID]:setAlignX("center")
	self.m_WeaponsImage[weaponID] = GUIImage:new(45+self.m_WaffenRow*150, 70+self.m_WaffenColumn*200, 60, 60, WeaponIcons[weaponID], self.m_Window)
	self.m_WeaponsMenge[weaponID] = GUILabel:new(25+self.m_WaffenRow*150, 135+self.m_WaffenColumn*200, 100, 20, "Waffenlager: "..Waffen, self.m_Window)
	self.m_WeaponsMenge[weaponID]:setAlignX("center")
	self.m_WeaponsMunition[weaponID] = GUILabel:new(25+self.m_WaffenRow*150, 150+self.m_WaffenColumn*200, 100, 20, "Magazine: "..Munition, self.m_Window)
	self.m_WeaponsMunition[weaponID]:setAlignX("center")
	self.m_WeaponsBuyGun[weaponID] = GUIButton:new(25+self.m_WaffenRow*150, 170+self.m_WaffenColumn*200, 100, 20,"Waffe kaufen", self)
	self.m_WeaponsBuyGun[weaponID]:setBackgroundColor(Color.Red):setFontSize(1)
	self.m_WeaponsBuyMunition[weaponID] = GUIButton:new(25+self.m_WaffenRow*150, 195+self.m_WaffenColumn*200, 100, 20,"Munition kaufen", self)
	self.m_WeaponsBuyMunition[weaponID]:setBackgroundColor(Color.Blue):setFontSize(1)
	
	self.m_WaffenAnzahl = self.m_WaffenAnzahl+1
	
	if self.m_WaffenAnzahl == 3 or self.m_WaffenAnzahl == 6 then
		self.m_WaffenRow = 0
		self.m_WaffenColumn = self.m_WaffenColumn+1
	else
		self.m_WaffenRow = self.m_WaffenRow+1
	end
end

function FactionWeaponShopGUI:factionReceiveWeaponShopInfos()
		triggerServerEvent("factionReceiveWeaponShopInfos",localPlayer)
end

function FactionWeaponShopGUI:destuctor()	
	--removeEventHandler("depotRetrieveInfo", root, bind(self.Event_depotRetrieveInfo, self))
end

addEventHandler("showFactionWeaponShopGUI", root,
		function(col)
			FactionWeaponShopGUI:new()
		end
	)