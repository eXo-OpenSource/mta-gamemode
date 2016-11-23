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
    self.m_SupportArrow = {}
    self.m_RankNames = {
        [1] = "Ticketsupporter",
        [2] = "Clanmember",
        [3] = "Supporter",
        [4] = "Moderator",
        [5] = "Administrator",
        [6] = "Servermanager",
        [7] = "Developer",
        [8] = "StellvProjektleiter",
        [9] = "Projektleiter"
    }


    addCommandHandler("admins", bind(self.onlineList, self))
    addCommandHandler("a", bind(self.chat, self))
    addCommandHandler("o", bind(self.ochat, self))
    addCommandHandler("adminmenu", bind(self.openAdminMenu, self))
    addCommandHandler("goto", bind(self.goToPlayer, self))
    addCommandHandler("gethere", bind(self.getHerePlayer, self))
    addCommandHandler("tp", bind(self.teleportTo, self))
    addCommandHandler("getVeh", bind(self.getVehFromId, self))

    addCommandHandler("addFactionVehicle", bind(self.addFactionVehicle, self))
    addCommandHandler("addCompanyVehicle", bind(self.addCompanyVehicle, self))

    local adminCommandBind = bind(self.command, self)

    addCommandHandler("timeban", adminCommandBind)
    addCommandHandler("permaban", adminCommandBind)
    addCommandHandler("prison", adminCommandBind)
    addCommandHandler("unprison", adminCommandBind)
    addCommandHandler("smode", adminCommandBind)
    addCommandHandler("rkick", adminCommandBind)
    addCommandHandler("warn", adminCommandBind)
    addCommandHandler("spect", adminCommandBind)
    addCommandHandler("clearchat", adminCommandBind)
	addCommandHandler("mark", adminCommandBind)
	addCommandHandler("gotomark", adminCommandBind)
	
    addRemoteEvents{"adminSetPlayerFaction", "adminSetPlayerCompany", "adminTriggerFunction",
    "adminGetPlayerVehicles", "adminPortVehicle", "adminPortToVehicle", "adminSeachPlayer", "adminSeachPlayerInfo",
    "adminRespawnFactionVehicles", "adminRespawnCompanyVehicles", "adminVehicleDespawn"}

    addEventHandler("adminSetPlayerFaction", root, bind(self.Event_adminSetPlayerFaction, self))
    addEventHandler("adminSetPlayerCompany", root, bind(self.Event_adminSetPlayerCompany, self))
    addEventHandler("adminTriggerFunction", root, bind(self.Event_adminTriggerFunction, self))
    addEventHandler("adminGetPlayerVehicles", root, bind(self.Event_vehicleRequestInfo, self))
    addEventHandler("adminPortVehicle", root, bind(self.Event_portVehicle, self))
    addEventHandler("adminPortToVehicle", root, bind(self.Event_portToVehicle, self))
    addEventHandler("adminSeachPlayer", root, bind(self.Event_seachPlayer, self))
    addEventHandler("adminSeachPlayerInfo", root, bind(self.Event_getPlayerInfo, self))
    addEventHandler("adminRespawnFactionVehicles", root, bind(self.Event_respawnFactionVehicles, self))
    addEventHandler("adminRespawnCompanyVehicles", root, bind(self.Event_respawnCompanyVehicles, self))
    addEventHandler("adminVehicleDespawn", root, bind(self.Event_vehicleDespawn, self))


end

function Admin:destructor()
	removeCommandHandler("admins", bind(self.onlineList, self))
    removeCommandHandler("timeban", adminCommandBind)
    removeCommandHandler("permaban", adminCommandBind)
    removeCommandHandler("prison", adminCommandBind)
    removeCommandHandler("smode", adminCommandBind)
    removeCommandHandler("rkick", adminCommandBind)
    removeCommandHandler("warn", adminCommandBind)
    removeCommandHandler("spect", adminCommandBind)
    removeCommandHandler("clearchat", adminCommandBind)
	removeCommandHandler("a", bind(self.chat, self))
	removeCommandHandler("o", bind(self.ochat, self))
end

function Admin:addAdmin(player,rank)
	outputDebug("Added Admin "..player:getName())
	self.m_OnlineAdmins[player] = rank
    player:setPublicSync("DeathTime", DEATH_TIME_ADMIN)
    if DEBUG then
        bindKey(player, "j", "down", function(player)
            if not doesPedHaveJetPack(player) then
              givePedJetPack(player)
           else
              removePedJetPack ( player )
           end
        end)
    end
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

function Admin:Event_seachPlayer(name)
    if client:getRank() >= RANK.Supporter then
        local resultPlayers = {}
        local result = sql:queryFetch("SELECT Id, Name FROM ??_account WHERE Name LIKE ?;", sql:getPrefix(), ("%%%s%%"):format(name))
        for i, row in pairs(result) do
            resultPlayers[row.Id] = row.Name
        end
        client:triggerEvent("adminReceiveSeachedPlayers", resultPlayers)
    end
end

function Admin:Event_getPlayerInfo(Id, name)
    local client = client
    if client:getRank() >= RANK.Supporter then
        Async.create( -- player:load()/:save() needs a aynchronous execution
            function ()
                local player, isOffline = DatabasePlayer.get(Id)
                if player then
                    if isOffline then
                        player:load()
                    end

                    local data = {
                        Name = name;
                        PlayTime = player:getPlayTime();
                        Job = player:getJob() and player:getJob():getId() or false;
                        Money = player:getMoney();
                        BankMoney = player:getBankMoney() or false;
                        Faction = player:getFaction() and player:getFaction():getShortName() or false;
                        Company = player:getCompany() and player:getCompany():getShortName() or false;
                        Group = player:getGroup() and player:getGroup():getName() or false;
                        Skin = player:getSkin() or false;
                        Ban = Ban.checkOfflineBan(Id);
						Karma = player:getKarma();
                    }

                    if isOffline then
                        delete(player)
                    end
                    client:triggerEvent("adminReceiveSeachedPlayerInfo", data)
                end
            end
        )()
    end
end

function Admin:Event_respawnFactionVehicles(Id)
    local faction = FactionManager:getSingleton():getFromId(Id)
    if faction then
        faction:respawnVehicles()
        client:sendShortMessage(_("%s Fahrzeuge respawnt", client, faction:getShortName()))
    end
end

function Admin:Event_respawnCompanyVehicles(Id)
    local company = CompanyManager:getSingleton():getFromId(Id)
    if company then
        company:respawnVehicles()
        client:sendShortMessage(_("%s Fahrzeuge respawnt", client, company:getName()))
    end
end

function Admin:command(admin, cmd, targetName, arg1, arg2)
    if cmd == "smode" or cmd == "clearchat" then
        self:Event_adminTriggerFunction(cmd, nil, nil, nil, admin)
	elseif cmd == "mark" then 
		self:markPosFunc(admin, false)
	elseif cmd == "gotomark" then 
		self:markPosFunc(admin, true)
    else
        if targetName then
            local target = PlayerManager:getSingleton():getPlayerFromPartOfName(targetName, admin)
            if isElement(target) then
                if cmd == "spect" then
                    self:Event_adminTriggerFunction(cmd, target, nil, nil, admin)
                    return
                else
                    if arg1 then
                        if cmd == "rkick" or cmd == "permaban" then
                            self:Event_adminTriggerFunction(cmd, target, arg1, 0, admin)
                            return
                        else
                            if arg2 then
                                self:Event_adminTriggerFunction(cmd, target, arg2, arg1, admin)
                                return
                            else
                                admin:sendError(_("Befehl: /%s [Ziel] [Dauer] [Grund]", admin, cmd))
                                return
                            end
                        end
                    end
                end
            end
        end
        if cmd == "spect" then
            admin:sendError(_("Befehl: /%s [Ziel]", admin, cmd))
            return
        elseif cmd == "rkick" or cmd == "permaban" then
            admin:sendError(_("Befehl: /%s [Ziel] [Grund]", admin, cmd))
            return
        else
            admin:sendError(_("Befehl: /%s [Ziel] [Dauer] [Grund]", admin, cmd))
            return
        end
	end
end

function Admin:Event_adminTriggerFunction(func, target, reason, duration, admin)
    if client and isElement(client) then
        admin = client
    elseif isElement(admin) then
        admin = admin
    else
        outputDebug("Event_adminTriggerFunction Error - Admin not found")
        return
    end

    if admin:getRank() >= ADMIN_RANK_PERMISSION[func] then
        if func == "goto" then
            self:goToPlayer(admin, func, target:getName())
        elseif func == "gethere" then
            self:getHerePlayer(admin, func, target:getName())
        elseif func == "kick" or func == "rkick" then
            self:sendShortMessage(_("%s hat %s gekickt! Grund: %s", admin, admin:getName(), target:getName(), reason))
            target:kick(admin, reason)
        elseif func == "prison" then
            duration = tonumber(duration)
            self:sendShortMessage(_("%s hat %s für %d Minuten ins Prison gesteckt! Grund: %s", admin, admin:getName(), target:getName(), duration, reason))
            target:setPrison(duration*60)
            self:addPunishLog(admin, target, func, reason, duration*60)
        elseif func == "unprison" then
            self:sendShortMessage(_("%s hat %s aus dem Prison gelassen!", admin, admin:getName(), target:getName()))
            target:endPrison()
            self:addPunishLog(admin, target, func)
        elseif func == "timeban" then
            duration = tonumber(duration)
			self:sendShortMessage(_("%s hat %s für %d Stunden gebannt! Grund: %s", admin, admin:getName(), target:getName(), duration, reason))
            Ban.addBan(target, admin, reason, duration*60*60)
            self:addPunishLog(admin, target, func, reason, duration*60*60)
        elseif func == "permaban" then
            self:sendShortMessage(_("%s hat %s permanent gebannt! Grund: %s", admin, admin:getName(), target:getName(), reason))
            Ban.addBan(target, admin, reason)
            self:addPunishLog(admin, target, func, reason, 0)
        elseif func == "addWarn" or func == "warn" then
            self:sendShortMessage(_("%s hat %s verwarnt! Ablauf in %d Tagen, Grund: %s", admin, admin:getName(), target:getName(), duration, reason))
            Warn.addWarn(target, admin, reason, duration*60*60*24)
            target:sendMessage(_("Du wurdest von %s verwarnt! Ablauf in %s Tagen, Grund: %s", target, admin:getName(), duration, reason), 255, 0, 0)
            self:addPunishLog(admin, target, func, reason, duration*60*60*24)
        elseif func == "removeWarn" then
            self:sendShortMessage(_("%s hat einen Warn von %s entfernt!", admin, admin:getName(), target:getName()))
            local id = reason
            Warn.removeWarn(target, id)
            self:addPunishLog(admin, target, func, "", 0)
        elseif func == "supportMode" or func == "smode" then
            self:toggleSupportMode(admin)
        elseif func == "clearchat" or func == "clearChat" then
			self:sendShortMessage(_("%s den aktuellen Chat gelöscht!", admin, admin:getName()))
            for index, player in pairs(Element.getAllByType("player")) do
                for i=0, 2100 do
                    player:outputChat(" ")
                end
                player:triggerEvent("closeAd")
            end
        elseif func == "adminAnnounce" then
            local text = target
            triggerClientEvent("announceText", admin, text)
        elseif func == "spect" then
            self:sendShortMessage(_("%s spected %s!", admin, admin:getName(), target:getName()))
            admin:sendInfo(_("Drücke Leertaste um das specten zu beenden!", admin))
            setCameraTarget(admin, target)
            admin:setFrozen(true)
			admin.m_PreSpectInt = getElementInterior(admin)
			admin.m_PreSpectDim = getElementDimension(admin)
			admin.m_SpectInteriorFunc = function ( int ) setElementInterior(admin,int); setCameraInterior(admin, int) end
			addEventHandler("onElementInteriorChange", target, admin.m_SpectInteriorFunc)
			admin.m_SpectDimensionFunc = function ( dim ) setElementDimension(admin,dim) end
			addEventHandler("onElementDimensionChange", target, admin.m_SpectDimensionFunc)
			if admin:isInVehicle() then
				admin:getOccupiedVehicle():setFrozen(true)
			end
            bindKey(admin, "space", "down", function()
                setCameraTarget(admin, admin)
                self:sendShortMessage(_("%s hat das specten von %s beendet!", admin, admin:getName(), target:getName()))
                unbindKey(admin, "space", "down")
                admin:setFrozen(false)
				if admin:isInVehicle() then
					admin:getOccupiedVehicle():setFrozen(false)
				end
				setElementInterior(admin, admin.m_PreSpectInt)
				setElementDimension(admin, admin.m_PreSpectDim)
				removeEventHandler("onElementDimensionChange", target, admin.m_SpectDimensionFunc)
				removeEventHandler("onElementInteriorChange", target, admin.m_SpectInteriorFunc)
            end)
        elseif func == "offlinePermaban" then
            self:sendShortMessage(_("%s hat %s offline permanent gebannt! Grund: %s", admin, admin:getName(), target, reason))
            local targetId = Account.getIdFromName(target)
            if targetId and targetId > 0 then
                Ban.addBan(targetId, admin, reason)
                self:addPunishLog(admin, targetId, func, reason, 0)
            else
                admin:sendError(_("Spieler nicht gefunden!", admin))
            end
        elseif func == "offlineTimeban" then
            self:sendShortMessage(_("%s hat %s offline für %d Stunden gebannt! Grund: %s", admin, admin:getName(), target, duration, reason))
            local targetId = Account.getIdFromName(target)
            if targetId and targetId > 0 then
                Ban.addBan(targetId, admin, reason, duration*60*60)
                self:addPunishLog(admin, targetId, func, reason, duration*60*60)
            else
                admin:sendError(_("Spieler nicht gefunden!", admin))
            end
        elseif func == "offlineUnban" then
            self:sendShortMessage(_("%s hat %s offline entbannt!", admin, admin:getName(), target))
            local targetId = Account.getIdFromName(target)
            if targetId and targetId > 0 then
                self:addPunishLog(admin, targetId, func, reason, 0)
                sql:queryExec("DELETE FROM ??_bans WHERE serial = ?;", sql:getPrefix(), Account.getLastSerialFromId(targetId))
            else
                admin:sendError(_("Spieler nicht gefunden!", admin))
            end
        end
    else
        admin:sendError(_("Du darst diese Aktion nicht ausführen!", admin))
    end
end

function Admin:chat(player,cmd,...)
	if player:getRank() >= RANK.Supporter then
		local msg = table.concat( {...}, " " )
		if self.m_RankNames[player:getRank()] then
			local text = ("[ %s %s ]: %s"):format(_(self.m_RankNames[player:getRank()], player), player:getName(), msg)
			self:sendMessage(text,255,255,0)
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:toggleSupportMode(player)
    if not player:getPublicSync("supportMode") then
        player:setPublicSync("supportMode", true)
        player:sendInfo(_("Support Modus aktiviert!", player))
        self:sendShortMessage(_("%s hat den Support Modus aktiviert!", player, player:getName()))
        player:setPublicSync("Admin:OldSkin", player:getModel())
        player:setModel(260)
        self:toggleSupportArrow(player, true)
		player.m_SupMode = true
		player:triggerEvent("setSupportDamage", true )
    else
        player:setPublicSync("supportMode", false)
        player:sendInfo(_("Support Modus deaktiviert!", player))
        self:sendShortMessage(_("%s hat den Support Modus deaktiviert!", player, player:getName()))
        player:setModel(player:getPublicSync("Admin:OldSkin"))
        self:toggleSupportArrow(player, false)
		player.m_SupMode = false
		player:triggerEvent("setSupportDamage", false)
    end
end

function Admin:toggleSupportArrow(player, state)
	if state == true then
		if isElement(self.m_SupportArrow[player]) then self.m_SupportArrow[player]:destroy() end
        local pos = player:getPosition()
		self.m_SupportArrow[player] = createMarker(pos, "arrow" ,0.5, 255, 255, 0)
        self.m_SupportArrow[player]:attach(player, 0, 0, 1.5)
        self.m_DeleteArrowBind = bind(self.deleteArrow, self)
		addEventHandler("onPlayerQuit", player, self.m_DeleteArrowBind)
		addEventHandler("onPlayerWasted", player, self.m_DeleteArrowBind)
	elseif state == false then
        if isElement(self.m_SupportArrow[player]) then self.m_SupportArrow[player]:destroy() end
        removeEventHandler("onPlayerQuit", player, self.m_DeleteArrowBind)
		removeEventHandler("onPlayerWasted", player, self.m_DeleteArrowBind)
	end
end

function Admin:deleteArrow()
    if isElement(self.m_SupportArrow[source]) then self.m_SupportArrow[source]:destroy() end
end

function Admin:sendMessage(msg,r,g,b)
	for key, value in pairs(self.m_OnlineAdmins) do
		outputChatBox(msg, key, r,g,b)
	end
end

function Admin:sendShortMessage(text, ...)
	for player, rank in pairs(self.m_OnlineAdmins) do
		player:sendShortMessage(("Admin: %s"):format(text), ...)
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
			if isElement(target) then
                self:sendShortMessage(_("%s hat sich zu %s geportet!", player, player:getName(), target:getName()))
                local dim,int = target:getDimension(), target:getInterior()
				local pos = target:getPosition()
				pos.x = pos.x + 0.01
				if player:isInVehicle() then player = player:getOccupiedVehicle() pos.z = pos.z+1.5 end
				player:setPosition(pos)
				player:setDimension(dim)
				player:setInterior(int)
			end
		else
			player:sendError(_("Kein Ziel eingegeben!", player))
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:getHerePlayer(player, cmd, target)
	if player:getRank() >= RANK.Supporter then
		if target then
			local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
			if isElement(target) then
                self:sendShortMessage(_("%s hat %s zu sich geportet!", player, player:getName(), target:getName()))
                local dim,int = player:getDimension(), player:getInterior()
				local pos = player:getPosition()
				pos.x = pos.x + 0.1
				if target:isInVehicle() then target = target:getOccupiedVehicle() pos.z = pos.z+1.5 end
				target:setPosition(pos)
				target:setDimension(dim)
				target:setInterior(int)
			end
		else
			player:sendError(_("Kein Ziel eingegeben!", player))
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:teleportTo(player,cmd,ort)
local tpTable = {
        ["noobspawn"] =     {["x"]= 1479.99,  ["y"]=-1747.69,  ["z"]=13.55,   ["typ"] = "Orte"},
        ["mountchilliad"]=  {["x"]=-2321.659, ["y"]=-1638.790, ["z"]=483.7031,["typ"] = "Orte"},
        ["startower"] =     {["x"]=1544.0634, ["y"]=-1352.865, ["z"]=329.4750,["typ"] = "Orte"},
        ["strand"] =        {["x"]=333.79,    ["y"]=-1799.40,  ["z"]=4.37,    ["typ"] = "Orte"},
        ["casino"] =        {["x"]=1471.12,   ["y"]=-1166.35,  ["z"]=23.63,   ["typ"] = "Orte"},
        ["flughafenls"] =   {["x"]=1993.06,   ["y"]=-2187.38,  ["z"]=13.23,   ["typ"] = "Orte"},
        ["flughafenlv"] =   {["x"]=1427.05,   ["y"]=1558.48,   ["z"]=10.50,   ["typ"] = "Orte"},
        ["flughafensf"] =   {["x"]=-1559.40,  ["y"]=-445.55,   ["z"]=5.73,    ["typ"] = "Orte"},
        ["stadthalle"] =    {["x"]=1802.17,   ["y"]=-1284.10,  ["z"]=13.33,   ["typ"] = "Orte"},
        ["ammunation"] =    {["x"]=1357.5644, ["y"]=-1280.081, ["z"]=13.29938,["typ"] = "Orte"},
        ["bank"] =          {["x"]=2294.48,   ["y"]=-11.43,    ["z"]=26.02,   ["typ"] = "Orte"},
        ["garten"] =        {["x"]=2450.16,   ["y"]=110.44,    ["z"]=26.16,   ["typ"] = "Orte"},
        ["premium"] =       {["x"]=1246.52,   ["y"]=-2055.33,  ["z"]=59.53,   ["typ"] = "Orte"},
        ["pizzajob"] =      {["x"]=2096.89,   ["y"]=-1826.28,  ["z"]=13.24,   ["typ"] = "Orte"},
        ["helijob"] =       {["x"]=1796.39,   ["y"]=-2318.27,  ["z"]=13.11,   ["typ"] = "Orte"},
        ["mülljob"] =       {["x"]=2102.45,   ["y"]=-2094.60,  ["z"]=13.23,   ["typ"] = "Orte"},
        ["lkwjob1"] =       {["x"]=2409.07,   ["y"]=-2471.10,  ["z"]=13.30,   ["typ"] = "Orte"},
        ["lkwjob2"] =       {["x"]=-234.96,   ["y"]=-254.46,   ["z"]=1.11,    ["typ"] = "Orte"},
        ["holzfällerjob"] = {["x"]=1041.02,   ["y"]=-343.88,   ["z"]=73.67,   ["typ"] = "Orte"},
        ["farmerjob"] =     {["x"]=-1049.75,  ["y"]=-1205.90,  ["z"]=128.66,  ["typ"] = "Orte"},
        ["sweeperjob"] =    {["x"]=219.49,    ["y"]=-1429.61,  ["z"]=13.01,   ["typ"] = "Orte"},
        ["drogentruck"] =   {["x"]=-1079.60,  ["y"]=-1620.10,  ["z"]=76.19,   ["typ"] = "Orte"},
        ["waffentruck"] =   {["x"]=-1864.28,  ["y"]=1407.51,   ["z"]=6.91,    ["typ"] = "Orte"},
        ["gabelstablerjob"] = {["x"]=93.67,   ["y"]=-205.68,   ["z"]=1.23,    ["typ"] = "Orte"},
        ["zombiesurvival"] =  {["x"]=-49.47,  ["y"]=1375.64,   ["z"]=9.86,    ["typ"] = "Orte"},
        ["snipergame"] =      {["x"]=-525.74, ["y"]=1972.69,   ["z"]=60.17,   ["typ"] = "Orte"},
        ["bikeshop"] =        {["x"]=2857.96, ["y"]=-1536.69,  ["z"]=10.73,   ["typ"] = "Orte"},
        ["bootshop"] =        {["x"]=1629.65, ["y"]=582.17,    ["z"]=11.44,    ["typ"] = "Orte"},
        ["sultanshop"] =      {["x"]=2127.09, ["y"]=-1135.96,  ["z"]=25.20,   ["typ"] = "Orte"},
        ["lvshop"] =          {["x"]=2198.23, ["y"]=1386.43,   ["z"]=10.55,   ["typ"] = "Orte"},
        ["quadshop"] =        {["x"]=117.53,  ["y"]=-165.56,   ["z"]=1.31,    ["typ"] = "Orte"},
        ["infernusshop"] =    {["x"]=545.20,  ["y"]=-1278.90,  ["z"]=16.97,   ["typ"] = "Orte"},
        ["tampashop"] =       {["x"]=1098.83, ["y"]=-1240.20,  ["z"]=15.55,   ["typ"] = "Orte"},
        ["bulletshop"] =      {["x"]=1135.19,   ["y"]=-1688.71,  ["z"]=13.51, ["typ"] = "Orte"},
        ["race"] =            {["x"]=2723.40,   ["y"]=-1851.72,  ["z"]=9.29,  ["typ"] = "Orte"},
        ["afk"] =             {["x"]=1567.72,   ["y"]=-1886.07,  ["z"]=13.24, ["typ"] = "Orte"},
        ["24-7"] =            {["x"]=1352.43,   ["y"]=-1752.75,  ["z"]=13.04, ["typ"] = "Orte"},
        ["tankstelle"] =      {["x"]=1944.21,   ["y"]=-1772.91,  ["z"]=13.07, ["typ"] = "Orte"},
        ["schatzsucher"] =    {["x"]=706.22,    ["y"]=-1699.38,  ["z"]=3.12,  ["typ"] = "Orte"},
        ["burgershot"] =      {["x"]=1187.46,   ["y"]=-924.68,   ["z"]=42.83, ["typ"] = "Orte"},
        ["sannews"] =         {["x"]=762.05,    ["y"]=-1343.33,  ["z"]=13.20,   ["typ"] = "Unternehmen"},
        ["fahrschule"] =      {["x"]=1372.3007, ["y"]=-1655.556, ["z"]=13.38281,["typ"] = "Unternehmen"},
        ["mechaniker"] =      {["x"]=886.21777, ["y"]=-1220.473, ["z"]=16.97656,["typ"] = "Unternehmen"},
        ["ept"] = 				{["x"]=1791.10,   ["y"]=-1901.46,  ["z"]=13.08,   ["typ"] = "Unternehmen"},
        ["grove"] =           {["x"]=2492.4296, ["y"]=-1664.581, ["z"]=13.34375,["typ"] = "Fraktionen"},
        ["lcn"] =             {["x"]=722.83886, ["y"]=-1196.875, ["z"]=19.12306,["typ"] = "Fraktionen"},
        ["rescue"] =          {["x"]=1727.42,   ["y"]=-1738.01,  ["z"]=13.14,   ["typ"] = "Fraktionen"},
        ["fbi"] =             {["x"]=1534.83,   ["y"]=-1440.72,  ["z"]=13.16,   ["typ"] = "Fraktionen"},
        ["pd"] =              {["x"]=1536.06,   ["y"]=-1675.63,  ["z"]=13.11,   ["typ"] = "Fraktionen"},
        ["pdgarage"] =        {["x"]=1543.18,    ["y"]=-1698.22,  ["z"]=5.57,    ["typ"] = "Fraktionen"},
        ["area"] =            {["x"]=134.53,    ["y"]=1929.06,   ["z"]=18.89,   ["typ"] = "Fraktionen"},
        ["ballas"] =          {["x"]=2685.32,   ["y"]=-2003.91,  ["z"]=13.40,   ["typ"] = "Fraktionen"},
        ["lv"] =              {["x"]=2078.15,   ["y"]=1005.51,   ["z"]=10.43,   ["typ"] = "Städte"},
        ["sf"] =              {["x"]=-1988.09,  ["y"]=148.66,    ["z"]=27.22,   ["typ"] = "Städte"},
        ["bayside"] =         {["x"]=-2504.66,  ["y"]=2420.90,   ["z"]=16.33,   ["typ"] = "Städte"},
        ["ls"] =              {["x"]=1507.3977, ["y"]=-959.6733, ["z"]=36.24750,["typ"] = "Städte"},
    }
	local x,y,z = 0,0,0
	if player:getRank() >= ADMIN_RANK_PERMISSION["tp"] then
		if ort then
			for k,v in pairs(tpTable) do
				if ort == k then
					if player:isInVehicle() then
						player:getOccupiedVehicle():setPosition(v["x"], v["y"], v["z"])
					else
						setElementInterior(player,0)
						setElementDimension(player,0)
						player:setPosition(v["x"], v["y"], v["z"])
					end
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
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:addPunishLog(admin, player, type, reason, duration)
    StatisticsLogger:getSingleton():addPunishLog(admin, player, type, reason, duration)

end

function Admin:Event_adminSetPlayerFaction(targetPlayer,Id)
	if client:getRank() >= RANK.Supporter then

        if targetPlayer:getFaction() then targetPlayer:getFaction():removePlayer(targetPlayer) end

        if Id == 0 then
            client:sendInfo(_("Du hast den Spieler aus seiner Fraktion entfernt!", client))
        else
            local faction = FactionManager:getSingleton():getFromId(Id)
    		if faction then
    			faction:addPlayer(targetPlayer,6)
    			client:sendInfo(_("Du hast den Spieler in die Fraktion "..faction:getName().." gesetzt!", client))
    		else
    			client:sendError(_("Fraktion nicht gefunden!", client))
    		end
        end

	end
end

function Admin:Event_adminSetPlayerCompany(targetPlayer,Id)
	if client:getRank() >= RANK.Supporter then
        if targetPlayer:getCompany() then targetPlayer:getCompany():removePlayer(targetPlayer) end
        if Id == 0 then
            client:sendInfo(_("Du hast den Spieler aus seinem Unternehmen entfernt!", client))
        else
            local company = CompanyManager:getSingleton():getFromId(Id)
    		if company then
    			company:addPlayer(targetPlayer,5)
    			client:sendInfo(_("Du hast den Spieler in das Unternehmen "..company:getName().." gesetzt!", client))
    		else
    			client:sendError(_("Unternehmen nicht gefunden!", client))
    		end
        end
	end
end

function Admin:Event_vehicleRequestInfo(target)
	local vehicles = {}
	for k, vehicle in pairs(target:getVehicles()) do
        vehicles[vehicle:getId()] = {vehicle, vehicle:getPositionType()}
	end

	client:triggerEvent("adminVehicleRetrieveInfo", vehicles)
end

function Admin:Event_portVehicle(veh)
    if client:getRank() >= RANK.Supporter then
        local pos = client:getPosition()
		veh:setInterior(client:getInterior())
		veh:setDimension(client:getDimension())
		veh:setPosition(pos.x+1, pos.y+1, pos.z+1)
        veh:setInGarage(false)
        veh:setPositionType(VehiclePositionType.World)
		client:sendInfo(_("Das Fahrzeug wurde zu dir geportet!", client))
    end
end

function Admin:Event_portToVehicle(veh)
    if client:getRank() >= RANK.Supporter then
        local pos = client:getPosition()
        local pos = veh:getPosition()
		client:setInterior(veh:getInterior())
		client:setDimension(veh:getDimension())
		client:setPosition(pos.x+1, pos.y+1, pos.z+1)
		client:sendInfo(_("Du wurdest zum Fahrzeug geportet!", client))
    end
end

function Admin:addFactionVehicle(player, cmd, factionID)
	if player:getRank() >= RANK.Supporter then
		if isPedInVehicle(player) then
			if factionID then
				factionID = tonumber(factionID)
				local faction = FactionManager:getFromId(factionID)
				if faction then
					local veh = getPedOccupiedVehicle(player)
					local model = getElementModel(veh)
					local posX, posY, posZ = getElementPosition(veh)
					local rotX, rotY, rotZ = getElementRotation(veh)
					FactionVehicle:create(faction, model, posX, posY, posZ, rotZ)
				else
					player:sendError(_("Fraktion nicht gefunden!", player))
				end
			else
				player:sendError(_("Befehl: /addFactionVehicle [FactionID]!", player))
			end
		else
			player:sendError(_("Du sitzt in keinem Fahrzeug!", player))
		end
	end
end

function Admin:addCompanyVehicle(player, cmd, companyID)
	if player:getRank() >= RANK.Supporter then
		if isPedInVehicle(player) then
			if companyID then
				companyID = tonumber(companyID)
				local company = CompanyManager:getFromId(companyID)
				if company then
					local veh = getPedOccupiedVehicle(player)
					local posX, posY, posZ = getElementPosition(veh)
					local rotX, rotY, rotZ = getElementRotation(veh)
					CompanyVehicle:create(company, veh.model, posX, posY, posZ, rotZ)
				else
					player:sendError(_("Unternehmen nicht gefunden!", player))
				end
			else
				player:sendError(_("Befehl: /addCompanyVehicle [CompanyID]!", player))
			end
		else
			player:sendError(_("Du sitzt in keinem Fahrzeug!", player))
		end
	end
end

function Admin:getVehFromId(player, cmd, vehId)
    if player:getRank() >= RANK.Supporter then
        if vehId then
            for index, veh in ipairs(getElementsByType("vehicle")) do
                if veh.getId then
                    if veh:getId() == tonumber(vehId) then
                        veh:setPosition(player:getPosition())
                        veh:setDimension(player:getDimension())
                        veh:setInterior(player:getInterior())
                        return
                    end
                end
            end
            player:sendError(_("Keine Fahrzeug gefunden!", player))
        else
            player:sendError(_("Keine ID Angegeben!", player))
        end
    end
end

function Admin:Event_vehicleDespawn()
    if client:getRank() >= RANK.Supporter then
        if isElement(source) then
            client:sendInfo(_("Du hast das Fahrzeug %s despawnt!", client, source:getName()))
            source:setDimension(2)
        end
    end
end

function Admin:markPosFunc( player, goto ) 
	if goto then 
		local markPos = getElementData( player, "Admin_MarkPos")
		if markPos then 
			player:sendInfo("Du hast dich zur Markierung geportet!")
			if getPedOccupiedVehicle(player) then 
				player = getPedOccupiedVehicle(player)
			end
			setElementInterior(player, markPos[4])
			setElementDimension(player, markPos[5])
			setElementPosition( player, markPos[1], markPos[2], markPos[3])
			setCameraTarget(player,player)
		else 
			player:sendError("Du hast keine Markierung /mark")
		end
	else
		local x,y,z = getElementPosition(player)
		local dim = getElementDimension(player)
		local interior = getElementInterior(player)
		setElementData(player, "Admin_MarkPos",{x,y,z,interior,dim})
		player:sendInfo("Markierung gesetzt!")
	end
end

