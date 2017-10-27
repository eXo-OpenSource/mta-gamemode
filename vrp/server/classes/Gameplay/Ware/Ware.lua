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
Ware.afterRoundTime = 6000
Ware.arenaZ = 500
Ware.Min_Players = 3
function Ware:constructor( dimension )
	self.m_GameModeList =
	{
		--[[
		WareMoney,
		WareSurvive,
		WareCarJack,
		WareCrateBreak,
		WareDuck,
		WareJump,
		WareKeepMove,
		WareDontMove,
		WareClimb,
		WareParachute,
		WareMath,
		WareStayTop,
		WareButtons,
		WareGuess,
		WareStayTop,
		WareRamp,
		WareMurder,
		WareMarker,]]
		WareSprint
	}
	self.m_Dimension = dimension or math.random(1,65555)
	self.m_Players = {}
	self.m_Gamespeed = 1
	self.m_RoundCount = 0
	self.m_Arena = { 0, 0, Ware.arenaZ, Ware.arenaSize*Ware.sidelength, Ware.arenaSize*Ware.sidelength}
	self.m_AfterRound = bind(self.afterRound, self)
	self.m_startRound = bind(self.startRound, self)
	self:startRound()
	self.m_Gamespeed = getGameSpeed()
	Player.getChatHook():register(bind(self.onPlayerChat, self))
end

function Ware:startRound()
	self.m_Successors = {}
	local randomMode = self.m_GameModeList[math.random(1,#self.m_GameModeList)]
	local roundTime = Ware.roundTimes[self.m_Gamespeed]
	local roundDuration = (roundTime*1000)*(randomMode.timeScale or 1)
	if randomMode then
		self.m_CurrentMode = randomMode:new(self)
		for key, player in ipairs(self.m_Players) do
			player:triggerEvent("onClientWareRoundStart", randomMode.modeDesc, roundDuration)
		end
	end
	self.m_RoundEnd = setTimer( self.m_AfterRound,roundDuration, 1)
	local x,y,z
	for k, player in ipairs( self.m_Players ) do
		x, y, z = getElementPosition(player)
		if isPedDead(player) or getElementHealth(player) == 0 or z < Ware.arenaZ then
			self:spawnWarePlayer(player)
		end
		setPedOnFire(player, false)
		setElementHealth(player, 100)
	end
end

function Ware:onDeath( player, killer, weapon)
	if self.m_CurrentMode then
		if self.m_CurrentMode.onDeath then
			self.m_CurrentMode:onDeath( player, killer, weapon)
		end
	end
end

function Ware:onPlayerChat(player, text, type)
	if self.m_CurrentMode then
		if self.m_CurrentMode.onChat then
			if table.find(self.m_Players, player) then
				self.m_CurrentMode:onChat(player, text, type)
			end
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
	local endGame = false
	self.m_RoundCount = self.m_RoundCount + 1
	if self.m_RoundCount > 10 and self.m_RoundCount < 20 then
		self.m_Gamespeed = 2
	elseif self.m_RoundCount >= 20 and self.m_RoundCount < 30 then
		self.m_Gamespeed = 3
	elseif self.m_RoundCount >= 30 then
		self.m_RoundCount = 0
		self.m_Gamespeed = 1
		endGame = true
	end
	if self.m_CurrentMode then
		local modeDesc = self.m_CurrentMode.modeDesc
		delete(self.m_CurrentMode)
		local winners = self.m_Successors
		local losers = self:getLosers()
		if winners then
			for k, player in ipairs( winners ) do
				player:setData("Ware:roundsWon", (player:getData("Ware:roundsWon") or 0) + 1)
				if #self.m_Players > Ware.Min_Players then
					player:setData("Ware:pumpkinsEarned",  (player:getData("Ware:pumpkinsEarned") or 0) + 1)
					player:sendShortMessage(_("Kürbis erhalten!", player))
				else
					player:sendError(_("Da zu wenig Spieler teilnehmen wird diese Runde nicht gewertet!", player))
				end
			end
		end
		local points = {}
		for k, player in ipairs( self.m_Players ) do
			table.insert(points,{player, player:getData("Ware:roundsWon") or 0})
		end
		table.sort(points,function(a,b) return a[2] > b[2] end)
		local x,y,z
		for k, player in ipairs( self.m_Players ) do
			x, y, z = getElementPosition(player)
			if isPedDead(player) or getElementHealth(player) == 0 or z < Ware.arenaZ then
				self:spawnWarePlayer(player)
			end
			setPedOnFire(player, false)
			setElementHealth(player, 100)
			setPedHeadless(player, false)
			player:triggerEvent("onClientWareChangeGameSpeed", self.m_Gamespeed)
			player:triggerEvent("onClientWareRoundEnd", points, winners, losers, modeDesc, endGame)
			if endGame then
				self:resetRound()
			end
		end
	end
	setTimer(self.m_startRound, Ware.afterRoundTime, 1)
end

function Ware:resetRound()
	local pumpkinsEarned
	for k, player in ipairs( self.m_Players ) do
		pumpkinsEarned = math.floor((math.floor((player:getData("Ware:pumpkinsEarned") or 0) / 2)) / 10)
		if pumpkinsEarned > 0 then
			player:getInventory():giveItem("Kürbis", pumpkinsEarned)
			player:sendInfo(_("Du erhälst "..pumpkinsEarned.. " Kürbisse als Belohnung!", player))
		end
		player:setData("Ware:roundsWon",  0	)
		player:setData("Ware:pumpkinsEarned",  0)
	end
end


function Ware:getLosers()
	local loosers = {}
	if self.m_Players then
		for i = 1, #self.m_Players do
			if not self:isPlayerWinner( self.m_Players[i] ) then
				table.insert( loosers, self.m_Players[i] )
			end
		end
	end
	return loosers
end

function Ware:joinPlayer( player )
	if not self:isPlayer(player) then
		table.insert(self.m_Players, player)
		player:setData("Ware:roundsWon", 0)
		player:setData("Ware:pumpkinsEarned",  0)
		player:triggerEvent("PlatformEnv:generate", 0, 0, Ware.arenaZ, Ware.arenaSize, Ware.arenaSize, self.m_Dimension, false, "files/images/Textures/Ware/waretex.jpg", "sam_camo", 3095)
		self:spawnWarePlayer(player)
		player.bInWare = self
		player:setData("inWare", true)
		player:triggerEvent("onClientWareJoin", self.m_Gamespeed)
		player:triggerEvent("Ware:closeGUI")

		player:createStorage(true)
	end
end

function Ware:spawnWarePlayer(player)
	spawnPlayer(player, 0, 0, Ware.arenaZ+2, 244)
	setElementPosition(player, Ware.arenaSize*Ware.sidelength/2+math.random(1,Ware.sidelength),Ware.arenaSize*Ware.sidelength/2+math.random(1,Ware.sidelength), Ware.arenaZ+2)

	player:setFrozen(false)
	player:setDimension(self.m_Dimension)
	player:setCameraTarget(player)
	player:setAlpha(255)
	player:setModel(18)
end

function Ware:leavePlayer(player)
	local key = self:isPlayer(player)
	if key then
		table.remove(self.m_Players, key)

		player:triggerEvent("onClientWareLeave", self.m_Gamespeed)
		player:triggerEvent("Ware:closeGUI")
		player:setData("inWare", nil)
		player:setData("Ware:roundsWon",  nil)
		player:setData("Ware:pumpkinsEarned",  nil)


		spawnPlayer(player, Vector3(932.17, -1065.47, 24.38), 110, player.m_Skin)
		player:setHeadless(false)
		player:setAlpha(255)
		player.bInWare = nil

		player:restoreStorage()
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

function Ware:getRandomPosition()
	local x, y, z, width, height = unpack(self.m_Arena)
	local posX = x + 5 + math.random(0, width-5)
	local posY = y + 5 + math.random(0, height-5)
	local posZ = z
	return Vector3(posX, posY, posZ)
end

function Ware:getPlayers() return self.m_Players end
