-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Minigames/BlackJack/BlackJack.lua
-- *  PURPOSE:     BlackJack
-- *
-- ****************************************************************************

BlackJack = inherit(Object)

function BlackJack:constructor(player) 
	self.m_Player = player 
	self.m_Spectators = {}


	self.m_Deck = BlackJackCards:new()
	
	player:triggerEvent("BlackJack:start")
end

function BlackJack:destructor() 
	if isValidElement(self.m_Player, "player") then 
		self.m_Player:triggerEvent("BlackJack:cancel")
	end
	self.m_Deck:delete()
end

function BlackJack:start()
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
	self.m_Player:triggerEvent("BlackJack:draw", sendDealerCards, sendPlayerCards, true, self.m_PlayerValue, self.m_DealerValue, self.m_DealerHand[1].Value)
	for player, k in pairs(self.m_Spectators) do 
		player:triggerEvent("BlackJack:draw", sendDealerCards, sendPlayerCards, true, self.m_PlayerValue, self.m_DealerValue, self.m_DealerHand[1].Value)
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
				end
			end

			self.m_Player:triggerEvent("BlackJack:draw", sendDealerCards, sendPlayerCards, false, self.m_PlayerValue, self.m_DealerValue)
			for player, k in pairs(self.m_Spectators) do 
				player:triggerEvent("BlackJack:draw", sendDealerCards, sendPlayerCards, false, self.m_PlayerValue, self.m_DealerValue)
			end
			if compare then 
				self:compare()
			else 
				self:playerWin(true)
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

function BlackJack:reset()
	if self.m_Pause then
		self.m_PlayerValue = 0 
		self.m_DealerValue = 0
		self.m_Pause = false 
		self.m_DealerHitting = false	

		if self.m_Deck then 
			self.m_Deck:delete()
		end
	
		self.m_Deck = BlackJackCards:new()
		self:start()
	end
end

function BlackJack:playerBust() 
	self.m_Pause = true
	if isValidElement(self.m_Player, "player") then 
		self.m_Player:triggerEvent("BlackJack:notify", "Du bist über 21! Bust!", false, true)
	end
end

function BlackJack:playerBlackJack() 
	self.m_Pause = true
	if isValidElement(self.m_Player, "player") then 
		self.m_Player:triggerEvent("BlackJack:notify", "Du hast genau 21! Blackjack!", true)
	end
end

function BlackJack:playerWin(dealerBust) 
	self.m_Pause = true
	if isValidElement(self.m_Player, "player") then 
		self.m_Player:triggerEvent("BlackJack:notify", dealerBust and "Der Dealer ist über 21! Sieg!" or "Du hast mehr als der Dealer! Sieg!", true)
	end
end

function BlackJack:playerLose()
	self.m_Pause = true
	if isValidElement(self.m_Player, "player") then 
		self.m_Player:triggerEvent("BlackJack:notify", "Du hast weniger als der Dealer! Verloren!")
	end
end

function BlackJack:tie() 
	self.m_Pause = true
	if isValidElement(self.m_Player, "player") then 
		self.m_Player:triggerEvent("BlackJack:notify", "Du hast genau so viel wie der Dealer! Unentschieden!")
	end
end

function BlackJack:hit() 
	if not self.m_Pause and not self.m_DealerHitting then
		local sendDealerCards = {}
		local sendPlayerCards = {}
		local card

		card = self.m_Deck:draw()
		self.m_PlayerHand[#self.m_PlayerHand+1] = card
		table.insert(sendPlayerCards, card)
		self.m_PlayerValue = self:addValue(self.m_PlayerValue, card)
		self.m_Player:triggerEvent("BlackJack:draw", sendDealerCards, sendPlayerCards, false, self.m_PlayerValue, self.m_DealerValue)
		for player, k in pairs(self.m_Spectators) do 
			player:triggerEvent("BlackJack:draw", sendDealerCards, sendPlayerCards, false, self.m_PlayerValue, self.m_DealerValue)
		end
		if self.m_PlayerValue > 21 then 
			self:playerBust()
		end
	end
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