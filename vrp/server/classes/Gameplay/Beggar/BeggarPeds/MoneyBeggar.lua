MoneyBeggar = inherit(BeggarPed)

function MoneyBeggar:constructor()
end

function MoneyBeggar:giveMoney(player, money)
	if self.m_Despawning then return end
	if not player.vehicle then
		if self.m_Robber == player:getId() then return self:sendMessage(player, BeggarPhraseTypes.NoTrust) end
		if player:getMoney() >= money then
			-- give wage
			local karma = math.min(money, 5)
			player:giveCombinedReward("Bettler-Geschenk", {
				money = -money,
				karma = karma,
				points = 1,
			})
			player:meChat(true, ("übergibt %s %s"):format(self.m_Name, money == 1 and "einen Schein" or "ein paar Scheine"))
			self:sendMessage(player, BeggarPhraseTypes.Thanks)

			-- give Achievement
			player:giveAchievement(56)
			if self.m_Name == BeggarNames[19] then
				player:giveAchievement(80)
			elseif self.m_Name == BeggarNames[32] then
				player:giveAchievement(81)
			end

			-- Despawn the Beggar
			setTimer(
				function ()
					self:despawn()
				end, 50, 1
			)
		else
			player:sendError(_("Du hast nicht soviel Geld dabei!", player))
		end
	else
		self:sendMessage(player, BeggarPhraseTypes.InVehicle)
	end
end


