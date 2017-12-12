-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Wearables/WearableShirt.lua
-- *  PURPOSE:     Wearable Clotes
-- *
-- ****************************************************************************
WearableClothes = inherit( Item )

function WearableClothes:constructor()
	self.m_CustomClothes = { }
end

function WearableClothes:destructor()

end

function WearableClothes:use(player, itemId, bag, place, itemName)
	local inventory = player:getInventory()
	local value = inventory:getItemValueByBag( bag, place)
	if value then
		local skinID = tonumber(gettok(value, 1, "+"))
		if skinID then
			if not player:isFactionDuty() then
				player:setSkin(skinID)
				self:checkForCustomClothes( player, value ) 
				player:meChat(true, "wechselt seine Kleidung.")
			else
				player:sendError(_("Du kannst im Dienst nicht deine Kleidung wechseln!", player))
			end
		end
	end
end

function WearableClothes:checkForCustomClothes( player, value ) 
	if value then 
		local skinID = tonumber(gettok(value, 1, "+"))
		local texturePath = gettok(value, 2, "+")
		local customURL = gettok(value, 3, "+")
		if skinID and texturePath and customURL then 
			if self.m_CustomClothes[player] then delete(self.m_CustomClothes[player]) end
			self.m_CustomClothes[player] = PlayerTexture:new(player, customURL, texturePath, true, false, false)
		end
	end
end
