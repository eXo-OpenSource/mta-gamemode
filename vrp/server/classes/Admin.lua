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
	self.m_DeleteArrowBind = bind(self.deleteArrow, self)

    addCommandHandler("timeban", adminCommandBind)
    addCommandHandler("permaban", adminCommandBind)
    addCommandHandler("prison", adminCommandBind)
    addCommandHandler("unprison", adminCommandBind)
    addCommandHandler("aduty", adminCommandBind)
    addCommandHandler("smode", adminCommandBind)
    addCommandHandler("rkick", adminCommandBind)
    addCommandHandler("warn", adminCommandBind)
    addCommandHandler("spect", adminCommandBind)
    addCommandHandler("clearchat", adminCommandBind)
	addCommandHandler("mark", adminCommandBind)
	addCommandHandler("gotomark", adminCommandBind)
	addCommandHandler("gotocords", adminCommandBind)
	addCommandHandler("cookie", adminCommandBind)
	addCommandHandler("disablereg", adminCommandBind)
	addCommandHandler("enablereg", adminCommandBind)

	addCommandHandler("drun", bind(self.runString, self))
	addCommandHandler("dpcrun", bind(self.runPlayerString, self))
	addCommandHandler("reloadhelp", bind(self.reloadHelpText, self))

    addRemoteEvents{"adminSetPlayerFaction", "adminSetPlayerCompany", "adminTriggerFunction", "adminOfflinePlayerFunction", "adminPlayerFunction", "adminGetOfflineWarns",
    "adminGetPlayerVehicles", "adminPortVehicle", "adminPortToVehicle", "adminEditVehicle", "adminSeachPlayer", "adminSeachPlayerInfo",
	"adminRespawnFactionVehicles", "adminRespawnCompanyVehicles", "adminVehicleDespawn", "openAdminGUI","checkOverlappingVehicles","admin:acceptOverlappingCheck",
	"onClientRunStringResult","adminObjectPlaced","adminGangwarSetAreaOwner","adminGangwarResetArea", "adminLoginFix", "adminTriggerTransaction", "adminRequestMultiAccounts",
	"adminDelteMultiAccount", "adminCreateMultiAccount", "adminRequestSerialAccounts", "adminDeleteAccountFromSerial"}

    addEventHandler("adminSetPlayerFaction", root, bind(self.Event_adminSetPlayerFaction, self))
    addEventHandler("adminSetPlayerCompany", root, bind(self.Event_adminSetPlayerCompany, self))
    addEventHandler("adminTriggerFunction", root, bind(self.Event_adminTriggerFunction, self))
    addEventHandler("adminPlayerFunction", root, bind(self.Event_playerFunction, self))
    addEventHandler("adminOfflinePlayerFunction", root, bind(self.Event_offlineFunction, self))
    addEventHandler("adminGetPlayerVehicles", root, bind(self.Event_vehicleRequestInfo, self))
    addEventHandler("adminPortVehicle", root, bind(self.Event_portVehicle, self))
    addEventHandler("adminPortToVehicle", root, bind(self.Event_portToVehicle, self))
    addEventHandler("adminEditVehicle", root, bind(self.Event_EditVehicle, self))
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
	addEventHandler("adminLoginFix", root, bind(self.Event_OnAdminLoginFix, self))
	addEventHandler("adminTriggerTransaction", root, bind(self.Event_forceTransaction, self))
	addEventHandler("adminRequestMultiAccounts", root, bind(self.Event_adminRequestMultiAccounts, self))
	addEventHandler("adminDelteMultiAccount", root, bind(self.Event_adminDelteMultiAccount, self))
	addEventHandler("adminCreateMultiAccount", root, bind(self.Event_adminCreateMultiAccount, self))
	addEventHandler("adminRequestSerialAccounts", root, bind(self.Event_adminRequestSerialAccounts, self))
	addEventHandler("adminDeleteAccountFromSerial", root, bind(self.Event_adminDeleteAccountFromSerial, self))
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

function Admin:Event_OnAdminLoginFix( id  )
	if client and client:getRank() >= ADMIN_RANK_PERMISSION["loginFix"] then
		if tonumber(id) then
			if DatabasePlayer.Map[tonumber(id)] then
				DatabasePlayer.Map[tonumber(id)] = nil
				client:sendInfo(_("Die Aktion war erfolgreich (ID: %s)", client, id))
			else
				client:sendInfo(_("Der Account (ID %s) ist nicht in Benutzung!", client, id))
			end
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
    removeCommandHandler("aduty", adminCommandBind)
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
	player:triggerEvent("setClientAdmin", player, rank)
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
						PrisonTime = player.m_PrisonTime;
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
        faction:respawnVehicles(client)
        client:sendShortMessage(_("%s Fahrzeuge respawnt", client, faction:getShortName()))
    end
end

function Admin:Event_respawnCompanyVehicles(Id)
    local company = CompanyManager:getSingleton():getFromId(Id)
    if company then
        company:respawnVehicles(client)
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

function Admin:command(admin, cmd, targetName, ...)
	local argTable = {...}
	local arg1, arg2 = argTable[1], argTable[2]

	if cmd == "aduty" or cmd == "smode" or cmd == "clearchat" then
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
	elseif cmd == "disablereg" then
		if admin:getRank() >= ADMIN_RANK_PERMISSION["disablereg"] then
			self:sendShortMessage(_("%s hat die Registration deaktiviert!", admin, admin:getName()))
			StatisticsLogger:getSingleton():addAdminAction(admin, "register", "Register disabled")
		end
	elseif cmd == "enablereg" then
		if admin:getRank() >= ADMIN_RANK_PERMISSION["disablereg"] then
			self:sendShortMessage(_("%s hat die Registration aktiviert!", admin, admin:getName()))
			StatisticsLogger:getSingleton():addAdminAction(admin, "register", "Register enabled")
		end
    else
		if targetName then
            local target = PlayerManager:getSingleton():getPlayerFromPartOfName(targetName, admin)
            if isElement(target) then
                if cmd == "spect" or cmd == "unprison" then
                    self:Event_playerFunction(cmd, target, nil, nil, admin)
                    return
                else
                    if arg1 then
						if cmd == "rkick" or cmd == "permaban" or cmd == "cookie" then
							local reason = table.concat(argTable," ")
                            self:Event_playerFunction(cmd, target, reason, 0, admin)
                            return
                        else
							if arg2 then
								table.remove(argTable, 1)
								local reason = table.concat(argTable," ")
                                self:Event_playerFunction(cmd, target, reason, arg1, admin)
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

    if admin:getRank() < ADMIN_RANK_PERMISSION[func] then
		admin:sendError(_("Du darfst diese Aktion nicht ausführen!", admin))
		return
	end

	if func == "aduty" or func == "smode" then
		self:toggleSupportMode(admin)
	elseif func == "clearchat" then
		self:sendShortMessage(_("%s den aktuellen Chat gelöscht!", admin, admin:getName()))
		for index, player in pairs(Element.getAllByType("player")) do
			for i=0, 2100 do
				player:sendMessage(" ")
			end
		end
		StatisticsLogger:getSingleton():addAdminAction( admin, "clearChat", false)
		outputChatBox("Der Chat wurde von "..getPlayerName(admin).." geleert!",root, 200, 0, 0)
	elseif func == "clearAd" then
		self:sendShortMessage(_("%s die aktuelle Werbung gelöscht!", admin, admin:getName()))
		for index, player in pairs(Element.getAllByType("player")) do
			player:triggerEvent("closeAd")
		end
		StatisticsLogger:getSingleton():addAdminAction( admin, "clearAd", false)
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

	elseif func == "eventMoneyDeposit" or func == "eventMoneyWithdraw" then
		local amount = tonumber(target)
		if amount and amount > 0 and reason then
			if func == "eventMoneyDeposit" then

				if admin:transferMoney(self.m_BankAccount, amount, "Admin-Event-Kasse", "Admin", "Deposit") then
					self.m_BankAccount:save()
					StatisticsLogger:getSingleton():addAdminAction(admin, "eventKasse", tostring("+"..amount))
					self:sendShortMessage(_("%s hat %d$ in die Eventkasse gelegt!", admin, admin:getName(), amount))
					self:openAdminMenu(admin)
				else
					admin:sendError(_("Du hast nicht genug Geld dabei!", admin))
				end
			else
				if self.m_BankAccount:transferMoney({admin, false}, amount, "Admin-Event-Kasse", "Admin", "Withraw") then
					self.m_BankAccount:save()
					StatisticsLogger:getSingleton():addAdminAction(admin, "eventKasse", tostring("-"..amount))
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
	end
end

function Admin:Event_playerFunction(func, target, reason, duration, admin)
	if client and isElement(client) then
        admin = client
    elseif isElement(admin) then
        admin = admin
    else
        outputDebug("Event_playerFunction Error - Admin not found")
        return
    end

	if admin:getRank() < ADMIN_RANK_PERMISSION[func] then
		admin:sendError(_("Du darfst diese Aktion nicht ausführen!", admin))
		return
	end

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
	elseif func == "rkick" then
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
	elseif func == "warn" then
		if not target then return end
		if not duration then return end
		if not reason then return end
		duration = tonumber(duration)
		self:sendShortMessage(_("%s hat %s verwarnt! Ablauf in %d Tagen, Grund: %s", admin, admin:getName(), target:getName(), duration, reason))

		local targetId = target:getId()
		Warn.addWarn(target, admin, reason, duration*60*60*24)

		if target and isElement(target) then
			target:sendMessage(_("Du wurdest von %s verwarnt! Ablauf in %s Tagen, Grund: %s", target, admin:getName(), duration, reason), 255, 0, 0)
		end
		self:addPunishLog(admin, targetId, func, reason, duration*60*60*24)
	elseif func == "removeWarn" then
		if not target then return end
		self:sendShortMessage(_("%s hat einen Warn von %s entfernt!", admin, admin:getName(), target:getName()))
		local id = reason
		Warn.removeWarn(target, id)
		self:addPunishLog(admin, target, func, "", 0)
	elseif func == "spect" then
		if not target then return end
		--if target == admin then admin:sendError("Du kannst dich nicht selbst specten!") return end
		if admin:getPrivateSync("isSpecting") then 
			if (type(admin.m_SpectStop) == "function") then 
				admin.m_SpectStop() 
			else 
				admin:sendError("Beende das spectaten zuerst!") 
				return 
			end 
		end

		admin.m_IsSpecting = true
		admin:setPrivateSync("isSpecting", target)
		admin.m_PreSpectInt = getElementInterior(admin)
		admin.m_PreSpectDim = getElementDimension(admin)
		admin.m_SpectInteriorFunc = function(int) _setElementInterior(admin, int) admin:setCameraInterior(int) end -- using overloaded methods to prevent that onElementInteriorChange will triggered
		admin.m_SpectDimensionFunc = function(dim) _setElementDimension(admin, dim) end -- using overloaded methods to prevent that onElementDimensionChange will triggered
		admin.m_SpectStop =
			function()
				if target.spectBy then
					for i, v in pairs(target.spectBy) do
						if v == admin then
							table.remove(target.spectBy, i)
						end
					end
				end
				if admin and isElement(admin) then
					admin:triggerEvent("stopCenteredFreecam")
					admin:triggerEvent("stopWeaponRecorder")
					StatisticsLogger:getSingleton():addAdminAction(admin, "spectEnd", target)
					self:sendShortMessage(_("%s hat das specten von %s beendet!", admin, admin:getName(), target:getName()))
					unbindKey(admin, "space", "down")
					admin:setFrozen(false)
					if admin:isInVehicle() then admin:getOccupiedVehicle():setFrozen(false) end
					admin:setInterior(admin.m_PreSpectInt)
					admin:setDimension(admin.m_PreSpectDim)

					admin.m_IsSpecting = false
					admin:setPrivateSync("isSpecting", false)
				end

				removeEventHandler("onElementDimensionChange", target, admin.m_SpectDimensionFunc)
				removeEventHandler("onElementInteriorChange", target, admin.m_SpectInteriorFunc)
				removeEventHandler("onPlayerQuit", target, admin.m_SpectStop) --trig
				removeEventHandler("onPlayerQuit", admin, admin.m_SpectStop) --trig

			end

		if not target.spectBy then target.spectBy = {} end
		table.insert(target.spectBy, admin)

		StatisticsLogger:getSingleton():addAdminAction( admin, "spect", target)
		self:sendShortMessage(_("%s spected %s!", admin, admin:getName(), target:getName()))
		admin:sendInfo(_("Drücke Leertaste zum beenden!", admin))

		admin:setInterior(target.interior)
		admin:setCameraInterior(target.interior)
		admin:setDimension(target.dimension)

		admin:triggerEvent("startCenteredFreecam", target, 100, true)
		admin:triggerEvent("startWeaponRecorder")

		addEventHandler("onElementInteriorChange", target, admin.m_SpectInteriorFunc)
		addEventHandler("onElementDimensionChange", target, admin.m_SpectDimensionFunc)
		addEventHandler("onPlayerQuit", admin, admin.m_SpectStop)
		addEventHandler("onPlayerQuit", target, admin.m_SpectStop)
		bindKey(admin, "space", "down", admin.m_SpectStop)

		admin:setFrozen(true)
		if admin.vehicle and admin.vehicleSeat == 0 then admin.vehicle:setFrozen(true) end
	elseif func == "nickchange" then
		local changeTarget = false
		if target then
			if isElement(target) and func == "nickchange" then
				local oldName = target:getName()
				changeTarget = target

				Async.create(function(ac, changeTarget, admin, reason, oldName)
					if changeTarget:setNewNick(admin, reason) then
						ac:sendShortMessage(_("%s hat %s in %s umbenannt!", admin, admin:getName(), oldName, reason))
					end
				end)(self, changeTarget, admin, reason, oldName)
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
end

function Admin:Event_offlineFunction(func, target, reason, duration, admin)
	if client and isElement(client) then
        admin = client
    elseif isElement(admin) then
        admin = admin
    else
        outputDebug("Event_offlineFunction Error - Admin not found")
        return
    end

	if admin:getRank() < ADMIN_RANK_PERMISSION[func] then
		admin:sendError(_("Du darfst diese Aktion nicht ausführen!", admin))
		return
	end

	if not target then return end
	local targetId = Account.getIdFromName(target)
	if not targetId or targetId == 0 then
		admin:sendError(_("Spieler nicht gefunden!", admin))
		return
	end

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
						delete(changeTarget) -- delete it anyways if nickchange didn't succeed
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
	elseif func == "offlinePrison" then
		if duration then
			duration = tonumber(duration)
			Async.create(
			function ()
				local targetPlayer, isOffline = DatabasePlayer.get(targetId)
				if targetPlayer then
					if isOffline then
						targetPlayer:load()
						self:sendShortMessage(_("%s hat %s für %d Minuten offline ins Prison gesteckt! Grund: %s", admin, admin:getName(), target, duration, reason))
						self:addPunishLog(admin, targetId, func, reason, duration*60)
						targetPlayer:setPrison(duration*60)
						delete(targetPlayer)
					end
				end
			end)()
		end
	elseif func == "offlineUnPrison" then
		Async.create(
		function ()
			local targetPlayer, isOffline = DatabasePlayer.get(targetId)
			if targetPlayer then
				if isOffline then
					targetPlayer:load()
					self:sendShortMessage(_("%s hat %s aus dem Prison gelassen!", admin, admin:getName(), target))
					target:endPrison()
					self:addPunishLog(admin, targetId, func)
					delete(targetPlayer)
				end
			end
		end)()
	else
        outputDebug("Event_offlineFunction Error - Function not found")
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
	if player:getRank() >= RANK.Supporter and player:getPublicSync("supportMode") and not doesPedHaveJetPack(player) then
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
		--player:setWalkingStyle(138)
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
		--player:setWalkingStyle(0)
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
	if table.size(self.m_OnlineAdmins) > 0 then

		outputChatBox(" ", player, 50, 200, 255)
		outputChatBox(" ", player, 50, 200, 255)
		outputChatBox(" ", player, 50, 200, 255)
		outputChatBox("Folgende Teammitglieder sind online:", player, 50, 200, 255)
		for onlineAdmin, rank in kspairs(self.m_OnlineAdmins, function(a, b) return a:getRank() > b:getRank() end) do
			if onlineAdmin:getPublicSync("supportMode") then
				outputChatBox(("    • %s #ffffff%s (Aktiv)"):format(self.m_RankNames[rank], onlineAdmin:getName()), player, unpack(self.m_RankColors[rank]))
			end
		end
		for onlineAdmin, rank in kspairs(self.m_OnlineAdmins, function(a, b) return a:getRank() > b:getRank() end) do
			if not onlineAdmin:getPublicSync("supportMode") then
				outputChatBox(("    • %s #ffffff%s (Inaktiv)"):format(self.m_RankNames[rank], onlineAdmin:getName()), player, 192, 192, 192, true)
			end
		end
		outputChatBox(" ", player, 50, 200, 255)
		outputChatBox(" ", player, 50, 200, 255)
		outputChatBox(" ", player, 50, 200, 255)
	else
		outputChatBox("Derzeit sind keine Teammitglieder online!", player, 255, 0, 0)
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
        ["noobspawn"] =     {["pos"] = Vector3(1481.01, -1764.31, 18.80),  	["typ"] = "Orte"},
        ["mountchilliad"]=  {["pos"] = Vector3(-2321.6, -1638.79, 483.70),  ["typ"] = "Orte"},
        ["startower"] =     {["pos"] = Vector3(1544.06, -1352.86, 329.47),  ["typ"] = "Orte"},
        ["strand"] =        {["pos"] = Vector3(333.79, -1799.40, 4.37),  	["typ"] = "Orte"},
        ["angeln"] =        {["pos"] = Vector3(382.74, -1897.72, 7.52),  	["typ"] = "Orte"},
        ["casino"] =      	{["pos"] = Vector3(1471.12, -1166.35, 23.63),  	["typ"] = "Orte"},
        ["caligulas"] =     {["pos"] = Vector3(2156.73, 1677.19, 10.70),  	["typ"] = "Orte"},
        ["flughafenls"] =   {["pos"] = Vector3(1993.06, -2187.38, 13.23),  	["typ"] = "Orte"},
        ["flughafenlv"] =   {["pos"] = Vector3(1427.05, 1558.48,  10.50),  	["typ"] = "Orte"},
        ["flughafensf"] =   {["pos"] = Vector3(-1559.40, -445.55,  5.73),  	["typ"] = "Orte"},
        ["bankpc"] =        {["pos"] = Vector3(2294.48, -11.43, 26.02),  	["typ"] = "Orte"},
        ["bankls"] =        {["pos"] = Vector3(1463.00, -1033.99, 23.66),   ["typ"] = "Orte"},
        ["garten"] =        {["pos"] = Vector3(2450.16, 110.44, 26.16),  	["typ"] = "Orte"},
        ["premium"] =       {["pos"] = Vector3(1246.52, -2055.33, 59.53),  	["typ"] = "Orte"},
		["race"] =          {["pos"] = Vector3(2723.40, -1851.72, 9.29),  	["typ"] = "Orte"},
        ["afk"] =           {["pos"] = Vector3(1567.72, -1886.07, 13.24),  	["typ"] = "Orte"},
        ["drogentruck"] =   {["pos"] = Vector3(-1079.60, -1620.10, 76.19),  ["typ"] = "Orte"},
		["waffentruck"] =   {["pos"] = Vector3(-1864.28, 1407.51,  6.91),  	["typ"] = "Orte"},
		["kanal"] = 		{["pos"] = Vector3(1483.34, -1760.16, -37.31),	["typ"] = "Orte", ["interior"] = 0, ["dimension"]  = 3},
        --["zombie"] =  		{["pos"] = Vector3(-49.47, 1375.64,  9.86),  	["typ"] = "Orte"},
        --["snipergame"] =    {["pos"] = Vector3(-525.74, 1972.69,  60.17),  	["typ"] = "Orte"},
        ["kart"] =    		{["pos"] = Vector3(1262.375, 188.479, 19.5), 	["typ"] = "Orte"},
        ["dm"] =    		{["pos"] = Vector3(1326.55, -1561.04, 13.55), 	["typ"] = "Orte"},
		["lsdocks"] =       {["pos"] = Vector3(2711.48, -2405.28, 13.49),	["typ"] = "Orte"},
		["pferderennen"] =  {["pos"] = Vector3(1631.56, -1166.35, 23.66),  	["typ"] = "Orte"},
		["boxhalle"] =  	{["pos"] = Vector3(2225.24, -1724.91, 13.24),  	["typ"] = "Orte"},
		["friedhof"] =   	{["pos"] = Vector3(908.84, -1102.33, 24.30),  	["typ"] = "Orte"},
		["lsforum"] =   	{["pos"] = Vector3(2798.93, -1830.34, 9.88),	["typ"] = "Orte"},
		["auktion"] =   	{["pos"] = Vector3(1556.03, -1353.56, 23237.37),["typ"] = "Orte", ["interior"] = 1},
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
        ["bulletshop"] =    {["pos"] = Vector3(-1629.03, 1226.92, 7.19),  	["typ"] = "Shops"},
        ["ammunation"] =    {["pos"] = Vector3(1357.56, -1280.08, 13.30),  	["typ"] = "Shops"},
        ["24-7"] =          {["pos"] = Vector3(1352.43, -1752.75, 13.04),  	["typ"] = "Shops"},
        ["tankstelle"] =    {["pos"] = Vector3(1944.21, -1772.91, 13.07),  	["typ"] = "Shops"},
        ["burgershot"] =    {["pos"] = Vector3(1187.46, -924.68,  42.83),  	["typ"] = "Shops"},
        ["tuning"] =    	{["pos"] = Vector3(1050.65, -1031.07, 31.75),  	["typ"] = "Shops"},
        ["texture"] =    	{["pos"] = Vector3(1844.30, -1861.05, 13.38),  	["typ"] = "Shops"},
        ["cjkleidung"] =    {["pos"] = Vector3(1128.82, -1452.29, 15.48),  	["typ"] = "Shops"},
        ["sannews"] =       {["pos"] = Vector3(762.05, -1343.33, 13.20),  	["typ"] = "Unternehmen"},
        ["fahrschule"] =    {["pos"] = Vector3(1372.30, -1655.55, 13.38),  	["typ"] = "Unternehmen"},
        ["mechaniker"] =    {["pos"] = Vector3(2406.46, -2089.79, 13.55),  	["typ"] = "Unternehmen"},
        ["ept"] = 			{["pos"] = Vector3(1791.10, -1901.46, 13.08),  	["typ"] = "Unternehmen"},
		["lcn"] =           {["pos"] = Vector3(722.84, -1196.875, 19.123),	["typ"] = "Fraktionen"},
		["grove"] =         {["pos"] = Vector3(2492.43, -1664.58, 13.34),  	["typ"] = "Fraktionen"},
        ["rescue"] =        {["pos"] = Vector3(1135.98, -1389.90, 13.76),  	["typ"] = "Fraktionen"},
        ["fbi"] =           {["pos"] = Vector3(1257.14, -1826.52, 13.12),  	["typ"] = "Fraktionen"},
        ["pd"] =            {["pos"] = Vector3(255.34, 66.01, 1003.64),  	["typ"] = "Fraktionen", ["interior"] = 6},
        ["pdgarage"] =      {["pos"] = Vector3(1584.75, -1688.79, 6.22),  	["typ"] = "Fraktionen", ["interior"] = 0, ["dimension"]  = 5},
        ["area"] =          {["pos"] = Vector3(134.53, 1929.06,  18.89),  	["typ"] = "Fraktionen"},
        ["ballas"] =        {["pos"] = Vector3(2213.78, -1435.18, 23.83),  	["typ"] = "Fraktionen"},
		["vatos"] =         {["pos"] = Vector3(1882.53, -2029.32, 13.39),	["typ"] = "Fraktionen"},
		["triaden"] =       {["pos"] = Vector3(1900.384, 954.533, 10.820),	["typ"] = "Fraktionen"},
		["kartell"] =       {["pos"] = Vector3(2529.555, -1465.829, 23.94), ["typ"] = "Fraktionen"},
		["biker"] =         {["pos"] = Vector3(752.73, 326.17, 19.88),  	["typ"] = "Fraktionen"},
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
						player:getOccupiedVehicle():setInterior(v["interior"] or 0)
						player:getOccupiedVehicle():setDimension(v["dimension"] or 0)
					else
						setElementDimension(player,0)
						player:setPosition(v["pos"])
						player:setInterior(v["interior"] or 0)
						player:setDimension(v["dimension"] or 0)
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
			Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(targetPlayer.m_Id)
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
				Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(targetPlayer.m_Id)
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
			Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(targetPlayer.m_Id)
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
				Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(targetPlayer.m_Id)
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

function Admin:Event_EditVehicle(veh, changes)
    if client:getRank() >= ADMIN_RANK_PERMISSION["editVehicleGeneral"] then

		if veh and isElement(veh) then
			if changes.Model and client:getRank() >= ADMIN_RANK_PERMISSION["editVehicleModel"] then

			end
			if changes.OwnerType and client:getRank() >= ADMIN_RANK_PERMISSION["editVehicleOwnerType"] then --change type before id!

			end
			if changes.OwnerID and client:getRank() >= ADMIN_RANK_PERMISSION["editVehicleOwnerID"] then

			end
		else
			client:sendError("Das Fahrzeug wurde nicht gefunden.")
		end
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
					local veh = VehicleManager:getSingleton():createNewVehicle(factionID, VehicleTypes.Faction, model, posX, posY, posZ, rotZ)
					local fc = factionCarColors[factionID]
					veh:setColor(fc.r, fc.g, fc.b, fc.r1, fc.g1, fc.b1)
					veh:getTunings():saveColors()
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
					local veh = VehicleManager:getSingleton():createNewVehicle(companyID, VehicleTypes.Company, veh.model, posX, posY, posZ, rotZ)
					local fc = companyColors[companyID]
					veh:setColor(cc.r, cc.g, cc.b, cc.r, cc.g, cc.b)
					veh:getTunings():saveColors()
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
    if client:getRank() < ADMIN_RANK_PERMISSION["despawnVehicle"] then
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
		StatisticsLogger:getSingleton():addAdminVehicleAction(client, "despawn", source, reason)
		self:sendShortMessage(_("%s hat das Fahrzeug %s von %s despawnt (Grund: %s).", client, client:getName(), source:getName(), getElementData(source, "OwnerName") or "", reason))

		if getElementData(source, "OwnerName") then
			local targetId = Account.getIdFromName(getElementData(source, "OwnerName"))
			if targetId and targetId > 0 then
				local delTarget, isOffline = DatabasePlayer.get(targetId)
				if delTarget then
					if isOffline then
						delTarget:addOfflineMessage(("Dein Fahrzeug (%s) wurde von %s despawnt (%s)!"):format(source:getName(), client:getName(), reason))
						delete(delTarget)
					else
						delTarget:sendShortMessage(_("Dein Fahrzeug (%s) wurde von %s despawnt! Grund: %s", client, source:getName(), client:getName(), reason), -1)
					end
				end
			end
			if instanceof(source, GroupVehicle) then
				source:getGroup():sendShortMessage(_("Euer Fahrzeug (%s) wurde von %s despawnt! Grund: %s", client, source:getName(), client:getName(), reason), -1)
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
	if DEBUG or getPlayerName(player) == "Console" or player:getRank() >= RANK.Moderator then
		Help:getSingleton():loadHelpTexts()
		player:sendInfo(_("Die F1 Hilfe wurde neu geladen!", player))
	end
end

function Admin:runString(player, cmd, ...)
	if DEBUG or getPlayerName(player) == "Console" or player:getRank() >= ADMIN_RANK_PERMISSION["runString"] then
		local codeString = table.concat({...}, " ")
		StatisticsLogger:getSingleton():addDrunLog(player, codeString)
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
			local codeString = table.concat({...}, " ")
			StatisticsLogger:getSingleton():addDrunLog(player, codeString, tPlayer)
			triggerClientEvent(tPlayer, "onServerRunString", player, codeString, sendResponse)

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

function Admin:sendNewPlayerMessage(name)
	self:sendShortMessage(("%s hat sich soeben registriert! Hilf ihm am besten etwas auf die Sprünge!"):format(name), "Neuer Spieler!", nil, 15000)
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

function Admin:Event_forceTransaction(amount, from, fromType, to, toType)
	if client:getRank() < RANK.Administrator then
		return
	end

	local id = false
	if fromType == "player" then
		local id = Account.getIdFromName(from)
		if not id or id == 0 then
			client:sendError(_("Der Spieler, der Geld abgezogen bekommen soll, existiert nicht!", client))
			return
		end
		fromBankAccount = BankAccount.loadByOwner(id, 1)

	elseif fromType == "faction" then
		local id = FactionManager:getSingleton():getFromName(from) and FactionManager:getSingleton():getFromName(from):getId() or false
		if not tonumber(id) then client:sendError("Die Fraktion, von der Geld abgezogen werden soll, existiert nicht!") return end
		if id == 1 or id == 2 or id == 3 then
			fromBankAccount = FactionState:getSingleton().m_BankAccountServer
		else
			fromBankAccount = BankAccount.loadByOwner(id, 2)
		end
		fromBankAccount = BankAccount.loadByOwner(id, 2)

	elseif fromType == "company" then
		local id = CompanyManager:getSingleton():getFromName(from) and CompanyManager:getSingleton():getFromName(from):getId() or false
		if not tonumber(id) then client:sendError("Das Unternehmen, von dem Geld abgezogen werden soll, existiert nicht!") return end
		fromBankAccount = BankAccount.loadByOwner(id, 3)

	elseif fromType == "group" then
		local id = GroupManager:getSingleton():getFromName(from) and GroupManager:getSingleton():getFromName(from):getId() or false
		if not tonumber(id) then client:sendError("Die Gruppe, von der Geld abgezogen werden soll, existiert nicht!") return end
		fromBankAccount = BankAccount.loadByOwner(id, 8)

	elseif fromType == "admin" then
		from = "Adminkasse"
		fromBankAccount = self.m_BankAccount

	end

	local id = false
	if toType == "player" then
		local id = Account.getIdFromName(to)
		if not id or id == 0 then
			client:sendError(_("Der Spieler, dem Geld überwiesen werden soll, existiert nicht!", client))
			return
		end
		toBankAccount = BankAccount.loadByOwner(id, 1)

	elseif toType == "faction" then
		local id = FactionManager:getSingleton():getFromName(to) and FactionManager:getSingleton():getFromName(to):getId() or false
		if not tonumber(id) then client:sendError("Die Fraktion, der Geld überwiesen werden soll, existiert nicht!") return end
		if id == 1 or id == 2 or id == 3 then
			toBankAccount = FactionState:getSingleton().m_BankAccountServer
		else
			toBankAccount = BankAccount.loadByOwner(id, 2)
		end

	elseif toType == "company" then
		local id = CompanyManager:getSingleton():getFromName(to) and CompanyManager:getSingleton():getFromName(to):getId() or false
		if not tonumber(id) then client:sendError("Das Unternehmen, dem Geld überwiesen werden soll, existiert nicht!") return end
		toBankAccount = BankAccount.loadByOwner(id, 3)

	elseif toType == "group" then
		local id = GroupManager:getSingleton():getFromName(to) and GroupManager:getSingleton():getFromName(to):getId() or false
		if not tonumber(id) then client:sendError("Der Gruppe, der Geld überwiesen werden soll, existiert nicht!") return end
		toBankAccount = BankAccount.loadByOwner(id, 8)

	elseif toType == "admin" then
		to = "Adminkasse"
		toBankAccount = self.m_BankAccount

	end

	if fromBankAccount and toBankAccount then
		fromBankAccount:transferMoney(toBankAccount, amount, ("Erzwungene Transaktion von %s"):format(client:getName()), "Admin", "TransactionForce")
		fromBankAccount:save()
		toBankAccount:save()
		client:sendShortMessage(("Transaktion über %s$ von %s zu %s erfolgreich!"):format(addComas(tostring(amount)), from, to))
	end
end

function Admin:Event_adminRequestMultiAccounts()
	if client:getRank() < RANK.Supporter then
		return
	end

	local multiAccountTable = {}
	local result = sql:queryFetch("SELECT * FROM ??_account_multiaccount", sql:getPrefix())
	for i, row in pairs(result) do
		local nameTable = {}
		for key, accountId in pairs(fromJSON(row.LinkedTo) or {}) do
			local nameResult = sql:queryFetchSingle("SELECT Name FROM ??_account WHERE Id = ?", sql:getPrefix(), accountId)
			nameTable[#nameTable+1] = nameResult.Name
		end

		local adminResult = sql:queryFetchSingle("SELECT Name FROM ??_account WHERE Id = ?", sql:getPrefix(), row.Admin)
		local adminName
		if adminResult then
			adminName = adminResult.Name
		else
			adminName = "-"
		end

        multiAccountTable[row.ID] = {serial=row.Serial, linkedTo=nameTable, allowCreate=row.allowCreate, admin=adminName}
	end

	client:triggerEvent("adminSendMultiAccountsToClient", multiAccountTable)
end

function Admin:Event_adminDelteMultiAccount(id)
	if client:getRank() < RANK.Administrator then
		client:sendError("Du bist nicht berechtigt!")
		return
	end

	local result = sql:queryExec("DELETE FROM ??_account_multiaccount WHERE ID = ?", sql:getPrefix(), tonumber(id))
	if result then
		client:sendInfo("Der Multi-Account wurde gelöscht!")
		client:triggerEvent("adminRemoveMultiAccountFromList", id)
	else
		client:sendError("Der Multi-Account konnte nicht gelöscht werden!")
	end
end

function Admin:Event_adminCreateMultiAccount(serial, name, multiAccountName, allowCreate)
	if client:getRank() < RANK.Administrator then
		client:sendError("Du bist nicht berechtigt!")
		return
	end

	local linkedToTable = {}
	if name ~= "" then
		local result = sql:queryFetchSingle("SELECT Id FROM ??_account WHERE Name = ?", sql:getPrefix(), name)
		if result then
			linkedToTable[#linkedToTable+1] = result.Id
		else
			client:sendError(_("Es existiert kein Spieler mit dem Namen %s!", client, name))
			return
		end
	end
	if multiAccountName ~= "" then
		local nameTable = split(multiAccountName, ",")
		for key, name in pairs(nameTable) do
			local result = sql:queryFetchSingle("SELECT Id FROM ??_account WHERE Name = ?", sql:getPrefix(), name)
			if result then
				linkedToTable[#linkedToTable+1] = result.Id
			else
				client:sendError(_("Es existiert kein Spieler mit dem Namen %s!", client, multiAccountName))
				return
			end
		end
	end

	local allowCreate = (#linkedToTable < 2 and fromboolean(allowCreate)) or 0
	local result, numrows, lastInsertID = sql:queryFetch("INSERT INTO ??_account_multiaccount (Serial, LinkedTo, allowCreate, Admin, Timestamp) VALUES (?, ?, ?, ?, ?)", sql:getPrefix(), serial, toJSON(linkedToTable), allowCreate, client:getId(), getRealTime().timestamp)
	if result then
		client:sendInfo("Der Multi-Account wurde erstellt!")
	else
		client:sendError("Der Multi-Account konnte nicht erstellt werden!")
	end
end

function Admin:Event_adminRequestSerialAccounts(serial)
	local result = sql:queryFetch("SELECT * FROM ??_account_to_serial WHERE Serial = ?", sql:getPrefix(), serial)
	local accountTable = {}
	for i, row in pairs(result) do
		local singleResult = sql:queryFetchSingle("SELECT Name FROM ??_account WHERE Id = ?", sql:getPrefix(), row.PlayerId)
		accountTable[#accountTable+1] = {row.PlayerId, singleResult.Name}
	end
	client:triggerEvent("adminSendSerialAccountsToClient", serial, accountTable)
end

function Admin:Event_adminDeleteAccountFromSerial(userId, serial)
	if client:getRank() < RANK.Administrator then
		client:sendError("Du bist nicht berechtigt!")
		return
	end

	local result = sql:queryExec("DELETE FROM ??_account_to_serial WHERE PlayerId = ? AND Serial = ?", sql:getPrefix(), userId, serial)
	if result then
		client:sendInfo("Der Account wurde von der Serial getrennt!")
		client:triggerEvent("adminDeleteAccountFromSerialList", userId)
	else
		client:sendError("Der Account konnte von der Serial nicht getrennt werden!")
	end
end

function Admin:toggleInvisible(player)
	if player:getRank() ~= RANK.Developer then
		return
	end

	if player:getPublicSync("isInvisible") then
		player:setPublicSync("isInvisible", false)
		player:setAlpha(255)
	else
		player:setPublicSync("isInvisible", true)
		player:setAlpha(0)
	end
end
