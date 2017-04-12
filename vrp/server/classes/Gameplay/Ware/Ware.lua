-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/Ware.lua
-- *  PURPOSE:     Ware class
-- *
-- ****************************************************************************
Ware = inherit(Object)

Ware.roundTimes = 
{
	[1] = 12,
	[2] = 10, 
	[3] = 5,
}

Ware.arenaSize = 4
Ware.sidelength = 9
Ware.afterRoundTime = 7000
function Ware:constructor( dimension )
	self.m_GameModeList = 
	{
		--WareMoney,
		--WareSurvive,
		--WareCarJack,
		--WareCrateBreak,
		--WareDuck, 
		--WareJump,
		--WareKeepMove,
		--WareDontMove,
		WareClimb,
	}
	self.m_Dimension = dimension or math.random(1,65555)
	self.m_Players = {}
	self.m_Gamespeed = 1
	self.m_RoundCount = 0
	self.m_Arena = {0,0,500,Ware.arenaSize*Ware.sidelength,Ware.arenaSize*Ware.sidelength}
	self.m_AfterRound = bind(self.afterRound, self)
	self.m_startRound = bind(self.startRound, self)
	self:startRound()
end

function Ware:startRound()
	self.m_Successors = {}
	local randomMode = self.m_GameModeList[math.random(1,#self.m_GameModeList)]
	if randomMode then 
		self.m_CurrentMode = randomMode:new(self)
		for key, player in ipairs(self.m_Players) do 
			player:triggerEvent("onClientWareRoundStart", randomMode.modeDesc)
		end
	end
	local roundTime = Ware.roundTimes[self.m_Gamespeed]
	self.m_RoundEnd = setTimer( self.m_AfterRound, (roundTime*1000)*(randomMode.timeScale or 1), 1)
end

function Ware:onDeath( player, killer, weapon)
	if self.m_CurrentMode then 
		if self.m_CurrentMode.onDeath then 
			self.m_CurrentMode:onDeath( player, killer, weapon)
		end
	end
end

function Ware:addPlayerToWinners( player ) 
	if not self:isPlayerWinner(player) then 
		table.insert(self.m_Successors, player)
		player:triggerEvent("onClientWareSuceed")
	end
end

function Ware:isPlayerWinner( player )
	for i = 1,#self.m_Successors do 
		if self.m_Successors[i] == player then 
			return i 
		end
	end
	return false
end
function Ware:afterRound()
	self.m_RoundCount = self.m_RoundCount + 1
	if self.m_RoundCount > 10 and self.m_RoundCount < 20 then 
		self.m_Gamespeed = 2
	elseif self.m_RoundCount >= 20 and self.m_RoundCount < 30 then 
		self.m_Gamespeed = 3
	elseif self.m_RoundCount >= 30 then 
		self.m_RoundCount = 0
		self.m_Gamespeed = 1
	end
	if self.m_CurrentMode then 
		delete(self.m_CurrentMode)
		local winners = self.m_Successors
		if winners then
			for k, player in ipairs( winners ) do 
				player:setData("Ware:roundsWon", (player:getData("Ware:roundsWon") or 0) + 1)
			end
		end
		local points = {}
		for k, player in ipairs( self.m_Players ) do 
			table.insert(points,{player, player:getData("Ware:roundsWon") or 0})
		end
		table.sort(points,function(a,b) return a[2] > b[2] end)
		for k, player in ipairs( self.m_Players ) do 
			if isPedDead(player) or getElementHealth(player) == 0 then
				self:spawnWarePlayer(player)
			end
			setPedOnFire(player, false)
			setElementHealth(player, 100)
			player:triggerEvent("onClientWareChangeGameSpeed", self.m_Gamespeed)
			player:triggerEvent("onClientWareRoundEnd", points)
		end
	end
	setTimer(self.m_startRound, Ware.afterRoundTime, 1)
end

function Ware:joinPlayer( player ) 
	if not self:isPlayer(player) then 
		table.insert(self.m_Players, player)
		player:setData("Ware:roundsWon",0)
		player:triggerEvent("PlatformEnv:generate", 0,0,500,Ware.arenaSize, Ware.arenaSize, self.m_Dimension, false, "files/images/Textures/waretex.png", "sam_camo", 3095)
		self:spawnWarePlayer(player)
		player.bInWare = self
		player:triggerEvent("onClientWareJoin", self.m_Gamespeed)
	end
end

function Ware:spawnWarePlayer(player)
	spawnPlayer(player,0,0,500,player.m_Skin)
	setElementFrozen(player,false)
	setElementPosition(player, Ware.arenaSize*Ware.sidelength/2+math.random(1,Ware.sidelength),Ware.arenaSize*Ware.sidelength/2+math.random(1,Ware.sidelength),502)
	setElementDimension(player, self.m_Dimension)
	setCameraTarget(player, player)
	setElementAlpha(player,255)
end
function Ware:leavePlayer( player ) 
	local key = self:isPlayer(player) 
	if key then
		table.remove(self.m_Players, key)
		player.bInWare = false
		player:triggerEvent("onClientWareLeave")
	end
end

function Ware:isPlayer( pPlayer )
	for key, player in ipairs(self.m_Players) do
		if player == pPlayer then 
			return key
		end
	end
	return false
end