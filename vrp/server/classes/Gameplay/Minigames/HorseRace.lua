HorseRace = inherit(Singleton)

function HorseRace:constructor()
	self.m_Stats = StatisticsLogger:getSingleton():getGameStats("HorseRace")

	self.m_Multiplier = 8
	self.m_Divisor = 500

	self:reset()

	self.m_refreshSpeedBind = bind(self.refreshSpeed, self)
	self.m_CalcBind = bind(self.calc, self)

	InteriorEnterExit:new(Vector3(1631.80, -1172.73, 24.08), Vector3(834.65, 7.28, 1004.19), 0, 90, 3)

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
	self.m_IsRunning = 0

	self.m_Players = {}

	--Debug
	local stumpy = getPlayerFromName("[eXo]Stumpy")
	if isElement(stumpy) then self.m_Players[#self.m_Players+1] = stumpy end
end


function HorseRace:Message()
	outputChatBox ( "CASINO: Um 19:30 findet das tägliche eXo-Pferderennen statt, du kannst im Casino", getRootElement(), 255, 150, 255 )
	outputChatBox ( "auf ein Pferd setzen und um 19:30 zur Live-Übertragung kommen! Viel Glück!", getRootElement(), 255, 150, 255 )
end

function HorseRace:startRace()
	if not self.m_IsRunning == true then
		outputChatBox ( "CASINO: Die Pferderennen Live-Übertragung im Alhambra beginnt!", getRootElement(), 255, 150, 255 )

		for index, playeritem in pairs(self.m_Players) do
			if isElement(playeritem) then
				if getElementInterior(playeritem) == 1 then
					outputChatBox("Du nimmst an der Live-Übertragung teil!",playeritem,0,255,0)
					setElementFrozen(playeritem,true)
					triggerClientEvent(playeritem,"startPferdeRennenClient",playeritem)
				else
					self.m_Players[index] = nil
				end
			else
				self.m_Players[index] = nil
			end
		end

		self:reset()

		triggerClientEvent("startProgTimerPferdeRennenClient",getRootElement())
		setTimer(function()
			setPferdeRandomWerte()
			self.m_CalcTimer = setTimer(self.m_CalcBind, 400,0)
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
	self.m_Horses[horseId]["BoostFrom"] = 200*self.m_Multiplier
	self.m_Horses[horseId]["BoostTo"] = 550*self.m_Multiplier
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

	for horseId, data in pairs(self.m_Horses) do
		if data["Pos"] < 495 then
			data["Pos"] = data["Pos"] + math.random(data["BoostFrom"], data["BoostTo"]) / self.m_Divisor
		end
	end

	if self.m_ProgressFinish == true then
		for horseId, data in pairs(self.m_Horses) do
			data["Pos"] = data["Pos"] + 2
		end
	end

	for index, playeritem in pairs(self.m_Players) do
		if isElement(playeritem) then
			triggerClientEvent(playeritem,"getPferdePositionen",playeritem, self.m_Horses[1]["Pos"], self.m_Horses[2]["Pos"], self.m_Horses[3]["Pos"], self.m_Horses[4]["Pos"])
		else
			self.m_Players[index] = nil
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
		outputChatBox("CASINO-Pferderennen: Das Pferderennen wurde beendet. Pferd "..horseId.." hat gewonnen!",getRootElement(),255,150,255)
		self:reset()

		triggerClientEvent(getRootElement(),"stopProgTimerPferdeRennenClient",getRootElement())

		for index, playeritem in pairs(self.m_Players) do
			if isElement(playeritem) then
				setElementFrozen(playeritem,false)
				triggerClientEvent(playeritem,"stopPferdeRennenClient",playeritem)
			end
		end
		self:checkWinner(horseId)
	end
end

function HorseRace:receiveProgress(prog)
    self.m_ProgressFinish = prog
end

function HorseRace:checkWinner(horseId)
	local result = mysql_query ( handler,"SELECT * FROM Pferdewetten" )
	for result,row in mysql_rows_assoc(result) do
		local pname = row["Name"]
		if getPlayerFromName(pname) then
			local player = getPlayerFromName(pname)
			if isElement(player) then
				local userpferd = tonumber(row["Pferd"])
				if userpferd == horseId then
					local gewinn = 0
					gewinn = tonumber(row["Einsatz"])*3
					outputChatBox("CASINO: Du hast beim Pferdewetten auf das richtige Pferd ("..horseId..") gesetzt und "..gewinn.."$ gewonnen!",player,255,150,255)
					givePlayerSaveMoney(player,gewinn)
					self.m_Stats["Outgoing"] = self.m_Stats["Outgoing"] + gewinn
				else
					outputChatBox("CASINO: Du hast leider auf das falsche Pferd ("..userpferd..") gesetzt und nichts gewonnen!",player,255,150,255)
				end
			end
		end
	end
	--local result2 = mysql_query ( handler,"TRUNCATE TABLE Pferdewetten" )
end

function HorseRace:addBet(einsatz,pferd)
	local player = client

	if einsatz and pferd then
		if not self.m_IsRunning == true then
			if exoGetElementData(player,"money") >= einsatz then
				if not handler then	MySQL_Startup()	end
				local result = mysql_query ( handler,"SELECT Name FROM Pferdewetten WHERE Name = '"..getPlayerName(player).."'" )
				if mysql_num_rows(result) == 0 then
					outputChatBox("Du hast "..einsatz.."$ auf das Pferd "..pferd.." gesetzt!",player,0,255,0)
					takePlayerSaveMoney(player,einsatz)
					mysql_query ( handler,"INSERT INTO Pferdewetten (Name, Einsatz, Pferd) VALUES ('"..getPlayerName(player).."', '"..einsatz.."', '"..pferd.."')" )
					self.m_Stats["Incoming"] = self.m_Stats["Incoming"]+einsatz
					savePferdeWettenStats()
				else
					infobox(player,"Du hast schon eine Wette laufen!",7000,255,0,0,255)
				end
			else
				infobox(player,"Du hast nicht genug Geld!",7000,255,0,0,255)
			end
		else
			infobox(player,"Das Pferderennen läuft bereits!!",7000,255,0,0,255)
		end
	else
		infobox(player,"Kein Pferd und Einsatz angegeben!",7000,255,0,0,255)
	end

end

