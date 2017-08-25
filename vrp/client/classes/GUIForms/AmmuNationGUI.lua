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

AmmuNationGUI.Data = {
	["Ammunation Central"] = {
		WeaponPosition = Vector3(1380.47, -1279.32, 13.7),
		CameraMatrix = {Vector3(1375.70, -1279.30, 15.90), Vector3(1380.47, -1279.32, 14)}
	},
	["Ammunation South"] = {
		WeaponPosition = Vector3(2380.06, -1985.14, 13.7),
		CameraMatrix = {Vector3(2375.70, -1985.14, 15.90), Vector3(2380.06, -1985.14, 14)}
	},
}

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
	GUIForm.constructor(self, 10, screenHeight*0.25, 300, screenHeight*0.5)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Ammunation", true, true, self)

	self.m_WeaponList = GUIGridList:new(5, 35, self.m_Width-10, self.m_Height-35-65, self)
	self.m_WeaponList:addColumn(_"Name", 0.75)
	self.m_WeaponList:addColumn(_"Preis", 0.25)
	self.m_AmountLabel = GUILabel:new(5, self.m_Height-35, self.m_Width/4, 30, "Anzahl:", self):setFontSize(1)
	self.m_Amount = GUIEdit:new(5+self.m_Width/4, self.m_Height-35, self.m_Width/4-10, 30, self)
	self.m_AmountLabel:setVisible(false)
	self.m_Amount:setVisible(false)
	self.m_Amount:setText("1")
	self.m_Buy = GUIButton:new(self.m_Width/2, self.m_Height-35, self.m_Width/2-2.5, 30, "Kaufen", self):setBackgroundColor(Color.Green)
	self.m_Buy.onLeftClick = function() self:buy() end

	self.m_RotateBind = bind(self.rotateObject, self)
	addEventHandler("refreshAmmunationMenu", root, bind(self.refreshShopMenu, self))
	addEventHandler("onClientRender", root, self.m_RotateBind)
	HUDRadar:getSingleton():hide()
end

function AmmuNationGUI:onHide()
	if isElement(self.m_Object) then self.m_Object:destroy() end
	setCameraTarget(localPlayer)
	removeEventHandler("onClientRender", root, self.m_RotateBind)
	HUDRadar:getSingleton():show()
end

function AmmuNationGUI:rotateObject()
	if self.m_Object and isElement(self.m_Object) then
		local rot = self.m_Object:getRotation()
		self.m_Object:setRotation(rot.x, rot.y, rot.z+1)
	end
end

function AmmuNationGUI:refreshShopMenu(shopId, typeName, weapons, magazines)
	self.m_Shop = shopId
	self.m_Name = typeName
	local item
	self.m_WeaponList:clear()

	item = self.m_WeaponList:addItem( _"Schutzweste", tostring(weapons[0]).."$")
	item.Id = 0
	item.Type = "Vest"
	item.onLeftClick = function()
		self:onSelectWeapon(0)
	end

	self.m_WeaponList:addItemNoClick("Waffen", "")
	for weaponId, price in pairs(weapons) do
		if weaponId > 0 then
			item = self.m_WeaponList:addItem(WEAPON_NAMES[weaponId], tostring(price).."$")
			item.Id = weaponId
			item.Type = "Weapon"
			item.onLeftClick = function()
				self:onSelectWeapon(weaponId)
			end
		end
	end
	self.m_WeaponList:addItemNoClick("Munition", "")
	for weaponId, data in pairs(magazines) do
		item = self.m_WeaponList:addItem(WEAPON_NAMES[weaponId], tostring(data.price.."$"))
		item.Id = weaponId
		item.Type = "Magazine"
		item.onLeftClick = function()
			self:onSelectMagazine()
		end
	end
end

function AmmuNationGUI:buy()
	local item = self.m_WeaponList:getSelectedItem()
	triggerServerEvent("ammunationBuyItem", resourceRoot, self.m_Shop, item.Type, item.Id, tonumber(self.m_Amount:getText()))
end

function AmmuNationGUI:onSelectWeapon(weaponId)
	local rot = Vector3(0,0,0)
	if isElement(self.m_Object) then rot = self.m_Object:getRotation() self.m_Object:destroy() end
	self.m_Object = createObject(weaponModels[weaponId], AmmuNationGUI.Data[self.m_Name].WeaponPosition, rot)
	self.m_Object:setInterior(localPlayer:getInterior())
	self.m_Object:setDimension(localPlayer:getDimension())
	self.m_AmountLabel:setVisible(false)
	self.m_Amount:setVisible(false)
	self.m_Amount:setText("1")

	setCameraMatrix(AmmuNationGUI.Data[self.m_Name].CameraMatrix[1], AmmuNationGUI.Data[self.m_Name].CameraMatrix[2], 0, 70)
end

function AmmuNationGUI:onSelectMagazine(weaponId)
	local rot = Vector3(0,0,0)
	if isElement(self.m_Object) then rot = self.m_Object:getRotation() self.m_Object:destroy() end
	self.m_Object = createObject(2061, AmmuNationGUI.Data[self.m_Name].WeaponPosition, rot)
	self.m_Object:setInterior(localPlayer:getInterior())
	self.m_Object:setDimension(localPlayer:getDimension())
	self.m_AmountLabel:setVisible(true)
	self.m_Amount:setVisible(true)

	setCameraMatrix(AmmuNationGUI.Data[self.m_Name].CameraMatrix[1], AmmuNationGUI.Data[self.m_Name].CameraMatrix[2], 0, 70)
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
