-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBarricade.lua
-- *  PURPOSE:     Barricade item class
-- *
-- ****************************************************************************
ItemBarricade = inherit(Item)

function ItemBarricade:constructor( )

end

function ItemBarricade:destructor()

end

function ItemBarricade:use(player)
	if player:isFactionDuty() then
		local result = self:startObjectPlacing(player,
			function(item, position, rotation)
				if item ~= self then return end
				if (position - player:getPosition()).length > 20 then
					player:sendError(_("Du musst in der Nähe der Zielposition sein!", player))
					return
				end
				
				self.m_WorldItem = self:place(player, position, rotation)
				--StatisticsLogger:getSingleton():itemPlaceLogs( player, "Barrikade", position.x..","..position.y..","..position.z ) --// disabled to prevent possible spam 
				self.m_WorldItem.m_Breakable = self.m_Breakable
				player:getInventory():removeItem(self:getName(), 1)
			end
		)
	else
		player:sendError(_("Du bist nicht im Dienst!", player))
		player:getInventory():removeAllItem(self:getName())
	end
end

function ItemBarricade:onClick(player, worldItem)
	if worldItem:collect(player) then
		player:sendShortMessage(_("Barrikade eingesammelt.", player))
	end
end

function ItemBarricade:isCollectAllowed(player, worldItem)
	if player:isFactionDuty() then return true end
	if player:getFaction():isStateFaction() then player:sendError(_("Du bist nicht im Dienst!", player)) end --to prevent spam for non-cop players
	return false
end