-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VendingMouseMenu.lua
-- *  PURPOSE:     Vending machine mouse menu class
-- *
-- ****************************************************************************
VendingMouseMenu = inherit(GUIMouseMenu)

function VendingMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically

	local snackString = ""
	if element:getModel() == 1775 then
		self:addItem(_"Sprunk-Automat"):setTextColor(Color.Red)
		snackString = "Getränk kaufen (20$)"
	elseif element:getModel() == 1776 then
		self:addItem(_"Süßigkeiten-Automat"):setTextColor(Color.Red)
		snackString = "Snack kaufen (20$)"
	elseif element:getModel() == 1209 then
		self:addItem(_"Soda-Automat"):setTextColor(Color.Red)
		snackString = "Getränk kaufen (20$)"
	end

	self:addItem(_(snackString),
		function()
			if self:getElement() then
				triggerServerEvent("vendingBuySnack", self:getElement())
			end
		end
	)
	self:addItem(_"Ausrauben",
		function()
			if self:getElement() then
				QuestionBox:new(_("Möchtest du wirklich den Automaten ausrauben? Du erhälst dafür 1 Wanted!"),
					function() 	triggerServerEvent("vendingRob", self:getElement()) end
				)
			end
		end
	)
end
