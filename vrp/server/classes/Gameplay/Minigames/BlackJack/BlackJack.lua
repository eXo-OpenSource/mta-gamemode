-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Minigames/BlackJack/BlackJack.lua
-- *  PURPOSE:     BlackJack
-- *
-- ****************************************************************************

BlackJack = inherit(Object)
BlackJack.DEFAULT_BETS = {1000, 5000, 10000, 20000, 50000}

function BlackJack:constructor(player, object) 
	self.m_BankAccountServer = BankServer.get("gameplay.blackjack")
	self.m_Player = player 
	self.m_Spectators = {}	
	self.m_Bet = 0
	self.m_DealerHand = {}
	self.m_PlayerHand = {}
	self.m_Deck = BlackJackCards:new()
	self.m_Object = object
	self.m_Bets = object.bets

	player:triggerEvent("BlackJack:start", self.m_Bets, false, self.m_Object)
end

function BlackJack:destructor() 
	if isValidElement(self.m_Player, "player") then 
		self.m_Player:triggerEvent("BlackJack:cancel")
		self.m_Player:setFrozen(false)
	end
	for player, k in pairs(self.m_Spectators) do 
		if isValidElement(player, "player") then 
			player:setFrozen(false)
			player:triggerEvent("BlackJack:cancel")
		else 
			self.m_Spectators[player] = nil
		end
	end
	self:setTableBet(nil)
	if not self.m_Object.m_Info then
		self.m_Object.m_Info = ElementInfo:new(self.m_Object.infoObj, "Casino", .4, "DoubleDown", true)
	end
	self.m_Object.ped:setAnimation("casino", "cards_loop", -1, false, false, false, true)
	self.m_Deck:delete()
end

function BlackJack:start(bet)
	if not isValidElement(self.m_Player, "player") then return end
	if self.m_Bets[bet] then 
		self.m_Bet = self.m_Bets[bet]
	else 
		self.m_Bet = self.m_Bets[1]
	end
	if self.m_Player:transferMoney(self.m_BankAccountServer, self.m_Bet, "BlackJack-Einsatz", "Gameplay", "BlackJack", {silent = true}) then
		self.m_Player:setFrozen(true)
		for player, k in pairs(self.m_Spectators) do 
			if isValidElement(player, "player") then
				player:triggerEvent("BlackJack:notify", "")
			else 
				self.m_Spectators[player] = nil
			end
		end
		for player, k in pairs(self.m_Spectators) do 
			if isValidElement(player, "player") then
				player:triggerEvent("BlackJack:reset")
			else 
				self.m_Spectators[player] = nil
			end
		end
		self.m_PlayerValue = 0 
		self.m_DealerValue = 0
		self.m_DealerHand = {}
		self.m_PlayerHand = {}


		local sendDealerCards = {}	
		local sendPlayerCards = {}
		local card

		for i = 1, 2 do
			card = self.m_Deck:draw()
			self.m_DealerHand[#self.m_DealerHand+1] = card
			self.m_DealerValue = self:addValue(self.m_DealerValue, card)
			table.insert(sendDealerCards, card)
		end

		for i = 1, 2 do
			card = self.m_Deck:draw()
			self.m_PlayerHand[#self.m_PlayerHand+1] = card
			self.m_PlayerValue = self:addValue(self.m_PlayerValue, card)
			table.insert(sendPlayerCards, card)
		end
		self.m_Player:triggerEvent("BlackJack:draw", self.m_Bet, sendDealerCards, sendPlayerCards, true, self.m_PlayerValue, self.m_DealerValue, self.m_DealerHand[1].Value)
		for player, k in pairs(self.m_Spectators) do 
			if isValidElement(player, "player") then
				player:triggerEvent("BlackJack:draw", self.m_Bet, sendDealerCards, sendPlayerCards, true, self.m_PlayerValue, self.m_DealerValue, self.m_DealerHand[1].Value)
			else 
				self.m_Spectators[player] = nil
			end
		end
		self:setTableBet(self.m_Bet)
		if self.m_Object.m_Info then 
			self.m_Object.m_Info:delete()
			self.m_Object.m_Info = nil
		end 
	else 
		self.m_Player:sendError(_("Du hast nicht genügend Geld für den Einsatz!", self.m_Player))
		self.m_Player:triggerEvent("BlackJack:start", self.m_Bets, false, self.m_Object)
		self.m_Player:setFrozen(true)
	end
end

function BlackJack:stand() 
	if not self.m_DealerHitting and not self.m_Pause then 
		if isValidElement(self.m_Player, "player") then
			self.m_DealerHitting = true 

			local sendDealerCards = {}
			local sendPlayerCards = {}
			local card
			local compare = false

			for i = 1, #self.m_Deck.m_Cards do -- we could use while(true) but beeing paranoid we rely on a different method to ensure an infinite loop in the sense of the game
				if self.m_DealerValue > self.m_PlayerValue then 
					compare = true
					break
				end
				if self.m_DealerValue < 17 then
					card = self.m_Deck:draw()
					if card then

						self.m_DealerHand[#self.m_DealerHand+1] = card
						table.insert(sendDealerCards, card)
						self.m_DealerValue = self:addValue(self.m_DealerValue, card)

						if self.m_DealerValue >= 17 and self.m_DealerValue < 22 then
							compare = true
							break
						elseif self.m_DealerValue > 21 then 
							compare = false
							break
						end
					end
				else 
					compare = true 
					break
				end
			end

			self.m_Player:triggerEvent("BlackJack:draw", self.m_Bet, sendDealerCards, sendPlayerCards, false, self.m_PlayerValue, self.m_DealerValue)
			for player, k in pairs(self.m_Spectators) do 
				if isValidElement(player, "player") then
					player:triggerEvent("BlackJack:draw", self.m_Bet, sendDealerCards, sendPlayerCards, false, self.m_PlayerValue, self.m_DealerValue)
				else 
					self.m_Spectators[player] = nil
				end
			end
			if compare then 
				self:compare()
			else 
				if self.m_PlayerValue ~= self.m_DealerValue then
					if self.m_PlayerValue < 21 then
						self:playerWin(true)
					else 
						self:playerBlackJack()
					end
				else 
					self:tie()
				end
			end
		end
	end
end

function BlackJack:compare() 
	if self.m_PlayerValue > self.m_DealerValue then 	
		if self.m_PlayerValue == 21 then 
			self:playerBlackJack()
		else 
			self:playerWin() 
		end
	elseif self.m_PlayerValue == self.m_DealerValue then 
		self:tie()
	else
		self:playerLose()
	end
end

function BlackJack:reset(bet)
	if self.m_Pause then
		self.m_PlayerValue = 0 
		self.m_DealerValue = 0

		self.m_Pause = false 
		self.m_PostFirstRound = false
		self.m_DealerHitting = false
		self.m_InsuranceWon = false	

		if self.m_Deck then 
			self.m_Deck:delete()
		end
	
		self.m_Deck = BlackJackCards:new()
		self:start(bet)
	end
end

function BlackJack:spectate(spectator)
	if not isValidElement(self.m_Player, "player") then return end
	if not self.m_Spectators[spectator] then 
		self.m_Spectators[spectator] = true
		spectator:triggerEvent("BlackJack:start", self.m_Bets, self.m_Player, self.m_Object)
		spectator:setFrozen(true)
		spectator.m_BlackJackSpectate = self
		self.m_Player:triggerEvent("BlackJack:updateSpectator", self.m_Spectators)
		for player, k in pairs(self.m_Spectators) do 
			if isValidElement(player, "player") then
				player:triggerEvent("BlackJack:updateSpectator", self.m_Spectators)
			else 
				self.m_Spectators[player] = nil
			end
		end
		
		if not self.m_PostFirstRound then 
			spectator:triggerEvent("BlackJack:draw", self.m_Bet, self.m_DealerHand, self.m_PlayerHand, true, self.m_PlayerValue, self.m_DealerValue, self.m_DealerHand[1] and self.m_DealerHand[1].Value or 0)
		else 
			spectator:triggerEvent("BlackJack:draw", self.m_Bet, self.m_DealerHand, self.m_PlayerHand, false, self.m_PlayerValue, self.m_DealerValue)
		end
	end
end

function BlackJack:stopSpectate(spectator)
	if self.m_Spectators[spectator] then 
		spectator:triggerEvent("BlackJack:cancel")
		spectator:setFrozen(false)
		self.m_Spectators[spectator] = nil
		spectator.m_BlackJackSpectate = nil
		self.m_Player:triggerEvent("BlackJack:updateSpectator", self.m_Spectators)
		for player, k in pairs(self.m_Spectators) do 
			if isValidElement(player, "player") then
				player:triggerEvent("BlackJack:updateSpectator", self.m_Spectators)
			else 
				self.m_Spectators[player] = nil
			end
		end
	end
end

function BlackJack:insurance() 
	if isValidElement(self.m_Player, "player") then
		if not self.m_PostFirstRound then 
			if self.m_Player:transferMoney(self.m_BankAccountServer, self.m_Bet*0.5, "BlackJack-Einsatz (Insurance)", "Gameplay", "BlackJack", {silent = false}) then
				if (tonumber(self.m_DealerHand[1].Value) == 1 or tonumber(self.m_DealerHand[1].Value) >= 10) and (tonumber(self.m_DealerHand[2].Value) >= 10 or tonumber(self.m_DealerHand[2].Value) == 1) then 
					self.m_InsuranceWon = true
				end
				self.m_Player:triggerEvent("BlackJack:insurance")
			else 
				self.m_Player:sendError(_("Du hast nicht genügend Geld für die Insurance!", self.m_Player))
			end
		end
	end
end

function BlackJack:playerBust() 
	self.m_Pause = true
	if isValidElement(self.m_Player, "player") then 
		self.m_Player:triggerEvent("BlackJack:notify", "Du bist über 21! Bust!", false, true)
	end
	for player, k in pairs(self.m_Spectators) do 
		if isValidElement(player, "player") then
			player:triggerEvent("BlackJack:notify", "Spieler ist über 21! Bust!", false, true)
		else 
			self.m_Spectators[player] = nil
		end
	end
end

function BlackJack:playerBlackJack() 
	self.m_Pause = true
	if isValidElement(self.m_Player, "player") then 
		self.m_Player:triggerEvent("BlackJack:notify", "Du hast genau 21! Blackjack!", true)
		self.m_BankAccountServer:transferMoney(self.m_Player, self.m_Bet*2.5, "BlackJack-Gewinn (BlackJack 2:3)", "Gameplay", "BlackJack", {silent = false})
	end
	for player, k in pairs(self.m_Spectators) do 
		if isValidElement(player, "player") then
			player:triggerEvent("BlackJack:notify", "Spieler hat genau 21! Blackjack!", true)
		else 
			self.m_Spectators[player] = nil
		end
	end
end

function BlackJack:playerWin(dealerBust) 
	self.m_Pause = true
	if isValidElement(self.m_Player, "player") then 
		self.m_Player:triggerEvent("BlackJack:notify", dealerBust and "Der Dealer ist über 21! Sieg!" or "Du hast mehr als der Dealer! Sieg!", true)
		self.m_BankAccountServer:transferMoney(self.m_Player, self.m_Bet*2, "BlackJack-Gewinn (Regulär 1:2)", "Gameplay", "BlackJack", {silent = false})
	end
	for player, k in pairs(self.m_Spectators) do 
		if isValidElement(player, "player") then
			player:triggerEvent("BlackJack:notify", dealerBust and "Der Dealer ist über 21! Sieg!" or "Spieler hat mehr als der Dealer! Sieg!", true)
		else 
			self.m_Spectators[player] = nil
		end
	end
end

function BlackJack:playerLose()
	self.m_Pause = true
	if isValidElement(self.m_Player, "player") then 
		if not self.m_InsuranceWon then
			self.m_Player:triggerEvent("BlackJack:notify", "Du hast weniger als der Dealer! Verloren!")
			for player, k in pairs(self.m_Spectators) do 
				if isValidElement(player, "player") then
					player:triggerEvent("BlackJack:notify", "Dealer hat mehr als Spieler! Verloren!")
				else 
					self.m_Spectators[player] = nil
				end
			end
		else 
			self.m_Player:triggerEvent("BlackJack:notify", "Du hast die Insurance-Wette gewonnen!")
			for player, k in pairs(self.m_Spectators) do 
				if isValidElement(player, "player") then
					player:triggerEvent("BlackJack:notify", "Insurance-Wette gewonnen!")
				else 
					self.m_Spectators[player] = nil
				end
			end
			self.m_BankAccountServer:transferMoney(self.m_Player, self.m_Bet, "BlackJack-Insurance (3:2)", "Gameplay", "BlackJack", {silent = false})
		end
	end
end

function BlackJack:tie() 
	self.m_Pause = true
	if isValidElement(self.m_Player, "player") then 
		self.m_Player:triggerEvent("BlackJack:notify", "Du hast genau so viel wie der Dealer! Unentschieden!")
		for player, k in pairs(self.m_Spectators) do 
			if isValidElement(player, "player") then
				player:triggerEvent("BlackJack:notify", "Unentschieden!")
			else 
				self.m_Spectators[player] = nil
			end
		end
		self.m_BankAccountServer:transferMoney(self.m_Player, self.m_Bet, "BlackJack-Rückzahlung (Unentschieden)", "Gameplay", "BlackJack", {silent = false})
	end
end

function BlackJack:hit() 
	if not self.m_Pause and not self.m_DealerHitting then
		self.m_PostFirstRound = true
		local sendDealerCards = {}
		local sendPlayerCards = {}
		local card

		card = self.m_Deck:draw()
		self.m_PlayerHand[#self.m_PlayerHand+1] = card
		table.insert(sendPlayerCards, card)
		self.m_PlayerValue = self:addValue(self.m_PlayerValue, card)
		self.m_Player:triggerEvent("BlackJack:draw", self.m_Bet, sendDealerCards, sendPlayerCards, false, self.m_PlayerValue, self.m_DealerValue)
		for player, k in pairs(self.m_Spectators) do 
			if isValidElement(player, "player") then
				player:triggerEvent("BlackJack:draw", self.m_Bet, sendDealerCards, sendPlayerCards, false, self.m_PlayerValue, self.m_DealerValue)
			else 
				self.m_Spectators[player] = nil
			end
		end
		if self.m_PlayerValue > 21 then 
			self:playerBust()
		end
	end
end

function BlackJack:setTableBet(bet)
	self.m_Object:setData("BlackJack:TableBet", bet, true)
end

function BlackJack:addValue(element, card)
	if element then 
		local value = tonumber(card.Value) 
		if value == 1 then 
			if element + 11 > 21 then 
				element = element + 1
			else 
				element = element + 11 
			end	
		elseif value > 10 then 
			element = element + 10 
		else 
			element = element + value
		end
		return element
	end
end
