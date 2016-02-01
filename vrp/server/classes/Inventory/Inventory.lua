-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Inventory.lua
-- *  PURPOSE:     Inventory Class
-- *
-- ****************************************************************************
Inventory = inherit(Singleton)

function Inventory:constructor(owner, inventorySlots, itemData)
	self.m_InventorySlots = inventorySlots
	self.m_ItemData = itemData
	self.m_Owner = owner
	self.m_Tasche = {}
	self.m_Items = {}
	
	self.m_Debug = true
	
	for k, v in pairs(inventorySlots) do
		self.m_Tasche[k] = {}
	end

	local id, platz

	local result = sql:queryFetch("SELECT * FROM ??_inventory_slots WHERE Name = ?", sql:getPrefix(), self.m_Owner:getName()) -- ToDo add Prefix
	for i, row in ipairs(result) do
		if tonumber(row["Menge"]) > 0 then
			id = tonumber(row["id"])
			platz = tonumber(row["Platz"])
			self.m_Items[id] = {}
			self.m_Items[id]["Objekt"] = row["Objekt"]
			self.m_Items[id]["Menge"] = tonumber(row["Menge"])
			self.m_Items[id]["Platz"] = platz
			self.m_Tasche[row["Tasche"]][platz] = id
		else
			removeItemFromPlatz(row["Tasche"], tonumber(row["Platz"]))
		end
	end

	triggerClientEvent(self.m_Owner, "loadPlayerInventarClient", self.m_Owner, self.m_InventorySlots, self.m_ItemData)
	self:syncClient()
end

function Inventory:destructor()

end

function Inventory:syncClient()
	triggerClientEvent(self.m_Owner, "syncInventoryFromServer", self.m_Owner, self.m_Tasche, self.m_Items)
end

function Inventory:useItem(itemid, tasche, itemname, platz, delete)
	if delete == true then
		self:removeItemFromPlatz(tasche, platz, 1)
	end
	outputChatBox("Du benutzt das Item "..itemname.." aus der Tasche "..tasche.."!", self.m_Owner, 0, 255, 0) -- in Developement
end

function Inventory:saveItemMenge(id, menge)
	sql:queryExec("UPDATE ??_inventory_slots SET Menge= ?? WHERE id = ??", sql:getPrefix(), menge, id )
	self:syncClient()
end

function Inventory:saveItemPlatz(id, platz)
	sql:queryExec("UPDATE ??_inventory_slots SET Platz= ?? WHERE id = ??", sql:getPrefix(), platz, id )
	self:syncClient()
end

function Inventory:deleteItem(id)
	sql:queryExec("DELETE FROM ??_inventory_slots WHERE `id`= ??", sql:getPrefix(), id )
	self:syncClient()
end

function Inventory:insertItem(anzahl, item, platz, tasche)
	sql:queryExec("INSERT INTO ??_inventory_slots (Name, Menge, Objekt, Platz, Tasche) VALUES (??, ??, ??, ??, ??)", sql:getPrefix(), self.m_Owner:getName(), anzahl, item, platz, tasche ) -- ToDo add Prefix
	self:syncClient()
	return sql:lastInsertId()
end

function Inventory:changePlaces(tasche, oPlace, nPlace)
	self:setItemPlace(tasche, oPlace, -1)
	self:setItemPlace(tasche, nPlace, oPlace)
	self:setItemPlace(tasche, -1, nPlace)
end

function Inventory:isPlatzEmpty(tasche, platz)
	local id = self.m_Tasche[tasche][platz] 
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

function Inventory:getLowEmptyPlace(tasche)
	for i = 0, self:getInventarPlaces(tasche), 1 do
		if(self:isPlatzEmpty(tasche, i)) then
			return i
		end
	end
	return false
end

function Inventory:getLowestOccupiedPlace(tasche)
	local tasche = self.m_Tasche[tasche]
	for index, value in pairs(tasche) do
		return self.m_Items[id]["Platz"]
	end
	return false
end

function Inventory:getInventarPlaces(tasche)
	if tasche then
		if self.m_InventorySlots[tasche] then
			return self.m_InventorySlots[tasche]-1
		else
			return 0
		end
	else
		return 0
	end
end

function Inventory:getCountOfPlaces(tasche, item)
	local invplaetze = self:getInventarPlaces(tasche)
	local freeplaces = 0
	for i = 0, invplaetze, 1 do
		if isPlatzEmpty(tasche, i) then
			freeplaces = freeplaces+1
		end
	end
	return freeplaces
end

function Inventory:getItemID(tasche, place)
	return self.m_Tasche[tasche][place]
end

function Inventory:setItemPlace(tasche, placeOld, placeNew)
	local id = self:getItemID(tasche, placeOld)
	local nid= self:getItemID(tasche, placeNew)
	if not id or not self.m_Items[id] and self.m_Items[nid] ~= self.m_Items[id] then
		return false
	end
	self.m_Tasche[tasche][placeOld] = nil
	self.m_Items[id]["Platz"] = placeNew
	self.m_Tasche[tasche][placeNew] = id
	self:saveItemPlatz(id, self.m_Items[id]["Platz"])
	return true
end

function Inventory:removeItemFromPlatz(tasche, platz, anzahl)
		local id = self.m_Tasche[tasche][platz]
		if(not id) then
			return false
		end

		if(not anzahl) then
			anzahl = self.m_Items[id]["Menge"]
		elseif(anzahl < 0) then
			error("removeItem > You cant remove less then 0 items!", 2)
			return false
		end
		local itemA = self.m_Items[id]["Menge"]

		if(itemA - anzahl < 0) then
			return false
		elseif(itemA - anzahl > 0) then
			self.m_Items[id]["Menge"] = itemA - anzahl
			self:saveItemMenge(id, self.m_Items[id]["Menge"])
		else
			self:deleteItem(id)
			self.m_Items[id] = nil
			self.m_Tasche[tasche][platz] = nil
		end
end



function Inventory:getFreePlacesForItem(item)

	if self.m_Debug == true then
		outputDebugString("INV-DEBUG-getFreePlacesForItem: Spieler: "..getPlayerName(player).." | Item: "..item)
	end

	if self.m_ItemData[item] then
		local tasche = self.m_ItemData[item]["Tasche"]
		local invplaetze = self:getInventarPlaces(tasche)
		local stackmax = self.m_ItemData[item]["Stack_max"]
		local item_max = self.m_ItemData[item]["Item_Max"]
		local placesplus = 0
		local anzahl = 0
		local places = 0

		if self:getPlayerItemAnzahl(item) >= item_max then
			return 0
		end

		for i = 0, invplaetze, 1 do
			local platz = i
			local id = self.m_Tasche[tasche][platz]
			local itemName = self.m_Items[id]["Objekt"]
			anzahl = 0
			placesplus = 0
			if itemName then
				if itemName == item then
					anzahl = tonumber(self.m_Items[id]["Menge"])
					if anzahl <= stackmax then
						placesplus = stackmax-anzahl
						places = places + placesplus
					end
				end
			else
				places = places+stackmax
			end
		end

		if places > item_max then places = item_max	end
		return places
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
	return 0
end

function Inventory:removeItem(item, anzahl)
	if self.m_Debug == true then
		outputDebugString("INV-DEBUG-removeItem: Spieler: "..getPlayerName(player).." | Item: "..item.." | Anzahl: "..anzahl)
	end

	if self.m_ItemData[item] then
		local tasche = self.m_ItemData[item]["Tasche"]
		local invplaetze = self:getInventarPlaces(tasche)
		for platz = 0, invplaetze, 1 do
			local id = self.m_Tasche[tasche][platz]
			local item_table = self.m_Items
			local itemname = item_table[id]
			local invanzahl = 0
			placesplus = 0
			if itemname then
				if itemname == item then
					invanzahl = tonumber(self.m_Items[id]["Menge"])
					if invanzahl >=anzahl then
						self:removeItemFromPlatz(tasche, platz, anzahl)
						return
					end
				end
			end
		end
		for i=1, anzahl, 1 do
			self:removeOneItem(item)
		end
	end
end

function Inventory:removeOneItem(item)
	if self.m_ItemData[item] then
		local tasche = self.m_ItemData[item]["Tasche"]
		local invplaetze = self:getInventarPlaces(tasche)
		local anzahl = 0
		for platz = 0, invplaetze, 1 do
			anzahl = 0
			local id = self.m_Tasche[tasche][platz]
			local item_table = self.m_Items
			local itemname = item_table[id]
			if itemname == item then
				anzahl = self.m_Items[id]["Menge"]
				if anzahl > 1 then
					self.m_Items[id]["Menge"] = anzahl-1
					self:saveItemMenge(id, self.m_Items[id]["Menge"])
					return true
				elseif anzahl == 1 then
					self:removeItemFromPlatz(tasche, platz, 1)
					return true
				end
			end
		end
		return anzahl
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
	return false
end

function Inventory:getPlatzForItem(item, itemanzahl)
	if self.m_ItemData[item] then
		local tasche = self.m_ItemData[item]["Tasche"]
		local stackmax = self.m_ItemData[item]["Stack_max"]
		for platz = 0, getInventarPlaces(tasche), 1 do
			local id = self.m_Tasche[tasche][platz]
			local itemname = self.m_Items[id]["Objekt"]
			local anzahl = 0
			if itemname == item then
				anzahl = tonumber(self.m_Items[id]["Menge"])+itemanzahl
				if anzahl <= stackmax then
					return platz
				end
			end
		end
		return false
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
end

function Inventory:getPlayerItemAnzahl(item)

	if self.m_Debug == true then
		outputDebugString("INV-DEBUG-getPlayerItemAnzahl: Spieler: "..getPlayerName(player).." | Item: "..item)
	end

	if self.m_ItemData[item] then
		local tasche = self.m_ItemData[item]["Tasche"]
		local anzahl = 0
		for platz = 0, self:getInventarPlaces(tasche), 1 do
			local id = self.m_Tasche[tasche][platz]
			if self.m_Items[id]["Objekt"] == item then
				anzahl = anzahl+tonumber(self.m_Items[id]["Menge"])
			end
		end
		return anzahl
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
end

function Inventory:wegwerfItem(item, tasche, id, platz)
	self.m_Owner:sendError(_("Du hast das Item (%s) weggeworfen!", self.m_Owner,item))
	self:removeItemFromPlatz(tasche, platz)
end

function Inventory:c_setItemPlace(tasche, platz, nplatz)
	self:setItemPlace(tasche, platz, nplatz)
end

function Inventory:c_stackItems(newid, oldid, oldplatz)
	local itemname_old = self.m_Items[oldid]["Objekt"]
	local itemname_new = self.m_Items[newid]["Objekt"]
	if itemname_old == itemname_new then
		local anzahl_new = self.m_Items[newid]["Menge"]
		local anzahl_old = self.m_Items[oldid]["Menge"]
		local gesamt = anzahl_new + anzahl_old
		if gesamt <= self.m_ItemData[itemname_old]["Stack_max"] then
			self.m_Items[newid]["Menge"] = gesamt
			self:saveItemMenge(newid, self.m_Items[newid]["Menge"])
			local tasche = self.m_Items[itemname_new]["Tasche"]
			self:removeItemFromPlatz(tasche, oldplatz, anzahl_old)
		end
	end
end


function Inventory:giveItem(item, anzahl)
	checkArgs("Inventory:giveItem", "string", "number")
	if self.m_Debug == true then
		outputDebugString("INV-DEBUG-giveItem: Spieler: "..self.m_Owner:getName().." | Item: "..item.." | Anzahl: "..anzahl)
	end

	if self.m_ItemData[item] then
		local tasche = self.m_ItemData[item]["Tasche"]

		if self:getPlayerItemAnzahl(item)+anzahl > self.m_ItemData[item]["Item_Max"]  then
			self.m_Owner:sendError(_("Die maximale Anzahl des Items %s beträgt %d!", self.m_Owner,item,max_items))
			return
		end

		local platztyp = "new"
		local platz
		
		if self:getPlatzForItem(item, anzahl) then --Stack
			platztyp = "stack"
			platz = self:getPlatzForItem(item, anzahl)
		else -- New
			platz = self:getLowEmptyPlace(tasche)
		end
		if platz then
			local id = self.m_Tasche[tasche][platz]
			if platztyp == "stack" then
				--outputDebugString("giveItem - OldStack")
				local itemA = self.m_Items[id]["Menge"]
				self.m_Items[id]["Menge"] = itemA + anzahl
				self:saveItemMenge(id, self.m_Items[id]["Menge"])
				triggerClientEvent(self.m_Owner, "setIKoords_c", self.m_Owner, platz, tasche)
				return true
			elseif platztyp == "new" then
				if anzahl > 0 then
				--	outputDebugString("giveItem - NewStack")
					local lastId = self:insertItem(anzahl, item, platz, tasche)
					self:loadItem(lastId)
					return true
				end
			end
		else
			self.m_Owner:sendError(_("Kein Platz in deinem Inventar!", self.m_Owner))
		end
	else
		self.m_Owner:sendError(_("Ungültiges Item! (%s)", self.m_Owner,item))
	end
end