AmmuLadder = inherit(Singleton)

local MAX_POINTS      = 48 
local START_RATING    = 0
local MIN_NAME_LENGHT = 6

addRemoteEvents{"onAmmuLadderQuit","foundNewTeam"}

AmmuLadder.Settings = {
	["2vs2"] = 
	{
		TIME = 1000*60*3,
		WEAPONS = {
			31,24,29
		}
	},
	["3vs3"] = 
	{
		TIME = 1000*60*5,
		WEAPONS = {
			31,24,29
		}
	},
	["5vs5"] = 
	{
		TIME = 1000*60*7,
		WEAPONS = {
			31,24,29
		}
	},	
}

function AmmuLadder:constructor()
	self.m_Timer = {}
	self.m_Teams = {}
	-- DEBUG
	addCommandHandler("resetwhole", bind(self.whipeTeams,self))
	--
	addEventHandler("onAmmuLadderQuit", root, bind(self.onEvent,self))
	addEventHandler("foundNewTeam"    , root, bind(self.foundTeam,self))
	
	self:loadTeams()
end

function AmmuLadder:whipeTeams()
	-- Todo ( only debug ) 
end

function AmmuLadder:getTeam(id)
	return self.m_Teams[id]
end

function AmmuLadder:foundTeam(founder,name,kind)
	if not AmmuLadder.Settings[kind] then return end
	if name:len() == MIN_NAME_LENGHT then return end
	if founder:getTeamId(kind) then return end
	
	sql:queryExec("INSERT INTO ??_ladder (Name,Rating,Type,Members,Founder) VALUES (?,?,?,?,?)",
		sql:getPrefix(), name, START_RATING, kind, toJSON({founder:getId()}), founder:getId())
	
	local id = sql:lastInsertId()	
	
	self.m_Teams[id] = AmmuTeam:new(id,name,START_RATING,kind,{},founder:getId()):addMember(founder)
end

addCommandHandler("kasdf",
	function(player)
		AmmuLadder:getSingleton():foundTeam(player,"testTeam"..math.random(9999),"2vs2")
	end
)

function AmmuLadder:queueTeam(kind)
	if not AmmuLadder.Settings[kind] then return end -- suppress wrong kinds
	local team = self:getTeam(client:getTeamId(kind))
	if team and #team:getMembers() then
		-- Todo
	end
end

function AmmuLadder:loadTeams()
	outputServerLog("Loading ladder-teams...")
	local query = sql:queryFetch("SELECT * FROM ??_ladder", sql:getPrefix())
	
	for key, value in pairs(query) do
		self.m_Teams[tonumber(value["Id"])] = AmmuTeam:new(value["id"],value["Name"],value["Rating"],value["Type"],fromJSON(value["Members"]),value["Founder"])
	end
end

function AmmuLadder:destructor()
	for key, value in pairs (self.m_Teams) do
		sql:queryExec("UPDATE ??_ladder SET Rating = ? WHERE id = ?;", sql:getPrefix(), value:getRating(), self.m_Id)			
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