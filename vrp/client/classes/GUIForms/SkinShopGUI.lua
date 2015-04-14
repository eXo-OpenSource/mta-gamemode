-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SkinShopGUI.lua
-- *  PURPOSE:     SkinShopGUI class
-- *
-- ****************************************************************************
SkinShopGUI = inherit(GUIForm)
inherit(Singleton, SkinShopGUI)

function SkinShopGUI:constructor()
	GUIForm.constructor(self, 10, 10, screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight/2)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Vehicle shop", false, true, self)
	self.m_SkinList = GUIGridList:new(0, self.m_Height*0.22, self.m_Width, self.m_Height*0.72, self.m_Window)
	self.m_SkinList:addColumn(_"Name", 0.75)
	self.m_SkinList:addColumn(_"Preis", 0.25)
	self.m_ShopImage = GUIImage:new(0, 30, self.m_Width, self.m_Height/7, "files/images/Shops/ClothesHeader.png", self.m_Window)
	GUILabel:new(0, self.m_Height-self.m_Height/14, self.m_Width, self.m_Height/14, "↕", self.m_Window):setAlignX("center")
	GUILabel:new(6, self.m_Height-self.m_Height/14, self.m_Width*0.5, self.m_Height/14, _"Doppelklick zum Kaufen", self.m_Window):setFont(VRPFont(self.m_Height*0.045)):setAlignY("center"):setColor(Color.Red)
	
	addEvent("skinBought", true)
	addEventHandler("skinBought", root, 
		function()
			delete(self)
			SuccessBox:new(_"Skin erfolgreich übernommen!", 0, 255, 0)
		end
	)
	
	-- Load skin info
	for skinId, info in pairs(SkinInfo) do
		local name, price = unpack(info)
		local item = self.m_SkinList:addItem(name, tostring(price).."$")
		
		-- Add doubleclick event
		item.onLeftDoubleClick = function()	triggerServerEvent("skinBuy", resourceRoot, skinId) end
	end
	
	showChat(false)
end

function SkinShopGUI:destructor()
	showChat(true)
	
	GUIForm.destructor(self)
end

function SkinShopGUI.initialise()
	local marker = Marker.create(218.2, -98.5, 1004.3, "cylinder", 1.4, 255, 255, 0)
	marker:setInterior(15)
	
	addEventHandler("onClientMarkerHit", marker,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				SkinShopGUI:new()
			end
		end
	)
end
