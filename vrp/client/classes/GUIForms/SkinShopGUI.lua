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
	localPlayer:setFrozen(true)

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
		function(skinId)
			delete(self)
			SuccessBox:new(_"Skin erfolgreich übernommen!", 0, 255, 0)

			localPlayer.m_OldSkin = skinId
		end
	)

	-- Load skin info
	for skinId, info in pairs(SkinInfo) do
		local name, price = unpack(info)
		local item = self.m_SkinList:addItem(name, tostring(price).."$")

		-- Add doubleclick event
		item.onLeftDoubleClick = function()	triggerServerEvent("skinBuy", resourceRoot, skinId) end
		item.onLeftClick = function () localPlayer:setModel(skinId) end
	end
	localPlayer.m_OldSkin = localPlayer:getModel()

	showChat(false)
end

function SkinShopGUI:destructor()
	localPlayer:setFrozen(false)
	localPlayer:setModel(localPlayer.m_OldSkin)
	setCameraTarget(localPlayer, localPlayer)
	showChat(true)

	GUIForm.destructor(self)
end

function SkinShopGUI.initializeAll()
	--[[
	local marker = Marker.create(218.2, -98.5, 1004.3, "cylinder", 1.4, 255, 255, 0)
	marker:setInterior(15)

	addEventHandler("onClientMarkerHit", marker,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				localPlayer:setPosition(Vector3(217.922, -98.563, 1005.258))
				localPlayer:setRotation(Vector3(0.000, 0.000, 299))
				setCameraMatrix(216.056396484375, -99.181800842285156, 1006.8388061523437, 216.90571594238281, -98.900047302246094, 1006.3923950195312, 0, 70)

				SkinShopGUI:new()
			end
		end
	)
	--]]

	for i, v in pairs(SkinShops) do
		local marker = Marker.create(v.Marker, "cylinder", 1.4, 255, 255, 0)
		marker:setInterior(v.MarkerInt)

		addEventHandler("onClientMarkerHit", marker,
			function(hitElement, matchingDimension)
				if hitElement == localPlayer and matchingDimension then
					localPlayer:setPosition(v.PlayerPos)
					localPlayer:setRotation(v.PlayerRot)
					setCameraMatrix(unpack(v.CameraMatrix))

					SkinShopGUI:new()
				end
			end
		)
	end
end
