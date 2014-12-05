-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemRadio.lua
-- *  PURPOSE:     3dRadio item class
-- *
-- ****************************************************************************
ItemRadio = inherit(DroppableItem)
addEvent("itemRadioChangeURL", true)

function ItemRadio:constructor()
	
end

function ItemRadio:destructor()
	
end

function ItemRadio:use(inventory, player, slot)
	local pos = player:getPosition()
	--self.m_Radio = createObject(2226, pos.x+1, pos.y, pos.z, 0, 0, 0)
	--setElementData(self.m_Radio, "Owner", player:getId())
	local worldItem = inventory:dropItem(self, slot, player, player.position + Vector3(2, 0, 0))
	
	addEventHandler("itemRadioChangeURL", worldItem:getObject(),
		function(url)
			setElementData(source, "url", url)
			triggerClientEvent("itemRadioChangeURL", source, url) -- send url twice so that we do not get in trouble with packet ordering
		end
	)
end

function ItemRadio:getModelId()
	return 2226
end

function ItemRadio:onClick(player, worldItem)
	if worldItem:getOwner() == player then
		-- TODO: It might be better to do this clientside to avoid the relay
		-- TODO: Also it might be better to generalise this API a bit (there are probably lots of items which use item mouse menus)
		triggerClientEvent(player, "itemRadioMenu", worldItem:getObject())
	else
		player:sendError(_("Du hast keine Befugnisse dieses Item zu nutzen!", player))
	end
end
