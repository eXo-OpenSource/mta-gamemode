ItemBomb = inherit(Item)

function ItemBomb:constructor()
	outputChatBox("HotwireKit has been added to a inventory")
end

function ItemBomb:destructor()
	outputChatBox("HotwireKit has been removed from a inventory")
end

function ItemBomb:use(inventory, player)
	if BankRobbery.onBombPlace(player) then
		-- Report the crime
		player:reportCrime(Crime.PlacingBomb)
		
		-- Todo: Play install animation
	else
		player:sendWarning(_("Du kannst die Bombe hier nicht platzieren!", client))
	end
end
