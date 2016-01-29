inventar_debug = false

local function isPlatzEmpty(player,tasche,platz)
	local id = getElementData(player,"Item_"..tasche,platz.."_id")
	local item_table = getElementData(player,"Item")
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

local function getLowEmptyPlace(player,tasche)
	for i = 0, getInventarPlaces(player,tasche),1 do
		if(isPlatzEmpty(player,tasche,i)) then
			return i
		end
	end
	return false
end



local function getLowestOccupiedPlace(player,tasche)
	local tasche = getElementData(player,"Item_"..tasche)
	for index,value in pairs(tasche) do
		if(value) then
			local place = getElementData(player,"Item",value.."_Platz")
			return place
		end
	end
	return false
end

function getInventarPlaces(player,tasche)
	if tasche then
		if getElementData(player,"Inventar",tasche.."Platz") then
			return tonumber(getElementData(player,"Inventar",tasche.."Platz"))-1
		else
			return 0
		end
	else
		return 0
	end
end

function getCountOfPlaces(player,tasche,item)
	local maxItemStack = tonumber(itemData[item]["Item_Max"])
	local places = maxItemStack
	local invplaetze = getInventarPlaces(player,tasche)
	local freeplaces = 0
	for i = 0, invplaetze,1 do
		if isPlatzEmpty(player,tasche,i) then
			freeplaces = freeplaces+1
		end
	end
	return freeplaces
end

function getItemID(player,tasche,platz)
	return getElementData(player,"Item_"..tasche,platz.."_id")
end

function setItemPlace(player,tasche,oplatz,platz)
	local id = getItemID(player,tasche,oplatz)
	local nid= getItemID(player,tasche,platz)
	if(not id or (nid and getElementData(player,"Item",nid) ~= getElementData(player,"Item",id)) ) then
		return false
	end
	setData(player,"Item_"..tasche,oplatz.."_id",nil,true)
	setData(player,"Item",id.."_Platz",platz,true)
	setData(player,"Item_"..tasche,platz.."_id",id,true)
	
	local saved = mysql_query(Datenbank,"UPDATE `inventarinhalt` SET `Platz`='"..MySQL_Save( getElementData(player,"Item",id.."_Platz") ).."' WHERE `id`='"..MySQL_Save(id).."'")
	mysql_free_result(saved)
	return true
end

function c_stackItems(newid,oldid,oldplatz) --OLD = Moved
	if(source ~= client) then
		return false
	end
	local player = source
	local item_table = getElementData(player,"Item")
	local itemname_old = item_table[oldid]
	local itemname_new = item_table[newid]
	if itemname_old == itemname_new then
		local anzahl_new = getElementData(player,"Item",newid.."_Menge")
		local anzahl_old = getElementData(player,"Item",oldid.."_Menge")
		local gesamt = anzahl_new + anzahl_old
		if gesamt <= itemData[itemname_old]["Stack_max"] then
			setData(player,"Item",newid.."_Menge",gesamt,true)
			local saved = mysql_query(Datenbank,"UPDATE `inventarinhalt` SET `Menge`='"..MySQL_Save( getElementData(player,"Item",newid.."_Menge") ).."' WHERE `id`='"..MySQL_Save(newid).."'")
			local tasche = itemData[itemname_new]["Tasche"]
			removeItemFromPlatz(player,tasche,oldplatz,anzahl_old)
		end
	end
end
addEvent("c_stackItems",true)
addEventHandler("c_stackItems",getRootElement(),c_stackItems)

function c_setItemPlace(tasche,platz,nplatz) 
	if(source ~= client) then
		return false
	end
	setItemPlace(source,tasche,platz,nplatz)
end
addEvent("c_setItemPlace",true)
addEventHandler("c_setItemPlace",getRootElement(),c_setItemPlace)

function removeItemFromPlatz(player,tasche,platz,anzahl)
		
		local id = getElementData(player,"Item_"..tasche,platz.."_id")
		if(not id) then
			return false
		end

		if(not anzahl) then
			anzahl = getElementData(player,"Item",id.."_Menge")
		elseif(anzahl < 0) then
			error("removeItem > You cant remove less then 0 items!",2)
			return false
		end
		local itemA = getElementData(player,"Item",id.."_Menge")
			
		if(itemA - anzahl < 0) then
			return false
		elseif(itemA - anzahl > 0) then
			setData(player,"Item",id.."_Menge",itemA - anzahl,true)
			local saved = mysql_query(Datenbank,"UPDATE `inventarinhalt` SET `Menge`='"..MySQL_Save( getElementData(player,"Item",id.."_Menge") ).."' WHERE `id`='"..MySQL_Save(id).."'")
			mysql_free_result(saved)
		else
			local saved = mysql_query(Datenbank,"DELETE FROM `inventarinhalt` WHERE `id`='"..MySQL_Save(id).."'")
			mysql_free_result(saved)
			setData(player,"Item",id,nil,true)
			setData(player,"Item",id.."_Menge",nil,true)
			setData(player,"Item",id.."_Platz",nil,true)
			setData(player,"Item_"..tasche,platz.."_id",nil,true)
		end

end

function wegwerfItem_func(item,tasche,id,platz)
	local player = client
	executeCommandHandler ( "meCMD", player, " wirft "..item.." weg..." )
	removeItemFromPlatz(player,tasche,platz)
end
addEvent("wegwerfItem",true)
addEventHandler("wegwerfItem",getRootElement(),wegwerfItem_func)


function getFreePlacesForItem(player,item)
	
	if inventar_debug == true then
		outputDebugString("INV-DEBUG-getFreePlacesForItem: Spieler: "..getPlayerName(player).." | Item: "..item)
	end
	
	if itemData[item] then
		local tasche = itemData[item]["Tasche"]
		local invplaetze = getInventarPlaces(player,tasche)
		local stackmax = itemData[item]["Stack_max"]
		local item_max = itemData[item]["Item_Max"]
		local placesplus = 0
		local anzahl = 0
		
		local places = 0
		
		if getPlayerItemAnzahl(player,item) >= item_max then
			return 0
		end
		
		for i = 0, invplaetze,1 do
			local platz = i
			local id = getElementData(player,"Item_"..tasche,platz.."_id")
			local item_table = getElementData(player,"Item")
			local itemname = item_table[id]
			anzahl = 0
			placesplus = 0
			if itemname then
				if itemname == item then
					anzahl = tonumber(getElementData(player,"Item",id.."_Menge"))
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

function removeItem(player,item,anzahl)
	if inventar_debug == true then
		outputDebugString("INV-DEBUG-removeItem: Spieler: "..getPlayerName(player).." | Item: "..item.." | Anzahl: "..anzahl)
	end
	
	if itemData[item] then
		local tasche = itemData[item]["Tasche"]
		local invplaetze = getInventarPlaces(player,tasche)
		for i = 0, invplaetze,1 do
			local platz = i
			local id = getElementData(player,"Item_"..tasche,platz.."_id")
			local item_table = getElementData(player,"Item")
			local itemname = item_table[id]
			local invanzahl = 0
			placesplus = 0
			if itemname then
				if itemname == item then
					invanzahl = tonumber(getElementData(player,"Item",id.."_Menge"))
					if invanzahl >=anzahl then
						removeItemFromPlatz(player,tasche,platz,anzahl)
						return
					end
				end
			end
		end
		
		
		for i=1,anzahl,1 do
			removeOneItem(player,item)
		end
	end
end

function removeOneItem(player,item)
	if itemData[item] then
		local tasche = itemData[item]["Tasche"]
		local invplaetze = getInventarPlaces(player,tasche)
		local anzahl = 0
		for i = 0, invplaetze,1 do
			anzahl = 0
			local platz = i
			local id = getElementData(player,"Item_"..tasche,platz.."_id")
			local item_table = getElementData(player,"Item")
			local itemname = item_table[id]
			if itemname == item then
				anzahl = getElementData(player,"Item",id.."_Menge")
				if anzahl > 1 then
					setData(player,"Item",id.."_Menge",anzahl - 1,true)
					local saved = mysql_query(Datenbank,"UPDATE `inventarinhalt` SET `Menge`='"..MySQL_Save( getElementData(player,"Item",id.."_Menge") ).."' WHERE `id`='"..MySQL_Save(id).."'")
					mysql_free_result(saved)
					return true
				elseif anzahl == 1 then
					removeItemFromPlatz(player,tasche,platz,1)
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


function getPlatzForItem(player,item,itemanzahl)
	if itemData[item] then
		local tasche = itemData[item]["Tasche"]
		local invplaetze = getInventarPlaces(player,tasche)
		local stackmax = itemData[item]["Stack_max"]
		for i = 0, invplaetze,1 do
			local platz =i
			local id = getElementData(player,"Item_"..tasche,platz.."_id")
			local item_table = getElementData(player,"Item")
			local itemname = item_table[id]
			local anzahl = 0
			if itemname == item then
				anzahl = tonumber(getElementData(player,"Item",id.."_Menge"))+itemanzahl
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

function getPlayerItemAnzahl(player,item)
	
	if inventar_debug == true then
		outputDebugString("INV-DEBUG-getPlayerItemAnzahl: Spieler: "..getPlayerName(player).." | Item: "..item)
	end
	
	if itemData[item] then
		local tasche = itemData[item]["Tasche"]
		local invplaetze = getInventarPlaces(player,tasche)
		local anzahl = 0
		for i = 0, invplaetze,1 do
			local platz = i
			local id = getElementData(player,"Item_"..tasche,platz.."_id")
			local item_table = getElementData(player,"Item")
			local itemname = item_table[id]
			if itemname == item then
				anzahl = anzahl+tonumber(getElementData(player,"Item",id.."_Menge"))
			end
		end
		return anzahl
	else
		outputDebugString("[INV] Unglültiges Item: "..item)
	end
end

function giveItem(player,item,anzahl)
	
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
		local new_items = getPlayerItemAnzahl(player,item)+anzahl
		
		if new_items > max_items  then
			outputChatBox("Die maximale Anzahl des Items '"..item.."' beträgt "..max_items.."!",player,255,0,0)
			return
		end
		
		local item_table = getElementData(player,"Item")
		
		local platztyp = "new"
		
		local stackplatz = getPlatzForItem(player,item,anzahl)
		if stackplatz then
			platztyp = "stack"
			platz = stackplatz
		else
			platz = getLowEmptyPlace(player,tasche)
		end
		if platz then

			local id = getElementData(player,"Item_"..tasche,platz.."_id")
			if platztyp == "stack" then
				--outputDebugString("giveItem - OldStack")
				local itemA = getElementData(player,"Item",id.."_Menge")
				setData(player,"Item",id.."_Menge",itemA + anzahl,true)
				local saved = mysql_query(Datenbank,"UPDATE `inventarinhalt` SET `Menge`='"..MySQL_Save( getElementData(player,"Item",id.."_Menge") ).."' WHERE `id`='"..MySQL_Save(id).."'")
				mysql_free_result(saved)
				triggerClientEvent(player,"setIKoords_c",player,platz,tasche)
				return true

			elseif platztyp == "new" then
				if anzahl > 0 then
				--	outputDebugString("giveItem - NewStack")
					local saved = mysql_query(Datenbank, "INSERT INTO `inventarinhalt` (Name,Menge,Objekt,Platz,Tasche) VALUES ('"..MySQL_Save(getPlayerName(player)).."','"..MySQL_Save(anzahl).."','"..MySQL_Save(item).."','"..MySQL_Save(platz).."','"..MySQL_Save(tasche).."')")
					mysql_free_result(saved)
					
					local result = mysql_query(Datenbank, "SELECT * FROM `inventarinhalt` WHERE Name = '"..MySQL_Save(getPlayerName(player)).."' AND `Tasche`='"..tasche.."' AND `Platz`='"..platz.."' AND `Objekt`='"..item.."'")
					if(result) then
						if mysql_num_rows(result) ~= 0 then
							for result,row in mysql_rows_assoc(result) do
								setData(player,"Item",tonumber(row["id"]),tostring(row["Objekt"]),true)
								setData(player,"Item",tonumber(row["id"]).."_Menge",tonumber(row["Menge"]),true)
								setData(player,"Item",tonumber(row["id"]).."_Platz",tonumber(row["Platz"]),true)
								setData(player,"Item_"..tostring(row["Tasche"]),tonumber(row["Platz"]).."_id",tonumber(row["id"]),true)
							end
						else
							outputDebugString("GIVE Anzahl ist 0!")
							mysql_free_result(result)
						end
					else
						outputDebugString("GIVE Die Daten konnten nicht aus der Tabelle 'inventarinhalt' ausgelesen werden!")
						mysql_free_result(result)
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