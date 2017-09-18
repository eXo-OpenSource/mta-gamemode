-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/PlayerMouseMenu.lua
-- *  PURPOSE:     Player mouse menu class
-- *
-- ****************************************************************************
BeggarPedMouseMenu = inherit(GUIMouseMenu)

function BeggarPedMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically

	self:addItem(("%s (Obdachloser)"):format(element:getData("BeggarName"))):setTextColor(Color.Orange)

	if element:getData("BeggarType") == BeggarTypes.Money then
		self:addItem("Geld geben",
			function ()
				SendMoneyGUI:new(
					function (amount)
						triggerServerEvent("giveBeggarPedMoney", self:getElement(), amount)
					end
				)
			end
		)
	elseif element:getData("BeggarType") == BeggarTypes.Food then
		self:addItem("Burger geben",
			function ()
				triggerServerEvent("giveBeggarItem", self:getElement(), "Burger")
			end
		)
	elseif element:getData("BeggarType") == BeggarTypes.Heroin then


		self:addItem("5g Heroin kaufen",
			function ()
				QuestionBox:new(
					_("Möchtest du 5g Heroin für 150$ kaufen?"),
					function ()
						triggerServerEvent("buyBeggarItem", self:getElement(), "Heroin")
					end
				)
			end
		)
	elseif element:getData("BeggarType") == BeggarTypes.Weed then

		self:addItem("Weed verkaufen",
			function ()
				InputBox:new("Weed verkaufen", "Wieviel Weed möchtest du verkaufen?",
					function (amount)
						if tonumber(amount) and tonumber(amount) > 0 and tonumber(amount) <= 200 then
							triggerServerEvent("sellBeggarWeed", self:getElement(), tonumber(amount))
						else
							outputChatBox(_("%s (Obdachloser): Mehr als 200g Weed kann ich mir nicht leisten!", element:getData("BeggarName")))
						end
					end, true)
			end
		)
	elseif element:getData("BeggarType") == BeggarTypes.Transport then
		self:addItem("Obdachlosen transportieren",
			function ()
				triggerServerEvent("acceptTransport", self:getElement())
			end
		)
	end

	self:addItem("Ausrauben",
		function ()
			triggerServerEvent("robBeggarPed", self:getElement())
		end
	)
	self:adjustWidth()
end
