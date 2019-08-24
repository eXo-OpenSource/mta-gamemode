-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PlayHouseShopGUI.lua
-- *  PURPOSE:     PlayHouse Shop GUI class
-- *
-- ****************************************************************************
PlayHouseShopGUI = inherit(GUIForm)
inherit(Singleton, PlayHouseShopGUI)

PlayHouseShopGUI.Items = 
{
	["Clubkarte"] = 50000, 
}

PlayHouseShopGUI.ItemDesc = 
{
	["Clubkarte"] = {"files/images/Inventory/items/Items/Clubcard.png", "Diese Karte erlaubt es dir, die oberen Gemächer zu betreten."},
}
function PlayHouseShopGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 12)
	self.m_Height = grid("y", 9)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Theke", true, true, self)
	
	GUIGridLabel:new(1, 1, 12, 1, _"Willkommen, was kann man für dich tun?", self)
	self.m_ShopItems = GUIGridGridList:new(1, 2, 6, 7, self)
	self.m_ShopItems:addColumn(_"Gegenstand", 0.6)
	self.m_ShopItems:addColumn(_"Preis", 0.4)
	
	self.m_ItemDescription = GUIGridLabel:new(8, 5, 4, 4, _"", self)
	self.m_ItemImage = GUIGridImage:new(8, 2, 4, 3, "files/images/Inventory/items/Items/Clubcard.png", self)
	self.m_ItemImage:setVisible(false)
	
	local item
	for name, price in pairs(PlayHouseShopGUI.Items) do
		item = self.m_ShopItems:addItem(name, ("$%s"):format(convertNumber(price)))
		item.price = price 
		item.name = name
		item.onLeftClick = bind(self.Event_UpdateDescription, self, item)
		item.onLeftDoubleClick = bind(self.Event_ClickItem, self, item)
	end

end

function PlayHouseShopGUI:Event_UpdateDescription(item) 
	if item and PlayHouseShopGUI.ItemDesc[item.name] then 
		self.m_ItemImage:setImage(PlayHouseShopGUI.ItemDesc[item.name][1])
		self.m_ItemImage:setVisible(true)
		self.m_ItemDescription:setText(PlayHouseShopGUI.ItemDesc[item.name][2])
	end
end

function PlayHouseShopGUI:Event_ClickItem(item) 
	triggerServerEvent("PlayHouse:buyItem", localPlayer, item.name, item.price)
	delete(self)
end


function PlayHouseShopGUI:destructor()
	GUIForm.destructor(self)
end
