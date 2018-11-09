-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ArmsDealerGUI.lua
-- *  PURPOSE:     Arrest GUI class
-- *
-- ****************************************************************************
ArmsDealerGUI = inherit(GUIForm)
inherit(Singleton, ArmsDealerGUI)

addRemoteEvents{"updateArmsDealerInfo"}
function ArmsDealerGUI:constructor( )
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 15)	
	self.m_Height = grid("y", 10)
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Waffenhandel", true, true, self)
	self.m_WeaponCategories = GUIGridChanger:new(1, 2, 8, 1, self.m_Window)
	self.m_WeaponCategories.onChange = function(name) self.m_CurrentCategory = name; self:updateGridList(name)  end

	GUIGridRectangle:new(10, 2, 5, 1, Color.Grey, self.m_Window)
	self.m_ShopInfoLabel = GUIGridLabel:new(10.1, 2, 4, 1, ("Diamanten:  %s"):format(0), self.m_Window)
	
	
	self.m_Grid = GUIGridGridList:new(1, 3, 14, 6, self.m_Window)
	self.m_Grid:addColumn(_"Waffen", 0.5)
	self.m_Grid:addColumn(_"Stück", 0.2)	
	self.m_Grid:addColumn(_"Preis", 0.2)
	self.m_Grid:addColumn(_"✘", 0.1)

	self.m_SelectButton = GUIGridButton:new(1, 9, 4, 1, "Auswählen", self.m_Window)
	self.m_SelectButton.onLeftClick = function() self:addCart() end
	self.m_EmptyButton = GUIGridButton:new(5, 9, 3, 1, "Leeren", self.m_Window)
	self.m_EmptyButton.onLeftClick = function() self:clearCart() end

	GUIGridRectangle:new(8, 9, 6, 1, Color.Grey, self.m_Window)
	self.m_PriceLabel = GUIGridLabel:new(8, 9, 6, 1, ("Preis: %s$"):format(0), self.m_Window):setAlignX("center")
	self.m_IconButton = GUIGridIconButton:new(14, 9, FontAwesomeSymbols.Cart, self.m_Window):setTooltip("Waren kaufen", "bottom"):setBackgroundColor(Color.Green)
	self.m_IconButton.onLeftClick = function() self:checkoutCart() end
	GUIGridRectangle:new(1, 10, 11, 1, Color.Grey, self.m_Window)
	self.m_TemplateInfoLabel = GUIGridLabel:new(1, 10, 11, 1, "Vorlage #", self.m_Window):setAlignX("center")

	triggerServerEvent("requestArmsDealerInfo", localPlayer)
	addEventHandler("updateArmsDealerInfo", localPlayer, bind(self.Event_onGetInfo, self))
end

function ArmsDealerGUI:Event_onGetInfo(data, validWeapons, weaponDepotInfo, weaponTable)
	if data then 
		self.m_Data = data
		self.m_ValidWeapons = validWeapons
		self.m_WeaponsMax = weaponDepotInfo
		self.m_WeaponDepot = weaponTable

		self.m_Cart = {}
		local first
		for category, subdata in pairs(data) do 
			if not first then first = category end
			self.m_WeaponCategories:addItem(category)	
		end
		self:updateGridList(first)
	end
end

function ArmsDealerGUI:updateGridList(category)
	if self.m_Data[category] then 
		self.m_Grid:clear()
		self.m_GridItems = {}
		local item, maxPrice, maxAmount
		for product, data in pairs(self.m_Data[category]) do 
			if category ~= "Waffen" then
				item = self.m_Grid:addItem(product, data[1], data[2], self.m_Cart[product] and "✘" or "")
				item.m_Name = product
				item.m_Data = data
				item.onLeftClick = function(itm) self.m_SelectedItem = itm end
			else 

				if tonumber(product) > 0 then	
					--//WEAPON
					maxAmount = self.m_WeaponsMax[tonumber(product)]["Waffe"] or 0
					maxPrice = maxAmount * self.m_WeaponsMax[tonumber(product)]["WaffenPreis"]
					item = self.m_Grid:addItem(("Waffenpaket: %s"):format(WEAPON_NAMES[product]), ("Max. %s"):format(maxAmount), ("Max. %s"):format(maxPrice), self.m_Cart[product] and "✘" or "")
					item.m_Name = product
					item.m_Type = "weapon"
					item.m_Data = {1, maxPrice, "weapon"}
					item.onLeftClick = function(itm) self.m_SelectedItem = itm end

					--//AMMO
					maxAmount = self.m_WeaponsMax[tonumber(product)]["Magazine"] or 0
					maxPrice = maxAmount * self.m_WeaponsMax[tonumber(product)]["MagazinPreis"]
					if maxPrice > 0 then
						item = self.m_Grid:addItem(("Munitionspaket: %s"):format(WEAPON_NAMES[product]), ("Max. %s"):format(maxAmount), ("Max. %s"):format(maxPrice), self.m_Cart[("%s-Magazin"):format(product)] and "✘" or "")
						item.m_Name = ("%s-Magazin"):format(product)
						item.m_Data = {1, maxPrice, "ammo"}
						item.onLeftClick = function(itm) self.m_SelectedItem = itm end
					end
				end
			end
		end
	end
end

function ArmsDealerGUI:addCart()
	if self.m_SelectedItem then 
		local product, data, type = self.m_SelectedItem.m_Name, self.m_SelectedItem.m_Data
		if not self.m_Cart[product] then 
			self.m_Cart[product] = data
			self.m_SelectedItem:setColumnText(4, "✘")
		end
	end
	self:updateCart()
end

function ArmsDealerGUI:clearCart()
	self.m_Cart = {}
	self:updateCart()
	self:updateGridList(self.m_CurrentCategory)
end

function ArmsDealerGUI:updateCart()
	local price = 0
	for product, subdata in pairs(self.m_Cart) do 
		price = price + subdata[2]
	end
	self.m_Price = price
	self.m_PriceLabel:setText(("Preis: %s$"):format(price))
end

function ArmsDealerGUI:checkoutCart() 
	if self.m_Price > 0 then
		QuestionBox:new(
			_("Bist du sicher, dass du die folgende Summe zahlen willst: $%s ?", self.m_Price),
			function()  end
		)
	end
end


function ArmsDealerGUI:destructor() 
	GUIForm.destructor(self)
end