AmmuLadder = inherit(Singleton)

local DUEL_TIME  = 1000*60*30 -- 30 sec
local MAX_POINTS = 48 

addRemoteEvents{"onAmmuLadderQuit"}

function AmmuLadder:constructor()
	self.m_Timer = {}

	-- DEBUG
	addCommandHandler("requestduel", bind(self.duellRequest,self))
	--
	addEventHandler("onPlayerQuit", root, bind(self.onEvent,self))
	addEventHandler("onPlayerWasted", root, bind(self.onEvent,self))
	addEventHandler("onAmmuLadderQuit", root, bind(self.onEvent,self))
end

function AmmuLadder:onEvent(...)
	if event == "onPlayerQuit" then
		if not self.m_IsDuelling then return end
		self:AbandonDuel(source)
	elseif event == "onPlayerWasted" then
		if not self.m_IsDuelling then return end
		self:AbandonDuel(source)
	elseif event == "onAmmuLadderQuit" then
		if not self.m_IsDuelling then return end
		self:AbandonDuel(select(1,...))
	end
end

function AmmuLadder:duellRequest(player,_,target)
	local targetUnit = getPlayerFromName(target) or nil
	if not targetUnit then
		return
	end
	local duelStatusPlayer = player.IsDuelling
	local duelStatusTarget = targetUnit.IsDuelling
	
	if not duelStatusPlayer and not duelStatusTarget then
		AmmuLadder:startDuel(player,targetUnit)
	end
		
end

function AmmuLadder:AbandonDuel(player)
	local playerPartner = player.DuelPartner
	killTimer(self.m_Timer[player])
	
	AmmuLadder:PortPlayerOut(player)
	AmmuLadder:PortPlayerOut(playerPartner)
end

function AmmuLadder:PortPlayerOut(player)
	player.IsDuelling = false
	player.DuelPartner = false
end

function AmmuLadder:startDuel(player,targetUnit)
	player.IsDuelling 			= true
	player.DuelPartner 			= targetUnit
	targetUnit.IsDuelling 		= true
	targetUnit.DuelPartner 		= player
	player.Rating 	= player.Rating 		 or 0
	targetUnit.Rating = targetUnit.Rating	 or 0
	
	self.m_Timer[player] = setTimer(bind(self.finishDuel,self),DUEL_TIME,1,player,targetUnit)
	self.m_Timer[targetUnit] = self.m_Timer[player]
end

function AmmuLadder:reportFlew(player)
	if not isElement(player) then
		return
	end
end

function AmmuLadder:finishDuel(playerA,playerB)
	local playerAChance = 1/(1+10(playerB.Rating - playerA.Rating)/400)
	local playerBChance = 1/(1+10(playerA.Rating - playerB.Rating)/400)
	
	if playerA.Hits > playerB.Hits then
		playerA.Rating = playerA.Rating + MAX_POINTS*(1 - playerAChance)
		playerB.Rating = playerB.Rating + MAX_POINTS*(0 - playerBChance)
	elseif playerA.Hits < playerB.Hits then
		playerB.Rating = playerB.Rating + MAX_POINTS*(1 - playerBChance)
		playerA.Rating = playerA.Rating + MAX_POINTS*(0 - playerAChance)	
	end
	
	AmmuLadder:PortPlayerOut(playerA)
	AmmuLadder:PortPlayerOut(playerB)	
	
end