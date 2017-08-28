ItemHolder = inherit(Object)
ItemHolder.Map = {}

function ItemHolder:new(...)
	local args = {...}
	if type(args[1]) == "table" then
		return new(ItemHolder, args[1].type, args[1].size, args[1].data)
	else
		return new(ItemHolder, ...)
	end
end

function ItemHolder:constructor(type, size, data)
	ItemHolder.Map[#ItemHolder.Map+1] = self

	self.m_Id = #ItemHolder.Map
	self.m_Type = type
	if self.m_Type == ITEM_HOLDER_TYPE_GEN_ITEM then
		self.m_Items = data
	elseif self.m_Type == ITEM_HOLDER_TYPE_WEAPONS then
		self.m_Weapons = data
	elseif self.m_Type == ITEM_HOLDER_TYPE_MONEY then
		self.m_Money = data
	end
	self.m_Object = false
	self.m_Size = size
end

function ItemHolder:destructor()

end

function ItemHolder:setOwner(owner)
	self.m_Owner = owner
end

function ItemHolder:addObject(object)
	self.m_Object = object
	setElementData(self.m_Object, "itemHolder", true)
	setElementData(self.m_Object, "holder_type", self.m_Type)
end

function ItemHolder:check()
	if self.m_Type ~= ITEM_HOLDER_TYPE_MONEY then
		return table.size(self.m_Items or self.m_Weapons or {}) < self.m_Size
	else
		return self.m_Money >= 0
	end
end

function ItemHolder:hasOwner()
	return self.m_Owner ~= nil and self.m_Owner ~= false
end

function ItemHolder:checkOwner(owner)
	return self.m_Owner == owner
end

function ItemHolder:add(item)
	if self.m_Type == ITEM_HOLDER_TYPE_MONEY then
		self.m_Money = self.m_Money + item
		return true
	else
		if self:check() then
			table.insert(self.m_Items or self.m_Weapons, item)
			return true
		end
	end

	return false
end

function ItemHolder:remove(item)
	if self.m_Type == ITEM_HOLDER_TYPE_MONEY then
		self.m_Money = self.m_Money - item
		return true
	else
		local idx = table.find(self.m_Items or self.m_Weapons, item)
		if idx then
			table.remove(self.m_Items or self.m_Weapons, idx)
			return true
		end
	end

	return false
end

function ItemHolder:getData()
	return (self.m_Money or self.m_Items or self.m_Weapons)
end

addEvent("itemHolder:getData", true)
addEventHandler("itemHolder:getData", root,
	function(Id, event)
		local itemHolder = ItemHolder.Map[Id]
		if itemHolder then
			if itemHolder:hasOwner() then
				if not itemHolder:checkOwner(client) then
					return false
				end
			end

			client:triggerEvent(event, itemHolder:getData())
		end
	end
)
