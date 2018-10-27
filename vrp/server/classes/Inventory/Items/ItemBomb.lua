-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBomb.lua
-- *  PURPOSE:     C4 bomb item class
-- *
-- ****************************************************************************
ItemBomb = inherit(Item)

function ItemBomb:constructor()

end

function ItemBomb:destructor()

end

function ItemBomb:use(player)
	local bombArea = BombArea.findAt(player:getPosition())
	if bombArea then
		-- Report the crime
		player:reportCrime(Crime.PlacingBomb)

		-- TODO: Play place animation

		-- Fire (starts the countdown)
		bombArea:fire(player) --bomb gets removed there
		return true
	end

	player:sendError(_("Du kannst die Bombe hier nicht platzieren!", client))
	return false

	--[[if BankRobbery.onBombPlace(player) then
		-- Report the crime
	]]
end
