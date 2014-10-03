ItemHash = inherit(Item)

function ItemHash:constructor()

end

function ItemHash:destructor()

end

function ItemHash:use(inventory, player)
	-- SET MAX_HEALTH
	player:setStat(24, 1000)
	player:setHealth(1000)
	
	setTimer(function() if isElement(player) then player:setStat(24, 569) end end, 10*60*1000, 1)
end
