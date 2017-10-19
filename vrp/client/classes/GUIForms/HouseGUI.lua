-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HouseGUI.lua
-- *  PURPOSE:     House GUI class
-- *
-- ****************************************************************************
HouseGUI = inherit(GUIForm)
HouseGUI.Blips = {}
inherit(Singleton, HouseGUI)

addRemoteEvents{"showHouseMenu","hideHouseMenu", "addHouseBlip", "removeHouseBlip"}

function HouseGUI:constructor(ownerName, price, rentprice, isValidRob, isClosed, tenants, money, hasKey, houseId)
	self.m_isOwner = ownerName == localPlayer:getName()
	self.m_isTenant = tenants and tenants[tostring(localPlayer:getPrivateSync("Id"))]
	self.m_isRentEnabled = rentprice > 0
	self.m_isInside = localPlayer:getDimension() > 0 or localPlayer:getInterior() > 0
	self.m_Tenants = tenants
	self.m_Money = money
	self.m_Price = price

	GUIWindow.updateGrid()	
	self.m_Width = grid("x", self.m_isOwner and 13 or 7) 
	self.m_Height = grid("y", self.m_isOwner and 10 or 8) 

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Hausmenü (Hausnr. %d)", houseId), true, true, self)
	
	self.m_OwnerLbl = GUIGridLabel:new(1, 1, 6, 1, _("Besitzer: %s", ownerName or "Niemand"), self.m_Window)
	self.m_PriceLbl = GUIGridLabel:new(1, 2, 5, 1, _("Preis: %s", toMoneyString(price)), self.m_Window)
	
	if not ownerName then
		self.m_BuyBtn = GUIGridButton:new(1, 3, 6, 1, _"Haus kaufen", self.m_Window):setBackgroundColor(Color.Green)
		self.m_BuyBtn.onLeftClick = bind(HouseGUI.buyHouse, self)
	elseif self.m_isRentEnabled then
		self.m_RentPriceLbl = GUIGridLabel:new(1, 3, 4, 1, _("Mietpreis: %s", toMoneyString(rentprice)), self.m_Window)
		self.m_RentBtn = GUIGridButton:new(4, 3, 3, 1, self.m_isTenant and _"Ausmieten" or _"Einmieten", self.m_Window):setEnabled(not self.m_isOwner)

		self.m_RentBtn.onLeftClick = function()
			if self.m_isTenant then
				triggerServerEvent("unrentHouse",root)
			else
				triggerServerEvent("rentHouse",root)
			end
		end
	else
		GUIGridLabel:new(1, 3, 6, 1, _"(Keine neuen Mieter akzeptiert)", self.m_Window)
	end

	
	self.m_LockBtn = GUIGridButton:new(1, 4, 6, 1, isClosed and _"Aufschließen" or _"Abschließen", self.m_Window):setEnabled(hasKey)
	self.m_SpawnBtn = GUIGridButton:new(1, 5, 6, 1, _"als Spawnpunkt festlegen", self.m_Window):setEnabled(hasKey)
	self.m_RobBtn = GUIGridButton:new(1, 6, 6, 1, _"Raub starten", self.m_Window):setBackgroundColor(Color.Orange):setEnabled(isValidRob)
	self.m_EnterLeaveBtn = GUIGridButton:new(1, 7, self.m_isInside and 6 or 5, 1, self.m_isInside and _"Verlassen" or (ownerName and _"Betreten" or _"Besichtigen"), self.m_Window):setBarEnabled(false)
	if not self.m_isInside then 
		self.m_DoorBellBtn = GUIGridIconButton:new(6, 7, FontAwesomeSymbols.Bell, self.m_Window):setTooltip(_"an der Tür klingeln", "bottom")
		self.m_DoorBellBtn.onLeftClick = function()
			triggerServerEvent("houseRingDoor",root)
		end
	end

	self.m_LockBtn.onLeftClick = function()
		triggerServerEvent("lockHouse",root)
	end

	self.m_SpawnBtn.onLeftClick = function()
		triggerServerEvent("onPlayerUpdateSpawnLocation", localPlayer, SPAWN_LOCATIONS.HOUSE)
	end

	self.m_RobBtn.onLeftClick = function()
		triggerServerEvent("tryRobHouse", localPlayer)
	end

	self.m_EnterLeaveBtn.onLeftClick = function()
		if self.m_isInside then
			triggerServerEvent("leaveHouse",root)
		else
			triggerServerEvent("enterHouse",root)
		end
		delete(self)
	end

	if localPlayer:getRank() >= ADMIN_RANK_PERMISSION.editHouse then
		self.m_EditBtn = GUIGridIconButton:new(6, 2, FontAwesomeSymbols.Edit, self.m_Window):setBackgroundColor(Color.Orange):setTooltip(_"Haus editieren", "left")
			self.m_EditBtn.onLeftClick = function()
			HouseEditGUI:new()
		end
	end
	
	if self.m_isOwner then
		self:loadOwnerOptions()
	end
end

function HouseGUI:loadOwnerOptions()
	GUIGridLabel:new(7, 1, 6, 1, _"Besitzer-Optionen", self.m_Window):setHeader("sub")

	self.m_LblMoney = GUIGridLabel:new(7, 2, 6, 1, _("Kasse: %s", toMoneyString(self.m_Money)), self.m_Window)
	self.m_EditMoney = GUIGridEdit:new(7, 3, 4, 1, self.m_Window):setCaption(_"Betrag"):setNumeric(true, true)
	self.m_MoneyDepositBtn = GUIGridIconButton:new(11, 3, FontAwesomeSymbols.Double_Up, self.m_Window):setTooltip(_"Einzahlen")
	self.m_MoneyWithdrawBtn = GUIGridIconButton:new(12, 3, FontAwesomeSymbols.Double_Down, self.m_Window):setTooltip(_"Auszahlen")
	self.m_MoneyDepositBtn.onLeftClick = bind(HouseGUI.deposit, self)
	self.m_MoneyWithdrawBtn.onLeftClick = bind(HouseGUI.withdraw, self)

	self.m_TenantGrid = GUIGridGridList:new(7, 4, 6, 4, self.m_Window)
	self.m_TenantGrid:addColumn(_"Mieter", 1)

	for id, tenant in pairs(self.m_Tenants) do
		local item = self.m_TenantGrid:addItem(tenant)
		item.Id = id
	end

	self.m_RemoveTenantBtn = GUIGridIconButton:new(12, 4, FontAwesomeSymbols.Minus, self.m_Window):setTooltip(_"Mieter entfernen", "left"):setBackgroundColor(Color.Red)
	self.m_RemoveTenantBtn.onLeftClick = bind(HouseGUI.removeTenant, self)

	self.m_EditRent = GUIGridEdit:new(7, 8, 4, 1, self.m_Window):setCaption(_"Miete"):setNumeric(true, true)
	self.m_SaveRentBtn = GUIGridIconButton:new(11, 8, FontAwesomeSymbols.Save, self.m_Window):setBackgroundColor(Color.Green)
	self.m_RemoveRentBtn = GUIGridIconButton:new(12, 8, FontAwesomeSymbols.Ban, self.m_Window):setTooltip(_"Einmieten verbieten"):setBackgroundColor(Color.Red)

	self.m_SaveRentBtn.onLeftClick = bind(HouseGUI.saveRent, self)
	self.m_RemoveRentBtn.onLeftClick = bind(HouseGUI.saveRent, self, true)

	self.m_SellBtn = GUIGridButton:new(7, 9, 6, 1, "Haus verkaufen", self.m_Window):setBackgroundColor(Color.Red)
	self.m_SellBtn.onLeftClick = bind(HouseGUI.sellHouse, self)
end

function HouseGUI:destructor()
	GUIForm.destructor(self)
end

function HouseGUI:deposit()
	local amount = self.m_EditMoney:getText()
	if amount and tonumber(amount) and tonumber(amount) > 0 then
		triggerServerEvent("houseDeposit", root, amount)
	else
		ErrorBox:new(_"Ungültiger Betrag!")
	end
end

function HouseGUI:withdraw()
	local amount = self.m_EditMoney:getText()
	if amount and tonumber(amount) and tonumber(amount) > 0 then
		triggerServerEvent("houseWithdraw", root, amount)
	else
		ErrorBox:new(_"Ungültiger Betrag!")
	end
end

function HouseGUI:removeTenant()
	local tenant = self.m_TenantGrid:getSelectedItem()
	if tenant and tenant.Id then
		triggerServerEvent("houseRemoveTenant", root, tenant.Id)
	else
		WarningBox:new(_"Bitte wähle einen Mieter aus!")
		return
	end

end

function HouseGUI:buyHouse()
	QuestionBox:new(_("Möchtest du wirklich dieses Haus kaufen? %s werden dir von deinem Konto abgebucht! Zudem kannst du nur ein Haus besitzen.", toMoneyString(self.m_Price)),
	function() triggerServerEvent("buyHouse",root) end
	)

end

function HouseGUI:sellHouse()
	QuestionBox:new("Möchtest du wirklich dein Haus verkaufen? Du erhälst 75% des Preises auf dein Konto gutgeschrieben!",
	function() triggerServerEvent("sellHouse",root) end
	)

end



function HouseGUI:saveRent(disable)
	local amount = disable == true and 0 or tonumber(self.m_EditRent:getText()) or 0
	
	if disable ~= true and math.clamp(1, amount, 500) ~= amount then
		return WarningBox:new("Die Miete muss zwischen 1$ und 500$ liegen")
	end
	triggerServerEvent("houseSetRent", root, amount)

end

addEventHandler("showHouseMenu", root,
	function(...)
		if HouseGUI:isInstantiated() then
			delete(HouseGUI:getSingleton())
		end
		HouseGUI:new(...)
	end
)

addEventHandler("hideHouseMenu", root,
	function()
		if HouseGUI:isInstantiated() then
			delete(HouseGUI:getSingleton())
		end
	end
)

addEventHandler("addHouseBlip", root,
	function(id, x, y)
		if not HouseGUI.Blips[id] then
			HouseGUI.Blips[id] = Blip:new("House.png", x, y, 2000)
			HouseGUI.Blips[id]:setDisplayText("Haus")
			HouseGUI.Blips[id]:setOptionalColor({122, 163, 57})
		end
	end
)

addEventHandler("removeHouseBlip", root,
	function(id)
		 if HouseGUI.Blips[id] then
		 	delete(HouseGUI.Blips[id])
			HouseGUI.Blips[id] = nil
		end
	end
)
