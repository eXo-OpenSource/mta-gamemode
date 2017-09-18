-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HouseEditGUI.lua
-- *  PURPOSE:     House Admin Edit GUI class
-- *
-- ****************************************************************************
HouseEditGUI = inherit(GUIForm)
inherit(Singleton, HouseEditGUI)

addRemoteEvents{"getAdminHouseData"}

function HouseEditGUI:constructor()
	GUIForm.constructor(self, screenWidth/2+(screenWidth*0.2/2)+10, screenHeight/2-(370/2), screenWidth*0.15, 120)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Haus editieren", true, true, self)
	self.m_Window:deleteOnClose( true )

	--HOUSE_INTERIOR_TABLE
	self.m_Interior =     GUILabel:new(10, 40, self.m_Width-20, 30, _"Aktueller Interior: ", self.m_Window)
	self.m_ChangeInt = GUIButton:new(10, 70, self.m_Width-20, 35, _"Interior ändern", self)
	self.m_ChangeInt:setFont(VRPFont(28)):setFontSize(1)
	self.m_ChangeInt.onLeftClick = function()
		self:hide()
		HouseGUI:getSingleton():hide()
		HouseInteriorChanger:new(self.m_CurrentInterior)
	end

	triggerServerEvent("houseAdminRequestData", root)
	addEventHandler("getAdminHouseData", root, bind(self.getHouseData, self))
end

function HouseEditGUI:getHouseData(interior)
	self.m_CurrentInterior = interior
	self.m_Interior:setText(_("Aktueller Interior: %d", interior))
end


HouseInteriorChanger = inherit(GUIForm)
inherit(Singleton, HouseInteriorChanger)

function HouseInteriorChanger:constructor(current)
	GUIForm.constructor(self, screenWidth/2-(screenWidth*0.2/2)+10, screenHeight-screenHeight*0.2, screenWidth*0.2, 100, false)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Interior Changer", true, true, self)
	self.m_Window:deleteOnClose( true )

	self.m_Changer = GUIChanger:new(10, 50, self.m_Width/2-15, 30, self)
	self.m_Changer.onChange = function(text, index)
		self:setInterior(tonumber(text))
	end
	for interiorId, key in ipairs(HOUSE_INTERIOR_TABLE) do
		self.m_Changer:addItem(tostring(interiorId))
	end

	self.m_Save = GUIButton:new(self.m_Width/2+10, 50, self.m_Width/2-15, 30,  _"setzen", self)
	self.m_Save.onLeftClick = function()
		local selected = self.m_Changer:getSelectedItem()
		if selected and tonumber(selected) and tonumber(selected) > 0 then
			triggerServerEvent("houseAdminChangeInterior", root, tonumber(selected))
		else
			ErrorBox:new("Internal Error! Wrong ID")
		end
	end

	self.m_OldPosition = {localPlayer:getInterior(), localPlayer:getDimension(), localPlayer:getPosition()}

	self.m_Changer:setSelectedItem(tostring(current))
	self:setInterior(current)
end

function HouseInteriorChanger:setInterior(id)
	local int, x, y, z = unpack(HOUSE_INTERIOR_TABLE[id])
	localPlayer:setInterior(int)
	localPlayer:setPosition(x, y, z)
end

function HouseInteriorChanger:destructor()
	local int, dim, pos = unpack(self.m_OldPosition)
	localPlayer:setInterior(int)
	localPlayer:setDimension(dim)
	localPlayer:setPosition(pos)

	HouseGUI:getSingleton():show()
	HouseEditGUI:getSingleton():show()
	GUIForm.destructor(self)
end
