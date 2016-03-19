-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Minigames/Highscore.lua
-- *  PURPOSE:     Serversided highscore class for Minigames
-- *
-- ****************************************************************************
Highscore = inherit(Object)

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
	end
end

function Highscore:createDefaults()
	self.m_Daily = {}
	self.m_Weekly = {}
	self.m_Monthly = {}
	self.m_Yearly = {}
	self.m_Global = {}

	local realtime = getRealTime()
	self.m_Daily[realtime.yearday] = {}
	self.m_Weekly[getWeekNumber()] = {}
	self.m_Monthly[realtime.month + 1] = {}
	self.m_Yearly[realtime.year + 1900] = {}

	sql:queryExec("INSERT INTO ??_highscores (Name, Daily, Weekly, Monthly, Yearly, Global) VALUES (?, ?, ?, ?, ?, ?)", sql:getPrefix(),
		self.m_Minigame, toJSON(self.m_Daily), toJSON(self.m_Weekly), toJSON(self.m_Monthly), toJSON(self.m_Yearly), toJSON(self.m_Global))
end

function Highscore:update()
	sql:queryExec("UPDATE ??_highscores SET Daily = ?, Weekly = ?, Monthly = ?, Yearly = ?, Global = ? WHERE Name = ?", sql:getPrefix(),
		toJSON(self.m_Daily), toJSON(self.m_Weekly), toJSON(self.m_Monthly), toJSON(self.m_Yearly), toJSON(self.m_Global), self.m_Minigame)
end

function Highscore:getHighscores()
	return {Daily = self.m_Daily, Weekly = self.m_Weekly, Monthly = self.m_Monthly, Yearly = self.m_Yearly, Global = self.m_Global}
end
