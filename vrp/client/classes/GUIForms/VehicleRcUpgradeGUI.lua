-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleRcUpgradeGUI.lua
-- *  PURPOSE:     VehicleUnregister GUI
-- *
-- ****************************************************************************
VehicleRcUpgradeTypeSelectGUI = inherit(GUIButtonMenu)
inherit(Singleton, VehicleRcUpgradeTypeSelectGUI)

addRemoteEvents{"sendOwningRcVehicle", "openVehicleRcUpgradeGUI", "sendOwningRcVans"}

function VehicleRcUpgradeTypeSelectGUI:constructor(rangeElement)
	GUIButtonMenu.constructor(self, _("Wähle den Gruppentyp aus"), false, false, false, false, rangeElement)

	self:addItem(_"Spieler", Color.Accent, bind(self.onItemClick, self, "player", rangeElement))
	if localPlayer:getGroupType() then
		self:addItem(_"Firma/Gang", Color.Accent, bind(self.onItemClick, self, "group", rangeElement))
	end
end

function VehicleRcUpgradeTypeSelectGUI:onItemClick(type, rangeElement)
	--nextframe(function()
		delete(self)
		triggerServerEvent("requestRcVans", resourceRoot, type)
	--end)
end

addEventHandler("openVehicleRcUpgradeGUI", root,
	function(rangeElement)
		VehicleRcUpgradeTypeSelectGUI:new(rangeElement)
	end
)



VehicleRcUpgradeVehicleSelectGUI = inherit(GUIButtonMenu)
inherit(Singleton, VehicleRcUpgradeVehicleSelectGUI)

function VehicleRcUpgradeVehicleSelectGUI:constructor(rangeElement, data)
	GUIButtonMenu.constructor(self, _("Wähle ein Fahrzeug aus"), false, false, false, false, rangeElement)
	self:updateList(data)
end

addEventHandler("sendOwningRcVans", root,
	function(data)
		VehicleRcUpgradeVehicleSelectGUI:new(localPlayer:getPosition(), data)
	end
)

function VehicleRcUpgradeVehicleSelectGUI:updateList(data)
	for i, item in pairs(self.m_Items) do self:removeItem(item) end

	for i, vehicle in pairs(data) do
		self:addItem(_("RC Van (%s)", getElementData(vehicle, "ID")), Color.Accent, bind(self.onItemClick, self, vehicle))
	end
end

function VehicleRcUpgradeVehicleSelectGUI:onItemClick(vehicle)
	--nextframe(function()
		delete(self)
		triggerServerEvent("requestOwningRcVehicle", resourceRoot, vehicle)
	--end)
end



VehicleRcUpgradeGUI = inherit(GUIForm)
inherit(Singleton, VehicleRcUpgradeGUI)

function VehicleRcUpgradeGUI:constructor(rangeElement, data)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 8)
	self.m_Height = grid("y", 8)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2-40, self.m_Width, self.m_Height, true, false, rangeElement)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Upgrades kaufen", true, true, self)
	self.m_Info = GUIGridLabel:new(1, 1, 7, 1, _"Doppelklick zum Kaufen", self):setColor(Color.Red)
	self:updateList(data)
end

function VehicleRcUpgradeGUI:updateList(data)
	if self.m_UpgradeGrid then delete(self.m_UpgradeGrid) end

	self.m_UpgradeGrid = GUIGridGridList:new(1,2, 7, 7, self.m_Window)
	self.m_UpgradeGrid:addColumn(_"Fahrzeug", 0.6)
	self.m_UpgradeGrid:addColumn(_"Eingebaut", 0.4)
	for upgrade, state in pairs(RC_UPGRADE_VEHICLE) do
		if state then
			local item = self.m_UpgradeGrid:addItem(_("%s (%s)", getVehicleNameFromModel(upgrade), toMoneyString(RC_UPGRADE_VEHICLE_PRICE[upgrade])), table.find(data, upgrade) and "✓" or "✘")
			item.Id = upgrade
			item.onLeftDoubleClick = bind(self.onUpgradeBuy_Click, self)
		end
	end
end

function VehicleRcUpgradeGUI:onUpgradeBuy_Click()
	if not self.m_UpgradeGrid:getSelectedItem() then return end
	if not RC_UPGRADE_VEHICLE[self.m_UpgradeGrid:getSelectedItem().Id] then return ErrorBox:new(_"Internal Error: Invalid Upgrade") end
	
	local item = self.m_UpgradeGrid:getSelectedItem()
	local vehName = getVehicleNameFromModel(item.Id)
	local price = RC_UPGRADE_VEHICLE_PRICE[item.Id]
	self:hide()
	nextframe(function()
		QuestionBox:new(_("Möchtest du den %s für dein RC Van wirklich kaufen? Dies kostet dich %s$", vehName, price), 
			function()
				triggerServerEvent("onRcUpgradeBuy", resourceRoot, item.Id)
				self:show()
			end,
			function() self:show() end,
			localPlayer:getPosition()
		)
	end)
end

addEventHandler("sendOwningRcVehicle", localPlayer, 
	function(data)
		if VehicleRcUpgradeGUI:isInstantiated() then delete(VehicleRcUpgradeGUI:getSingleton()) end
		VehicleRcUpgradeGUI:new(localPlayer:getPosition(), data)
	end
)