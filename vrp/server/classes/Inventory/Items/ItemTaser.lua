-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemTaser.lua
-- *  PURPOSE:     Taser Item class
-- *
-- ****************************************************************************
ItemTaser = inherit(Item)

function ItemTaser:constructor()
	self.m_PlayerSecondWeapon = {}
end

function ItemTaser:destructor()

end

function ItemTaser:use(player)
	if player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
		local weapon = getPedWeapon(player, 2)
		local ammo = getPedTotalAmmo(player, 2)
		if weapon == 23 then
		 	player:takeWeapon(23)
			player:meChat(true, "steckt seinen Taser weg.")
			if self.m_PlayerSecondWeapon[player] then
				player:giveWeapon(unpack(self.m_PlayerSecondWeapon[player]))
				self.m_PlayerSecondWeapon[player] = nil
			end
		else
			player:giveWeapon(23, 9999)
			self.m_PlayerSecondWeapon[player] = {weapon, ammo}
			player:meChat(true, "zieht seinen Taser.")
		end
	else
		player:sendError(_("Du bist nicht berechtigt! Das Item wurde abgenommen!", player))
		player:getInventory():removeAllItem(self:getName())
	end
end
