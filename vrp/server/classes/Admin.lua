-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Admin.lua
-- *  PURPOSE:     Admin class
-- *
-- ****************************************************************************
Admin = inherit(Singleton)
ADMIN_OVERLAP_THRESHOLD = 5

function Admin:constructor()
    self.m_OnlineAdmins = {}
    self.m_MtaAccounts = {}

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

	self.m_RankColors = {
		[1] = {120, 120, 120, true},
		[2] = {210, 40, 100, true},
		[3] = {200, 170, 40, true},
		[4] = {75, 150, 200, true},
		[5] = {60, 185, 100, true},
		[6] = {235, 130, 10, true},
		[7] = {160, 65, 180, true},
		[8] = {200, 75, 60, true},
		[9] = {180, 60, 60, true},
	}

	local bankAccountId = 1
	self.m_BankAccount = BankAccount.load(bankAccountId) or BankAccount.create(BankAccountTypes.Admin, bankAccountId)

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
	self.m_ToggleJetPackBind = bind(self.toggleJetPack, self)

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
	addCommandHandler("gotocords", adminCommandBind)
	addCommandHandler("cookie", adminCommandBind)

	addCommandHandler("drun", bind(self.runString, self))
	addCommandHandler("dpcrun", bind(self.runPlayerString, self))
	addCommandHandler("reloadhelp", bind(self.reloadHelpText, self))

    addRemoteEvents{"adminSetPlayerFaction", "adminSetPlayerCompany", "adminTriggerFunction", "adminOfflinePlayerFunction", "adminGetOfflineWarns",
    "adminGetPlayerVehicles", "adminPortVehicle", "adminPortToVehicle", "adminSeachPlayer", "adminSeachPlayerInfo",
    "adminRespawnFactionVehicles", "adminRespawnCompanyVehicles", "adminVehicleDespawn", "openAdminGUI","checkOverlappingVehicles","admin:acceptOverlappingCheck", "onClientRunStringResult","adminObjectPlaced","adminGangwarSetAreaOwner","adminGangwarResetArea"}


    addEventHandler("adminSetPlayerFaction", root, bind(self.Event_adminSetPlayerFaction, self))
    addEventHandler("adminSetPlayerCompany", root, bind(self.Event_adminSetPlayerCompany, self))
    addEventHandler("adminTriggerFunction", root, bind(self.Event_adminTriggerFunction, self))
    addEventHandler("adminOfflinePlayerFunction", root, bind(self.Event_offlineFunction, self))
    addEventHandler("adminGetPlayerVehicles", root, bind(self.Event_vehicleRequestInfo, self))
    addEventHandler("adminPortVehicle", root, bind(self.Event_portVehicle, self))
    addEventHandler("adminPortToVehicle", root, bind(self.Event_portToVehicle, self))
    addEventHandler("adminSeachPlayer", root, bind(self.Event_seachPlayer, self))
    addEventHandler("adminSeachPlayerInfo", root, bind(self.Event_getPlayerInfo, self))
    addEventHandler("adminRespawnFactionVehicles", root, bind(self.Event_respawnFactionVehicles, self))
    addEventHandler("adminRespawnCompanyVehicles", root, bind(self.Event_respawnCompanyVehicles, self))
    addEventHandler("adminGetOfflineWarns", root, bind(self.Event_getOfflineWarns, self))

    addEventHandler("adminVehicleDespawn", root, bind(self.Event_vehicleDespawn, self))
    addEventHandler("openAdminGUI", root, bind(self.openAdminMenu, self))
	addEventHandler("checkOverlappingVehicles", root, bind(self.checkOverlappingVehicles, self))
	addEventHandler("admin:acceptOverlappingCheck", root, bind(self.Event_OnAcceptOverlapCheck, self))
	addEventHandler("onClientRunStringResult", root, bind(self.Event_OnClientRunStringResult, self))
	addEventHandler("superman:start", root, bind(self.Event_OnSuperManStartRequest, self))
	addEventHandler("superman:stop", root, bind(self.Event_OnSuperManStopRequest, self))
	addEventHandler("adminObjectPlaced", root, bind(self.Event_ObjectPlaced, self))
	addEventHandler("adminGangwarSetAreaOwner", root, bind(self.Event_OnAdminGangwarChangeOwner, self))
	addEventHandler("adminGangwarResetArea", root, bind(self.Event_OnAdminGangwarReset, self))
	setTimer(function()
		for player, marker in pairs(self.m_SupportArrow) do
			if player and isElement(marker) and isElement(player) then
				local dim, int = player:getDimension(), player:getInterior()
				marker:attach(player, 0, 0, 1.5)
				marker:setDimension(dim)
				marker:setInterior(int)
			else
				if marker and isElement(marker) then marker:destroy() end
				if player then
					self.m_SupportArrow[player] = nil
				end
			end
		end
	end, 10000, 0)

	if DEBUG then
		addCommandHandler("placeObject", bind(self.placeObject, self))

		addEventHandler("onDebugMessage", root, function(message, level, file, line)
			for player, rank in pairs(self.m_OnlineAdmins) do
				if rank >= RANK.Supporter then
					player:triggerEvent("receiveServerDebug", message, level, file, line)
				end
			end
		end)
	end

end

function Admin:Event_OnAdminGangwarReset( id, ts )
	if client and client:getRank() >= ADMIN_RANK_PERMISSION["eventGangwarMenu"] then
		local area = Gangwar:getSingleton().m_Areas[id]
		if area then
			if not ts then ts = 0 end
			if ts < 0 then ts = 0 end
			local time = getRealTime(ts)
			local day = time.monthday
			local month = time.month+1
			local year = time.year+1900
			local hour = time.hour
			local minute = time.minute
			ts = ts - ( GANGWAR_ATTACK_PAUSE * UNIX_TIMESTAMP_24HRS )
			if ts < 0 then ts = 0 end
			area.m_LastAttack = ts
			area:update()
			area.m_RadarArea:delete()
			area:createRadar()
			self:sendShortMessage(_("%s hat die Attackier-Zeit des Gebietes %s geändert!", client, client:getName(), Gangwar:getSingleton().m_Areas[id].m_Name))
			client:sendInfo(_("Das Gebiet wird freigegeben am: "..day.."/"..month.."/"..year.." "..hour..":"..minute.."h !", client))
			client:triggerEvent("gangwarRefresh")
			StatisticsLogger:getSingleton():addAdminAction( client, "GW-AttackTime", "Gebiet: "..Gangwar:getSingleton().m_Areas[id].m_Name.."; AttackTime: "..day.."/"..month.."/"..year.." "..hour..":"..minute.."h !")
		end
	end
end

function Admin:Event_OnAdminGangwarChangeOwner( id, faction)
	if client and client:getRank() >= ADMIN_RANK_PERMISSION["eventGangwarMenu"] then
		if id and faction and id > 0 and faction > 0 then
			local area = Gangwar:getSingleton().m_Areas[id]
			if area then
				local faction = FactionManager:getSingleton():getFromId(faction)
				area.m_Owner = faction.m_Id
				local now = getRealTime().timestamp
				area.m_LastAttack = now
				area:update()
				area.m_RadarArea:delete()
				area:createRadar()
				client:sendInfo(_("Das Gebiet wurde umgesetzt!", client))
				self:sendShortMessage(_("%s hat das Gebiet %s der Fraktion %s gesetzt!", client, client:getName(), Gangwar:getSingleton().m_Areas[id].m_Name, faction:getShortName()))
				StatisticsLogger:getSingleton():addAdminAction( client, "Gangwar-Gebiet", "Gebiet: " ..Gangwar:getSingleton().m_Areas[id].m_Name.." Fraktion: "..faction:getShortName().." !")
				client:triggerEvent("gangwarRefresh")
			end
		end
	end
end

function Admin:Event_OnSuperManStartRequest()
	if client:getRank() >= ADMIN_RANK_PERMISSION["supermanFly"] then
		if client:getPublicSync("supportMode") then
			if exports["superman"] then
				exports["superman"]:startSuperMan(client)
			end
		end
	end
end

function Admin:Event_OnSuperManStopRequest()
	if client:getRank() >= RANK.Moderator then
		if client:getPublicSync("supportMode") then
			if exports["superman"] then
				exports["superman"]:stopSuperMan(client)
			end
		end
	end
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
	removeCommandHandler("gotocords", adminCommandBind)
	removeCommandHandler("crespawn", adminCommandBind)

	delete(self.m_BankAccount)
end

function Admin:addAdmin(player,rank)
	--outputDebug("Added Admin "..player:getName()) (gets outputted already (ACL addObject))
	self.m_OnlineAdmins[player] = rank
	if DEBUG then
    	player:setPublicSync("DeathTime", DEATH_TIME_ADMIN)
	end
    if DEBUG or rank >= RANK.Servermanager then
		if getAccount(player:getName().."-eXo") then removeAccount(getAccount(player:getName().."-eXo")) end
		local pw = string.random(15)
		local user = player:getName().."-eXo"
		self.m_MtaAccounts[player] = addAccount(user, pw)
		if self.m_MtaAccounts[player] then
			player:logIn(self.m_MtaAccounts[player], pw)
			ACLGroup.get("Admin"):addObject("user."..user)
			player:triggerEvent("setClientAdmin", player, rank)
		end
    end
end

function Admin:removeAdmin(player)
	self.m_OnlineAdmins[player] = nil
	if self.m_MtaAccounts[player] then
		ACLGroup.get("Admin"):removeObject("user."..self.m_MtaAccounts[player]:getName())
		removeAccount(self.m_MtaAccounts[player])
		self.m_MtaAccounts[player] = nil
	end
end

function Admin:openAdminMenu(player)
	if client then player = client end
	if self.m_OnlineAdmins[player] > 0 then
		player:triggerEvent("showAdminMenu", self.m_BankAccount:getMoney())
		player:triggerEvent("adminRefreshEventMoney", self.m_BankAccount:getMoney())
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
						Warn = Warn.getAmount(Id);
						Karma = player:getKarma();
                    }

                    if isOffline then delete(player) end
                    client:triggerEvent("adminReceiveSeachedPlayerInfo", data)
                end
            end
        )()
    end
end

function Admin:Event_respawnFactionVehicles(Id)
    local faction = FactionManager:getSingleton():getFromId(Id)
    if faction then
        faction:respawnVehicles( client )
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

function Admin:Event_getOfflineWarns(target)
	local id = Account.getIdFromName(target)

	if id then
		local result = sql:queryFetch("SELECT * FROM ??_warns WHERE userId = ?", sql:getPrefix(), id)
		for index, row in pairs(result) do
			row.adminName = Account.getNameFromId(row.adminId)
		end
		client:triggerEvent("adminReceiveOfflineWarns", result)
	end
end

function Admin:command(admin, cmd, targetName, arg1, arg2)

	if cmd == "smode" or cmd == "clearchat" then
        self:Event_adminTriggerFunction(cmd, nil, nil, nil, admin)
	elseif cmd == "mark" then
		if admin:getRank() >= ADMIN_RANK_PERMISSION["mark"] then
			self:Command_MarkPos(admin, true)
			StatisticsLogger:getSingleton():addAdminAction( admin, "mark", false)
		end
	elseif cmd == "gotomark" then
		if admin:getRank() >= ADMIN_RANK_PERMISSION["mark"] then
			self:Command_MarkPos(admin, false)
			StatisticsLogger:getSingleton():addAdminAction( admin, "gotomark", false)
		end
	elseif cmd == "gotocords" then
		local x, y, z = targetName, arg1, arg2
		if x and y and z and tonumber(x) and tonumber(y) and tonumber(z) then
			local pos = {x, y, z}
			self:Event_adminTriggerFunction(cmd, pos, nil, nil, admin)
		else
			admin:sendError("Ungültige Koordinaten: /gotocords [x] [y] [z]")
		end
	elseif cmd == "crespawn" then
		if targetName and tonumber(targetName) and tonumber(targetName) > 0 then
			self:Event_adminTriggerFunction("respawnRadius", targetName, nil, nil, admin)
		else
			admin:sendError("Radius ungültig: /crespawn [radius]")
		end
    else
		if targetName then
            local target = PlayerManager:getSingleton():getPlayerFromPartOfName(targetName, admin)
            if isElement(target) then
                if cmd == "spect" or cmd == "unprison" then
                    self:Event_adminTriggerFunction(cmd, target, nil, nil, admin)
                    return
                else
                    if arg1 then
                        if cmd == "rkick" or cmd == "permaban" or cmd == "cookie" then
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
        if cmd == "spect" or cmd == "unprison" or cmd == "freeze" then
            admin:sendError(_("Befehl: /%s [Ziel]", admin, cmd))
            return
        elseif cmd == "rkick" or cmd == "permaban" or cmd == "cookie" then
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
		elseif func == "freeze" then
            if target:isFrozen() then
				target:setFrozen(false)
				self:sendShortMessage(_("%s hat %s entfreezt!", admin, admin:getName(), target:getName()))
				target:sendShortMessage(_("Du wurdest von %s entfreezt", target, admin:getName()))
			else
				if target.vehicle then target:removeFromVehicle() end
				target:setFrozen(true)
				self:sendShortMessage(_("%s hat %s gefreezt!", admin, admin:getName(), target:getName()))
				target:sendShortMessage(_("Du wurdest von %s gefreezt", target, admin:getName()))
			end
        elseif func == "kick" or func == "rkick" then
            self:sendShortMessage(_("%s hat %s gekickt! Grund: %s", admin, admin:getName(), target:getName(), reason))
			outputChatBox("Der Spieler "..target:getName().." wurde von "..admin:getName().." gekickt!",root, 200, 0, 0)
			outputChatBox("Grund: "..reason,root, 200, 0, 0)
			kickPlayer(target, admin, reason)
        elseif func == "prison" then
            duration = tonumber(duration)
			if duration then
				self:sendShortMessage(_("%s hat %s für %d Minuten ins Prison gesteckt! Grund: %s", admin, admin:getName(), target:getName(), duration, reason))
				target:setPrison(duration*60)
				self:addPunishLog(admin, target, func, reason, duration*60)
				outputChatBox(getPlayerName(admin).." hat "..getPlayerName(target).." für "..duration.." Min. ins Prison gesteckt!",root, 200, 0, 0)
				outputChatBox("Grund: "..reason,root, 200, 0, 0)
			else
			outputChatBox("Syntax: /prison [ziel] [Zeit in Minuten] [Grund]",admin,200,0,0)
			end
		elseif func == "unprison" then
			if target then
				if target.m_PrisonTime > 0 then
					self:sendShortMessage(_("%s hat %s aus dem Prison gelassen!", admin, admin:getName(), target:getName()))
					target:endPrison()
					self:addPunishLog(admin, target, func)
				else admin:sendError("Spieler ist nicht im Prison!")
				end
			else
				outputChatBox("Syntax: /unprison [ziel]",admin,200,0,0)
			end
        elseif func == "timeban" then
			if not target then return end
            if not duration then return end
			if not reason then return end
			duration = tonumber(duration)
			self:sendShortMessage(_("%s hat %s für %d Stunden gebannt! Grund: %s", admin, admin:getName(), target:getName(), duration, reason))
            self:addPunishLog(admin, target, func, reason, duration*60*60)
			outputChatBox("Der Spieler "..getPlayerName(target).." wurde von "..getPlayerName(admin).." für "..duration.." Stunden gebannt!",root, 200, 0, 0)
			outputChatBox("Grund: "..reason,root, 200, 0, 0)
			Ban.addBan(target, admin, reason, duration*60*60)
        elseif func == "permaban" then
			if not target then return end
            if not reason or #reason == 0 then return end
			self:sendShortMessage(_("%s hat %s permanent gebannt! Grund: %s", admin, admin:getName(), target:getName(), reason))
            self:addPunishLog(admin, target, func, reason, 0)
			outputChatBox("Der Spieler "..getPlayerName(target).." wurde von "..getPlayerName(admin).." gebannt!",root, 200, 0, 0)
			outputChatBox("Grund: "..reason,root, 200, 0, 0)
			Ban.addBan(target, admin, reason)
        elseif func == "addWarn" or func == "warn" then
			if not target then return end
			if not duration then return end
			if not reason then return end
			duration = tonumber(duration)
			self:sendShortMessage(_("%s hat %s verwarnt! Ablauf in %d Tagen, Grund: %s", admin, admin:getName(), target:getName(), duration, reason))
            Warn.addWarn(target, admin, reason, duration*60*60*24)
            target:sendMessage(_("Du wurdest von %s verwarnt! Ablauf in %s Tagen, Grund: %s", target, admin:getName(), duration, reason), 255, 0, 0)
            self:addPunishLog(admin, target, func, reason, duration*60*60*24)
        elseif func == "removeWarn" then
			if not target then return end
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
                    player:sendMessage(" ")
                end
                player:triggerEvent("closeAd")
            end
			StatisticsLogger:getSingleton():addAdminAction( admin, "clearChat", false)
			outputChatBox("Der Chat wurde von "..getPlayerName(admin).." geleert!",root, 200, 0, 0)
		elseif func == "resetAction" then
			self:sendShortMessage(_("%s hat die Aktionssperre resettet! Aktionen können wieder gestartet werden!", admin, admin:getName()))
			ActionsCheck:getSingleton():reset()
			StatisticsLogger:getSingleton():addAdminAction( admin, "resetAction", false)
		elseif func == "respawnRadius" then
			local radius = tonumber(target)
			local pos = admin:getPosition()
			local col = createColSphere(pos, radius)
			local vehicles = getElementsWithinColShape(col, "vehicle")
			col:destroy()
			local count = 0
			for index, vehicle in pairs(vehicles) do
				if vehicle:isRespawnAllowed() then
					vehicle:respawn(true)
					count = count + 1
				end
			end
			self:sendShortMessage(_("%s hat %d Fahrzeuge in einem Radius von %d respawnt!", admin, admin:getName(), count, radius))
        elseif func == "adminAnnounce" then
            local text = target
            triggerClientEvent("breakingNews", root, ("%s: %s"):format(client:getName(), text), "Admin Ankündigung", {255, 150, 0}, {0, 0, 0})
			StatisticsLogger:getSingleton():addAdminAction( admin, "adminAnnounce", text)
        elseif func == "spect" then
			if not target then return end
			--if target == admin then admin:sendError("Du kannst dich nicht selbst specten!") return end
			if admin:getPrivateSync("isSpecting") then admin:sendError("Beende das spectaten zuerst!") return end

			admin.m_IsSpecting = true
			admin:setPrivateSync("isSpecting", target)
			admin.m_PreSpectInt = getElementInterior(admin)
			admin.m_PreSpectDim = getElementDimension(admin)
			admin.m_SpectInteriorFunc = function(int) admin:setInterior(int) admin:setCameraInterior(int) end -- using oop methods to prevent that onElementInteriorChange will triggered
			admin.m_SpectDimensionFunc = function(dim) admin:setDimension(dim) end -- using oop methods to prevent that onElementDimensionChange will triggered
			admin.m_SpectStop =
				function()
					for i, v in pairs(target.spectBy) do
						if v == admin then
							table.remove(target.spectBy, i)
						end
					end

					setCameraTarget(admin, admin)
					self:sendShortMessage(_("%s hat das specten von %s beendet!", admin, admin:getName(), target:getName()))
					unbindKey(admin, "space", "down")

					admin:setFrozen(false)
					if admin:isInVehicle() then admin:getOccupiedVehicle():setFrozen(false) end

					removeEventHandler("onElementDimensionChange", target, admin.m_SpectDimensionFunc)
					removeEventHandler("onElementInteriorChange", target, admin.m_SpectInteriorFunc)
					removeEventHandler("onPlayerQuit", target, admin.m_SpectStop) --trig
					admin:setInterior(admin.m_PreSpectInt)
					admin:setDimension(admin.m_PreSpectDim)

					admin.m_IsSpecting = false
					admin:setPrivateSync("isSpecting", false)
				end

			if not target.spectBy then target.spectBy = {} end
			table.insert(target.spectBy, admin)

			StatisticsLogger:getSingleton():addAdminAction( admin, "spect", target)
			self:sendShortMessage(_("%s spected %s!", admin, admin:getName(), target:getName()))
			admin:sendInfo(_("Drücke Leertaste zum beenden!", admin))

			admin:setInterior(target.interior)
			admin:setCameraInterior(target.interior)
			admin:setDimension(target.dimension)

			-- this will probably fix the camera issue
			local position = target.position
			setCameraMatrix(admin, position)
			setCameraTarget(admin, target)

			addEventHandler("onElementInteriorChange", target, admin.m_SpectInteriorFunc)
			addEventHandler("onElementDimensionChange", target, admin.m_SpectDimensionFunc)
			addEventHandler("onPlayerQuit", target, admin.m_SpectStop)
			bindKey(admin, "space", "down", admin.m_SpectStop)

			admin:setFrozen(true)
			if admin.vehicle and admin.vehicleSeat == 0 then admin.vehicle:setFrozen(true) end

		 elseif func == "eventMoneyDeposit" or func == "eventMoneyWithdraw" then
            local amount = tonumber(target)
            if amount and amount > 0 and reason then
				if func == "eventMoneyDeposit" then
					if admin:getMoney() >= amount then
						self.m_BankAccount:addMoney(amount)
						self.m_BankAccount:save()
						admin:takeMoney(amount, "Admin-Event-Kasse")
						StatisticsLogger:getSingleton():addAdminAction( admin, "eventKasse", tostring("+"..amount))
						self:sendShortMessage(_("%s hat %d$ in die Eventkasse gelegt!", admin, admin:getName(), amount))
						self:openAdminMenu(admin)
					else
						admin:sendError(_("Du hast nicht genug Geld dabei!", admin))
					end
				else
					if self.m_BankAccount:getMoney() >= amount then
						self.m_BankAccount:takeMoney(amount)
						self.m_BankAccount:save()
						admin:giveMoney(amount, "Admin-Event-Kasse")
						StatisticsLogger:getSingleton():addAdminAction( admin, "eventKasse", tostring("-"..amount))
						self:sendShortMessage(_("%s hat %d$ aus der Eventkasse genommen!", admin, admin:getName(), amount))
						self:openAdminMenu(admin)
					else
						admin:sendError(_("In der Kasse ist nicht soviel Geld!", admin))
					end
				end
            else
                admin:sendError(_("Betrag oder Grund ungültig!", admin))
            end
		elseif func == "gotocords" then
			local x, y, z = unpack(target)
			admin:setInterior(0)
			admin:setDimension(0)
			admin:setPosition(x, y, z)
			if admin.vehicle then
				admin.vehicle:setInterior(0)
				admin.vehicle:setDimension(0)
				admin.vehicle:setPosition(x, y, z)
			else
				admin:setPosition(x, y, z)
			end
			self:sendShortMessage(_("%s hat sich nach %s geportet!", admin, admin:getName(), getZoneName(x, y, z)))
			StatisticsLogger:getSingleton():addAdminAction(admin, "goto", "Coords ("..x..","..y..","..z..")")
		elseif func == "nickchange" then
			local changeTarget = false
			if target then
				if isElement(target) and func == "nickchange" then
					local oldName = target:getName()
					changeTarget = target
					if changeTarget:setNewNick(admin, reason) then
						self:sendShortMessage(_("%s hat %s in %s umbenannt!", admin, admin:getName(), oldName, reason))
					end
				end
			else
      		  admin:sendError(_("Ungültiges Ziel!", admin))
			end
		elseif func == "cookie" then
			local reason = reason:gsub("_", " ")
			if target:getInventory():giveItem("Keks", 1) then
				target:sendSuccess(_("%s hat dir einen Keks gegeben! Grund: %s", target, admin:getName(), reason))
				self:sendShortMessage(_("%s hat %s einen Keks gegeben! Grund: %s", admin, admin:getName(), target:getName(), reason))
			else
				admin:sendError(_("Es ist kein Platz für einen Keks in %s's Inventar.", admin, target:getName()))
			end
        end
    else
        admin:sendError(_("Du darfst diese Aktion nicht ausführen!", admin))
    end
end

function Admin:Event_offlineFunction(func, target, reason, duration)
	if not target then return end
	local targetId = Account.getIdFromName(target)
	if not targetId or targetId == 0 then
		admin:sendError(_("Spieler nicht gefunden!", admin))
		return
	end
	local admin = client

	if func == "offlinePermaban" then
		if not reason or #reason == 0 then return end
		self:sendShortMessage(_("%s hat %s offline permanent gebannt! Grund: %s", admin, admin:getName(), target, reason))
		Ban.addBan(targetId, admin, reason)
		self:addPunishLog(admin, targetId, func, reason, 0)
		outputChatBox("Der Spieler "..target.." wurde von "..getPlayerName(admin).." gebannt!",root, 200, 0, 0)
		outputChatBox("Grund: "..reason,root, 200, 0, 0)
    elseif func == "offlineTimeban" then
		self:sendShortMessage(_("%s hat %s offline für %d Stunden gebannt! Grund: %s", admin, admin:getName(), target, duration, reason))
		if tonumber(duration) then
			if type(reason) == "string" then
				Ban.addBan(targetId, admin, reason, duration*60*60)
				self:addPunishLog(admin, targetId, func, reason, duration*60*60)
				outputChatBox("Der Spieler "..target.." wurde von "..getPlayerName(admin).." für "..duration.." Stunden gebannt!",root, 200, 0, 0)
				outputChatBox("Grund: "..reason,root, 200, 0, 0)
			else
				admin:sendError("Keinen Grund angegeben!")
			end
		else
			admin:sendError("Keine Dauer angegeben!")
		end
    elseif func == "offlineUnban" then
		self:sendShortMessage(_("%s hat %s offline entbannt!", admin, admin:getName(), target))
		self:addPunishLog(admin, targetId, func, reason, 0)
		sql:queryExec("DELETE FROM ??_bans WHERE serial = ? OR player_id = ?;", sql:getPrefix(), Account.getLastSerialFromId(targetId), targetId)
		outputChatBox("Der Spieler "..target.." wurde von "..getPlayerName(admin).." entbannt!",root, 200, 0, 0)
	elseif func == "offlineNickchange" then
		Async.create( -- player:load()/:save() needs a aynchronous execution
			function ()
				local changeTarget, isOffline = DatabasePlayer.get(targetId)
				if changeTarget then
					if isOffline then
						changeTarget:load()
						if changeTarget:setNewNick(admin, reason) then
							self:sendShortMessage(_("%s hat %s in %s umbenannt!", admin, admin:getName(), target, reason))
							changeTarget:addOfflineMessage("Du wurdest vom Admin "..admin:getName().." von "..target.." zu "..reason.." umgenannt!",1)
							delete(changeTarget)
							return
						end
					else
						admin:sendError(_("Der Spieler ist online!", admin))
					end
				else
					admin:sendError(_("Spieler nicht gefunden!", admin))
				end
			end
		)()
	elseif func == "offlineWarn" then
		if not duration then return end
		if not reason then return end
		duration = tonumber(duration)
		self:sendShortMessage(_("%s hat %s offline verwarnt! Ablauf in %d Tagen, Grund: %s", admin, admin:getName(), target, duration, reason))
		Warn.addWarn(targetId, admin, reason, duration*60*60*24)
		self:addPunishLog(admin, targetId, func, reason, duration*60*60*24)
	elseif func == "removeOfflineWarn" then
		self:sendShortMessage(_("%s hat einen Warn von %s entfernt! (Offline)", admin, admin:getName(), target))
		local id = reason
		Warn.removeWarn(targetId, id)
		self:addPunishLog(admin, targetId, func, "", 0)
	end
end

function Admin:outputSpectatingChat(source, messageType, message, phonePartner, playerToSend)
	if source.spectBy then
		for _, admin in pairs(source.spectBy) do
			if isElement(admin) then
				outputChatBox(("[%s] %s: %s"):format(messageType, getPlayerName(source), message), admin, 150, 150, 150)
			end
		end

		return
	end

	if playerToSend then
		for _, v in pairs(playerToSend) do
			if v.spectBy then
				for _, admin in pairs(v.spectBy) do
					if isElement(admin) then
						outputChatBox(("[%s] %s: %s"):format(messageType, getPlayerName(source), message), admin, 150, 150, 150)
					end
				end
			end
		end
	end

	--[[if phonePartner and phonePartner.spectBy then

	end]]
end

function Admin:chat(player,cmd,...)
	if player:getRank() >= RANK.Ticketsupporter then
		local msg = table.concat( {...}, " " )
		if self.m_RankNames[player:getRank()] then
			local text = ("[ %s %s ]: %s"):format(_(self.m_RankNames[player:getRank()], player), player:getName(), msg)
			self:sendMessage(text,255,255,0)
			StatisticsLogger:getSingleton():addAdminAction( player, "a", text)
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:toggleJetPack(player)
	if player:getRank() >= RANK.Administrator and player:getPublicSync("supportMode") and not doesPedHaveJetPack(player) then
		givePedJetPack(player)
	else
		if doesPedHaveJetPack(player) then
			removePedJetPack(player)
		end
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
		if player:getRank() >= RANK.Moderator then
			player:triggerEvent("superman:toggle", true)
		end
		player:triggerEvent("disableDamage", true )
		StatisticsLogger:getSingleton():addAdminAction(player, "SupportMode", "aktiviert")
		bindKey(player, "j", "down", self.m_ToggleJetPackBind)
    else
        player:setPublicSync("supportMode", false)
        player:sendInfo(_("Support Modus deaktiviert!", player))
        self:sendShortMessage(_("%s hat den Support Modus deaktiviert!", player, player:getName()))
        player:setModel(player:getPublicSync("Admin:OldSkin"))
        self:toggleSupportArrow(player, false)
		player.m_SupMode = false
		if player:getRank() >= RANK.Moderator then
			player:triggerEvent("superman:toggle", false)
		end
		player:triggerEvent("disableDamage", false)
		StatisticsLogger:getSingleton():addAdminAction(player, "SupportMode", "deaktiviert")
		self:toggleJetPack(player)
		unbindKey(player, "j", "down", self.m_ToggleJetPackBind)
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

function Admin:sendMessage(msg,r,g,b, minRank)
	for key, value in pairs(self.m_OnlineAdmins) do
		if key:getRank() >= (minRank or 1) then
			outputChatBox(msg, key, r,g,b)
		end
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
		StatisticsLogger:getSingleton():addAdminAction( player, "o", ("[ %s %s ]: %s"):format(_(rankName, player), player:getName(), msg))
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:onlineList(player)
	local count = 0
	for key, value in pairs(self.m_OnlineAdmins) do
		count = count+1
	end
	if count > 0 then
		outputChatBox("Folgende Teammitglieder sind derzeit online:",player,50,200,255)
		for key, value in pairs(self.m_OnlineAdmins) do
			outputChatBox(("%s #ffffff%s"):format(self.m_RankNames[value], key:getName()),player, unpack(self.m_RankColors[value]))
		end
	else
		outputChatBox("Derzeit sind keine Teammitglieder online!",player,255,0,0)
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
				local player2 = player
				if player:isInVehicle() then player = player:getOccupiedVehicle() pos.z = pos.z+1.5 end
				player:setPosition(pos)
				setElementDimension(player, dim)
				setElementInterior(player,int)
				StatisticsLogger:getSingleton():addAdminAction( player2, "goto", target:getName())
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
				local target2 = target
				if target:isInVehicle() then target = target:getOccupiedVehicle() pos.z = pos.z+1.5 end
				target:setPosition(pos)
				setElementDimension(target,dim)
				setElementInterior(target,int)
				StatisticsLogger:getSingleton():addAdminAction( player, "gethere", target2:getName())
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
        ["noobspawn"] =     {["pos"] = Vector3(1479.99, -1747.69, 13.55),  	["typ"] = "Orte"},
        ["mountchilliad"]=  {["pos"] = Vector3(-2321.6, -1638.79, 483.70),  ["typ"] = "Orte"},
        ["startower"] =     {["pos"] = Vector3(1544.06, -1352.86, 329.47),  ["typ"] = "Orte"},
        ["strand"] =        {["pos"] = Vector3(333.79, -1799.40, 4.37),  	["typ"] = "Orte"},
        ["angeln"] =        {["pos"] = Vector3(382.74, -1897.72, 7.52),  	["typ"] = "Orte"},
        ["casino"] =        {["pos"] = Vector3(1471.12, -1166.35, 23.63),  	["typ"] = "Orte"},
        ["flughafenls"] =   {["pos"] = Vector3(1993.06, -2187.38, 13.23),  	["typ"] = "Orte"},
        ["flughafenlv"] =   {["pos"] = Vector3(1427.05, 1558.48,  10.50),  	["typ"] = "Orte"},
        ["flughafensf"] =   {["pos"] = Vector3(-1559.40, -445.55,  5.73),  	["typ"] = "Orte"},
        ["stadthalle"] =    {["pos"] = Vector3(1802.17, -1284.10, 13.33),  	["typ"] = "Orte"},
        ["bankpc"] =        {["pos"] = Vector3(2294.48, -11.43, 26.02),  	["typ"] = "Orte"},
        ["bankls"] =        {["pos"] = Vector3(1461.12, -998.87, 26.51),   	["typ"] = "Orte"},
        ["garten"] =        {["pos"] = Vector3(2450.16, 110.44, 26.16),  	["typ"] = "Orte"},
        ["premium"] =       {["pos"] = Vector3(1246.52, -2055.33, 59.53),  	["typ"] = "Orte"},
		["race"] =          {["pos"] = Vector3(2723.40, -1851.72, 9.29),  	["typ"] = "Orte"},
        ["afk"] =           {["pos"] = Vector3(1567.72, -1886.07, 13.24),  	["typ"] = "Orte"},
        ["drogentruck"] =   {["pos"] = Vector3(-1079.60, -1620.10, 76.19),  ["typ"] = "Orte"},
        ["waffentruck"] =   {["pos"] = Vector3(-1864.28, 1407.51,  6.91),  	["typ"] = "Orte"},
        ["zombie"] =  		{["pos"] = Vector3(-49.47, 1375.64,  9.86),  	["typ"] = "Orte"},
        ["snipergame"] =    {["pos"] = Vector3(-525.74, 1972.69,  60.17),  	["typ"] = "Orte"},
        ["kart"] =    		{["pos"] = Vector3(1262.375, 188.479, 19.5), 	["typ"] = "Orte"},
        ["dm"] =    		{["pos"] = Vector3(1326.55, -1561.04, 13.55), 	["typ"] = "Orte"},
		["lsdocks"] =       {["pos"] = Vector3(2711.48, -2405.28, 13.49),	["typ"] = "Orte"},
		["pferderennen"] =  {["pos"] = Vector3(1631.56, -1166.35, 23.66),  	["typ"] = "Orte"},
		["boxhalle"] =  	{["pos"] = Vector3(2225.24, -1724.91, 13.24),  	["typ"] = "Orte"},
		["grove"] =         {["pos"] = Vector3(2492.43, -1664.58, 13.34),  	["typ"] = "Orte"},
        ["pizza"] =      	{["pos"] = Vector3(2096.89, -1826.28, 13.24),  	["typ"] = "Jobs"},
        ["heli"] =       	{["pos"] = Vector3(1796.39, -2318.27, 13.11),  	["typ"] = "Jobs"},
        ["müll"] =       	{["pos"] = Vector3(2102.45, -2094.60, 13.23),  	["typ"] = "Jobs"},
        ["lkw1"] =       	{["pos"] = Vector3(2409.07, -2471.10, 13.30),  	["typ"] = "Jobs"},
        ["lkw2"] =       	{["pos"] = Vector3(-234.96, -254.46,  1.11),  	["typ"] = "Jobs"},
        ["holzfäller"] = 	{["pos"] = Vector3(1041.02, -343.88,  73.67),  	["typ"] = "Jobs"},
        ["farmer"] =     	{["pos"] = Vector3(-53.69, 78.28, 2.79), 		["typ"] = "Jobs"},
        ["sweeper"] =    	{["pos"] = Vector3(219.49, -1429.61, 13.01),  	["typ"] = "Jobs"},
		["schatzsucher"] =  {["pos"] = Vector3(706.22, -1699.38, 3.12),  	["typ"] = "Jobs"},
        ["gabelstapler"] = 	{["pos"] = Vector3(93.67, -205.68,  1.23),  	["typ"] = "Jobs"},
        ["kiesgrube"] = 	{["pos"] = Vector3(590.71, 868.91, -42.50),  	["typ"] = "Jobs"},
        ["bikeshop"] =      {["pos"] = Vector3(2857.96, -1536.69, 10.73),  	["typ"] = "Shops"},
        ["bootshop"] =      {["pos"] = Vector3(1628.25, 597.11, 1.76),  	["typ"] = "Shops"},
        ["sultanshop"] =    {["pos"] = Vector3(2127.09, -1135.96, 25.20),  	["typ"] = "Shops"},
        ["lvshop"] =        {["pos"] = Vector3(2198.23, 1386.43,  10.55),  	["typ"] = "Shops"},
        ["quadshop"] =      {["pos"] = Vector3(117.53, -165.56,  1.31),  	["typ"] = "Shops"},
        ["infernusshop"] =  {["pos"] = Vector3(545.20, -1278.90, 16.97),  	["typ"] = "Shops"},
        ["tampashop"] =     {["pos"] = Vector3(1098.83, -1240.20, 15.55),  	["typ"] = "Shops"},
        ["bulletshop"] =    {["pos"] = Vector3(1135.19, -1688.71, 13.51),  	["typ"] = "Shops"},
        ["ammunation"] =    {["pos"] = Vector3(1357.56, -1280.08, 13.30),  	["typ"] = "Shops"},
        ["24-7"] =          {["pos"] = Vector3(1352.43, -1752.75, 13.04),  	["typ"] = "Shops"},
        ["tankstelle"] =    {["pos"] = Vector3(1944.21, -1772.91, 13.07),  	["typ"] = "Shops"},
        ["burgershot"] =    {["pos"] = Vector3(1187.46, -924.68,  42.83),  	["typ"] = "Shops"},
        ["tuning"] =    	{["pos"] = Vector3(1050.65, -1031.07, 31.75),  	["typ"] = "Shops"},
        ["texture"] =    	{["pos"] = Vector3(1844.30, -1861.05, 13.38),  	["typ"] = "Shops"},
        ["cjkleidung"] =    {["pos"] = Vector3(1128.82, -1452.29, 15.48),  	["typ"] = "Shops"},
        ["sannews"] =       {["pos"] = Vector3(762.05, -1343.33, 13.20),  	["typ"] = "Unternehmen"},
        ["fahrschule"] =    {["pos"] = Vector3(1372.30, -1655.55, 13.38),  	["typ"] = "Unternehmen"},
        ["mechaniker"] =    {["pos"] = Vector3(886.21, -1220.47, 16.97),  	["typ"] = "Unternehmen"},
        ["ept"] = 			{["pos"] = Vector3(1791.10, -1901.46, 13.08),  	["typ"] = "Unternehmen"},
        --["lcn"] =           {["pos"] = Vector3(722.84, -1196.875, 19.123),	["typ"] = "Fraktionen"},
        ["rescue"] =        {["pos"] = Vector3(1727.42, -1738.01, 13.14),  	["typ"] = "Fraktionen"},
        ["fbi"] =           {["pos"] = Vector3(1257.14, -1826.52, 13.12),  	["typ"] = "Fraktionen"},
        ["pd"] =            {["pos"] = Vector3(1536.06, -1675.63, 13.11),  	["typ"] = "Fraktionen"},
        ["pdgarage"] =      {["pos"] = Vector3(1543.18, -1698.22, 5.57),  	["typ"] = "Fraktionen"},
        ["area"] =          {["pos"] = Vector3(134.53, 1929.06,  18.89),  	["typ"] = "Fraktionen"},
        ["ballas"] =        {["pos"] = Vector3(2213.78, -1435.18, 23.83),  	["typ"] = "Fraktionen"},
		["biker"] =         {["pos"] = Vector3(684.82, -485.55, 16.19),  	["typ"] = "Fraktionen"},
		["vatos"] =         {["pos"] = Vector3(2828.332, -2111.481, 12.206),["typ"] = "Fraktionen"},
		["yakuza"] =        {["pos"] = Vector3(1441.33, -1329.08, 13.55),  	["typ"] = "Fraktionen"},
		["biker"] =         {["pos"] = Vector3(684.82, -485.55, 16.19),  	["typ"] = "Fraktionen"},
        ["lv"] =            {["pos"] = Vector3(2078.15, 1005.51,  10.43),  	["typ"] = "Städte"},
        ["sf"] =            {["pos"] = Vector3(-1988.09, 148.66, 27.22),  	["typ"] = "Städte"},
        ["bayside"] =       {["pos"] = Vector3(-2504.66, 2420.90,  16.33),  ["typ"] = "Städte"},
        ["ls"] =            {["pos"] = Vector3(1507.39, -959.67, 36.24),  	["typ"] = "Städte"},
	}

	local x,y,z = 0,0,0
	if player:getRank() >= ADMIN_RANK_PERMISSION["tp"] then
		if ort then
			for k,v in pairs(tpTable) do
				if ort == k then
					if player:isInVehicle() then
						player:getOccupiedVehicle():setPosition(v["pos"])
					else
						setElementInterior(player,0)
						setElementDimension(player,0)
						player:setPosition(v["pos"])
					end
					StatisticsLogger:getSingleton():addAdminAction(player, "goto", "TP "..ort)
					self:sendShortMessage(_("%s hat sich zu %s geportet!", player, player:getName(), ort))
					return
				end
			end
			player:sendError(_("Ungültiger Ort! Tippe /tp um alle Orte zu sehen!", player))
		else
			outputChatBox("Hier sind alle Orte aufgelistet:", player, 255, 255, 0 )
			local strings = false
			local currentTyp = false
			local already = {}
			for _, _ in pairs(tpTable) do
				currentTyp = false
				strings = false
				for k,v in pairs(tpTable) do
					if not already[v["typ"]] then
						if not currentTyp then currentTyp = v["typ"] end
						if v["typ"] == currentTyp then
							if not strings then strings = "#009900"..currentTyp..": #FFFFFF" end
							strings = strings..k.." | "
							if #strings > 90 then
								outputChatBox(strings,player,255, 255, 255, true)
								strings = ""
							end
						end
					end
				end
				already[currentTyp] = true
				if strings then
					outputChatBox(strings,player,255,255,255,true)
				end
			end
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:addPunishLog(admin, player, type, reason, duration)
    StatisticsLogger:getSingleton():addPunishLog(admin, player, type, reason, duration)
end

function Admin:Event_adminSetPlayerFaction(targetPlayer, Id, rank, internal, external)
	if client:getRank() >= RANK.Supporter then

        if targetPlayer:getFaction() then
			local faction = targetPlayer:getFaction()
			if external or internal then
				HistoryPlayer:getSingleton():addLeaveEntry(targetPlayer.m_Id, client.m_Id, faction.m_Id, "faction", faction:getPlayerRank(targetPlayer), internal, external)
			end
			faction:removePlayer(targetPlayer)
		end

        if Id == 0 then
            client:sendInfo(_("Du hast den Spieler aus seiner Fraktion entfernt!", client))
        else
            local faction = FactionManager:getSingleton():getFromId(Id)
    		if faction then
				if external or internal then
					HistoryPlayer:getSingleton():addJoinEntry(targetPlayer.m_Id, client.m_Id, faction.m_Id, "faction")
					HistoryPlayer:getSingleton():setHighestRank(targetPlayer.m_Id, tonumber(rank), faction.m_Id, "faction")
				end

    			faction:addPlayer(targetPlayer, tonumber(rank))
    			client:sendInfo(_("Du hast den Spieler in die Fraktion "..faction:getName().." gesetzt!", client))
    		else
    			client:sendError(_("Fraktion nicht gefunden!", client))
    		end
        end

	end
end

function Admin:Event_adminSetPlayerCompany(targetPlayer, Id, rank, internal, external)
	if client:getRank() >= RANK.Supporter then

        if targetPlayer:getCompany() then
			local company = targetPlayer:getCompany()
			if external or internal then
				HistoryPlayer:getSingleton():addLeaveEntry(targetPlayer.m_Id, client.m_Id, company.m_Id, "company", company:getPlayerRank(targetPlayer), internal, external)
			end
			company:removePlayer(targetPlayer)
		end

        if Id == 0 then
            client:sendInfo(_("Du hast den Spieler aus seinem Unternehmen entfernt!", client))
        else
            local company = CompanyManager:getSingleton():getFromId(Id)
    		if company then
				if external or internal then
					HistoryPlayer:getSingleton():addJoinEntry(targetPlayer.m_Id, client.m_Id, company.m_Id, "company")
					HistoryPlayer:getSingleton():setHighestRank(targetPlayer.m_Id, tonumber(rank), company.m_Id, "company")
				end
    			company:addPlayer(targetPlayer, tonumber(rank))
    			client:sendInfo(_("Du hast den Spieler in das Unternehmen "..company:getName().." gesetzt!", client))
    		else
    			client:sendError(_("Unternehmen nicht gefunden!", client))
    		end
        end
	end
end

function Admin:Event_vehicleRequestInfo(target, isGroup)
	local vehicleTable = {}

	if isGroup and target:getGroup() then
		vehicleTable = target:getGroup():getVehicles()
	else
		vehicleTable = target:getVehicles()
	end

	local vehicles = {}
	for k, vehicle in pairs(vehicleTable) do
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
        if client.vehicle then return end

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

function Admin:Event_vehicleDespawn(reason)
    if client:getRank() < RANK.Clanmember then
		-- Todo: Report cheat attempt
		return
	end

	if not isElement(source) or getElementType(source) ~= "vehicle" then
		return
	end

	if not source:isRespawnAllowed() then
		client:sendError(_("Dieses Fahrzeug kann nicht despawnt werden!", client))
		return
	end

	VehicleManager:getSingleton():checkVehicle(source)

	if source:isPermanent() then
		client:sendInfo(_("Du hast das Fahrzeug %s despawnt!", client, source:getName()))

		if getElementData(source, "OwnerName") then
			local targetId = Account.getIdFromName(getElementData(source, "OwnerName"))
			if targetId and targetId > 0 then
				local delTarget, isOffline = DatabasePlayer.get(targetId)
				if delTarget then
					if isOffline then
						delTarget:addOfflineMessage(("Dein Fahrzeug (%s) wurde von %s despawnt (%s)!"):format(source:getName(), client:getName(), reason))
						delete(delTarget)
					else
						delTarget:sendInfo(_("Dein Fahrzeug (%s) wurde von %s despawnt! Grund: %s", client, source:getName(), client:getName(), reason))
					end
				end
			end
		end

		source:setDimension(PRIVATE_DIMENSION_SERVER)
		source.despawned = true
	elseif instanceof(source, TemporaryVehicle) then
		client:sendInfo(_("Du hast das Fahrzeug %s gelöscht!", client, source:getName()))
		source:destroy()
	end
end

function Admin:Command_MarkPos(player, add)
	if isElement(player) then
		if not add then
			local markPos = getElementData(player, "Admin_MarkPos")
			if markPos then
				player:sendInfo("Du hast dich zu Markierung geportet!")
				if getPedOccupiedVehicle(player) then
					player = getPedOccupiedVehicle(player)
				end
				setElementInterior(player,markPos[2])
				setElementDimension(player,markPos[3])
				player:setPosition(markPos[1])
				setCameraTarget(player)
			else
				player:sendError("Du hast keine Markierung /mark")
			end
		else
			local pos = player:getPosition()
			local dim = player:getDimension()
			local interior = player:getInterior()
			setElementData(player, "Admin_MarkPos", {pos, interior, dim})
			player:sendInfo("Markierung gesetzt!")
		end
	end
end

function Admin:reloadHelpText(player)
	if DEBUG or getPlayerName(player) == "Console" or player:getRank() >= RANK.Servermanager then
		Help:getSingleton():loadHelpTexts()
		player:sendInfo(_("Die F1 Hilfe wurde neu geladen!", player))
	end
end

function Admin:runString(player, cmd, ...)
	if DEBUG or getPlayerName(player) == "Console" or player:getRank() >= ADMIN_RANK_PERMISSION["runString"] then
		local codeString = table.concat({...}, " ")
		runString(codeString, player)
		--self:sendShortMessage(_("%s hat /drun benutzt!\n %s", player, player:getName(), codeString))
	end
end

function Admin:runPlayerString(player, cmd, target, ...)
	if DEBUG or getPlayerName(player) == "Console" or player:getRank() >= ADMIN_RANK_PERMISSION["runString"] then
		local tPlayer
		local sendResponse
		if target ~= "root" then
			tPlayer = PlayerManager:getSingleton():getPlayerFromPartOfName(target, player)
			sendResponse = true
		else
			tPlayer = root
			sendResponse = false
		end
		if tPlayer then
			triggerClientEvent(tPlayer, "onServerRunString", player, table.concat({...}, " "), sendResponse)

			--self:sendShortMessage(_("%s hat /dpcrun benutzt!\n %s", player, player:getName(), codeString))
	  	else
			player:sendError(_("Kein Ziel gefunden!", player))
		end
	end
end

function Admin:Event_OnClientRunStringResult(result)
	if isElement(source) and source:getType() == "player" then
		outputChatBox(source:getName() .." executed command: "..result, source, 255, 51, 51)
	end
end

function Admin:checkOverlappingVehicles()
	QuestionBox:new(client, client,  _("Warnung! Diese Funktion ist performance-lastig",client), "admin:acceptOverlappingCheck")
end

function Admin:Event_OnAcceptOverlapCheck()
    if source:getRank() >= RANK.Administrator then
		local vehicles = getElementsByType("vehicle")
		OVERLAPPING_VEHICLES = {}
		for i = 1, #vehicles do
			if (getElementDimension(vehicles[i]) == 0 and getElementInterior(vehicles[i])) == 0 and not (instanceof(vehicles[i], FactionVehicle) or instanceof(vehicles[i], CompanyVehicle)) then
				for i2 = 1, #vehicles do
					if vehicles[i2] ~= vehicles[i] then
						if vehicles[i].getPosition and vehicles[i2].getPosition then
							local pos1, pos2 = vehicles[i]:getPosition(), vehicles[i2]:getPosition()
							local dist = getDistanceBetweenPoints3D(pos1, pos2)
							if dist <= ADMIN_OVERLAP_THRESHOLD then
								OVERLAPPING_VEHICLES[#OVERLAPPING_VEHICLES+1] = vehicles[i]
							end
						end
					end
				end
			end
		end
		local markedVehicles = {}
		local veh, x,y,z
		for i = 1,#OVERLAPPING_VEHICLES do
			veh = OVERLAPPING_VEHICLES[i]
			if not markedVehicles[veh] then
				x,y,z = getElementPosition(veh)
				outputChatBox(x..","..y..","..z, source, 200, 0, 0)
				markedVehicles[veh] = true
			end
		end
		outputChatBox("^^^ Es wurden "..#OVERLAPPING_VEHICLES.." die sich möglicherweise Überlappen gefunden! ^^^", source, 200, 50, 0)
	else
		source:sendError("Erst ab Administrator!")
	end
end

function Admin:sendNewPlayerMessage(player)
	self:sendShortMessage(("%s hat sich soeben registriert! Hilf ihm am besten etwas auf die Sprünge!"):format(player:getName()), "Neuer Spieler!", nil, 15000)
end

function Admin:placeObject(player, cmd, model)
	if player:getRank() < RANK.Administrator then
		return
	end

	if model and tonumber(model) then
		player:triggerEvent("objectPlacerStart", tonumber(model), "adminObjectPlaced", false, true)
		player.m_PlacingInfo = {["model"] = model}
		return true
	else
		player:sendError(_("Syntax: /placeObject [Model-ID]", player))
	end
end

function Admin:Event_ObjectPlaced(x, y, z, rotation)
	if client:getRank() < RANK.Administrator then
		return
	end

	outputChatBox(("Position: %.2f, %.2f, %.2f"):format(x, y, z))
	outputChatBox(("Rotation: 0, 0, %.2f"):format(rotation))

	createObject(client.m_PlacingInfo["model"], x, y, z, 0, 0, rotation)
	client.m_PlacingInfo = nil
	return
end
