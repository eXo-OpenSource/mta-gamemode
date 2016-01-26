-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Admin.lua
-- *  PURPOSE:     Admin class
-- *
-- ****************************************************************************
Admin = inherit(Singleton)

function Admin:constructor()
  self.m_OnlineAdmins = {}
	
	self.m_RankNames = {
		[1] = "Supporter",
		[2] = "Moderator",
		[3] = "Super-Moderator",
		[4] = "Administrator",
		[5] = "Projektleiter"
	}
	
	addRemoteEvents{"adminSetPlayerFaction"}
	
	addCommandHandler("admins", bind(self.onlineList, self))
	addCommandHandler("a", bind(self.chat, self))
	addCommandHandler("o", bind(self.ochat, self))
	addCommandHandler("adminmenu", bind(self.openAdminMenu, self))
	addCommandHandler("goto", bind(self.goToPlayer, self))
	addCommandHandler("gethere", bind(self.getHerePlayer, self))
	addCommandHandler("tp", bind(self.teleportTo, self))
	addEventHandler("adminSetPlayerFaction", root, bind(self.Event_adminSetPlayerFaction, self))
	outputDebugString("Admin loaded")
end

function Admin:destructor()
	removeCommandHandler("admins", bind(self.onlineList, self))
	removeCommandHandler("a", bind(self.chat, self))
	removeCommandHandler("o", bind(self.ochat, self))
end

function Admin:addAdmin(player,rank)
	outputDebugString("Added Admin "..player:getName())
	self.m_OnlineAdmins[player] = rank
end

function Admin:removeAdmin(player)
	self.m_OnlineAdmins[player] = nil
end

function Admin:openAdminMenu( player ) 
	if self.m_OnlineAdmins[player] > 0 then
		triggerClientEvent(player,"showAdminMenu",player)
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:chat(player,cmd,...)
	if player:getRank() >= RANK.Supporter then
		local msg = table.concat( {...}, " " )
		local rankName = self.m_RankNames[player:getRank()]
		local text = ("[ %s %s ]: %s"):format(_(rankName, player), player:getName(), msg)
		self:sendMessage(text,255,255,0)
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:sendMessage(msg,r,g,b)
	for key, value in pairs(self.m_OnlineAdmins) do
		outputChatBox(msg, key, r,g,b)
	end
end

function Admin:ochat(player,cmd,...)
	if player:getRank() >= RANK.Supporter then
		local rankName = self.m_RankNames[player:getRank()]
		local msg = table.concat( {...}, " " )
		outputChatBox(("[ %s %s ]: %s"):format(_(rankName, player), player:getName(), msg), root, 50, 200, 255)
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:onlineList(player)
	
		outputChatBox("Folgende Teammitglieder sind derzeit online:",player,50,200,255)
		for key, value in pairs(self.m_OnlineAdmins) do
			outputChatBox(self.m_RankNames[value].." "..key:getName(),player,255,255,255)
		end

end

function Admin:goToPlayer(player,cmd,target)
	if player:getRank() >= RANK.Supporter then
		if target then
			local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
			local x,y,z = getElementPosition(target)
			if isPedInVehicle(player) then removePedFromVehicle(player) end
			setElementPosition(player,x+0.01,y,z)
		else
			player:sendError(_("Kein Ziel eingegeben!", player))
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:getHerePlayer(player,cmd,target)
	if player:getRank() >= RANK.Supporter then
		if target then
			local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
			local x,y,z = getElementPosition(player)
			if isPedInVehicle(target) then removePedFromVehicle(target) end
			setElementPosition(target,x+0.01,y,z)
		else
			player:sendError(_("Kein Ziel eingegeben!", player))
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:teleportTo(player,cmd,ort)
	local tpTable = {
		["noobspawn"] = 	{["x"]= 1481.288, ["y"]=-1753.393, ["z"]=13.54687,["typ"] = "Orte"},
		["mountchilliard"] ={["x"]=-2321.659, ["y"]=-1638.790, ["z"]=483.7031,["typ"] = "Orte"},
		["startower"] = 	{["x"]=1544.0634, ["y"]=-1352.865, ["z"]=329.4750,["typ"] = "Orte"},
		["buehne"] = 		{["x"]=318.84375, ["y"]=-1801.556, ["z"]=4.633217,["typ"] = "Orte"},
		["casino"] = 		{["x"]=1821.6538, ["y"]=-1684.816, ["z"]=13.38281,["typ"] = "Orte"},
		["paintball"] = 	{["x"]=1849.3808, ["y"]=-1257.169, ["z"]=13.39062,["typ"] = "Orte"},
		["ammu"] = 			{["x"]=1357.5644, ["y"]=-1280.081, ["z"]=13.29938,["typ"] = "Orte"},
		["sannews"] = 		{["x"]=757.33300, ["y"]=-1400.400, ["z"]=13.36718,["typ"] = "Unternehmen"},
		["fahrschule"] = 	{["x"]=1372.3007, ["y"]=-1655.556, ["z"]=13.38281,["typ"] = "Unternehmen"},
		["mech"] = 			{["x"]=886.21777, ["y"]=-1220.473, ["z"]=16.97656,["typ"] = "Unternehmen"},
		["pt"] = 			{["x"]=1821.6269, ["y"]=-1886.315, ["z"]=13.35982,["typ"] = "Unternehmen"},
		["rnd"] = 			{["x"]=2898.3359, ["y"]=-774.2070, ["z"]=10.84404,["typ"] = "Unternehmen"},
		["grove"] = 		{["x"]=2492.4296, ["y"]=-1664.581, ["z"]=13.34375,["typ"] = "Fraktionen"},
		["army"] = 			{["x"]=2706.7177, ["y"]=-2405.295, ["z"]=13.51257,["typ"] = "Fraktionen"},
		["atzecas"] = 		{["x"]=382.73831, ["y"]=2232.8793, ["z"]=42.09375,["typ"] = "Fraktionen"},
		["lcn"] = 			{["x"]=722.83886, ["y"]=-1196.875, ["z"]=19.12306,["typ"] = "Fraktionen"},
		["rescue"] = 		{["x"]=1795.0996, ["y"]=-1757.618, ["z"]=13.54687,["typ"] = "Fraktionen"},
		["yakuza"] = 		{["x"]=757.33300, ["y"]=-1400.400, ["z"]=13.36718,["typ"] = "Fraktionen"},
		["fbi"] = 			{["x"]=1634.0410, ["y"]=-1739.902, ["z"]=13.53907,["typ"] = "Fraktionen"},
		["lspd"] = 			{["x"]=1535.3554, ["y"]=-1673.450, ["z"]=13.38281,["typ"] = "Fraktionen"},
		["vatos"] = 		{["x"]=2691.6318, ["y"]=-2003.450, ["z"]=13.39194,["typ"] = "Fraktionen"},
		["biker"] = 		{["x"]=667.99609, ["y"]=-485.0830, ["z"]=16.18750,["typ"] = "Fraktionen"},
		["area"] = 			{["x"]=112.34863, ["y"]=1963.3906, ["z"]=18.98105,["typ"] = "Fraktionen"},
		["lv"] = 			{["x"]=1797.1542, ["y"]=843.14648, ["z"]=10.63281,["typ"] = "Städte"},
		["sf"] = 			{["x"]=1991.0194, ["y"]=154.79472, ["z"]=27.53906,["typ"] = "Städte"},
		["ls"] =			{["x"]=1507.3977, ["y"]=-959.6733, ["z"]=36.24750,["typ"] = "Städte"}
	}
	local x,y,z = 0,0,0
	if ort then
		for k,v in pairs(tpTable) do
			if ort == k then
				if isPedInVehicle(player) then removePedFromVehicle(player) end
				setElementPosition(player,v["x"],v["y"],v["z"])
				return
			end
		end
		player:sendError(_("Ungültiger Ort! Tippe /tp um alle Orte zu sehen!", player))
	else
		outputChatBox("Hier sind alle Orte aufgelistet:", player, 255, 255, 255 )
		local strings = {}
		for k,v in pairs(tpTable) do
			if not strings[v["typ"]] then strings[v["typ"]] = "" end
			strings[v["typ"]] = strings[v["typ"]]..k.."|"
		end
		for v in pairs(strings) do
			outputChatBox(v..": "..strings[v], player, 0, 125, 0 )
		end
	end
end

function Admin:Event_adminSetPlayerFaction(targetPlayer,Id)
	if client:getRank() >= RANK.Supporter then
		local faction = FactionManager:getSingleton():getFromId(Id)
		if faction then
			faction:addPlayer(targetPlayer,6)
			client:sendInfo(_("Du hast den Spieler in die Fraktion "..faction:getName().." gesetzt!", client))
		else
			client:sendError(_("Fraktion nicht gefunden!", client))
		end
	end
end