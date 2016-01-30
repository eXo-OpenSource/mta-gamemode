-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     Gangwar Attack class
-- *
-- ****************************************************************************
AttackSession = inherit(Object)


--// @param_desc: faction1: attacker-faction, faction2: defender-faction
function AttackSession:constructor( pAreaObj , faction1 , faction2  ) 
	self.m_AreaObj = pAreaObj
	self.m_Faction1 = faction1 
	self.m_Faction2 = faction2 
	self.m_Disqualified = {	} --//
	self.m_Participants = {	}
	self:setupSession( )
	self.m_BattleTime = setTimer(bind(self.attackWin, self), GANGWAR_MATCH_TIME*60000, 1)
	
end

function AttackSession:setupSession ( )
	for k,v in ipairs( self.m_Faction1:getOnlinePlayers() ) do 
		self.m_Participants[#self.m_Participants + 1] = v
	end
	for k,v in ipairs( self.m_Faction2:getOnlinePlayers() ) do 
		self.m_Participants[#self.m_Participants + 1] = v
	end
	self:synchronizeAllParticipants( ) 
end

function AttackSession:synchronizeAllParticipants( ) 
	for k,v in ipairs( self.m_Participants ) do 
		v:triggerEvent("AttackClient:launchClient",self.m_Faction1,self.m_Faction2,self.m_Participants,self.m_Disqualified)
		v.m_RefAttackSession = self
	end
	for k,v in ipairs( self.m_Disqualified ) do 
		v:triggerEvent("AttackClient:launchClient",self.m_Faction1,self.m_Faction2,self.m_Participants,self.m_Disqualified)
		v.m_RefAttackSession = self
	end
end

function AttackSession:addParticipantToList( player )
	local bInList = self:isParticipantInList( player )
	if not bInList then 
		self.m_Participants[#self.m_Participants + 1] = player 
	end
end

function AttackSession:isParticipantInList( player )
	for index = 1,#self.m_Participants do 
		if self.m_Participants[index] == player then 
			return true
		end
	end
	return false
end

function AttackSession:removeParticipant( player )
	for index = 1,#self.m_Participants do 
		if self.m_Participants[index] == player then 
			return table.remove( self.m_Participants, index )
		end
	end
end

function AttackSession:isPlayerDisqualified( player )
	for index = 1,#self.m_Disqualified do 
		if self.m_Disqualified[index] == player.name then 
			return true
		end
	end
	return false
end

function AttackSession:disqualifyPlayer( player )
	local bIsDisqualifed = self:isPlayerDisqualified( player )
	if not bIsDisqualifed then 
		self.m_Disqualified[ #self.m_Disqualified + 1] = player.name
	end
end

function AttackSession:joinPlayer( player ) 
	self:addParticipant( player )
	player.m_RefAttackSession = self
end

function AttackSession:quitPlayer( player ) 
	self:removeParticipant( player )
end

function AttackSession:onPlayerLeaveCenter( player )
	local id = player.m_Faction.m_Id 
	if id == self.m_Faction1.m_Id then
		local isAnyoneInside = self:checkPlayersInCenter( )
		if not isAnyoneInside then 
			self:setCenterCountdown()
			--// Notify team 1
		end
	end
end

function AttackSession:SessionCheck() 
	local factionCount1 = 0 
	local factionCount2 = 0
	for k,v in ipairs( self.m_Participants ) do 
		local id = v.m_Faction.m_Id 
		if id == self.m_Faction1 then 
			factionCount1 = factionCount1 + 1
		else 
			factionCount2 = factionCount2 + 1
		end
	end
	if factionCount1 == 0 then 
		self.endReason = 1
		self:attackLose()
	elseif factionCount2 == 0 then 
		self.endReason = 2
		self:attackWin()
	end
end

function AttackSession:onPlayerWasted( player, tAmmo, killer, kWeapon, bodyP )
	local factionID = player.m_Faction.m_Id 
	local bParticipant = self:isParticipantInList( player )
	if bParticipant then 
		if killer then 
			local factionID2 = killer.m_Faction.m_Id 
			local bParticipant2 = self:isParticipantInList( killer ) 
			if bParticipant2 then 
				self:removeParticipant( player )
				self:disqualifyPlayer( player )
			end
		else 
			self:removeParticipant( player )
			self:disqualifyPlayer( player )
		end
		player.m_Faction:sendMessage("[Gangwar] #FFFFFFEin Mitglied ("..player.name..") ist getötet worden!",200,0,0,true)
	end
end

function AttackSession:onPlayerEnterCenter( player )
	local id = player.m_Faction.m_Id 
	if id == self.m_Faction1.m_Id then
		local bCenterTimer = isTimer( self.m_HoldCenterTimer )
		local bNotifyTimer = isTimer( self.m_NotifiyAgainTimer )
		if bCenterTimer then 
			killTimer( self.m_HoldCenterTimer )
		end
		if bNotifyTimer then 
			killTimer( self.m_NotifiyAgainTimer )
		end
	end
end

function AttackSession:setCenterCountdown()
	self.endReason = 3
	self.m_Faction1:sendMessage("[Gangwar] #FFFFFFIhr habt noch "..GANGWAR_CENTER_TIMEOUT.." Sekunden Zeit die Flagge zu erreichen!",200,0,0,true)
	self.m_HoldCenterTimer = setTimer( bind(self.attackLose, self), GANGWAR_CENTER_TIMEOUT*1000,1)
	self.m_NotifiyAgainTimer = setTimer( bind(self.notifyFaction1, self), math.floor((GANGWAR_CENTER_TIMEOUT*1000)/2),1)
end

function AttackSession:notifyFactions() 
	if self.endReason == 1 then 
		for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do
			v:sendInfo(_("Alle Gegner sind eleminiert!", v))
		end
		for k, v in ipairs(self.m_Faction2:getOnlinePlayers()) do
			v:sendInfo(_("Alle Mitglieder sind gefallen!", v))
		end
	elseif self.endReason == 2 then 
		for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do
			v:sendInfo(_("Alle Mitglieder sind gefallen!", v))
		end
		for k, v in ipairs(self.m_Faction2:getOnlinePlayers()) do
			v:sendInfo(_("Alle Gegner sind eleminiert!", v))
		end
	else
		for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do
			v:sendInfo(_("Die Flagge wurde nicht gehalten!", v))
		end
		for k, v in ipairs(self.m_Faction2:getOnlinePlayers()) do
			v:sendInfo(_("Die Gegner haben die Flagge nicht gehalten!", v))
		end
	end
end

function AttackSession:stopClients()
		for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do
			v:triggerEvent("AttackClient:stopClient")
		end
		for k, v in ipairs(self.m_Faction2:getOnlinePlayers()) do
			v:triggerEvent("AttackClient:stopClient")
		end
end

function AttackSession:notifyFaction1( ) 
	self.m_Faction1:sendMessage("[Gangwar] #FFFFFFIhr habt nur noch "..math.floor(GANGWAR_CENTER_TIMEOUT/2).." Sekunden Zeit die Flagge zu erreichen!",200,0,0,true)
end

function AttackSession:checkPlayersInCenter( )
	local pTable = getElementsWithinColShape( self.m_AreaObj.m_CenterSphere, "player")
	local factionID
	for key, player in ipairs( pTable ) do 
		if not isPedDead( player ) then 
			factionID = player.m_Faction.m_Id 
			if factionID == self.m_Faction1 then 
				return true
			end
		end
	end
	return false
end


function AttackSession:attackLose() --// loose for team1 
	self:notifyFactions() 
	self.m_AreaObj:update()
	
	self.m_Faction1:sendMessage("[Gangwar] #FFFFFFDer Angriff ist gescheitert!",200,0,0,true)
	self.m_Faction2:sendMessage("[Gangwar] #FFFFFFDas Gebiet wurde verteidigt!",0,180,40,true)
	
	self.m_AreaObj:attackEnd(  ) 
	self:stopClients()
end

function AttackSession:attackWin() --// win for team1
	self:notifyFactions()
	self.m_AreaObj.m_Owner = self.m_Faction1.m_Id 
	self.m_AreaObj:update()
	
	self.m_Faction2:sendMessage("[Gangwar] #FFFFFFDas Gebiet ist verloren!",2000,0,0,true)
	self.m_Faction1:sendMessage("[Gangwar] #FFFFFFDer Angriff war erfolgreich!",0,180,40,true)
	
	self.m_AreaObj:attackEnd(  ) 
	self:stopClients()
end

function AttackSession:getFactions() 
	return self.m_Faction1,self.m_Faction2
end