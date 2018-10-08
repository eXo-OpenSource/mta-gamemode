ItemBeggar = inherit(BeggarPed)

function ItemBeggar:constructor()
end

function ItemBeggar:giveItem(player, item)
	if self.m_Despawning then return end
	if not player.vehicle then
		if self.m_Robber == player:getId() then return self:sendMessage(player, BeggarPhraseTypes.NoTrust) end
		if player:getInventory():getItemAmount(item) >= 1 then
			player:getInventory():removeItem(item, 1)
			player:giveCombinedReward("Bettler-Handel", {
				karma = 5,
				points = 5,
			})
			self:sendMessage(player, BeggarPhraseTypes.Thanks)
			player:meChat(true, ("übergibt %s eine Tüte"):format(self.m_Name))
			setTimer(
				function ()
					self:despawn()
				end, 50, 1
			)
		else
			player:sendError(_("Du hast kein/en %s dabei!", player, item))
		end
	else
		client:sendError(_("Steige zuerst aus deinem Fahrzeug aus!", client))
	end
end

function ItemBeggar:buyItem(player, item)
	if self.m_Despawning then return end
	if not BeggarItemBuy[item] then return end

	if not player.vehicle then
		if self.m_Robber == player:getId() then return self:sendMessage(player, BeggarPhraseTypes.NoTrust) end
		if player:getInventory():getFreePlacesForItem(item) >= BeggarItemBuy[item]["amount"] then
			local price = BeggarItemBuy[item]["amount"] * BeggarItemBuy[item]["pricePerAmount"]
			if player:getMoney() >= price then
				local karma = 5
				player:giveCombinedReward("Bettler-Handel", {
					money = {
						mode = "take",
						bank = false,
						amount = price,
						toOrFrom = self.m_BankAccountServer,
						category = "Gameplay",
						subcategory = "BeggarTrade"
					},
					karma = -5,
					points = 5,
				})
				player:getInventory():giveItem(item, BeggarItemBuy[item]["amount"])
				self:sendMessage(player, BeggarPhraseTypes.Thanks)
				player:meChat(true, ("erhält von %s eine Tüte!"):format(self.m_Name))
				setTimer(
					function ()
						self:despawn()
					end, 50, 1
				)
			else
				player:sendError(_("Du hast nicht genug Geld dabei! (%d$)", player, price, item))
			end
		else
			player:sendError(_("In deinem Inventar ist nicht genug Platz für %d %s!", player, BeggarItemBuy[item]["amount"], item))
		end
	else
		client:sendError(_("Steige zuerst aus deinem Fahrzeug aus!", client))
	end
end

function ItemBeggar:giveLoot(player)
	local item = BeggarItemBuyTypes[self.m_Type][math.random(1, #BeggarItemBuyTypes[self.m_Type])]
	local amount = math.floor(BeggarItemBuy[item]["amount"]/2)
	player:getInventory():giveItem(item, math.floor(BeggarItemBuy[item]["amount"]/2))
	player:sendInfo(_("Du hast %s %s von %s erhalten.", player, amount, item, self.m_Name))
end