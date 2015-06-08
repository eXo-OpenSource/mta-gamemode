AmmuLadder = inherit(Singleton)

local MAX_POINTS      = 48 
local START_RATING    = 0
local MIN_NAME_LENGHT = 6

addRemoteEvents{"onAmmuLadderQuit","foundNewTeam","getLadderRating"}

AmmuLadder.Settings = {
	["1vs1"] = 
	{
		TIME = 1000*60*1.5,
		WEAPONS = {
			31,24,29
		},
		MAX_PER_TEAM = 1,
	},
	["2vs2"] = 
	{
		TIME = 1000*60*3,
		WEAPONS = {
			31,24,29
		},
		MAX_PER_TEAM = 2,
	},
	["3vs3"] = 
	{
		TIME = 1000*60*5,
		WEAPONS = {
			31,24,29
		},
		MAX_PER_TEAM = 3,
	},
	["5vs5"] = 
	{
		TIME = 1000*60*7,
		WEAPONS = {
			31,24,29
		},
		MAX_PER_TEAM = 5,
	},	
}

function AmmuLadder:constructor()
	self.m_Timer = {}
	self.m_Teams = {}
	self.m_QueuedTeams = {
		["1vs1"] = {},
		["2vs2"] = {},
		["3vs3"] = {},
		["5vs5"] = {},
	}
	self.m_QueueTimer = Timer(bind(self.passQueue,self),5000,0)
	-- DEBUG
	addCommandHandler("resetwhole", bind(self.whipeTeams,self))
	--
	addEventHandler("onAmmuLadderQuit", root, bind(self.onEvent,self))
	addEventHandler("foundNewTeam"    , root, bind(self.foundTeam,self))
	addEventHandler("getLadderRating" , root, bind(self.sendRating,self))
	
	self:loadTeams()
end

function AmmuLadder:sendRating(player)
	if player then client = player end
	local data = {} 
	for kind in pairs(AmmuLadder.Settings) do
		local team = self.m_Teams[client:getTeamId(kind)]
		if team then
			data[kind] = { RATING = team:getRating(), NAME = team:getName() }
		end
	end
	client:triggerEvent("reciveLadderRating", data)
end

function AmmuLadder:whipeTeams()
	-- Todo ( only debug ) 
end

function AmmuLadder:getTeam(id)
	return self.m_Teams[id]
end

function AmmuLadder:passQueue()
	for _, kind in ipairs(self.m_QueuedTeams) do
		for _, team in ipairs(kind) do
			if not team:getStatus() then
				self:findOpponent(team,kind)
			end
		end
	end
end

function AmmuLadder:findOpponent(team,kind)
	team:setRequestStatus(true)
	local teamRating = math.floor(team:getRating()/100)*100
	local opponent
	local ratingStatus = teamRating
	-- look for compatible elo
	for _, opponent in ipairs(self.m_QueuedTeams[kind]) do
		if not opponent:getStatus() then
			local opponentRating = math.floor(opponent:getRating()/100)*100
			if teamRating-opponentRating < 100 or opponentRating-teamRating < 100 then
				opponent:setRequestStatus(true)
				self:startBattle(team,opponent)
			end
		end
	end
end

function AmmuLadder:startBattle(team1,team2)
	local arena = AmmuArena:new(team1,team2)
end

function AmmuLadder:foundTeam(founder,name,kind)
	if not AmmuLadder.Settings[kind] then return end
	if name:len() < MIN_NAME_LENGHT then return end
	if founder:getTeamId(kind) then return end
	
	sql:queryExec("INSERT INTO ??_ladder (Name,Rating,Type,Members,Founder) VALUES (?,?,?,?,?)",
		sql:getPrefix(), name, START_RATING, kind, toJSON({founder:getId()}), founder:getId())
	
	local id = sql:lastInsertId()	
	
	self.m_Teams[id] = AmmuTeam:new(id,name,START_RATING,kind,{},founder:getId()):addMember(founder)
end

addCommandHandler("kasdf",
	function(player)
		AmmuLadder:getSingleton():foundTeam(player,"testTeam"..math.random(9999),"1vs1")
	end
)

function AmmuLadder:queueTeam(kind)
	if not AmmuLadder.Settings[kind] then return end -- suppress wrong kinds
	local team = self:getTeam(client:getTeamId(kind))
	if team and #team:getMembers() == AmmuLadder.Settings[kind].MAX_PER_TEAM and not team:getQueueStatus() then
		table.insert(self.m_QueuedTeams[kind],team)
		team:setQueueStatus(true)
	end
end

function AmmuLadder:loadTeams()
	outputServerLog("Loading ladder-teams...")
	local query = sql:queryFetch("SELECT * FROM ??_ladder", sql:getPrefix())
	
	for key, value in pairs(query) do
		self.m_Teams[tonumber(value["Id"])] = AmmuTeam:new(value["id"],value["Name"],tonumber(value["Rating"]),value["Type"],fromJSON(value["Members"]),tonumber(value["Founder"]))
	end
end

function AmmuLadder:destructor()
	for key, value in pairs (self.m_Teams) do
		sql:queryExec("UPDATE ??_ladder SET Rating = ? WHERE id = ?;", sql:getPrefix(), value:getRating(), value:getId())			
	end
end

function AmmuLadder:onEvent(...)
	if event == "onPlayerQuit" then
		-- Todo: move this to the AmmuArena-class
	end
end

function AmmuLadder:getSettings(kind)
	return self.Settings[kind]
end

--[[

	Calculation for rating ( elo-system from chess ): 

	local playerAChance = 1/(1+10(playerB.Rating - playerA.Rating)/400)
	local playerBChance = 1/(1+10(playerA.Rating - playerB.Rating)/400)
	
	if playerA.Hits > playerB.Hits then
		playerA.Rating = playerA.Rating + MAX_POINTS*(1 - playerAChance)
		playerB.Rating = playerB.Rating + MAX_POINTS*(0 - playerBChance)
	elseif playerA.Hits < playerB.Hits then
		playerB.Rating = playerB.Rating + MAX_POINTS*(1 - playerBChance)
		playerA.Rating = playerA.Rating + MAX_POINTS*(0 - playerAChance)	
	end
	
]]