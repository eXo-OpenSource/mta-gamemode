-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Inventory.lua
-- *  PURPOSE:     Inventory - Class
-- *
-- ****************************************************************************
Inventory = inherit(Object)

function Inventory:constructor(owner, inventorySlots, itemData, classItems)
	self.m_InventorySlots = inventorySlots
	self.m_ItemData = itemData
	self.m_Owner = owner
	self.m_Bag = {}
	self.m_Items = {}
	self.m_ClassItems = classItems

	self.m_Debug = false

	for k, v in pairs(inventorySlots) do
		self.m_Bag[k] = {}
	end

	local id, place

	local result = sql:queryFetch("SELECT * FROM ??_inventory_slots WHERE PlayerId = ?", sql:getPrefix(), self.m_Owner:getId())
	for i, row in ipairs(result) do
		if tonumber(row["Menge"]) > 0 then
			id = tonumber(row["id"])
			place = tonumber(row["Platz"])
			self.m_Items[id] = {}
			self.m_Items[id]["Objekt"] = row["Objekt"]
			self.m_Items[id]["Menge"] = tonumber(row["Menge"])
			self.m_Items[id]["Platz"] = place
			self.m_Items[id]["Value"] = row["Value"] or ""
			self.m_Bag[row["Tasche"]][place] = id
			if self:isSpecialItem(row["Objekt"]) then
				local row_special = sql:queryFetchSingle("SELECT * FROM ??_inventory_items_special WHERE Item = ? AND PlayerId = ?", sql:getPrefix(), row["Objekt"], self.m_Owner:getId())
				if row_special then
					self.m_Items[id]["Special"] = row_special.Value
				end
				if row["Objekt"] == "Mautpass" then
					if row_special and tonumber(row_special.Value) > getRealTime().timestamp then
					else
						self:removeAllItem("Mautpass")
						if isElement(self.m_Owner) then
							self.m_Owner:sendMessage(_("Dein Mautpass ist abgelaufen und wurde entfernt!", self.m_Owner), 255, 0, 0)
						end
						sql:queryExec("DELETE FROM ??_inventory_items_special WHERE Id = ?", sql:getPrefix(), row_special.ID)
					end
				end
			end
		else
			removeItemFromPlace(row["Tasche"], tonumber(row["Platz"]))
		end
	end

	triggerClientEvent(self.m_Owner, "loadPlayerInventarClient", self.m_Owner, self.m_InventorySlots, self.m_ItemData)
	self:syncClient()
end

function Inventory:destructor()
	self.m_Items = nil
	self.m_Bag = nil
	InventoryManager:getSingleton():deleteInventory(self.m_Owner)
end

function Inventory:syncClient()
	if not self.m_Owner.m_Disconnecting then
		self.m_Owner:triggerEvent( "syncInventoryFromServer", self.m_Bag, self.m_Items,self.m_ItemData)
	end
end

function Inventory:forceRefresh()
	self.m_Owner:triggerEvent( "forceInventoryRefresh", self.m_Bag, self.m_Items,self.m_ItemData)
end

function Inventory:isSpecialItem(item)
	if ItemManager:getSingleton().m_SpecialItems[item] == true then
		return true
	end
	return false
end

function Inventory:getSpecialItemData(item)
	if self.m_Items[self:getItemIdFromName(item)]["Special"] then return self.m_Items[self:getItemIdFromName(item)]["Special"] else return false end
end

function Inventory:setSpecialItemData(item, value)
	self.m_Items[self:getItemIdFromName(item)]["Special"] = value
	local row = sql:queryFetchSingle("SELECT * FROM ??_inventory_items_special WHERE Item = ? AND PlayerId = ?", sql:getPrefix(), item, self.m_Owner:getId())
	if not row then
		sql:queryExec("INSERT INTO ??_inventory_items_special (PlayerId, Item, Value) VALUES (?, ?, ?)", sql:getPrefix(), self.m_Owner:getId(), item, value)
	else
		sql:queryExec("UPDATE ??_inventory_items_special SET Value = ? WHERE Item = ? AND PlayerId = ?", sql:getPrefix(), value, item, self.m_Owner:getId())
	end
end

function Inventory:loadItem(id)
	local result = sql:queryFetch("SELECT * FROM ??_inventory_slots WHERE id = ?", sql:getPrefix(), id) -- ToDo add Prefix
	for i, row in ipairs(result) do
		if tonumber(row["Menge"]) > 0 then
			id = tonumber(row["id"])
			place = tonumber(row["Platz"])
			self.m_Items[id] = {}
			self.m_Items[id]["Objekt"] = row["Objekt"]
			self.m_Items[id]["Menge"] = tonumber(row["Menge"])
			self.m_Items[id]["Platz"] = place
			self.m_Items[id]["Value"] = row["Value"]
			self.m_Bag[row["Tasche"]][place] = id
		else
			removeItemFromPlace(row["Tasche"], tonumber(row["Platz"]))
		end
	end
	self:syncClient()
end

function Inventory:useItem(itemId, bag, itemName, place, delete)
	if self:getItemAmount(itemName) <= 0 then
		client:sendError(_("Inventar Fehler: Kein Item", client))
		return
	end

	if self.m_ItemData[itemName]["Verbraucht"] == 1 then
		self:removeItemFromPlace(bag, place, 1)
	end

	if self.m_ClassItems[itemName] then
		local instance = ItemManager.Map[itemName]
		if instance.use then
			if instance:use(client, itemId, bag, place, itemName ) == false then
				return false
			end
		end
	end
	if itemName == "Mautpass" then
		local id = self:getItemID(bag, place)
		if self.m_Items[id] and self.m_Items[id].Special then
			client:sendShortMessage(_("Dein Mautpass ist noch bis %s gültig!", client, getOpticalTimestamp(self.m_Items[id].Special)), "San Andreas Government")
		else
			client:sendShortMessage(_("Dein Mautpass ist abgelaufen!", client), "San Andreas Government")
			self:removeItemFromPlace(bag, place, 1)
		end
	end

	-- Possible issue: If Item:use fails, the item will never get removed


	--outputChatBox("Du benutzt das Item "..itemName.." aus der Tasche "..bag.."!", self.m_Owner, 0, 255, 0) -- in Developement
	self:syncClient()
end

function Inventory:useItemSecondary(itemId, bag, itemName, place)
	if self:getItemAmount(itemName) <= 0 then
		client:sendError(_("Inventar Fehler: Kein Item", client))
		return
	end

	if self.m_ClassItems[itemName] then
		local instance = ItemManager.Map[itemName]
		if instance.useSecondary then
			return instance:useSecondary(client, itemId, bag, place, itemName)
		end
	end
end

function Inventory:saveSpecialItem(id, amount)
	sql:queryExec("UPDATE ??_inventory_slots SET Menge = ?? WHERE id = ?", sql:getPrefix(), amount, id )
	self:syncClient()
end

function Inventory:saveItemAmount(id, amount)
	sql:queryExec("UPDATE ??_inventory_slots SET Menge = ?? WHERE id = ?", sql:getPrefix(), amount, id )
	self:syncClient()
end

function Inventory:saveItemPlace(id, place)
	sql:queryExec("UPDATE ??_inventory_slots SET Platz = ?? WHERE id = ?", sql:getPrefix(), place, id )
	self:syncClient()
end

function Inventory:saveItemValue(id, value)
	sql:queryExec("UPDATE ??_inventory_slots SET Value =? WHERE id = ?", sql:getPrefix(), value, id )
	self:syncClient()
end
function Inventory:deleteItem(id)
	sql:queryExec("DELETE FROM ??_inventory_slots WHERE id= ?", sql:getPrefix(), id )
	self:syncClient()
end

function Inventory:insertItem(amount, item, place, bag, value)
	sql:queryExec("INSERT INTO ??_inventory_slots (PlayerId, Menge, Objekt, Platz, Tasche, Value) VALUES (?, ?, ?, ?, ?, ?)", sql:getPrefix(), self.m_Owner:getId(), amount, item, place, bag, self:getItemValueByBag(bag,place) or "" ) -- ToDo add Prefix
	return sql:lastInsertId()
end

function Inventory:changePlaces(bag, oldPlace, newPlace)
	self:setItemPlace(bag, oldPlace, -1)
	self:setItemPlace(bag, newPlace, oldPlace)
	self:setItemPlace(bag, -1, newPlace)
end

function Inventory:isPlaceEmpty(bag, place)
	local id = self.m_Bag[bag][place]
	if self.m_Items[id] then
		if self.m_Items[id]["Objekt"] then
			return false
		else
			return true
		end
	else
		return true
	end
end

function Inventory:getLowEmptyPlace(bag)
	for i = 0, self:getPlaces(bag), 1 do
		if(self:isPlaceEmpty(bag, i)) then
			return i
		end
	end
	return false
end

function Inventory:getLowestOccupiedPlace(bag)
	local bag = self.m_Bag[bag]
	for index, value in pairs(bag) do
		return self.m_Items[id]["Platz"]
	end
	return false
end

function Inventory:getPlaces(bag)
	if bag then
		if self.m_InventorySlots[bag] then
			return self.m_InventorySlots[bag]-1
		else
			return 0
		end
	else
		return 0
	end
end

function Inventory:getCountOfPlaces(bag, item)
	local places = self:getPlaces(bag)
	local freePlaces = 0
	for i = 0, places, 1 do
		if isPlaceEmpty(bag, i) then
			freePlaces = freePlaces+1
		end
	end
	return freePlaces
end

function Inventory:getItemID(bag, place)
	return self.m_Bag[bag][place]
end

function Inventory:setItemPlace(bag, placeOld, placeNew)
	local id = self:getItemID(bag, placeOld)
	local nid= self:getItemID(bag, placeNew)
	if not id or not self.m_Items[id] and self.m_Items[nid] ~= self.m_Items[id] then
		return false
	end
	self.m_Bag[bag][placeOld] = nil
	self.m_Items[id]["Platz"] = placeNew
	self.m_Bag[bag][placeNew] = id
	self:saveItemPlace(id, self.m_Items[id]["Platz"])
	return true
end

function Inventory:getItemValueByBag( bag, place)
	if bag then
		if place then
			local id = self:getItemID(bag, place)
			if id then
				return self.m_Items[id]["Value"]
			end
		end
	end
end

function Inventory:setItemValueByBag( bag, place, value )
	if bag then
		if place then
			local id = self:getItemID(bag, place)
			if id then
				self.m_Items[self.m_Bag[bag][place]]["Value"] = value
				self:saveItemValue(id, value)
			end
		end
	end
end

function Inventory:getItemPlacesByName(item)
	local placeTable = {}
	if self.m_ItemData[item] then
		local bag = self.m_ItemData[item]["Tasche"]
		local amount = 0
		local places = self:getPlaces(bag)
		for place = 0, places, 1 do
			local id = self.m_Bag[bag][place]
			if id then
				if self.m_Items[id]["Objekt"] == item then
					placeTable[#placeTable+1] = {place, bag}
				end
			end
		end
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
	return placeTable
end

function Inventory:removeItemFromPlace(bag, place, amount, value)
	local id = self.m_Bag[bag][place]
	if not id then return false end

	local ItemAmount = self.m_Items[id]["Menge"]

	if not amount then
		amount = ItemAmount
	elseif(amount < 0) then
		error("removeItem > You cant remove less then 0 items!", 2)
		return false
	end
	local itemValue = value or ""
	if self.m_Debug == true then
		outputDebugString("RemoveItemFromPlace: Parameters->"..tostring(bag)..", place:"..place..", amount:"..amount..", value: "..itemValue.."!",0,200,0,200)
	end
	if(ItemAmount - amount < 0) then
		return false
	elseif(ItemAmount - amount > 0) then
		self.m_Items[id]["Menge"] = ItemAmount - amount
		self:saveItemAmount(id, self.m_Items[id]["Menge"])
	else
		self:deleteItem(id)
		self.m_Items[id] = nil
		self.m_Bag[bag][place] = nil
	end
	self:syncClient()
end

function Inventory:getMaxItemAmount(item)
	return self.m_ItemData[item]["Item_Max"]
end

function Inventory:getFreePlacesForItem(item)
	if self.m_Debug == true then
		outputDebugString("INV-DEBUG-getFreePlacesForItem: Spieler: "..getPlayerName(self.m_Owner).." | Item: "..item)
	end

	if self.m_ItemData[item] then
		local bag = self.m_ItemData[item]["Tasche"]
		local invplaetze = self:getPlaces(bag)
		local stackMax = self.m_ItemData[item]["Stack_max"]
		local itemMax = self.m_ItemData[item]["Item_Max"]
		local placesplus = 0
		local amount = 0
		local places = 0

		if self:getItemAmount(item) >= itemMax then
			return 0
		end

		for i = 0, invplaetze, 1 do
			local place = i
			local id = self.m_Bag[bag][place]
			local itemName = self.m_ItemData[item]["Name"]
			amount = 0
			placesplus = 0
			if itemName and id then
				if itemName == item then
					amount = self.m_Items[id]["Menge"]
					if amount <= stackMax then
						placesplus = stackMax-amount
						places = places + placesplus
					end
				end
			else
				places = places+stackMax
			end
		end

		if places > itemMax then places = itemMax	end
		return places
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
	return 0
end

function Inventory:removeItem(item, amount, value)
	if self.m_Debug == true then
		outputDebugString("INV-DEBUG-removeItem: Spieler: "..getPlayerName(self.m_Owner).." | Item: "..item.." | Anzahl: "..amount)
	end

	if self.m_ItemData[item] then
		local bag = self.m_ItemData[item]["Tasche"]
		local places = self:getPlaces(bag)
		local itemValue
		for place = 0, places, 1 do
			local id = self.m_Bag[bag][place]
			if self.m_Items[id] then
				if self.m_Items[id]["Objekt"] then
					if self.m_Items[id]["Objekt"] == item then
						if self.m_Items[id]["Menge"] >= amount then
							if not value then
								self:removeItemFromPlace(bag, place, amount)
							else
								itemValue = self:getItemValueByBag(bag, place)
								if itemValue == value then
									self:removeItemFromPlace(bag, place, amount, value)
								end
							end
							return
						end
					end
				end
			end
		end
		for i=1, amount, 1 do
			self:removeOneItem(item, value)
		end
	end
end

function Inventory:removeAllItem(item, value)
	if self.m_ItemData[item] then
		local bag = self.m_ItemData[item]["Tasche"]
		local places = self:getPlaces(bag)
		local id,itemName
		local itemValue
		for place = 0, places, 1 do
			id = self.m_Bag[bag][place]
			if id then
				itemName = self.m_Items[id]["Objekt"]
				if itemName == item then
					if not value then
						self:removeItemFromPlace(bag, place)
					else
						itemValue = self:getItemValueByBag(bag, place)
						if itemValue == value then
							self:removeItemFromPlace(bag, place)
						end
					end
				end
			end
		end
	end
end

function Inventory:removeOneItem(item, value)
	if self.m_ItemData[item] then
		local bag = self.m_ItemData[item]["Tasche"]
		local places = self:getPlaces(bag)
		local amount = 0
		for place = 0, places, 1 do
			amount = 0
			local id = self.m_Bag[bag][place]
			local item_table = self.m_Items
			local itemname = item_table[id]
			local itemValue = self:getItemValueByBag(bag, place)
			if itemname == item then
				amount = self.m_Items[id]["Menge"]
				if amount > 1 then
					if not value then
						self.m_Items[id]["Menge"] = amount-1
						self:saveItemAmount(id, self.m_Items[id]["Menge"])
						return true
					else
						if itemValue == value then
							self.m_Items[id]["Menge"] = amount-1
							self:saveItemAmount(id, self.m_Items[id]["Menge"])
							return true
						end
					end
				elseif amount == 1 then
					if not value then
						self:removeItemFromPlace(bag, place, 1)
						return true
					else
						if itemValue == value then
							self:removeItemFromPlace(bag, place, 1)
							return true
						end
					end
				end
			end
		end
		return amount
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
	return false
end

function Inventory:getPlaceForItem(item, itemAmount)
	if self.m_ItemData[item] then
		local bag = self.m_ItemData[item]["Tasche"]
		local id
		for place = 0, self:getPlaces(bag), 1 do
			id = self.m_Bag[bag][place]
			if id then
				if self.m_Items[id]["Objekt"] == item then
					if self.m_Items[id]["Menge"]+itemAmount <= self.m_ItemData[item]["Stack_max"] then
						return place
					end
				end
			end
		end
		return false
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
end

function Inventory:getItemAmount(item)

	if self.m_Debug == true then
		outputDebugString("INV-DEBUG-getPlayerItemAnzahl: Spieler: "..getPlayerName(self.m_Owner).." | Item: "..item)
	end

	if self.m_ItemData[item] then
		local bag = self.m_ItemData[item]["Tasche"]
		local amount = 0
		local places = self:getPlaces(bag)
		for place = 0, places, 1 do
			local id = self.m_Bag[bag][place]
			if id then
				if self.m_Items[id]["Objekt"] == item then
					amount = amount+self.m_Items[id]["Menge"]
				end
			end
		end
		return amount
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
end

function Inventory:getItemIdFromName(item)

	if self.m_Debug == true then
		outputDebugString("INV-DEBUG-getItemId: Spieler: "..getPlayerName(self.m_Owner).." | Item: "..item)
	end

	if self.m_ItemData[item] then
		local bag = self.m_ItemData[item]["Tasche"]
		local amount = 0
		local places = self:getPlaces(bag)
		for place = 0, places, 1 do
			local id = self.m_Bag[bag][place]
			if id then
				if self.m_Items[id]["Objekt"] == item then
					return id
				end
			end
		end
		return false
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
end

function Inventory:throwItem(item, bag, id, place, name)
	self.m_Owner:sendError(_("Du hast das Item (%s) weggeworfen!", self.m_Owner,name))
	self.m_Owner:meChat(true, "zerstört "..name.."!")
	local value = self:getItemValueByBag(bag,place)
	WearableManager:getSingleton():removeWearable( self.m_Owner, name, value )
	self:removeItemFromPlace(bag, place)
end

function Inventory:c_setItemPlace(bag, place, nplace)
	self:setItemPlace(bag, place, nplace)
end

function Inventory:c_stackItems(newId, oldId, oldPlace)
	local itemNameOld = self.m_Items[oldId]["Objekt"]
	local itemNameNew = self.m_Items[newId]["Objekt"]
	if itemNameOld == itemNameNew then
		local amountNew = self.m_Items[newId]["Menge"]
		local amountOld = self.m_Items[oldId]["Menge"]
		local total = amountNew + amountOld
		if total <= self.m_ItemData[itemNameOld]["Stack_max"] then
			self.m_Items[newId]["Menge"] = total
			self:saveItemAmount(newId, self.m_Items[newId]["Menge"])
			local bag = self.m_Items[itemNameNew]["Tasche"]
			self:removeItemFromPlace(bag, oldPlace, amountOld)
		end
	end
end


function Inventory:giveItem(item, amount, value) -- donotsync if player disconnects
	checkArgs("Inventory:giveItem", "string", "number")
	if self.m_Debug == true then
		outputDebugString("INV-DEBUG-giveItem: Spieler: "..self.m_Owner:getName().." | Item: "..item.." | Anzahl: "..amount)
	end

	if self.m_ItemData[item] then
		local bag = self.m_ItemData[item]["Tasche"]
		local itemMax = self.m_ItemData[item]["Item_Max"]
		if self:getItemAmount(item)+amount > itemMax  then
			self.m_Owner:sendError(_("Du kannst maximal %d %s in dein Inventar legen!", self.m_Owner,itemMax, item))
			return
		end
		local placeType, place
		if self:getPlaceForItem(item, amount) then --Stack
			placeType = "stack"
			place = self:getPlaceForItem(item, amount)
		else -- New
			placeType = "new"
			place = self:getLowEmptyPlace(bag)
		end
		if place then
			local id = self.m_Bag[bag][place]
			if placeType == "stack" then
				--outputDebugString("giveItem - OldStack")
				local itemAmount = self.m_Items[id]["Menge"]
				self.m_Items[id]["Menge"] = itemAmount + amount
				self:saveItemAmount(id, self.m_Items[id]["Menge"])
				--triggerClientEvent(self.m_Owner, "setInventoryCoordinates", self.m_Owner, place, bag)
				return true
			elseif placeType == "new" then
				if amount > 0 then
				--	outputDebugString("giveItem - NewStack")
					local lastId = self:insertItem(amount, item, place, bag, value or "")
					self:loadItem(lastId)
					self:setItemValueByBag(bag,place, value or "")
					return true
				end
			end
		elseif not self.m_Owner.m_Disconnecting then
			self.m_Owner:sendError(_("Nicht genug Platz für %d %s in deinem Inventar!", self.m_Owner,amount,item))
		end
	elseif not self.m_Owner.m_Disconnecting then
		self.m_Owner:sendError(_("Ungültiges Item! (%s)", self.m_Owner,item))
	end
end
