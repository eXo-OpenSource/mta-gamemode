-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Minigames/BlackJack/BlackJackCards.lua
-- *  PURPOSE:     BlackJackCards
-- *
-- ****************************************************************************

local suits = {"h", "d", "c", "s"}
BlackJackCards = inherit(Object)



function BlackJackCards:constructor() 
	cards = {}
	local values = {}
	for i = 1, 13 do 
	    table.insert(values, ("%02d"):format(i))
	end
	numericalindex = 0
	for k, suit in ipairs(suits) do 
	    for index, value in ipairs(values) do 
	        numericalindex = numericalindex + 1
			cards[numericalindex] = {Suit = suit, Value = value}  
	    end
	end
	cards = fisherYatesShuffle(cards)
	self.m_Cards = cards
end

function BlackJackCards:draw() 
	local card, index =  math.randomchoice(self.m_Cards) 
	table.remove(self.m_Cards, index)
	return card
end

function BlackJackCards:destructor() 

end

