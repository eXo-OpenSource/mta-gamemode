WeedBeggar = inherit(BeggarPed)

function WeedBeggar:constructor()

end

function WeedBeggar:sellWeed(player, amount)
	if self.m_Despawning then return end
	if not player.vehicle then
		if self.m_Robber == player:getId() then return self:sendMessage(player, BeggarPhraseTypes.NoTrust) end
		if player:getInventoryOld():removeItem("Weed", amount) then
			player:giveCombinedReward("Bettler-Handel", {
				money = {
					mode = "give",
					bank = false,
					amount = amount*15,
					toOrFrom = self.m_BankAccountServer,
					category = "Gameplay",
					subcategory = "BeggarWeed"
				},
				karma = -math.ceil(amount/50),
				points = math.ceil(20 * amount/200),
			})
			player:meChat(true, ("übergibt %s %s"):format(self.m_Name, amount > 100 and "eine große Tüte" or "eine Tüte"))
			self:sendMessage(player, BeggarPhraseTypes.Thanks)
			-- Despawn the Beggar
			setTimer(
				function ()
					self:despawn()
				end, 50, 1
			)
		else
			player:sendError(_("Du hast nicht so viel Weed dabei!", player))
		end
	else
		self:sendMessage(player, BeggarPhraseTypes.InVehicle)
	end
end
