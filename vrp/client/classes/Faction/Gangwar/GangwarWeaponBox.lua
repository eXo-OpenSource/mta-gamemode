-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarWeaponBox.lua
-- *  PURPOSE:     Gangwar Waffenbox
-- *
-- ****************************************************************************

WeaponBoxGUI = inherit(GUIForm)
inherit(Singleton, WeaponBoxGUI)
local width,height = screenWidth * 0.3 , screenHeight*0.4

function WeaponBoxGUI:constructor( pGangwarDisplay , pWeapons)
	GUIForm.constructor(self, screenWidth*0.5- ( width/2) , screenHeight*0.5 - (height*0.5), width, height, true, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Waffenbox", true, true, self)

	self.m_WeaponList = GUIGridList:new(5, 35, self.m_Width-10, self.m_Height-60, self)
	self.m_WeaponList:addColumn(_"Waffen", 1)
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, "?", self.m_Window):setAlignX("right")
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, _"Doppelklick zum Nehmen", self.m_Window):setFont(VRPFont(self.m_Height*0.04)):setAlignY("center"):setColor(Color.Red)

	self.m_Window:deleteOnClose( true )
	self.m_GangwarDisplay = pGangwarDisplay
	self.m_GangwarDisplay.m_isBoxActive = true
	self.m_Weapons = pWeapons
	local item
	for key, tbl in ipairs( self.m_Weapons ) do
		local weaponID, ammu = tbl[1], tbl[2]
		item = self.m_WeaponList:addItem(WEAPON_NAMES[weaponID] .." ("..ammu..")")
		item.Name = weaponID
		item.onLeftDoubleClick = function () self:selectWeapon(key ) end
	end
end

function WeaponBoxGUI:refreshItems( pWeapons )
	self.m_WeaponList:delete()
	self.m_Weapons = pWeapons
	self.m_WeaponList = GUIGridList:new(5, 35, self.m_Width-10, self.m_Height-60, self)
	self.m_WeaponList:addColumn(_"Waffen", 1)
	local item
	for key, tbl in ipairs( self.m_Weapons ) do
		local weaponID, ammu = tbl[1], tbl[2]
		item = self.m_WeaponList:addItem(WEAPON_NAMES[weaponID] .." ("..ammu..")")
		item.Name = weaponID
		item.onLeftDoubleClick = function () self:selectWeapon( key ) end
	end
end

function WeaponBoxGUI:onHide()
	self.m_GangwarDisplay.m_isBoxActive = false
	triggerServerEvent("ClientBox:onCloseWeaponBox", localPlayer, localPlayer)
end

function WeaponBoxGUI:selectWeapon( pID )
	triggerServerEvent("ClientBox:takeWeaponFromBox", localPlayer, pID)
end
