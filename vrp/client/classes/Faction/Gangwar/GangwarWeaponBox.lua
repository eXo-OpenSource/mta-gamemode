-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarWeaponBox.lua
-- *  PURPOSE:     Gangwar Waffenbox
-- *
-- ****************************************************************************

WeaponBoxGUI = inherit(GUIForm)
inherit(Object, WeaponBoxGUI)
local width,height = screenWidth * 0.3 , screenHeight*0.4

function WeaponBoxGUI:constructor()
	GUIForm.constructor(self, screenWidth*0.5- ( width/2) , screenHeight*0.5 - (height*0.5), width, height, true, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Waffenbox", true, true, self)

	self.m_AnimationList = GUIGridList:new(5, 35, self.m_Width-10, self.m_Height-60, self)
	self.m_AnimationList:addColumn(_"Waffen", 1)
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, "?", self.m_Window):setAlignX("right")
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, _"Doppelklick zum nehmen", self.m_Window):setFont(VRPFont(self.m_Height*0.04)):setAlignY("center"):setColor(Color.Red)

	self.m_Window:setCloseOnClose( true )
end
