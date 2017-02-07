HorseRace = inherit(Singleton)

function HorseRace:constructor()
	self.m_Stats = StatisticsLogger:getSingleton():getGameStats("HorseRace")

	self.m_Multiplier = 8
	self.m_Divisor = 500

	self:reset()

	self.m_refreshSpeedBind = bind(self.refreshSpeed, self)
	self.m_CalcBind = bind(self.calc, self)

	InteriorEnterExit:new(Vector3(1631.80, -1172.73, 24.08), Vector3(834.65, 7.28, 1004.19), 0, 90, 3)

	self.m_NPC = NPC:new(295, 820.19, 1.90, 1004.18, 270)
	self.m_NPC:setImmortal(true)
	self.m_NPC:setInterior(3)

	self.m_Marker = createMarker(822.84, 2.07, 1003.3, "cylinder", 1)
	setElementInterior(self.m_Marker, 3)

	addEventHandler("onMarkerHit", self.m_Marker, function(hitElement, dim)
		if hitElement:getType() == "player" and dim and not hitElement.vehicle then
			hitElement:triggerEvent("showHorseBetGUI")
		end
	end)

	addCommandHandler("pferderennen", bind(self.startRaceCmd, self))

	addRemoteEvents{"horseRaceReceiveProgress", "horseRaceAddBet"}
	addEventHandler("horseRaceReceiveProgress", root, bind(self.receiveProgress, self))
	addEventHandler("horseRaceAddBet", root, bind(self.addBet, self))

end

function HorseRace:reset()
	if self.m_CalcTimer and isTimer(self.m_CalcTimer) then killTimer(self.m_CalcTimer) end
	if self.m_ChangeSpeedTimer and isTimer(self.m_ChangeSpeedTimer) then killTimer(self.m_ChangeSpeedTimer) end

	self.m_ProgressFinish = false
	self.m_Horses = {
			[1] = {["Pos"] = 0, ["BoostFrom"] = 0, ["BoostTo"] = 0},
			[2] = {["Pos"] = 0, ["BoostFrom"] = 0, ["BoostTo"] = 0},
			[3] = {["Pos"] = 0, ["BoostFrom"] = 0, ["BoostTo"] = 0},
			[4] = {["Pos"] = 0, ["BoostFrom"] = 0, ["BoostTo"] = 0},
		}

	self.m_WinningHorse = 0
	self.m_IsRunning = false

	self.m_Players = {}
	local stumpy = getPlayerFromName("[eXo]Stumpy")
	if isElement(stumpy) then self.m_Players[#self.m_Players+1] = stumpy end
end


function HorseRace:Message()
	outputChatBox ( "[Pferde-Wetten] Um 19:30 findet das tägliche eXo-Pferderennen statt, du kannst im Wettbüro", rootElement, 255, 150, 255 )
	outputChatBox ( "auf ein Pferd setzen und um 19:30 die Live-Übertragung anschauen! Viel Glück!", rootElement, 255, 150, 255 )
end

function HorseRace:startRace()
	--Debug
	local stumpy = getPlayerFromName("[eXo]Stumpy")
	if isElement(stumpy) then self.m_Players[#self.m_Players+1] = stumpy end

	if not self.m_IsRunning == true then
		self:reset()
		outputChatBox ( "[Pferde-Wetten] Die Pferderennen Live-Übertragung beginnt!", rootElement, 255, 150, 255 )
		self.m_IsRunning = true
		for index, playeritem in pairs(self.m_Players) do
			if isElement(playeritem) then
				playeritem:sendShortMessage(_("Du nimmst an der Live-Übertragung teil!", playeritem), _("Pferde-Wetten", playeritem))
				playeritem:setFrozen(true)
				playeritem:triggerEvent("startPferdeRennenClient")
			else
				self.m_Players[index] = nil
			end
		end

		triggerClientEvent(root, "startProgTimerPferdeRennenClient", root)
		setTimer(function()
			self:refreshSpeed()
			self.m_CalcTimer = setTimer(self.m_CalcBind, 400, 0)
		end, 10000, 1)
	end
end

function HorseRace:startRaceCmd(player)
	if not self.m_IsRunning == true then
		self:startRace()
	else
		outputChatBox("Es läuft schon ein Pferderennen!",player,255,0,0)
	end
end

function HorseRace:boostHorse(horseId)
	self.m_Horses[horseId]["BoostFrom"] = 200 * self.m_Multiplier
	self.m_Horses[horseId]["BoostTo"] = 550 * self.m_Multiplier
end

function HorseRace:refreshSpeed()
	local from_start = 10*self.m_Multiplier
	local from_end = 40*self.m_Multiplier
	local to_start = 40*self.m_Multiplier
	local to_end = 240*self.m_Multiplier

	for horseId, data in pairs(self.m_Horses) do
		data["BoostFrom"] = math.random(from_start, from_end)
		data["BoostTo"] = math.random(to_start, to_end)
	end

	local rndBoost = math.random(1,4)
	self:boostHorse(rndBoost)

	self.m_ChangeSpeedTimer = setTimer(self.m_refreshSpeedBind, math.random(1000,3000), 1)
end

function HorseRace:calc()
	for id, data in pairs(self.m_Horses) do
		if data["Pos"] < 495 then
			data["Pos"] = data["Pos"] + math.random(data["BoostFrom"], data["BoostTo"]) / self.m_Divisor
		end
	end

	if self.m_ProgressFinish == true then
		for id, data in pairs(self.m_Horses) do
			data["Pos"] = data["Pos"] + 2
		end
	end
	for index, playeritem in pairs(self.m_Players) do
		if isElement(playeritem) then
			playeritem:triggerEvent("getPferdePositionen", self.m_Horses[1]["Pos"], self.m_Horses[2]["Pos"], self.m_Horses[3]["Pos"], self.m_Horses[4]["Pos"])
		else
			--self.m_Players[index] = nil
		end
	end

	if self.m_WinningHorse == 0 then
		for horseId, data in pairs(self.m_Horses) do
			if data["Pos"] >= 495 and self.m_ProgressFinish then
				self:setWinner(horseId)
			end
		end
	end

end

function HorseRace:setWinner(horseId)
	if self.m_WinningHorse == 0 then
		self.m_WinningHorse = horseId
		outputChatBox(("[Pferde-Wetten] Das Pferderennen wurde beendet. Pferd %d hat gewonnen!"):format(horseId), rootElement, 255, 150, 255)
		self:reset()

		triggerClientEvent(root, "stopProgTimerPferdeRennenClient", root)

		for index, playeritem in pairs(self.m_Players) do
			if isElement(playeritem) then
				setElementFrozen(playeritem,false)
				playeritem:setFrozen(false)
				playeritem:triggerEvent("stopPferdeRennenClient")
			end
		end
		self:checkWinner(horseId)
	end
end

function HorseRace:receiveProgress(prog)
    self.m_ProgressFinish = prog
end

function HorseRace:checkWinner(winningHorse)
	local result = sql:queryFetch("SELECT * FROM ??_horse_bets", sql:getPrefix())
 	for i, row in pairs(result) do
		local player = Player.getFromId(row.UserId)
		if player and isElement(player) and player:isLoggedIn() then
			if row["Horse"] == winningHorse then
				local win = tonumber(row["Bet"])*3
				outputChatBox(_("[Pferde-Wetten] Du hast auf das richtige Pferd (%d) gesetzt und %d$ gewonnen!", player, winningHorse, win), player, 255, 150, 255)
				player:giveMoney(win, "Pferde-Wetten")
				self.m_Stats["Outgoing"] = self.m_Stats["Outgoing"] + gewinn
			else
				outputChatBox(_("[Pferde-Wetten] Du hast auf das falsche Pferd (%d) gesetzt und nichts gewonnen!", player, row["Horse"]) ,player, 255, 150, 255)
			end
		end
	end

	sql:queryExec("TRUNCATE TABLE ??_horse_bets", sql:getPrefix())
end

function HorseRace:addBet(horse, bet)
	if bet and horse then
		if not self.m_IsRunning == true then
			if client:getMoney() >= bet then
				local row = sql:queryFetchSingle("SELECT * FROM ??_horse_bets WHERE UserId = ?;", sql:getPrefix(), client:getId())
				if not row then
					client:takeMoney(bet, "Horse-Race")
					sql:queryExec("INSERT INTO ??_horse_bets (UserId, Bet, Horse) VALUES (?, ?, ?)", sql:getPrefix(), client:getId(), bet, horse)
					client:sendShortMessage(_("Du hast %d$ auf Pferd %d gesetzt!", client, bet, horse), _("Pferde-Wetten", client))
					self.m_Stats["Incoming"] = self.m_Stats["Incoming"]+bet
					self.m_Stats["Played"] = self.m_Stats["Played"]+1
				else
					client:sendError(_("Du hast bereits eine Wette am laufen!", client))
				end
			else
				client:sendError(_("Du hast nicht genug Geld! (%d$)", client, bet))
			end
		else
			client:sendError(_("Das Pferderennen läuft bereits!!", client))
		end
	else
		client:sendError(_("Kein Pferd oder Einsatz angegeben!", client))
	end
end

