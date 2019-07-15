-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     Gangwar Attack class
-- *
-- ****************************************************************************
AttackSession = inherit(Object)
addRemoteEvents{"GangwarPick:submit"}
GANGWAR_TEAMBLIPS = true

--// @param_desc: faction1: attacker-faction, faction2: defender-faction
function AttackSession:constructor( pAreaObj , faction1 , faction2, attackingPlayer )
	self.m_AreaObj = pAreaObj
	self.m_Faction1 = faction1
	self.m_Faction2 = faction2
	self.m_Disqualified = {	}
	self.m_Participants = {	}
	self.m_AttackingPlayer = attackingPlayer
	self.m_PickList = { }
	self:setupSession( )
	self:createBarricadeCars( )

	--self.m_DamageFunc = bind(self.onGangwarDamage, self)
	--addEventHandler("onClientDamage", root, self.m_DamageFunc)

	self.m_GangwarPickSubmit = bind(self.onSubmitPick, self)
	addEventHandler("GangwarPick:submit", root, self.m_GangwarPickSubmit )
	self.m_BattleTime = setTimer(bind(self.attackWin, self), GANGWAR_MATCH_TIME*60000, 1)
	self.m_DecisionTime = setTimer(bind(self.onDecisionTimeEnd, self), 60000*3, 1)
	self.m_SynchronizeTime = setTimer(bind(self.synchronizeTime, self), 5000, 0)
	self:createWeaponBox()
	self.m_Active = true
	self.m_DecisionEnded = false
	self.m_Blips = {}
	self:createTeamBlips()
	GangwarStatistics:getSingleton():newCollector( pAreaObj.m_ID )
end

function AttackSession:destructor()
	self:destroyBarricadeCars( )
	self:destroyWeaponBox()
	if isTimer( self.m_BattleTime ) then
		killTimer( self.m_BattleTime )
	end
	if isTimer( self.m_WeaponBoxTimer ) then
		killTimer( self.m_WeaponBoxTimer )
	end
	if isTimer( self.m_SynchronizeTime ) then 
		killTimer(self.m_SynchronizeTime)
	end
	local bCenterTimer = isTimer( self.m_HoldCenterTimer )
	local bNotifyTimer = isTimer( self.m_NotifiyAgainTimer )
	if bCenterTimer then
		killTimer( self.m_HoldCenterTimer )
	end
	if bNotifyTimer then
		killTimer( self.m_NotifiyAgainTimer )
	end
	self.m_Active = false
	--removeEventHandler("onClientDamage", root, self.m_DamageFunc)
end

function AttackSession:logSession(winner)
	local attackEnd = getRealTime().timestamp
	local attackStart = self.m_AreaObj.m_LastAttack or 0
	local attackerFaction = self.m_Faction1
	if attackerFaction then
		attackerFaction = attackerFaction.m_Name
	end
	local ownerFaction = self.m_Faction2
	if ownerFaction then
		ownerFaction = self.m_Faction2.m_Name
	end
	if winner then
		winner = winner.m_Name
	end
	StatisticsLogger:getSingleton():addGangwarLog(self.m_AreaObj.m_Name, attackerFaction, ownerFaction, attackStart, attackEnd, winner)
	GangwarStatistics:getSingleton():addAttackLog( self.m_AreaObj.m_Name, attackerFaction, ownerFaction, attackStart, attackEnd, winner)
end
function AttackSession:setupSession ( )
	for k,v in ipairs( self.m_Faction1:getOnlinePlayers() ) do
		self.m_Participants[#self.m_Participants + 1] = v
		v.g_kills = 0
		v.g_damage = 0
		v:setPublicSync("gangwarParticipant", true) 
	end
	for k,v in ipairs( self.m_Faction2:getOnlinePlayers() ) do
		self.m_Participants[#self.m_Participants + 1] = v
		v.g_kills = 0
		v.g_damage = 0
		v:setPublicSync("gangwarParticipant", true) 
	end
	self:synchronizeAllParticipants( )
end

function AttackSession:synchronizeAllParticipants( )
	local pickParticipants = {}
	for k,v in ipairs( self.m_Participants ) do
		if v:getFaction() == self.m_Faction1 then
			table.insert(pickParticipants, v)
		end
	end
	local canModify = false 
	local showPickGUI = false
	for k,v in ipairs( self.m_Participants ) do
		canModify = v == self.m_AttackingPlayer or v:getFaction():getPlayerRank(v) >= 3
		showPickGUI = v:getFaction() == self.m_Faction1 
		v:triggerEvent("AttackClient:launchClient",self.m_Faction1,self.m_Faction2,self.m_Participants,self.m_Disqualified, GANGWAR_MATCH_TIME*60, self.m_AreaObj.m_Position, self.m_AreaObj.m_ID, false, self.m_AreaObj.m_Name, canModify, pickParticipants, showPickGUI )
		v:triggerEvent("GangwarQuestion:new")
	end
end

function AttackSession:synchronizeLists( )
	local pickParticipants = {}
	for k,v in ipairs( self.m_Participants ) do
		if v.getFaction and v:getFaction() == self.m_Faction1 then
			table.insert(pickParticipants, v)
		end
	end
	for k,v in ipairs( self.m_Faction1:getOnlinePlayers()) do
		v:triggerEvent("AttackClient:synchronizeLists",self.m_Participants,self.m_Disqualified, self.m_PickList, self.m_PickUpdater, self.m_PickTick, pickParticipants)
	end
	for k,v in ipairs( self.m_Faction2:getOnlinePlayers() ) do
		v:triggerEvent("AttackClient:synchronizeLists",self.m_Participants,self.m_Disqualified, self.m_PickList, self.m_PickUpdater, self.m_PickTick, pickParticipants)
	end
end

function AttackSession:synchronizeTime( )
	local timeLeft = getTimerDetails( self.m_BattleTime )
	timeLeft = math.ceil(timeLeft /1000)
	for k,v in ipairs( self.m_Faction1:getOnlinePlayers()) do
		v:triggerEvent("AttackClient:synchronizeTime", timeLeft)
	end
	for k,v in ipairs( self.m_Faction2:getOnlinePlayers() ) do
		v:triggerEvent("AttackClient:synchronizeTime", timeLeft)
	end
end

function AttackSession:addParticipantToList( player, bLateJoin )
	local bInList = self:isParticipantInList( player )
	if not bInList then
		local canModify =  self.m_AttackingPlayer == player or player.getFaction and player:getFaction():getPlayerRank(player) >= 3
		self.m_Participants[#self.m_Participants + 1] = player
		local pickParticipants = {}
		local showPickGUI
		for k,v in ipairs( self.m_Participants ) do
			if v:getFaction() == self.m_Faction1 then
				table.insert(pickParticipants, v)
			end
		end
		player:setPublicSync("gangwarParticipant", true) 
		if not bLateJoin then
			showPickGUI = player:getFaction() == self.m_Faction1
			player:triggerEvent("AttackClient:launchClient", self.m_Faction1, self.m_Faction2, self.m_Participants, self.m_Disqualified, GANGWAR_MATCH_TIME*60, self.m_AreaObj.m_Position, self.m_AreaObj.m_ID, false, self.m_AreaObj.m_Name, canModify, pickParticipants, showPickGUI)
		else
			if isTimer( self.m_BattleTime ) then
				showPickGUI = player:getFaction() == self.m_Faction1
				local timeLeft = getTimerDetails( self.m_BattleTime )
				timeLeft = math.ceil(timeLeft /1000)
				player:triggerEvent("AttackClient:launchClient", self.m_Faction1, self.m_Faction2, self.m_Participants, self.m_Disqualified, timeLeft, self.m_AreaObj.m_Position, self.m_AreaObj.m_ID, false, self.m_AreaObj.m_Name, canModify, pickParticipants, showPickGUI, self.m_DecisionEnded)
			end
		end
		self:synchronizeLists( )
		player:triggerEvent("GangwarQuestion:new")
		player.g_damage = 0 
		player.g_kills = 0
		self.m_Faction1:sendMessage("[Gangwar] #FFFFFFDer Spieler "..player.name.." jointe dem Gangwar nach!",0,204,204,true)
		self.m_Faction2:sendMessage("[Gangwar] #FFFFFFDer Spieler "..player.name.." jointe dem Gangwar nach!",0,204,204,true)
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
			table.remove( self.m_Participants, index )
		end
	end
	player:setPublicSync("gangwarParticipant", false) 
	self:synchronizeLists( )
	self:sessionCheck()
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
	if player and isElement(player) then
		local bIsDisqualifed = self:isPlayerDisqualified( player )
		if not bIsDisqualifed then
			self.m_Disqualified[ #self.m_Disqualified + 1] = player.name
			self:removeParticipant( player )
			self:synchronizeLists( )
		end
	end
end

function AttackSession:joinPlayer( player )
	if not self:isPlayerDisqualified( player ) then
		self:addParticipantToList( player , true)
	else 
		if isTimer( self.m_BattleTime ) then
			local pickParticipants = {}
			for k,v in ipairs( self.m_Participants ) do
				if v:getFaction() == self.m_Faction1 then
					table.insert(pickParticipants, v)
				end
			end
			local timeLeft = getTimerDetails( self.m_BattleTime )
			timeLeft = math.ceil(timeLeft /1000)
			local canModify = player == self.m_AttackingPlayer or player:getFaction():getPlayerRank(player) >= 3
			local showPickGUI = player:getFaction() == self.m_Faction1
			player:triggerEvent("AttackClient:launchClient",self.m_Faction1,self.m_Faction2,self.m_Participants,self.m_Disqualified, timeLeft, self.m_AreaObj.m_Position, self.m_AreaObj.m_ID, false, self.m_AreaObj.m_Name, canModify, pickParticipants, showPickGUI)
		end
	end
	self:createTeamBlips()
end

function AttackSession:quitPlayer( player )
	self:removeParticipant( player )
	self:createTeamBlips()
end

function AttackSession:onPurposlyDisqualify( player, bAfk, bPick)
	if player and isElement(player) then
		local reason = ""
		if bAfk then 
			reason = "(AFK)"
		end
		if bPick then
			reason = "(Nicht eingeteilt)"
		end
		self:disqualifyPlayer( player )
		self.m_Faction1:sendMessage("[Gangwar] #FFFFFFDer Spieler "..getPlayerName(player).." nimmt nicht am Gangwar teil! "..reason, 100, 120, 100, true)
		self.m_Faction2:sendMessage("[Gangwar] #FFFFFFDer Spieler "..getPlayerName(player).." nimmt nicht am Gangwar teil! "..reason, 100, 120, 100, true)
	end
end

function AttackSession:onGangwarDamage( target, weapon, bpart, loss )
	if self:isParticipantInList( target ) and self:isParticipantInList( source ) then
		if target:getFaction() ~= source:getFaction() then
			local basicDamage = WEAPON_DAMAGE[weapon] or getWeaponProperty(weapon, "poor", "damage") or 1
			local multiplier = DAMAGE_MULTIPLIER[bpart] and DAMAGE_MULTIPLIER[bpart] or 1
			local realLoss = basicDamage*multiplier
			local health = getElementHealth(target)
			if realLoss < basicDamage then 
				realLoss = basicDamage
			end

			if realLoss > health then -- workaround for 5 hp damages
				realLoss = health
			end

			triggerClientEvent("onGangwarDamage", source, target, weapon, bpart, realLoss)
			source.g_damage = source.g_damage + math.floor(realLoss)
		end
	end
end

function AttackSession:sessionCheck()
	local factionCount1 = 0
	local factionCount2 = 0	
	for k,v in ipairs( self.m_Participants ) do
		if v.m_Faction == self.m_Faction1 then
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

function AttackSession:onPlayerWasted( player, killer,  weapon, bodypart )
	local bParticipant = self:isParticipantInList( player )
	if bParticipant then
		if killer then
			local bParticipant2 = self:isParticipantInList( killer )
			if bParticipant2 then
				if player and isElement(player) then 
					if killer.g_kills then 
						killer.g_kills = killer.g_kills + 1
					else 
						killer.g_kills = 1 
					end
					player.m_Faction:sendMessage("[Gangwar] #FFFFFFEin Mitglied ("..player.name..") ist getötet worden!",200,0,0,true)
					killer.m_Faction:sendMessage("[Gangwar] #FFFFFFEin Gegner ("..player.name..") ist getötet worden!",0,200,0,true)
					local loss = player.m_LossBeforeDead or 0
					triggerClientEvent("onGangwarKill", killer, player, weapon, bodypart, loss )
					self:onPlayerLeaveCenter( player ) 
					--killer.g_damage = killer.g_damage + math.floor(loss)
					self:disqualifyPlayer( player )
				end
			end
		else
			player.m_Faction:sendMessage("[Gangwar] #FFFFFFEin Mitglied ("..player.name..") ist getötet worden!",200,0,0,true)
			self:disqualifyPlayer( player )
			self:onPlayerLeaveCenter( player ) 
		end
	end
end

function AttackSession:onPlayerEnterCenter( player )
	if self.m_Active then
		local faction = player.m_Faction
		if faction == self.m_Faction1 then
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
end

function AttackSession:onPlayerLeaveCenter( player )
	if self.m_Active then
		local faction = player.m_Faction
		if faction == self.m_Faction1 then
			local isAnyoneInside = self:checkPlayersInCenter( )
			if not isAnyoneInside then
				self:setCenterCountdown()
			end
		end
	end
end

function AttackSession:onSubmitPick( participants ) 
	if client and self.m_PickList then 
		if client:getFaction() == self.m_Faction1 then
			if client:getFaction():getPlayerRank(client) > 2 or client == self.m_AttackingPlayer then
				self.m_PickList = participants
				self.m_PickUpdater = client:getName()
				self.m_PickTick = getTickCount()
				self:synchronizeLists( )
			else 
				client:sendError(_("Du hast keine Berechtigung die Spieler einzuteielen!", client))
			end
		end
	end
end

function AttackSession:checkPlayersInCenter( )
	if self.m_Active then
		local pTable = getElementsWithinColShape( self.m_AreaObj.m_CenterSphere, "player")
		local faction, executionPedCheck
		local dim = getElementDimension( self.m_AreaObj.m_CenterSphere )
		local dim2, int2
		local int = getElementInterior( self.m_AreaObj.m_CenterSphere )
		for key, player in ipairs( pTable ) do
			dim2 = getElementDimension( player )
			int2 = getElementInterior( player )
			executionPedCheck = player.getExecutionPed and not player:getExecutionPed()
			if dim == dim2 and int == int2 then
				if not isPedDead( player ) and executionPedCheck and self:isParticipantInList(player) and getElementHealth(player) ~= 0 then
					faction = player.m_Faction
					if faction == self.m_Faction1 then
						return true
					end
				end
			end
		end
		return false
	end
end

function AttackSession:setCenterCountdown()
	if self.m_Active then
		self.endReason = 3
		self.m_Faction1:sendMessage("[Gangwar] #FFFFFFIhr habt noch "..GANGWAR_CENTER_TIMEOUT.." Sekunden Zeit die Flagge zu erreichen!",200,0,0,true)
		self.m_Faction2:sendMessage("[Gangwar] #FFFFFFEure Gegner haben noch "..GANGWAR_CENTER_TIMEOUT.." Sekunden Zeit die Flagge zu erreichen!",0,200,0,true)
		if self.m_HoldCenterTimer and isTimer(self.m_HoldCenterTimer) then killTimer(self.m_HoldCenterTimer) end 
		if self.m_NotifiyAgainTimer and isTimer(self.m_NotifiyAgainTimer) then killTimer(self.m_NotifiyAgainTimer) end 
		self.m_HoldCenterTimer = setTimer( bind(self.attackLose, self), GANGWAR_CENTER_TIMEOUT*1000,1)
		self.m_NotifiyAgainTimer = setTimer( bind(self.notifyFaction1, self), math.floor((GANGWAR_CENTER_TIMEOUT*1000)/2),1)
	end
end
	
function AttackSession:notifyFactions()
	if self.endReason == 1 then
		for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do
			v:sendInfo(_("Alle Mitglieder sind gefallen!",v))
		end
		for k, v in ipairs(self.m_Faction2:getOnlinePlayers()) do
			v:sendInfo(_("Alle Gegner sind eleminiert!",v))
		end
	elseif self.endReason == 2 then
		for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do
			v:sendInfo(_("Alle Gegner sind eleminiert!",v))
		end
		for k, v in ipairs(self.m_Faction2:getOnlinePlayers()) do
			v:sendInfo(_("Alle Mitglieder sind gefallen!",v))
		end
		self.m_Faction1:sendMessage("[Gangwar] #FFFFFFAlle Gegner wurden eleminiert!",200,0,0,true)
	elseif self.endReason == 3 then
		for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do
			v:sendInfo(_("Die Flagge wurde nicht gehalten!",v))
		end
		for k, v in ipairs(self.m_Faction2:getOnlinePlayers()) do
			v:sendInfo(_("Die Gegner haben die Flagge nicht gehalten!",v))
		end
	end
end

function AttackSession:stopClients( bNoOutput )
	local allGangwarPlayers = {}
	self:destroyTeamBlips()
	for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do
		v:triggerEvent("AttackClient:stopClient")
		allGangwarPlayers[#allGangwarPlayers+1] = v
		v:setPublicSync("gangwarParticipant", false) 
	end
	for k, v in ipairs(self.m_Faction2:getOnlinePlayers()) do
		v:triggerEvent("AttackClient:stopClient")
		allGangwarPlayers[#allGangwarPlayers+1] = v
		v:setPublicSync("gangwarParticipant", false) 
	end
	if not bNoOutput then
		GangwarStatistics:getSingleton():collectDamage(self.m_AreaObj.m_ID, allGangwarPlayers)
	end
end

function AttackSession:notifyFaction1( )
	if not self:backupCenterCheck() then 
		self.m_Faction1:sendMessage("[Gangwar] #FFFFFFIhr habt nur noch "..math.floor(GANGWAR_CENTER_TIMEOUT/2).." Sekunden Zeit die Flagge zu erreichen!",200,0,0,true)
		self.m_Faction2:sendMessage("[Gangwar] #FFFFFFEure Gegner haben nur noch "..math.floor(GANGWAR_CENTER_TIMEOUT/2).." Sekunden Zeit die Flagge zu erreichen!",0,200,0,true)
	end
end

function AttackSession:backupCenterCheck() 
	local pTable = self.m_Faction1:getOnlinePlayers()
	local faction
	local dim = getElementDimension( self.m_AreaObj.m_CenterSphere )
	local dim2, int2
	local int = getElementInterior( self.m_AreaObj.m_CenterSphere )
	local pX, pY, pZ = getElementPosition(self.m_AreaObj.m_CenterSphere)
	local x,y,z, dist
	for key, player in ipairs( pTable ) do
		x,y,z = getElementPosition(player)
		dim2 = getElementDimension( player )
		int2 = getElementInterior( player )
		if dim == dim2 and int == int2 then
			if not isPedDead( player ) and ( player.getExecutionPed and not player:getExecutionPed()) and self:isParticipantInList(player) and getElementHealth(player) ~= 0 then
				faction = player.m_Faction
				if faction == self.m_Faction1 then
					dist = math.floor(getDistanceBetweenPoints3D(pX, pY, pZ, x, y, z))
					if dist <= GANGWAR_CENTER_HOLD_RANGE then
						return true
					end
				end
			end
		end
	end
	return false
end

function AttackSession:attackLose() --// loose for team1
	if self.endReason == 3 then 
		if self:backupCenterCheck() then 
			return
		end
	end
	self:notifyFactions()
	for k, v in ipairs(self.m_Faction2:getOnlinePlayers()) do 
		v:givePoints(20)
	end
	self.m_AreaObj:update()
	self.m_Faction1:sendMessage("[Gangwar] #FFFFFFDer Angriff ist gescheitert!",200,0,0,true)
	self.m_Faction2:sendMessage("[Gangwar] #FFFFFFDas Gebiet wurde verteidigt!",0,180,40,true)
	self:logSession(self.m_Faction2)
	self.m_AreaObj:attackEnd(  )
	self:stopClients()
	if isTimer( self.m_BattleTime ) then
		killTimer( self.m_BattleTime )
	end
end

function AttackSession:attackWin() --// win for team1
	self:notifyFactions()
	self.m_AreaObj.m_Owner = self.m_Faction1.m_Id
	for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do 
		v:givePoints(20)
	end
	self.m_AreaObj:update()

	self.m_Faction2:sendMessage("[Gangwar] #FFFFFFDas Gebiet ist verloren!",2000,0,0,true)
	self.m_Faction1:sendMessage("[Gangwar] #FFFFFFDer Angriff war erfolgreich!",0,180,40,true)
	self:logSession(self.m_Faction1)
	self.m_AreaObj:attackEnd(  )
	self:stopClients()
	if isTimer( self.m_BattleTime ) then
		killTimer( self.m_BattleTime )
	end
end

function AttackSession:onDecisionTimeEnd()
	if self.m_PickList and #self.m_PickList > 0  then
		local saveCount = 0
		for k,v in ipairs( self.m_Participants ) do
			if v:getFaction() == self.m_Faction2 then
				saveCount = saveCount + 1
			end
		end
		if saveCount < 3 then saveCount = 3 end
		for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do
			if not self:isPlayerInPick(v) then 
				self:onPurposlyDisqualify( v, false, true)
			end
		end
		for k, player in ipairs(self.m_PickList) do 
			if player and isElement(player) then
 				if k > saveCount + 1 then 
					self:onPurposlyDisqualify( player, false, true)
				end
			end
		end
	end
	for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do 
		v:triggerEvent("GangwarPick:close")
	end
	for k, v in ipairs(self.m_Faction2:getOnlinePlayers()) do 
		v:triggerEvent("GangwarPick:close")
	end
	self:createTeamBlips()
	self.m_DecisionEnded = true
end

function AttackSession:isPlayerInPick( player )
	for _, player2 in ipairs(self.m_PickList) do 
		if player2 and isElement(player2) and player == player2 then 
			return true
		end
	end
	return false
end

function AttackSession:getFactions()
	return self.m_Faction1,self.m_Faction2
end

function AttackSession:createBarricadeCars( )
	self.m_Barricades = {	}
	local iCarCount = self.m_AreaObj.m_CarCount
	local x,y,z = self.m_AreaObj.m_Position[1], self.m_AreaObj.m_Position[2], self.m_AreaObj.m_Position[3]
	local newX, newY
	local factionColor = factionCarColors[self.m_Faction1.m_Id]
	for i = 1, iCarCount do
		newX, newY = getPointFromDistanceRotation(x, y, 6, 360 * (i/5));
		self.m_Barricades[i] = TemporaryVehicle.create(482, newX, newY, z, i* (360/iCarCount))
		self.m_Barricades[i]:setData("isGangwarVehicle", true)
		self.m_Barricades[i]:disableRespawn(true)
		setElementData( self.m_Barricades[i] , "breakCar", true)
		setVehicleDamageProof( self.m_Barricades[i], true )
		setVehicleColor( self.m_Barricades[i], factionColor.r , factionColor.g , factionColor.b )
		self.m_OnEnter = bind( AttackSession.onVehicleEnter, self)
		addEventHandler("onVehicleStartEnter", self.m_Barricades[i], self.m_OnEnter )
	end
end

function AttackSession:onVehicleEnter( pEnter )
	if pEnter.m_Faction == self.m_Faction1 then
	
	else
		pEnter:sendError(_("Sie sind kein Angreifer!", pEnter))
		cancelEvent()
	end
end

function AttackSession:destroyBarricadeCars( )
	for i = 1, #self.m_Barricades do
		destroyElement( self.m_Barricades[i] )
	end
end

function AttackSession:createWeaponBox()
	local x, y, z = self.m_AreaObj.m_Position[1], self.m_AreaObj.m_Position[2], self.m_AreaObj.m_Position[3]
	self.m_WeaponBox = createObject( 964, x, y, z-1.5)
	self:generateWeapons( )
	self.m_WeaponBoxAttendants = {}
	self.m_bindFunc = bind( AttackSession.onWeaponBoxClick, self )
	addEventHandler("onElementClicked", self.m_WeaponBox, self.m_bindFunc )
	self.m_WeaponBoxFunc = bind( AttackSession.takeWeaponFromBox, self)
	addEventHandler("ClientBox:takeWeaponFromBox", root , self.m_WeaponBoxFunc)
	self.m_BindCloseWeaponFunc = bind( AttackSession.removeFromWeaponBoxUI, self)
	addEventHandler("ClientBox:onCloseWeaponBox", root, self.m_BindCloseWeaponFunc )
	self.m_BindBoxTimer = function() self:destroyWeaponBox() end
	self.m_WeaponBoxTimer = setTimer(self.m_BindBoxTimer, 60000,1)
	self.m_Faction1:sendMessage("[Gangwar] #FFFFFFDie Waffenbox ist für eine Minute vorhanden!",0,204,204,true)
end

function AttackSession:generateWeapons( )
	self.m_BoxWeapons =	{	}
	for i = 1, 2 do
		self.m_BoxWeapons[#self.m_BoxWeapons+1] = {31,200}
	end
	for i = 1, 3 do
		self.m_BoxWeapons[#self.m_BoxWeapons+1] = {24,200}
	end
	for i = 1, 3 do
		self.m_BoxWeapons[#self.m_BoxWeapons+1] = {29,200}
	end
	for i = 1, 1 do
		self.m_BoxWeapons[#self.m_BoxWeapons+1] = {33,200}
	end
end

function AttackSession:onWeaponBoxClick( button, state, clicker)
	if button == "left" and state == "up" then
		if clicker.m_Faction == self.m_Faction1 then
			self:addToWeaponBoxUI( clicker )
			clicker:triggerEvent( "Gangwar:showWeaponBox", self.m_BoxWeapons  )
		end
	end
end

function AttackSession:addToWeaponBoxUI( player )
	if not self:isInWeaponBoxUI( player ) then
		self.m_WeaponBoxAttendants[#self.m_WeaponBoxAttendants + 1] = player
	end
end

function AttackSession:isInWeaponBoxUI( player )
	if self.m_WeaponBoxAttendants then
		for i = 1, #self.m_WeaponBoxAttendants do
			if self.m_WeaponBoxAttendants[i] == player then
				return i
			end
		end
	end
	return false
end

addEvent("ClientBox:onCloseWeaponBox", true)
function AttackSession:removeFromWeaponBoxUI( player )
	local key = self.isInWeaponBoxUI( player )
	if key then
		table.remove( self.m_WeaponBoxAttendants, key )
	end
end

addEvent("ClientBox:takeWeaponFromBox", true)
function AttackSession:takeWeaponFromBox( key )

	if self.m_BoxWeapons[key] then
		local weaponId = self.m_BoxWeapons[key][1]

		if client:getWeaponLevel() < MIN_WEAPON_LEVELS[weaponId] then
			client:sendError(_("Dein Waffenlevel ist zu niedrig! (Benötigt: %i)", client, MIN_WEAPON_LEVELS[weaponId]))
			return
		end
		giveWeapon( source, weaponId, self.m_BoxWeapons[key][2], true )
		self.m_Faction1:sendMessage("[Gangwar] #FFFFFFDer Spieler "..getPlayerName( source ).." nahm sich eine "..WEAPON_NAMES[weaponId].." aus der Box heraus.",0,204,204,true)
		table.remove( self.m_BoxWeapons, key )
		self:refreshWeaponBox(  )
	end
end

function AttackSession:refreshWeaponBox(  )
	for i = 1, # self.m_WeaponBoxAttendants do
		self.m_WeaponBoxAttendants[i]:triggerEvent( "ClientBox:refreshItems", self.m_BoxWeapons )
	end
end

function AttackSession:destroyWeaponBox()
	if isElement( self.m_WeaponBox ) then
		destroyElement( self.m_WeaponBox )
		for i = 1, #self.m_WeaponBoxAttendants do
			self.m_WeaponBoxAttendants[i]:triggerEvent( "ClientBox:forceClose")
		end
		self.m_WeaponBoxAttendants = {}
	end
end

function AttackSession:destroyTeamBlips()
	for key, player in pairs(getElementsByType("player")) do
		player:triggerEvent("Gangwar:destroyTeamBlips")
	end
end

function AttackSession:createTeamBlips()
	if GANGWAR_TEAMBLIPS == false then return end
	local faction1 = {}
	local faction2 = {}
	for key, player in pairs(self.m_Participants) do
		if not self:isPlayerDisqualified(player) then
			if player:getFaction() == self.m_Faction1 then
				faction1[#faction1+1] = player
			elseif player:getFaction() == self.m_Faction2 then
				faction2[#faction2+1] = player
			end
		end
	end
	for key, player in pairs(self.m_Participants) do
		if player:getFaction() == self.m_Faction1 then
			playertable = faction1
		elseif player:getFaction() == self.m_Faction2 then
			playertable = faction2
		end
		player:triggerEvent("Gangwar:createTeamBlips", playertable) 
	end
end