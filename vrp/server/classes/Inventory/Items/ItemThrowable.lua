-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/ItemThrowable.lua
-- *  PURPOSE:     Throwable Item class
-- *
-- ****************************************************************************

ItemThrowable = inherit(ItemNew)

ItemThrowable.Data = {
    [1486] = { -- bottle
        CustomBound = { x = 1, y = 1, z = 1 },
        EntityOffset = { position = { x = 0, y = 0, z = 0 }, rotation = { x = 0, y = 0, z = 0 } },
        OffsetMatrix = { position = { x = 0, y = 0.05, z = 0.05 }, rotation = { x = 90, y = 180, z = 90 } }
    },
    
    [1265] = { --trash
        CustomBound = { x = 1, y = 1, z = 1 },
        EntityOffset = { position = { x = 0, y = 0, z = 0.08 }, rotation = { x = 0, y = 0, z = 0 } },
        OffsetMatrix = { position = { x = 0.14, y = 0, z = 0.29 }, rotation = { x = 0, y = 180, z = 0 } }
    },
    
    [1901] = { --shoe
        CustomBound = { x = 0.3, y = 0.05, z = 0.8 },
        EntityOffset = { position = { x = 0, y = 0.15, z = -0.2 }, rotation = { x = 0, y = 0, z = 0 } },
        OffsetMatrix = { position = { x = 0.25, y = 0.06, z = 0.32 }, rotation = { x = 0, y = 180, z = 270 } }
    }
}

function ItemThrowable:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end
	if Fishing:getSingleton():isPlayerFishing(player) then return player:sendError(_("Pack erst deine Angel weg!")) end
    outputChatBox("uiui " .. tostring(self:getModel()))
    outputConsole(inspect(self.m_ItemData))
    if not ItemThrowable.Data[self:getModel()] then outputChatBox("BRUH") return false end
    
    local data = ItemThrowable.Data[self:getModel()]

    if not player:getThrowingObject() then 
		player:meChat(true, "zieht eine Flasche.")
		player:sendInfo(_("Die Flasche ist bereit!", player))
		ThrowObject:new(player, self:getModel(), self:getModel(), data.OffsetMatrix)
			:setSkillBased(true)
			:setEntityOffsetMatrix(data.EntityOffset)
			:setCustomBoundingBox(data.CustomBound)
			:setDamage(0)
            :setThrowCallback(function() 
                player:getInventory():takeItem("Flasche", 1)
            end)
	else 
		if player:getThrowingObject():getModel() == self:getModel() then 
			player:getThrowingObject():delete()
			player:setThrowingObject(nil)
			player:meChat(true, "legt die Flasche weg.")
			player:sendInfo(_("Die Flasche wurde zurückgelegt!", player))
		end
    end
end
