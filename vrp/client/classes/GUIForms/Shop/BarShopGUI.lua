-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/BarShopGUI.lua
-- *  PURPOSE:     Item shop GUI class
-- *
-- ****************************************************************************
BarShopGUI = inherit(GUIButtonMenu)
inherit(Singleton, BarShopGUI)

addRemoteEvents{"showBarGUI"}
function BarShopGUI:constructor(shopId, shopName, stripperPrice, stripperCount, isOwner, timeLeft, rangeElement)
	GUIButtonMenu.constructor(self, shopName, false, false, false, false, rangeElement)

	self:addItem(_("Shop öffnen"), Color.Accent, function()
		if ItemShopGUI:isInstantiated() then delete(ItemShopGUI:getSingleton()) end
			delete(self)
			local callback = function(shop, itemName, amount)
				triggerServerEvent("barBuyDrink", root, shop, itemName, amount)
			end
			ItemShopGUI:new(callback, shopName, rangeElement)
			triggerServerEvent("barRequestShopItems", localPlayer, shopId)
	end)
	self:addItem(_("Stripper engagieren"), Color.Accent, function()
		delete(self)
		local price
		
		if timeLeft then
			InfoBox:new(_("Die Stripper sind noch für %s Minuten bezahlt.", math.round(timeLeft / 1000 / 60, 1)))
		end

		if isOwner then
			price = stripperPrice / 2
			InfoBox:new(_"Da du in der Firma bist, zu dem die Bar gehört, zahlst du nur den Anteil an die Stripper.")
		else
			price = stripperPrice
		end

		InputBox:new(_("Stripper engagieren"), _("Für wie viel Minuten möchtest du die Stripper (%d Stripper) engagieren (%d$ pro Minute)", stripperCount, price * stripperCount), 
		function(minutes)
			if #minutes == 0 then return ErrorBox:new(_"Gib eine Zahl an.") end

			triggerServerEvent("barRentStrippers", localPlayer, shopId, tonumber(minutes))
		end, true)
	end)
end

addEventHandler("showBarGUI", root,
	function(shopId, name, price, count, isOwner, timeLeft, ped)
		BarShopGUI:new(shopId, name, price, count, isOwner, timeLeft, ped)
	end
)