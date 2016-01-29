-- while schleife in andere if-Abfragen reinpacken...

itemData = {}

function createPlayerInventar(player)
	local pname = getPlayerName(player)
	local saved = mysql_query(Datenbank, "INSERT INTO `inventarinfo` (Name) VALUES ('"..MySQL_Save(pname).."')")
	if(saved) then
		setTimer(giveItem,1000,1,player,"eXoPad",1)
		setTimer(giveItem,1000,1,player,"Ausweis-Fuehrerschein",1)
		mysql_free_result(saved)
	end
end


local function resourceStart()

	local result = mysql_query(Datenbank, "SELECT * FROM `inventardef`")
	if(mysql_num_rows(result) ~= 0) then
		
		for r,row in mysql_rows_assoc(result) do
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

		mysql_free_result(result)
	else
		
		outputDebugString("Die Daten konnten nicht aus der Tabelle 'inventardef' ausgelesen werden!")
		mysql_free_result(result)
	end
	
	for theKey,playeritem in ipairs(getElementsByType ( "player" )) do 
		loadPlayerInventar(playeritem)
	end
end
setTimer(resourceStart,1500,1)

function loadPlayerInventar(player)
	

	if not isElement(player) then source = player end
	
	
	
	if isElement(player) then
		if inventar_debug == true then
			outputDebugString("INV-DEBUG-loadPlayerInventar: Spieler: "..getPlayerName(player))
		end
		
		local playername = getPlayerName(player)
		local result = mysql_query(Datenbank, "SELECT * FROM `inventarinfo` WHERE `Name`='"..MySQL_Save(playername).."'")
		if(mysql_num_rows(result) ~= 0) then
			local pInfo = mysql_fetch_assoc(result)
			mysql_free_result(result)
			for index,wert in pairs(pInfo) do
				if(tonumber(wert)) then
					setData(player,"Inventar",tostring(index),tonumber(wert),true)
				else
					setData(player,"Inventar",tostring(index),wert,true)
				end
			end
		else
			createPlayerInventar(player)
			loadPlayerInventar(player)
			--outputDebugString("Die Daten des Spielers "..playername.." konnten nicht aus der Tabelle 'inventarinfo' ausgelesen werden!")
			mysql_free_result(result)
		end
		
		local playername = getPlayerName(player)
		
		setData(player,"Item","","",true)
		setData(player,"Item_Menge","","",true)
		setData(player,"Item_Platz","","",true)
		setData(player,"Item_Tasche","","",true)

		local result = mysql_query(Datenbank, "SELECT * FROM `inventarinhalt` WHERE `Name`='"..MySQL_Save(playername).."'")
		if(mysql_num_rows(result) ~= 0) then
			for result,row in mysql_rows_assoc(result) do
				if tonumber(row["Menge"]) > 0 then
					setData(player,"Item",tonumber(row["id"]),tostring(row["Objekt"]),true)
					setData(player,"Item",tonumber(row["id"]).."_Menge",tonumber(row["Menge"]),true)
					setData(player,"Item",tonumber(row["id"]).."_Platz",tonumber(row["Platz"]),true)
					setData(player,"Item_"..tostring(row["Tasche"]),tonumber(row["Platz"]).."_id",tonumber(row["id"]),true)
				else
					removeItemFromPlatz(player,row["Tasche"],tonumber(row["Platz"]))
				end
			end
			mysql_free_result(result)
		else
			mysql_free_result(result)
		end
		
		triggerClientEvent(player,"loadItemDataFromServer",player,itemData)
		
		triggerClientEvent(player,"loadPlayerInventarClient",player)
		
		loadSpecialItems(player)
	end
end
addEventHandler ( "onPlayerJoin", getRootElement(), loadPlayerInventar )
addCommandHandler("loadinv",loadPlayerInventar)

function loadSpecialItems(player)
	local ablauf_ts = MySQL_GetString( "items_special", "Ablauf", "Item = 'Mautpass' AND Spieler LIKE '"..getPlayerName(player).."'" )
	if ablauf_ts then
		ablauf_ts = tonumber(ablauf_ts)
	--	if ablauf_ts > 0 then
			local now = getRealTime().timestamp
			if ablauf_ts < now then
				outputChatBox("Dein Mautpass ist abgelaufen! Er wurde aus deinem Inventar entfernt!",player,255,0,0)
				removeItem(player,"Mautpass",1)
				local result = mysql_query(Datenbank, "DELETE FROM  items_special WHERE Item = 'Mautpass' AND Spieler LIKE '"..getPlayerName(player).."'")
			end
	--	end
	end
	local maske = MySQL_GetString( "items_special", "Wert", "Item = 'Maske' AND Spieler LIKE '"..getPlayerName(player).."'" )
	if maske then
		maske = tonumber(maske)
		exoSetElementData(player,"maske_id",maske)
	end
	local helm = MySQL_GetString( "items_special", "Wert", "Item = 'Helm' AND Spieler LIKE '"..getPlayerName(player).."'" )
	if helm then
		helm = tonumber(helm)
		exoSetElementData(player,"helm_id",helm)
	end
	
end

local function onPlayerQuit()
	if(not getElementData(source,"loggedin")) then
		return 0
	end
	updatePlayerTable(source,"Inventar","inventarinfo")
	-- Save in den einzelnen Funktionen in inventar_functions_s.lua
end
addEventHandler("onPlayerQuit",getRootElement(),onPlayerQuit)

local function onStop(rs)
	if(rs ~= getThisResource) then
		return 0
	end
	local players = getElementsByType("player")
	for index, value in ipairs(players) do
		if(getElementData(value,"loggedin")) then
			updatePlayerTable(value,"Inventar","inventarinfo")
		end
	end
	
	-- Save in den einzelnen Funktionen in inventar_functions_s.lua
end
addEventHandler("onResourceStop",root,onStop)

local function changePlaces(player,tasche,oPlace,nPlace)
	if(client ~= player) then
		return false
	end
	setItemPlace(player,tasche,oPlace,-1)
	setItemPlace(player,tasche,nPlace,oPlace)
	setItemPlace(player,tasche,-1,nPlace)
end
addEvent("changePlaces",true)
addEventHandler("changePlaces",getRootElement(),changePlaces)