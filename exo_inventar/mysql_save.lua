local function quitPlayer()	
	if(getElementData(source,"loggedin") == false) then
		return 1
	end
	local time = getRealTime()
	updatePlayerTable(source,"UnL","benutzertabelle","Passwort")

end
addEventHandler ( "onPlayerQuit", getRootElement(), quitPlayer )

local function onResourceStop(rs)
	if(rs ~= getThisResource()) then
		return false
	end
	
	local players = getElementsByType("player")
	for index, value in ipairs(players) do
		if(getElementData(value,"loggedin")) then
			updatePlayerTable(value,"UnL","benutzertabelle","Passwort")
		end
	end
end
addEventHandler ( "onResourceStop", getRootElement(), onResourceStop)

function updatePlayerTable(player,elementDataName,tableName,...)
	if(getElementData(player,"loggedin") ~= true) then
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
	for i,v in pairs(getElementData(player,elementDataName)) do
		if(not isDistricted[tostring(i)]) then
			if(i == "Name" or i == "Benutzername") then
				nameTag = i
			else
				if(mysqlString ~= "") then
					mysqlString = tostring(mysqlString)..",`"..MySQL_Save(tostring(i)).."`='"..MySQL_Save(tostring(v)).."'"
				else
					mysqlString = "`"..MySQL_Save(i).."`='"..MySQL_Save(tostring(v)).."'"
				end
			end
		else
		end

	end
	local saved = mysql_query(Datenbank,"UPDATE `"..tostring(tableName).."` SET "..tostring(mysqlString).." WHERE `"..tostring(nameTag).."`='"..MySQL_Save(getPlayerName(player)).."'")
	return true
end

function insertPlayerTable(player,elementData,tableName)
	if(getElementData(player,"loggedin") ~= true) then
		return false
	end

	local index = ""
	local value = ""
	
	for i,v in pairs(getElementData(player,elementDataName)) do
			if(mysqlString ~= "") then
				index = index..","..MySQL_Save(i)
				value = value..",'"..MySQL_Save(v).."'"
			else
				index = MySQL_Save(i)
				value = "'"..MySQL_Save(v).."'"
			end
	end
	local saved = mysql_query(Datenbank, "INSERT INTO `"..tostring(tableName).."` ("..tostring(index)..") VALUES ("..tostring(value)..")")
	mysql_free_result(saved)
	return true
end

function readTable(player,tableName,synch,...)
	local result
	if(not synch) then
		synch = false
	end
	local bedTable= {...} -- bed = Bedingung
	local playername = getPlayerName(player)
	if(bedTable[2]) then
		local mysqlString = tostring("SELECT * FROM `"..tostring(tableName).."` WHERE `"..MySQL_Save(tostring(bedTable[1])).."`='"..MySQL_Save(tostring(bedTable[2])).."'")
		result = mysql_query(Datenbank, mysqlString)
	else
		local mysqlString = tostring("SELECT * FROM `"..tostring(tableName).."` WHERE `Name`='"..MySQL_Save(playername).."'")
		result = mysql_query(Datenbank, mysqlString)
	end
	if(mysql_num_rows(result) ~= 0) then
		local pInfo = mysql_fetch_assoc(result)
		mysql_free_result(result)
		for index,wert in pairs(pInfo) do
			if(tonumber(wert)) then
				setData(player,tostring(tableName),tostring(index),tonumber(wert),synch)
			else
				setData(player,tostring(tableName),tostring(index),wert,synch)
			end
		end
	else
		outputDebugString("Die Daten von "..playername.." konnten nicht aus der Tabelle '"..tableName.."' ausgelesen werden!")
		mysql_free_result(result)
	end
	
end

--  Fixen + Item World Spawn zuende machen + Items aufhebbar machen + Items wegschmeißbar machen (world) + Items verschieben + MouseDown Bug beheben + Items Use + Items Handeln + Tresore + Items Kofferräume + Items Mülleimer