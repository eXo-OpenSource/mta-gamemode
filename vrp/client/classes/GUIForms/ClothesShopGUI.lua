-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ClothesShopGUI.lua
-- *  PURPOSE:     ClothesShopGUI class
-- *
-- ****************************************************************************
ClothesShopGUI = inherit(GUIForm)
inherit(Singleton, ClothesShopGUI)

addRemoteEvents{"showClothesShopGUI"}

function ClothesShopGUI:constructor(shopId, typeId, clothes)
	localPlayer:setFrozen(true)

	GUIForm.constructor(self, 10, 10, screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight/2)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Kleidungsshop", false, true, self)
	self.m_Grid = GUIGridList:new(0, self.m_Height*0.22, self.m_Width, self.m_Height*0.72, self.m_Window)
	self.m_Grid:addColumn(_"Name", 0.75)
	self.m_Grid:addColumn(_"Preis", 0.25)
	self.m_ShopImage = GUIImage:new(0, 30, self.m_Width, self.m_Height/7, "files/images/Shops/ClothesHeader.png", self.m_Window)
	GUILabel:new(0, self.m_Height-self.m_Height/14, self.m_Width, self.m_Height/14, "↕", self.m_Window):setAlignX("center")
	GUILabel:new(6, self.m_Height-self.m_Height/14, self.m_Width*0.5, self.m_Height/14, _"Doppelklick zum Kaufen", self.m_Window):setFont(VRPFont(self.m_Height*0.045)):setAlignY("center"):setColor(Color.Red)


	self.m_RotatePlayer = bind(self.rotatePlayer, self)

	self.m_Shop = shopId or 0
	self.m_TypeId = typeId


	localPlayer.m_OldClothTexture, localPlayer.m_OldClothModel = localPlayer:getClothes(self.m_TypeId)

	self:refreshClothes(clothes)

	addEventHandler("onClientPreRender", root, self.m_RotatePlayer)

	showChat(false)
end

function ClothesShopGUI:refreshClothes(clothes)
	local item
	self.m_Grid:clear()

	for id, data in pairs(clothes) do
		item = self.m_Grid:addItem(data.Name, tostring(data.Price.."$"))
		item.Id = id

		item.onLeftDoubleClick = function()
			delete(self)
			triggerServerEvent("shopBuyClothes", localPlayer, self.m_Shop, self.m_TypeId, id)
		end

		item.onLeftClick = function ()
			localPlayer:removeClothes(self.m_TypeId)
			if id >= 0 then
				local texture, model = getClothesByTypeIndex(self.m_TypeId, id)
				localPlayer:addClothes(texture, model, self.m_TypeId)
			end
		end

	end
end

function ClothesShopGUI:destructor()
	removeEventHandler("onClientPreRender", root, self.m_RotatePlayer)
	localPlayer:setFrozen(false)
	localPlayer:removeClothes(self.m_TypeId)
	if localPlayer.m_OldClothTexture and localPlayer.m_OldClothModel then
		localPlayer:addClothes(localPlayer.m_OldClothTexture, localPlayer.m_OldClothModel, self.m_TypeId)
	end
	setCameraTarget(localPlayer, localPlayer)
	showChat(true)
	GUIForm.destructor(self)
end

function ClothesShopGUI:rotatePlayer()
	local rot = localPlayer:getRotation()
	localPlayer:setRotation(0, 0, rot.z+1)
end


addEventHandler("showClothesShopGUI", root,
	function(shopId, typeId, clothes)
		if ClothesShopGUI:isInstantiated() then delete(ClothesShopGUI:getSingleton()) end
		ClothesShopGUI:new(shopId, typeId, clothes)
	end
)
