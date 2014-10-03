ItemHash = inherit(Item)

function ItemHash:constructor()

end

function ItemHash:destructor()

end

function ItemHash:use(inventory, player)
	setSkyGradient(200, 0, 100, 150, 0, 70)
	
	setTimer(function() if isElement(player) then resetSkyGradient() end end, 10*60*1000, 1)
end
