BuyItemBeggar = inherit(BeggarPed)

function BuyItemBeggar:constructor()
end

function BuyItemBeggar:giveItem(player, item)
	if self.m_Despawning then return end
	if not player.vehicle then
		if self.m_Robber == player:getId() then return self:sendMessage(player, BeggarPhraseTypes.NoTrust) end
		local name = ItemManager.get(item).Name

		if player:getInventory():getItemAmount(item) >= 1 then
			player:getInventory():takeItem(item, 1)
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
			player:sendError(_("Du hast kein/en %s dabei!", player, name))
		end
	else
		client:sendError(_("Steige zuerst aus deinem Fahrzeug aus!", client))
	end
end
