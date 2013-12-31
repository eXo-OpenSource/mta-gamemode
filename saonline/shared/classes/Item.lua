-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Item.lua
-- *  PURPOSE:     Item class
-- *
-- ****************************************************************************
Item = inherit(Object)

function Item:constructor(itemid, iteminfo)
	assert(itemid)
	assert(Items[itemid])
	self.m_ItemId = itemid
	self.m_Count = 1
end

function Item:getItemId()
	return self.m_ItemId
end

function Item:getCount()
	return self.m_Count
end