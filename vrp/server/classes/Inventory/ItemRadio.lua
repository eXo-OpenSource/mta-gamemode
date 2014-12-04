-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemRadio.lua
-- *  PURPOSE:     3dRadio item class
-- *
-- ****************************************************************************
ItemRadio = inherit(Item)
addEvent("itemRadioChangeURL", true)

function ItemRadio:constructor()
	
end

function ItemRadio:destructor()
	
end

function ItemRadio:use(inventory, player)
	local pos = player:getPosition()
	self.m_Radio = createObject(2226, pos.x+1, pos.y, pos.z, 0, 0, 0)
	self.m_Radio:setData("Owner", player:getId())
	
	addEventHandler("itemRadioChangeURL", self.m_Radio,
		function(url)
			setElementData(self.m_Radio, "url", url)
			triggerClientEvent("itemRadioChangeURL", self.m_Radio, url) -- send url twice so that we do not get in trouble with packet ordering
		end
	)
end
