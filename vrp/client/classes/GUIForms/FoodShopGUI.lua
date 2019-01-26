-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FoodShopGUI.lua
-- *  PURPOSE:     FoodShop GUI Class
-- *
-- ****************************************************************************
FoodShopGUI = inherit(GUIForm)
inherit(Singleton, FoodShopGUI)

local CLUCKIN_BELL = {
	["Pos"] = Vector3(370.5, -5.3, 1001.95),
	["Rot"] = Vector3(334, 25, 74),
	["CameraMatrixPos"] =  Vector3(370.09591674805, -6.1112585067749, 1002.5751953125),
	["CameraMatrixLookAt"] = Vector3(370.86077880859, 73.279449462891, 941.77612304688),
	["Objects"] = {["Small"] = 2215, ["Middle"] = 2216, ["Big"] = 2217, ["Healthy"] = 2353},
	["SFX"] = {container = 15, enter = {29, 30, 31, 32, 33, 34, 36}, buy = {5, 8, 37, 10}, leave = {7, 4}}
}

local PIZZA_STACK = {
	["Pos"] = Vector3(375.9, -118.2, 1001.6),
	["Rot"] = Vector3(334, 25, 73),
	["CameraMatrixPos"] =  Vector3(375.52822875977, -119.26042175293, 1002.2143554688),
	["CameraMatrixLookAt"] = Vector3(382.27285766602, -31.187650680542, 955.33477783203),
	["Objects"] = {["Small"] = 2218, ["Middle"] = 2219, ["Big"] = 2220, ["Healthy"] = 2355},
	["SFX"] = {container = 17, enter = {33, 36, 37, 41}, buy = {6, 13}, leave = {7, 8, 11}}
}

local BURGER_SHOT = {
	["Pos"] = Vector3(377.7, -66.7, 1001.6),
	["Rot"] = Vector3(334, 25, 72.25),
	["CameraMatrixPos"] =  Vector3(377.15213012695, -67.673896789551, 1002.1579589844),
	["CameraMatrixLookAt"] = Vector3(376.87426757813, 21.821876525879, 957.54370117188),
	["Objects"] = {["Small"] = 2213, ["Middle"] = 2214, ["Big"] = 2212, ["Healthy"] = 2354},
	["SFX"] = {container = 11, enter = {30, 32}, buy = {3, 6}, leave = {5, 26, 27}}
}

local RUSTY_BROWN = {
	["Pos"] = Vector3(379.9, -189, 1000.8),
	["Rot"] = Vector3(0, 0, 0),
	["CameraMatrixPos"] = Vector3(378.86856079102, -188.8207244873, 1001.381652832),
	["CameraMatrixLookAt"] = Vector3(468.87298583984, -191.9049987793, 957.9110717773),
	["Objects"] = {["Small"] = 2221, ["Middle"] = 2223, ["Big"] = 2222}
}

local typeTable = {
	["CluckinBell"] = CLUCKIN_BELL,
	["PizzaStack"] =  PIZZA_STACK,
	["BurgerShot"] =  BURGER_SHOT,
	["RustyBrown"] = RUSTY_BROWN
}

-- 0 70
addRemoteEvents{"showFoodShopMenu", "refreshFoodShopMenu"}

function FoodShopGUI:constructor()
	GUIForm.constructor(self, 10, screenHeight/2-350/2, 300, 350)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Restaurant", true, true, self)

	self.m_FoodList = GUIGridList:new(5, 35, self.m_Width-10, 270, self)
	self.m_FoodList:addColumn(_"Name", 0.75)
	self.m_FoodList:addColumn(_"Preis", 0.25)
	self.m_Buy = GUIButton:new(5, 315, self.m_Width-10, 30, "Kaufen", self):setBackgroundColor(Color.Green)
	self.m_Buy.onLeftClick = function() self:buy() end
	self.m_RefreshBind = bind(self.refreshFoodShopMenu, self)
	addEventHandler("refreshFoodShopMenu", root, self.m_RefreshBind)
end

function FoodShopGUI:virtual_destructor()
	self:playSFX("leave")
end

function FoodShopGUI:onHide()
	if isElement(self.m_Object) then self.m_Object:destroy() end
	if self.m_CamaraMatrix then
		setCameraTarget(localPlayer)
		self.m_CamaraMatrix = false
	end
	removeEventHandler("refreshFoodShopMenu", root, self.m_RefreshBind)
end

function FoodShopGUI:refreshFoodShopMenu(shopId, type, menues, items)
	self.m_Shop = shopId
	self.m_ShopType = type
	self:playSFX("enter")
	local item
	self.m_FoodList:clear()
	self.m_FoodList:addItemNoClick("zum hier essen", "")
	for index, menu in pairs(menues) do
		item = self.m_FoodList:addItem(menu["Name"], tostring(menu["Price"]).."$")
		item.Id = index
		item.Type = "Menu"
		item.onLeftClick = function() self:onSelectMenu(index, type) end
	end
	self.m_FoodList:addItemNoClick("zum mitnehmen", "")
	for name, price in pairs(items) do
		item = self.m_FoodList:addItem(name, tostring(price.."$"))
		item.Id = name
		item.Type = "Item"
		item.onLeftClick = function() self:onSelectItem(name) end
	end
end

function FoodShopGUI:playSFX(type)
	local table = typeTable[self.m_ShopType]
	if table["SFX"] and table["SFX"][type] then
		playSFX("spc_fa", table["SFX"].container, table["SFX"][type][math.random(1, #table["SFX"][type])], false)
	end
end

function FoodShopGUI:buy()
	local item = self.m_FoodList:getSelectedItem()
	self:playSFX("buy")
	if  item.Type == "Menu" then
		triggerServerEvent("foodShopBuyMenu", resourceRoot, self.m_Shop, item.Id)
	else
		triggerServerEvent("shopBuyItem", resourceRoot, self.m_Shop, item.Id)
	end
end

function FoodShopGUI:onSelectMenu(menu, type)
	local table = typeTable[type]
	setCameraMatrix(table["CameraMatrixPos"], table["CameraMatrixLookAt"], 0, 70)
	self.m_CamaraMatrix = true
	if isElement(self.m_Object) then self.m_Object:destroy() end
	self.m_Object = createObject(table["Objects"][menu], table["Pos"], table["Rot"])
	self.m_Object:setInterior(localPlayer:getInterior())
	self.m_Object:setDimension(localPlayer:getDimension())
end

function FoodShopGUI:onSelectItem(item)
	if self.m_CamaraMatrix then
		setCameraTarget(localPlayer)
		self.m_CamaraMatrix = false
	end
end

addEventHandler("showFoodShopMenu", root,
		function()
			if FoodShopGUI:isInstantiated() then delete(FoodShopGUI:getSingleton()) end
			FoodShopGUI:getSingleton():new()
		end
	)

addEventHandler("shopCloseGUI", root,
		function()
			if FoodShopGUI:isInstantiated() then delete(FoodShopGUI:getSingleton()) end
		end
	)
