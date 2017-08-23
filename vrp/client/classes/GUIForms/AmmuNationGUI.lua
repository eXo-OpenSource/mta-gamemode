-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AmmuNationGUI.lua
-- *  PURPOSE:     Ammu nation GUI class
-- *
-- ****************************************************************************
AmmuNationGUI = inherit(GUIForm)
inherit(Singleton, AmmuNationGUI)

addRemoteEvents{"showAmmunationMenu", "refreshAmmunationMenu"}

AmmuNationGUI.WeaponPosition = Vector3(1380.47, -1279.32, 13.7)

local weaponModels = {
	[30] = 355,
	[31] = 356,
	[29] = 353,
	[22] = 346,
	[24] = 348,
	[25] = 349,
	[33] = 357,
	[1] = 331,
	[0] = 1242
}

function AmmuNationGUI:constructor()
	GUIForm.constructor(self, 10, screenHeight/2-350/2, 300, screenHeight/2-10)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Ammunation", true, true, self)

	self.m_WeaponList = GUIGridList:new(5, 35, self.m_Width-10, 270, self)
	self.m_WeaponList:addColumn(_"Name", 0.75)
	self.m_WeaponList:addColumn(_"Preis", 0.25)
	self.m_Buy = GUIButton:new(5, 315, self.m_Width-10, 30, "Kaufen", self):setBackgroundColor(Color.Green)
	self.m_Buy.onLeftClick = function() self:buy() end

	self.m_RotateBind = bind(self.rotateObject, self)
	addEventHandler("refreshAmmunationMenu", root, bind(self.refreshShopMenu, self))
	addEventHandler("onClientRender", root, self.m_RotateBind)
end

function AmmuNationGUI:onHide()
	if isElement(self.m_Object) then self.m_Object:destroy() end
	if self.m_CamaraMatrix then
		setCameraTarget(localPlayer)
		self.m_CamaraMatrix = false
	end
	removeEventHandler("onClientRender", root, self.m_RotateBind)
end

function AmmuNationGUI:rotateObject()
	if self.m_Object and isElement(self.m_Object) then
		local rot = self.m_Object:getRotation()
		self.m_Object:setRotation(rot.x, rot.y, rot.z+1)
	end
end

function AmmuNationGUI:refreshShopMenu(shopId, weapons, magazines)
	self.m_Shop = shopId
	local item
	self.m_WeaponList:clear()
	self.m_WeaponList:addItemNoClick("Waffen", "")
	for weaponId, price in pairs(weapons) do
		item = self.m_WeaponList:addItem(WEAPON_NAMES[weaponId], tostring(price).."$")
		item.Id = weaponId
		item.Type = "Weapon"
		item.onLeftClick = function()
			self:onSelectWeapon(weaponId)
		end
	end
	self.m_WeaponList:addItemNoClick("Munition", "")
	for weaponId, data in pairs(magazines) do
		item = self.m_WeaponList:addItem(WEAPON_NAMES[weaponId], tostring(data.price.."$"))
		item.Id = name
		item.Type = "Magazine"
		item.onLeftClick = function()
			self:onSelectMagazine(name)
		end
	end
end

function AmmuNationGUI:buy()
	local item = self.m_WeaponList:getSelectedItem()
	triggerServerEvent("ammunationBuyItem", resourceRoot, self.m_Shop, item.Type, item.Id)
end

function AmmuNationGUI:onSelectWeapon(weaponId)
	if isElement(self.m_Object) then self.m_Object:destroy() end
	self.m_Object = createObject(weaponModels[weaponId], AmmuNationGUI.WeaponPosition, table["Rot"])
	self.m_Object:setInterior(localPlayer:getInterior())
	self.m_Object:setDimension(localPlayer:getDimension())

	--[[
	local typeTable = {
		["CluckinBell"] = CLUCKIN_BELL,
		["PizzaStack"] =  PIZZA_STACK,
		["BurgerShot"] =  BURGER_SHOT,
		["RustyBrown"] = RUSTY_BROWN
	}
	local table = typeTable[type]
	setCameraMatrix(table["CameraMatrixPos"], table["CameraMatrixLookAt"], 0, 70)
	self.m_CamaraMatrix = true
	if isElement(self.m_Object) then self.m_Object:destroy() end
	self.m_Object = createObject(table["Objects"][menu], table["Pos"], table["Rot"])
	self.m_Object:setInterior(localPlayer:getInterior())
	self.m_Object:setDimension(localPlayer:getDimension())
	]]
end

function AmmuNationGUI:onSelectMagazine(item)
	if self.m_CamaraMatrix then
		setCameraTarget(localPlayer)
		self.m_CamaraMatrix = false
	end
end

addEventHandler("showAmmunationMenu", root,
		function()
			if AmmuNationGUI:isInstantiated() then delete(AmmuNationGUI:getSingleton()) end
			AmmuNationGUI:getSingleton():new()
		end
	)

addEventHandler("shopCloseGUI", root,
		function()
			if AmmuNationGUI:isInstantiated() then delete(AmmuNationGUI:getSingleton()) end
		end
	)


--[[
function AmmuNationGUI:constructor()
	self.m_Selection = 1
	self.m_CameraInstance = false

	GUIForm.constructor(self,screenWidth/2,screenHeight/2,400,200)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Ammu-Nation", true, true, self)
	self.m_Label = GUILabel:new(30, 40, 300, 300, _("Waffe: %s\nBenötigtes Level: %d",AmmuNationGUI.INFO[self.m_Selection].NAME, MIN_WEAPON_LEVELS[AmmuNationGUI.INFO[self.m_Selection].ID]), self.m_Window)
	self.m_Label:setFont(VRPFont(24))
	self.m_BuyMagazine = GUIButton:new(30, 90, self.m_Width-60, 35, _("Magazin kaufen ($%i)",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Magazine.price), self.m_Window)
	self.m_BuyMagazine:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_BuyMagazine.onLeftClick = bind(self.buyMagazine,self)
	self.m_BuyWeapon = GUIButton:new(30, 135, self.m_Width-60, 35, _("Waffe kaufen ($%i)",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Weapon), self.m_Window)
	self.m_BuyWeapon:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_BuyWeapon.onLeftClick = bind(self.buyWeapon,self)
	GUILabel:new(30, 175, 300, 20, "Leertaste - Schließen", self.m_Window)

	self.m_OnKeyFunc = bind(self.onKey, self)
	addEventHandler("onClientKey", root, self.m_OnKeyFunc)
end

function AmmuNationGUI:destructor()
	if self.m_CameraInstance then
		delete(self.m_CameraInstance)
	end
	setCameraTarget(localPlayer, localPlayer)
	removeEventHandler("onClientKey", root, self.m_OnKeyFunc)

	GUIForm.destructor(self)
end

function AmmuNationGUI:buyMagazine()
	triggerServerEvent("onPlayerMagazineBuy",localPlayer,AmmuNationGUI.INFO[self.m_Selection].ID)
end

function AmmuNationGUI:buyWeapon()
	triggerServerEvent("onPlayerWeaponBuy",localPlayer,AmmuNationGUI.INFO[self.m_Selection].ID)
end

function AmmuNationGUI:updateDimension(int)
	for key, value in pairs(AmmuNationGUI.INFO) do
		value.WEAPON:setDimension(localPlayer:getDimension())
		value.WEAPON:setInterior(7)
	end
end

function AmmuNationGUI:onKey(key, state)
	if key == "space" then
		delete(self)
		return
	end

	if state then
		if key == "arrow_l" then
			self.m_Selection = self.m_Selection - 1
		elseif key == "arrow_r" then
			self.m_Selection = self.m_Selection + 1
		else
			return
		end
		self.m_Selection = math.max(math.min(self.m_Selection, #AmmuNationGUI.INFO), 1)

		if AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Magazine then
			self.m_Label:setText(_("Waffe: %s\nBenötigtes Level: %d",AmmuNationGUI.INFO[self.m_Selection].NAME,MIN_WEAPON_LEVELS[AmmuNationGUI.INFO[self.m_Selection].ID]))
			self.m_BuyMagazine:setText(_("Magazin kaufen ($%i)",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Magazine.price))
			self.m_BuyMagazine:setVisible(true)
			self.m_BuyWeapon:setText(_("Waffe kaufen ($%i)",AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Weapon))
		else
			self.m_Label:setText(_("%s\nBenötigtes Level: %d",AmmuNationGUI.INFO[self.m_Selection].NAME,MIN_WEAPON_LEVELS[AmmuNationGUI.INFO[self.m_Selection].ID]))
			self.m_BuyMagazine:setVisible(false)
			self.m_BuyWeapon:setText(_("%s kaufen ($%i)",AmmuNationGUI.INFO[self.m_Selection].NAME, AmmuNationInfo[AmmuNationGUI.INFO[self.m_Selection].ID].Weapon))
		end
		self:updateMatrix()
	end
end

function AmmuNationGUI:updateMatrix()
	self.m_CurrentMatrix = {getCameraMatrix(localPlayer)}
	local fadeMatrix = AmmuNationGUI.INFO[self.m_Selection].MATRIX

	if self.m_CameraInstance then
		delete(self.m_CameraInstance)
	end

	self.m_CameraInstance = cameraDrive:new(self.m_CurrentMatrix[1],self.m_CurrentMatrix[2],self.m_CurrentMatrix[3],
		self.m_CurrentMatrix[4],self.m_CurrentMatrix[5],self.m_CurrentMatrix[6],
		fadeMatrix[1],fadeMatrix[2],fadeMatrix[3],
		fadeMatrix[4],fadeMatrix[5],fadeMatrix[6],
		1500
	)
end

addEvent("openAmmuNationGUI", true)
addEventHandler("openAmmuNationGUI", root,
	function()
		local gui = AmmuNationGUI:getSingleton()
		gui:updateMatrix()
		gui:updateDimension()
	end
)

AmmuNationGUI.INFO = {
	[1] = {
		NAME = "AK-47",
		WEAPON = createObject(355,308,-144.6,1001.2),
		MATRIX = {308.227966,-142.709167,1001.194458,301.387390,-242.401749,1005.015076},
		ID = 30
	},
	[2] = {
		NAME = "M4A1",
		WEAPON = createObject(356,308.299,-144.6,1000.7),
		MATRIX = {308.141602,-143.443695,1000.868408,311.496613,-242.906876,991.079712},
		ID = 31
	},
	[3] = {
		NAME = "MP5",
		WEAPON = createObject(353,303.299,-144.6,1001.2),
		MATRIX = {303.581848,-143.040573,1001.265564,294.203888,-242.526535,1005.086182},
		ID = 29
	},
	[4] = {
		NAME = "Pistol",
		WEAPON = createObject(346,309.20001220703,-142.30000305176,999.70001220703,0,24,358),
		MATRIX = {309.173553,-141.216537,1000.342041,322.899658,-225.678635,948.595093},
		ID = 22
	},
	[5] = {
		NAME = "Desert Eagle",
		WEAPON = createObject(348,310,-142.39999389648,999.70001220703,0,23,305),
		MATRIX = {311.121979,-141.730835,1000.188477,238.921417,-199.475098,962.074463},
		ID = 24
	},
	[6] = {
		NAME = "Shotgun",
		WEAPON = createObject(349,317.29998779297,-131.5,1000.6,0,0,270),
		MATRIX = {315.967560,-131.796539,1000.857971,415.202942,-131.063644,988.537292},
		ID = 25
	},
	[7] = {
		NAME = "Rifle",
		WEAPON = createObject(357,317.29998779297,-133.5,1000.6,0,0,270),
		MATRIX = {315.967560,-133.8,1000.857971,415.202942,-131.063644,988.537292},
		ID = 33
	},

	[8] = {
		NAME = "Schlagring",
		WEAPON = createObject(331,313, -131.27, 1002,0,0,180),
		MATRIX = {313, -134.74839782715, 1002.470703125, 313, -133.81578063965, 1002.1194458008},
		ID = 1
	},

	[9] = {
		NAME = "Schutzweste",
		WEAPON = createObject(1242,308, -131.27, 1001.75,0,0,180),
		MATRIX = {308, -134.74839782715, 1002.470703125, 308, -133.81578063965, 1002.1194458008},
		ID = 0
	},
}
]]
