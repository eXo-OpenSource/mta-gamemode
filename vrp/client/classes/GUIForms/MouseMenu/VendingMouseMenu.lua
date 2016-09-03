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

	if element:getModel() == 1775 then
		self:addItem(_"Sprunk-Automat"):setTextColor(Color.Red)
	elseif element:getModel() == 1776 then
		self:addItem(_"Süßigkeiten-Automat"):setTextColor(Color.Red)
	elseif element:getModel() == 1209 then
		self:addItem(_"Soda-Automat"):setTextColor(Color.Red)
	end

	self:addItem(_"Snack/Getränk kaufen (20$)",
		function()
			if self:getElement() then
				triggerServerEvent("vendingBuySnack", self:getElement())
			end
		end
	)
	self:addItem(_"Ausrauben",
		function()
			if self:getElement() then
				triggerServerEvent("vendingRob", self:getElement())
			end
		end
	)
end
