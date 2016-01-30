-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Inventory.lua
-- *  PURPOSE:     Inventory Class
-- *
-- ****************************************************************************
Inventory = inherit(Singleton)

function Inventory:constructor()

	self.m_ItemData = {}
	self.m_ItemData = self:loadItems()

	addRemoteEvents{"changePlaces", "onPlayerItemUseServer", "c_stackItems", "wegwerfItem", "c_setItemPlace"}
	addEventHandler("changePlaces", root, bind(self.Event_changePlaces, self))
	addEventHandler("onPlayerItemUseServer", root, bind(self.Event_onItemUse, self))
	addEventHandler("c_stackItems",getRootElement(),bind(self.Event_c_stackItems, self))
	addEventHandler("wegwerfItem",getRootElement(),bind(self.Event_wegwerfItem, self))
	addEventHandler("c_setItemPlace",getRootElement(),bind(self.Event_c_setItemPlace, self))
end

function Inventory:destructor()

end

function Inventory:getItemData()
	return self.m_ItemData
end

function Inventory:loadItems()
	local result = sql:queryFetch("SELECT * FROM inventardef") -- ToDo add Prefix
	local itemData = {}
	for i, row in ipairs(result) do
		itemData[row["Objektname"]] = {}
		itemData[row["Objektname"]]["Name"] = row["Objektname"]
		itemData[row["Objektname"]]["Info"] = row["Info"]
		itemData[row["Objektname"]]["Tasche"] = row["Tasche"]
		itemData[row["Objektname"]]["Icon"] = row["Icon"]
		itemData[row["Objektname"]]["Item_Max"] = tonumber(row["max_items"])
		itemData[row["Objektname"]]["Wegwerf"] = tonumber(row["wegwerfen"])
		itemData[row["Objektname"]]["Handel"] = tonumber(row["Handel"])
		itemData[row["Objektname"]]["Stack_max"] = tonumber(row["stack_max"])
		itemData[row["Objektname"]]["Verbraucht"] = tonumber(row["verbraucht"])
	end

	return itemData
end

function Inventory:saveItemMenge(id,menge)
	sql:queryExec("UPDATE inventarinhalt SET Menge= ?? WHERE id = ??",menge,id ) -- ToDo add Prefix
end

function Inventory:createInventory(player)
	sql:queryExec("INSERT INTO inventarinfo (Name) VALUES(?)",player:getName() ) -- ToDo add Prefix
	self:loadInventory(player)
end

function Inventory:loadInventory(player)
	local result = sql:queryFetch("SELECT * FROM inventarinfo WHERE Name = ?",player:getName()) -- ToDo add Prefix
	if #result == 0 then
		self:createInventory(player)
		return
	end

	self:setData(player,"Inventar","ItemsPlatz",14,true)
	self:setData(player,"Inventar","ObjektePlatz",3,true)
	self:setData(player,"Inventar","EssenPlatz",5,true)
	self:setData(player,"Inventar","DrogenPlatz",7,true)


	local result = sql:queryFetch("SELECT * FROM inventarinhalt WHERE Name = ?",player:getName()) -- ToDo add Prefix
	for i, row in ipairs(result) do
		if tonumber(row["Menge"]) > 0 then
			self:setData(player,"Item",tonumber(row["id"]),tostring(row["Objekt"]),true)
			self:setData(player,"Item",tonumber(row["id"]).."_Menge",tonumber(row["Menge"]),true)
			self:setData(player,"Item",tonumber(row["id"]).."_Platz",tonumber(row["Platz"]),true)
			self:setData(player,"Item_"..tostring(row["Tasche"]),tonumber(row["Platz"]).."_id",tonumber(row["id"]),true)
		else
			removeItemFromPlatz(player,row["Tasche"],tonumber(row["Platz"]))
		end
	end

	triggerClientEvent(player,"loadItemDataFromServer",player,self.m_ItemData)
	triggerClientEvent(player,"loadPlayerInventarClient",player)

end

function Inventory:Event_changePlaces(player,tasche,oPlace,nPlace)
	if(client ~= player) then
		return false
	end
	setItemPlace(player,tasche,oPlace,-1)
	setItemPlace(player,tasche,nPlace,oPlace)
	setItemPlace(player,tasche,-1,nPlace)
end

function Inventory:setData(element,tname,index,value,stream)
	if(not isElement(element)) then
		outputDebugString("Inventar: setData > arg #1 not a element",2)
		return false
	elseif(type(tname) ~= "string") then
		outputDebugString("Inventar: setData > arg #2 not a string",2)
		return false
	end
	if not self:getData(element,tname) then
		setElementData(element,tname,{})
	end
	local invtable = self:getData(element,tname)
	invtable[index] = value
	setElementData(element,tname,invtable,false)

	if(stream == true) then
		if(self:getData(element,tname.."_c") == false) then
			setElementData(element,tname.."_c",{})
		end
		local invtable = self:getData(element,tname)
		invtable[index] = value
		setElementData(element,tname.."_c",invtable,true)

	end
end

function Inventory:updatePlayerTable(player,elementDataName,tableName,...)
	if(self:getData(player,"loggedin") ~= true) then
		return false
	end
	local district = {...}
	local isDistricted = {}
	for i,v in pairs(district) do
		isDistricted[tostring(v)] = true
	end
	if(type(elementDataName) ~= "string" or not elementDataName) then
		error("updatePlayerTable > arg #1 no string",2)
		return false
	elseif(type(tableName) ~= "string" or not tableName) then
		error("updatePlayerTable > arg #2 no string",2)
		return false
	end
	local mysqlString = ""
	local nameTag
	for i,v in pairs(self:getData(player,elementDataName)) do
		if(not isDistricted[tostring(i)]) then
			if(i == "Name" or i == "Benutzername") then
				nameTag = i
			else
				if(mysqlString ~= "") then
					mysqlString = tostring(mysqlString)..",`"..tostring(i).."`='"..tostring(v).."'"
				else
					mysqlString = "`"..i.."`='"..tostring(v).."'"
				end
			end
		else
		end

	end
	sql:queryExec("UPDATE ?? SET ?? WHERE ?? = ??",tostring(tableName),tostring(mysqlString),tostring(nameTag),player:getName() ) -- ToDo add Prefix
	return true
end

function Inventory:Event_onItemUse(itemid,tasche,itemname,platz,delete)
	if delete == true then
		self:removeItemFromPlatz(client,tasche,platz,1)
	end
	outputChatBox("Du benutzt das Item "..itemname.." aus der Tasche "..tasche.."!",client,0,255,0)
end

inventar_debug = false

function Inventory:isPlatzEmpty(player,tasche,platz)
	local id = self:getData(player,"Item_"..tasche,platz.."_id")
	local item_table = self:getData(player,"Item")
	if item_table[id] then
		local itemname = item_table[id]

		if(itemname) then
			return false
		else
			return true
		end
	else
		return true
	end
end

function Inventory:getLowEmptyPlace(player,tasche)
	for i = 0, self:getInventarPlaces(player,tasche),1 do
		if(self:isPlatzEmpty(player,tasche,i)) then
			return i
		end
	end
	return false
end

function Inventory:getLowestOccupiedPlace(player,tasche)
	local tasche = self:getData(player,"Item_"..tasche)
	for index,value in pairs(tasche) do
		if(value) then
			local place = self:getData(player,"Item",value.."_Platz")
			return place
		end
	end
	return false
end

function Inventory:getInventarPlaces(player,tasche)
	if tasche then
		if self:getData(player,"Inventar",tasche.."Platz") then
			return tonumber(self:getData(player,"Inventar",tasche.."Platz"))-1
		else
			return 0
		end
	else
		return 0
	end
end

function Inventory:getCountOfPlaces(player,tasche,item)
	local maxItemStack = tonumber(itemData[item]["Item_Max"])
	local places = maxItemStack
	local invplaetze = self:getInventarPlaces(player,tasche)
	local freeplaces = 0
	for i = 0, invplaetze,1 do
		if isPlatzEmpty(player,tasche,i) then
			freeplaces = freeplaces+1
		end
	end
	return freeplaces
end

function Inventory:getItemID(player,tasche,platz)
	return self:getData(player,"Item_"..tasche,platz.."_id")
end

function Inventory:setItemPlace(player,tasche,oplatz,platz)
	local id = self:getItemID(player,tasche,oplatz)
	local nid= self:getItemID(player,tasche,platz)
	if(not id or (nid and self:getData(player,"Item",nid) ~= self:getData(player,"Item",id)) ) then
		return false
	end
	self:setData(player,"Item_"..tasche,oplatz.."_id",nil,true)
	self:setData(player,"Item",id.."_Platz",platz,true)
	self:setData(player,"Item_"..tasche,platz.."_id",id,true)
	sql:queryExec("UPDATE inventarinhalt SET Platz= ?? WHERE id = ??",self:getData(player,"Item",id.."_Platz"),id ) -- ToDo add Prefix

	return true
end

function Inventory:Event_c_stackItems(newid,oldid,oldplatz) --OLD = Moved
	if(source ~= client) then
		return false
	end
	local player = source
	local item_table = self:getData(player,"Item")
	local itemname_old = item_table[oldid]
	local itemname_new = item_table[newid]
	if itemname_old == itemname_new then
		local anzahl_new = self:getData(player,"Item",newid.."_Menge")
		local anzahl_old = self:getData(player,"Item",oldid.."_Menge")
		local gesamt = anzahl_new + anzahl_old
		if gesamt <= itemData[itemname_old]["Stack_max"] then
			self:setData(player,"Item",newid.."_Menge",gesamt,true)
			self:saveItemMenge(newid,self:getData(player,"Item",id.."_Menge"))
			local tasche = itemData[itemname_new]["Tasche"]
			self:removeItemFromPlatz(player,tasche,oldplatz,anzahl_old)
		end
	end
end
addEvent("c_stackItems",true)


function Inventory:Event_c_setItemPlace(tasche,platz,nplatz)
	if(source ~= client) then
		return false
	end
	setItemPlace(source,tasche,platz,nplatz)
end

function Inventory:getData(element, name,index)
		if(not element ) then
			return error("getElementData > no argument",2)
		elseif(not isElement(element)) then
			return error("getElementData > arg #1 not a element",2)
		elseif(type(name) ~= "string") then
			return error("getElementData > arg #2 not a string",2)
		end
		local result
		if(not index) then
			result = getElementData ( element, name)
		else
			if(getElementData(element,name)) then
				result = getElementData ( element, name)[index]
			else
				result = getElementData ( element, name)
			end
		end
		return result
end

function Inventory:removeItemFromPlatz(player,tasche,platz,anzahl)

		local id = self:getData(player,"Item_"..tasche,platz.."_id")
		if(not id) then
			return false
		end

		if(not anzahl) then
			anzahl = self:getData(player,"Item",id.."_Menge")
		elseif(anzahl < 0) then
			error("removeItem > You cant remove less then 0 items!",2)
			return false
		end
		local itemA = self:getData(player,"Item",id.."_Menge")

		if(itemA - anzahl < 0) then
			return false
		elseif(itemA - anzahl > 0) then
			self:setData(player,"Item",id.."_Menge",itemA - anzahl,true)
			self:saveItemMenge(id,self:getData(player,"Item",id.."_Menge"))

		else
			sql:queryExec("DELETE FROM `inventarinhalt` WHERE `id`= ??",id ) -- ToDo add Prefix
			self:setData(player,"Item",id,nil,true)
			self:setData(player,"Item",id.."_Menge",nil,true)
			self:setData(player,"Item",id.."_Platz",nil,true)
			self:setData(player,"Item_"..tasche,platz.."_id",nil,true)
		end

end

function Inventory:Event_wegwerfItem(item,tasche,id,platz)
	local player = client
	executeCommandHandler ( "meCMD", player, " wirft "..item.." weg..." )
	self:removeItemFromPlatz(player,tasche,platz)
end


function Inventory:getFreePlacesForItem(player,item)

	if inventar_debug == true then
		outputDebugString("INV-DEBUG-getFreePlacesForItem: Spieler: "..getPlayerName(player).." | Item: "..item)
	end

	if itemData[item] then
		local tasche = itemData[item]["Tasche"]
		local invplaetze = self:getInventarPlaces(player,tasche)
		local stackmax = itemData[item]["Stack_max"]
		local item_max = itemData[item]["Item_Max"]
		local placesplus = 0
		local anzahl = 0

		local places = 0

		if self:getPlayerItemAnzahl(player,item) >= item_max then
			return 0
		end

		for i = 0, invplaetze,1 do
			local platz = i
			local id = self:getData(player,"Item_"..tasche,platz.."_id")
			local item_table = self:getData(player,"Item")
			local itemname = item_table[id]
			anzahl = 0
			placesplus = 0
			if itemname then
				if itemname == item then
					anzahl = tonumber(self:getData(player,"Item",id.."_Menge"))
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

function Inventory:removeItem(player,item,anzahl)
	if inventar_debug == true then
		outputDebugString("INV-DEBUG-removeItem: Spieler: "..getPlayerName(player).." | Item: "..item.." | Anzahl: "..anzahl)
	end

	if itemData[item] then
		local tasche = itemData[item]["Tasche"]
		local invplaetze = self:getInventarPlaces(player,tasche)
		for i = 0, invplaetze,1 do
			local platz = i
			local id = self:getData(player,"Item_"..tasche,platz.."_id")
			local item_table = self:getData(player,"Item")
			local itemname = item_table[id]
			local invanzahl = 0
			placesplus = 0
			if itemname then
				if itemname == item then
					invanzahl = tonumber(self:getData(player,"Item",id.."_Menge"))
					if invanzahl >=anzahl then
						self:removeItemFromPlatz(player,tasche,platz,anzahl)
						return
					end
				end
			end
		end


		for i=1,anzahl,1 do
			self:removeOneItem(player,item)
		end
	end
end

function Inventory:removeOneItem(player,item)
	if itemData[item] then
		local tasche = itemData[item]["Tasche"]
		local invplaetze = self:getInventarPlaces(player,tasche)
		local anzahl = 0
		for i = 0, invplaetze,1 do
			anzahl = 0
			local platz = i
			local id = self:getData(player,"Item_"..tasche,platz.."_id")
			local item_table = self:getData(player,"Item")
			local itemname = item_table[id]
			if itemname == item then
				anzahl = self:getData(player,"Item",id.."_Menge")
				if anzahl > 1 then
					self:setData(player,"Item",id.."_Menge",anzahl - 1,true)
					self:saveItemMenge(id,self:getData(player,"Item",id.."_Menge"))

					return true
				elseif anzahl == 1 then
					self:removeItemFromPlatz(player,tasche,platz,1)
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


function Inventory:getPlatzForItem(player,item,itemanzahl)
	if itemData[item] then
		local tasche = itemData[item]["Tasche"]
		local invplaetze = getInventarPlaces(player,tasche)
		local stackmax = itemData[item]["Stack_max"]
		for i = 0, invplaetze,1 do
			local platz =i
			local id = self:getData(player,"Item_"..tasche,platz.."_id")
			local item_table = self:getData(player,"Item")
			local itemname = item_table[id]
			local anzahl = 0
			if itemname == item then
				anzahl = tonumber(self:getData(player,"Item",id.."_Menge"))+itemanzahl
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

function Inventory:getPlayerItemAnzahl(player,item)

	if inventar_debug == true then
		outputDebugString("INV-DEBUG-getPlayerItemAnzahl: Spieler: "..getPlayerName(player).." | Item: "..item)
	end

	if itemData[item] then
		local tasche = itemData[item]["Tasche"]
		local invplaetze = self:getInventarPlaces(player,tasche)
		local anzahl = 0
		for i = 0, invplaetze,1 do
			local platz = i
			local id = self:getData(player,"Item_"..tasche,platz.."_id")
			local item_table = self:getData(player,"Item")
			local itemname = item_table[id]
			if itemname == item then
				anzahl = anzahl+tonumber(self:getData(player,"Item",id.."_Menge"))
			end
		end
		return anzahl
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
end

function Inventory:giveItem(player,item,anzahl)

	if inventar_debug == true then
		outputDebugString("INV-DEBUG-giveItem: Spieler: "..getPlayerName(player).." | Item: "..item.." | Anzahl: "..anzahl)
	end


	if itemData[item] then
		local tasche = itemData[item]["Tasche"]


		if(not item or type(item) ~= "string") then
			outputDebugString("giveItem > arg #2 not a string")
			return
		elseif(not anzahl or type(anzahl) ~= "number") then
			outputDebugString("giveItem > arg #3 not a string")
			return
		elseif(not tasche or type(tasche) ~= "string") then
			outputDebugString("giveItem > arg #4 not a string")
			return
		elseif(not player or getElementType(player) ~= "player") then
			outputDebugString("giveItem > arg #1 not a player")
			return
		end

		local max_items = tonumber(itemData[item]["Item_Max"])
		local new_items = self:getPlayerItemAnzahl(player,item)+anzahl

		if new_items > max_items  then
			outputChatBox("Die maximale Anzahl des Items '"..item.."' beträgt "..max_items.."!",player,255,0,0)
			return
		end

		local item_table = self:getData(player,"Item")

		local platztyp = "new"

		local stackplatz = self:getPlatzForItem(player,item,anzahl)
		if stackplatz then
			platztyp = "stack"
			platz = stackplatz
		else
			platz = self:getLowEmptyPlace(player,tasche)
		end
		if platz then

			local id = self:getData(player,"Item_"..tasche,platz.."_id")
			if platztyp == "stack" then
				--outputDebugString("giveItem - OldStack")
				local itemA = self:getData(player,"Item",id.."_Menge")
				self:setData(player,"Item",id.."_Menge",itemA + anzahl,true)
				self:saveItemMenge(id,self:getData(player,"Item",id.."_Menge"))

				triggerClientEvent(player,"setIKoords_c",player,platz,tasche)
				return true

			elseif platztyp == "new" then
				if anzahl > 0 then
				--	outputDebugString("giveItem - NewStack")

					sql:queryExec("INSERT INTO `inventarinhalt` (Name,Menge,Objekt,Platz,Tasche) VALUES (??, ??, ??, ??, ??)",getPlayerName(player), anzahl, item, platz, tasche ) -- ToDo add Prefix
					local result = sql:queryFetch("SELECT * FROM inventarinhalt WHERE Name = ?? AND `Tasche` = ??' AND `Platz` = ?? AND `Objekt`= ??",getPlayerName(player),tasche,platz,item) -- ToDo add Prefix

					for i, row in ipairs(result) do
						self:setData(player,"Item",tonumber(row["id"]),tostring(row["Objekt"]),true)
						self:setData(player,"Item",tonumber(row["id"]).."_Menge",tonumber(row["Menge"]),true)
						self:setData(player,"Item",tonumber(row["id"]).."_Platz",tonumber(row["Platz"]),true)
						self:setData(player,"Item_"..tostring(row["Tasche"]),tonumber(row["Platz"]).."_id",tonumber(row["id"]),true)
					end

					triggerClientEvent(player,"setIKoords_c",player,platz,tasche)
					return true
				end
			end
		else
			outputChatBox("Kein Platz in deinem Inventar!",player,255,0,0)
		end
	else
		outputChatBox("Ungültiges Item! ("..item..")",player,255,0,0)
	end
end
