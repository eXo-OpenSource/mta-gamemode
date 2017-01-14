-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Minigames/Highscore.lua
-- *  PURPOSE:     Serversided highscore class for Minigames
-- *
-- ****************************************************************************
Highscore = inherit(Object)
Highscore.Map = {}

addRemoteEvents{"highscoreRequestData"}

function Highscore.getFromName(name)
	if Highscore.Map[name] then	return Highscore.Map[name] end
	return false
end

addEventHandler("highscoreRequestData", root,
	function(name)
		if Highscore.getFromName(name) then
			client:triggerEvent("highscoreReceiveData", Highscore.getFromName(name):getHighscoresFormated())
		else
			client:sendError("Highscore not found!")
		end
	end
)

function Highscore:constructor(Name)
	self.m_Minigame = Name

	local result = sql:queryFetch("SELECT * FROM ??_highscores WHERE Name = ?", sql:getPrefix(), self.m_Minigame)[1]

	if result then
		self.m_Daily = fromJSON(result.Daily)
		self.m_Weekly = fromJSON(result.Weekly)
		self.m_Monthly = fromJSON(result.Monthly)
		self.m_Yearly = fromJSON(result.Yearly)
		self.m_Global = fromJSON(result.Global)
	else
		self:createDefaults()
		return
	end

	Highscore.Map[self.m_Minigame] = self
end

function Highscore:createDefaults()
	self.m_Daily = {}
	self.m_Weekly = {}
	self.m_Monthly = {}
	self.m_Yearly = {}
	self.m_Global = {}

	local realtime = MinigameManager.getRealTime()
	self.m_Daily[realtime.yearday] = {}
	self.m_Weekly[realtime.week] = {}
	self.m_Monthly[realtime.month] = {}
	self.m_Yearly[realtime.year] = {}

	sql:queryExec("INSERT INTO ??_highscores (Name, Daily, Weekly, Monthly, Yearly, Global) VALUES (?, ?, ?, ?, ?, ?)", sql:getPrefix(),
		self.m_Minigame, toJSON(self.m_Daily), toJSON(self.m_Weekly), toJSON(self.m_Monthly), toJSON(self.m_Yearly), toJSON(self.m_Global))

	Highscore.Map[self.m_Minigame] = self
end

function Highscore:updateDefaults()
	local realtime = MinigameManager.getRealTime()

	if not self.m_Daily[realtime.yearday] then
		self.m_Daily[realtime.yearday] = {}
	end

	if not self.m_Weekly[realtime.week] then
		self.m_Weekly[realtime.week] = {}
	end

	if not self.m_Monthly[realtime.month] then
		self.m_Monthly[realtime.month] = {}
	end

	if not self.m_Yearly[realtime.year] then
		self.m_Yearly[realtime.year] = {}
	end

	--self:update()
end

function Highscore:update()
	sql:queryExec("UPDATE ??_highscores SET Daily = ?, Weekly = ?, Monthly = ?, Yearly = ?, Global = ? WHERE Name = ?", sql:getPrefix(),
		toJSON(self.m_Daily), toJSON(self.m_Weekly), toJSON(self.m_Monthly), toJSON(self.m_Yearly), toJSON(self.m_Global), self.m_Minigame)
end

function Highscore:getHighscores()
	return {Daily = self.m_Daily, Weekly = self.m_Weekly, Monthly = self.m_Monthly, Yearly = self.m_Yearly, Global = self.m_Global}
end

function Highscore:getHighscoresFormated()
	local realtime = MinigameManager.getRealTime()
	local newTable = {}
	local highscores = {}

	highscores.Daily = self.m_Daily[realtime.yearday]
	highscores.Weekly = self.m_Weekly[realtime.week]
	highscores.Monthly = self.m_Monthly[realtime.month]
	highscores.Yearly = self.m_Yearly[realtime.year]
	highscores.Global = self.m_Global

	for index, tbl in pairs(highscores) do
		newTable[index] = {}

		table.sort(highscores[index],
			function(a, b)
				return a.Score > b.Score
			end
		)

		for i = 1, 10 do
			if tbl[i] then
				local name = Account.getNameFromId(tbl[i].PlayerID) or "-"
				local score = tbl[i].Score or 0
				newTable[index][i] = {name = name, score = score }
			end
		end
	end

	return newTable
end

function Highscore:isHighscoreForPlayer(Id)
	local Daily, Weekly, Monthly, Yearly, Global = false, false, false, false, false
	local realtime = MinigameManager.getRealTime()

	for _, v in pairs(self.m_Daily[realtime.yearday]) do
		if v.PlayerID == Id then
			Daily = true
		end
	end

	for _, v in pairs(self.m_Weekly[realtime.week]) do
		if v.PlayerID == Id then
			Weekly = true
		end
	end

	for _, v in pairs(self.m_Monthly[realtime.month]) do
		if v.PlayerID == Id then
			Monthly = true
		end
	end

	for _, v in pairs(self.m_Yearly[realtime.year]) do
		if v.PlayerID == Id then
			Yearly = true
		end
	end

	for _, v in pairs(self.m_Global) do
		if v.PlayerID == Id then
			Global = true
		end
	end

	return {Daily = Daily, Weekly = Weekly, Monthly = Monthly, Yearly = Yearly, Global = Global}
end

function Highscore:addHighscore(Id, score)
	assert(type(Id) == "number")
	assert(type(score) == "number")

	local st = getTickCount()

	self:updateDefaults()

	local realtime = MinigameManager.getRealTime()
	local insert = {PlayerID = Id, Score = score}
	local CurrentHighscores = self:isHighscoreForPlayer(Id)
	local doUpdate = false

	if CurrentHighscores.Daily then
		for _, v in pairs(self.m_Daily[realtime.yearday]) do
			if v.PlayerID == Id then
				if v.Score < score then
					v.Score = score
				--	outputChatBox("Updated daily score Player-Id: "..v.PlayerID.." - Score: new: "..score.." old: "..v.Score)
					doUpdate = true
				end
			end
		end
	else
	--	outputChatBox("Insert daily score - Player-Id: "..insert.PlayerID.." - Score: "..insert.Score)
		table.insert(self.m_Daily[realtime.yearday], insert)
		doUpdate = true
	end

	if CurrentHighscores.Weekly then
		for _, v in pairs(self.m_Weekly[realtime.week]) do
			if v.PlayerID == Id then
				if v.Score < score then
					v.Score = score
				--	outputChatBox("Updated weekly score Player-Id: "..v.PlayerID.." - Score: new: "..score.." old: "..v.Score)
					doUpdate = true
				end
			end
		end
	else
	--	outputChatBox("Insert weekly score - Player-Id: "..insert.PlayerID.." - Score: "..insert.Score)
		table.insert(self.m_Weekly[realtime.week], insert)
		doUpdate = true
	end

	if CurrentHighscores.Monthly then
		for _, v in pairs(self.m_Monthly[realtime.month]) do
			if v.PlayerID == Id then
				if v.Score < score then
					v.Score = score
				--	outputChatBox("Updated monthly score Player-Id: "..v.PlayerID.." - Score: new: "..score.." old: "..v.Score)
					doUpdate = true
				end
			end
		end
	else
	--	outputChatBox("Insert monthly score - Player-Id: "..insert.PlayerID.." - Score: "..insert.Score)
		table.insert(self.m_Monthly[realtime.month], insert)
		doUpdate = true
	end

	if CurrentHighscores.Yearly then
		for _, v in pairs(self.m_Yearly[realtime.year]) do
			if v.PlayerID == Id then
				if v.Score < score then
					v.Score = score
				--	outputChatBox("Updated yearly score Player-Id: "..v.PlayerID.." - Score: new: "..score.." old: "..v.Score)
					doUpdate = true
				end
			end
		end
	else
	--	outputChatBox("Insert yearly score - Player-Id: "..insert.PlayerID.." - Score: "..insert.Score)
		table.insert(self.m_Yearly[realtime.year], insert)
		doUpdate = true
	end


	if CurrentHighscores.Global then
		for _, v in pairs(self.m_Global) do
			if v.PlayerID == Id then
				if v.Score < score then
					--outputChatBox("Updated global score Player-Id: "..v.PlayerID.." - Score: new: "..score.." old: "..v.Score)
					v.Score = score
					doUpdate = true
				end
			end
		end
	else
		--outputChatBox("Insert global score - Player-Id: "..insert.PlayerID.." - Score: "..insert.Score)
		table.insert(self.m_Global, insert)
		doUpdate = true
	end

	if doUpdate then self:update() end
end
