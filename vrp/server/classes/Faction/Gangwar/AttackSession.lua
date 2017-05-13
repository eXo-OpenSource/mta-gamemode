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
	self:createBarricadeCars( )
	self.m_BreakFunc = bind(  self.onBreakCMD , self)
	addEventHandler("onPlayerCommand", root, self.m_BreakFunc)
	self.m_DamageFunc = bind(  self.onGangwarDamage , self)
	addEventHandler("onClientDamage", root, self.m_DamageFunc)
	self.m_BattleTime = setTimer(bind(self.attackWin, self), GANGWAR_MATCH_TIME*60000, 1)
	self:createWeaponBox()
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
	removeEventHandler("onPlayerCommand", root, self.m_BreakFunc)
	removeEventHandler("onClientDamage", root, self.m_DamageFunc)
end

function AttackSession:setupSession ( )
	for k,v in ipairs( self.m_Faction1:getOnlinePlayers() ) do
		self.m_Participants[#self.m_Participants + 1] = v
		v.kills = 0
	end
	for k,v in ipairs( self.m_Faction2:getOnlinePlayers() ) do
		self.m_Participants[#self.m_Participants + 1] = v
		v.kills = 0
	end
	self:synchronizeAllParticipants( )
end

function AttackSession:synchronizeAllParticipants( )
	for k,v in ipairs( self.m_Participants ) do
		v:triggerEvent("AttackClient:launchClient",self.m_Faction1,self.m_Faction2,self.m_Participants,self.m_Disqualified, GANGWAR_MATCH_TIME*60, self.m_AreaObj.m_Position, self.m_AreaObj.m_ID )
		v:triggerEvent("GangwarQuestion:new")
	end

end

function AttackSession:synchronizeLists( )
	for k,v in ipairs( self.m_Faction1:getOnlinePlayers()) do
		v:triggerEvent("AttackClient:synchronizeLists",self.m_Participants,self.m_Disqualified)
	end
	for k,v in ipairs( self.m_Faction2:getOnlinePlayers() ) do
		v:triggerEvent("AttackClient:synchronizeLists",self.m_Participants,self.m_Disqualified)
	end
end

function AttackSession:synchronizePlayerList( player )
	player:triggerEvent("AttackClient:synchronizeLists",self.m_Participants,self.m_Disqualified)
end


function AttackSession:addParticipantToList( player, bLateJoin )
	local bInList = self:isParticipantInList( player )
	if not bInList then
		self.m_Participants[#self.m_Participants + 1] = player
		if not bLateJoin then
			player:triggerEvent("AttackClient:launchClient",self.m_Faction1,self.m_Faction2,self.m_Participants,self.m_Disqualified, GANGWAR_MATCH_TIME*60, self.m_AreaObj.m_Position, self.m_AreaObj.m_ID)
		else
			if isTimer( self.m_BattleTime ) then
				local timeLeft = getTimerDetails( self.m_BattleTime )
				timeLeft = math.ceil(timeLeft /1000)
				player:triggerEvent("AttackClient:launchClient",self.m_Faction1,self.m_Faction2,self.m_Participants,self.m_Disqualified, timeLeft, self.m_AreaObj.m_Position, self.m_AreaObj.m_ID)
			end
		end
		self:synchronizeLists( )
		player:triggerEvent("GangwarQuestion:new")
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
	local bIsDisqualifed = self:isPlayerDisqualified( player )
	if not bIsDisqualifed then
		self.m_Disqualified[ #self.m_Disqualified + 1] = player.name
		self:removeParticipant( player )
		self:synchronizeLists( )
	end
end

function AttackSession:joinPlayer( player )
	if not self:isPlayerDisqualified( player ) then
		self:addParticipantToList( player , true)
	else 
		if isTimer( self.m_BattleTime ) then
			local timeLeft = getTimerDetails( self.m_BattleTime )
			timeLeft = math.ceil(timeLeft /1000)
			player:triggerEvent("AttackClient:launchClient",self.m_Faction1,self.m_Faction2,self.m_Participants,self.m_Disqualified, timeLeft, self.m_AreaObj.m_Position, self.m_AreaObj.m_ID)
		end
	end
end

function AttackSession:quitPlayer( player )
	self:removeParticipant( player )
end

function AttackSession:onPurposlyDisqualify( player, bAfk )
	local reason = ""
	if bAfk then 
		reason = "(AFK)"
	end
	self:disqualifyPlayer( player )
	self.m_Faction1:sendMessage("[Gangwar] #FFFFFFDer Spieler "..getPlayerName(player).." nimmt nicht am Gangwar teil! "..reason,100,120,100,true)
	self.m_Faction2:sendMessage("[Gangwar] #FFFFFFDer Spieler "..getPlayerName(player).." nimmt nicht am Gangwar teil! "..reason,100,120,100,true)
end

function AttackSession:onPlayerLeaveCenter( player )
	local faction = player.m_Faction
	if faction == self.m_Faction1 then
		local isAnyoneInside = self:checkPlayersInCenter( )
		if not isAnyoneInside then
			self:setCenterCountdown()
		end
	end
end

function AttackSession:onGangwarDamage( target, weapon, bpart, loss )
	if self:isParticipantInList( target ) and self:isParticipantInList( source ) then
		triggerClientEvent("onGangwarDamage", source, target, weapon, bpart, loss)
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

function AttackSession:onPlayerWasted( player, killer,  kWeapon, bodyP )
	local bParticipant = self:isParticipantInList( player )
	if bParticipant then
		if killer then
			local bParticipant2 = self:isParticipantInList( killer )
			if bParticipant2 then
				player.m_Faction:sendMessage("[Gangwar] #FFFFFFEin Mitglied ("..player.name..") ist getötet worden!",200,0,0,true)
				killer.m_Faction:sendMessage("[Gangwar] #FFFFFFEin Gegner ("..player.name..") ist getötet worden!",0,200,0,true)
				self:disqualifyPlayer( player )
				triggerClientEvent("onGangwarKill", killer, player, weapon, bpart)
			end
			if killer.kills then 
				killer.kills = killer.kills + 1
			else 
				killer.kills = 1 
			end
		else
			player.m_Faction:sendMessage("[Gangwar] #FFFFFFEin Mitglied ("..player.name..") ist getötet worden!",200,0,0,true)
			self:disqualifyPlayer( player )
		end
	end
end

function AttackSession:onPlayerEnterCenter( player )
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

function AttackSession:setCenterCountdown()
	self.endReason = 3
	self.m_Faction1:sendMessage("[Gangwar] #FFFFFFIhr habt noch "..GANGWAR_CENTER_TIMEOUT.." Sekunden Zeit die Flagge zu erreichen!",200,0,0,true)
	self.m_HoldCenterTimer = setTimer( bind(self.attackLose, self), GANGWAR_CENTER_TIMEOUT*1000,1)
	self.m_NotifiyAgainTimer = setTimer( bind(self.notifyFaction1, self), math.floor((GANGWAR_CENTER_TIMEOUT*1000)/2),1)
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

function AttackSession:stopClients()
	local receiveTimeout = 0
	for k, v in ipairs(self.m_Faction1:getOnlinePlayers()) do
		v:triggerEvent("AttackClient:stopClient")
		receiveTimeout = receiveTimeout +1
	end
	for k, v in ipairs(self.m_Faction2:getOnlinePlayers()) do
		v:triggerEvent("AttackClient:stopClient")
		receiveTimeout = receiveTimeout + 1
	end
	GangwarStatistics:getSingleton():setCollectorTimeout( self.m_AreaObj.m_ID, receiveTimeout )
end

function AttackSession:notifyFaction1( )
	self.m_Faction1:sendMessage("[Gangwar] #FFFFFFIhr habt nur noch "..math.floor(GANGWAR_CENTER_TIMEOUT/2).." Sekunden Zeit die Flagge zu erreichen!",200,0,0,true)
end

function AttackSession:checkPlayersInCenter( )
	local pTable = getElementsWithinColShape( self.m_AreaObj.m_CenterSphere, "player")
	local faction
	for key, player in ipairs( pTable ) do
		if not isPedDead( player ) then
			faction = player.m_Faction
			if faction == self.m_Faction1 then
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
	if isTimer( self.m_BattleTime ) then
		killTimer( self.m_BattleTime )
	end
end

function AttackSession:attackWin() --// win for team1
	self:notifyFactions()
	self.m_AreaObj.m_Owner = self.m_Faction1.m_Id
	self.m_AreaObj:update()

	self.m_Faction2:sendMessage("[Gangwar] #FFFFFFDas Gebiet ist verloren!",2000,0,0,true)
	self.m_Faction1:sendMessage("[Gangwar] #FFFFFFDer Angriff war erfolgreich!",0,180,40,true)

	self.m_AreaObj:attackEnd(  )
	self:stopClients()
	if isTimer( self.m_BattleTime ) then
		killTimer( self.m_BattleTime )
	end
end

function AttackSession:getFactions()
	return self.m_Faction1,self.m_Faction2
end

function AttackSession:createBarricadeCars( )
	self.m_Barricades = {	}
	local iCarCount = self.m_AreaObj.m_CarCount
	local x,y,z = self.m_AreaObj.m_Position[1], self.m_AreaObj.m_Position[2], self.m_AreaObj.m_Position[3]
	local newX, newY
	local factionColor = factionColors[self.m_Faction1.m_Id]
	for i = 1, iCarCount do
		newX, newY = getPointFromDistanceRotation(x, y, 6, 360 * (i/5));
		self.m_Barricades[i] = TemporaryVehicle.create(482, newX, newY, z, i* (360/iCarCount))
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

function AttackSession:onBreakCMD( cmdstring )
	if cmdstring == "fbrake" then
		if source.m_Faction == self.m_Faction1 then
			local pOcc = getPedOccupiedVehicle( source )
			if pOcc then
				if getElementData( pOcc, "breakCar") then
					local bState = not isElementFrozen( pOcc )
					setElementFrozen( pOcc, bState)
					source:triggerEvent("AttackClient:sendBreakMsg", bState)
				end
			end
		end
	end
end

function AttackSession:destroyBarricadeCars( )
	for i = 1, #self.m_Barricades do
		destroyElement( self.m_Barricades[i] )
	end
	removeEventHandler("onPlayerCommand", root, self.m_BreakFunc)
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
	self.m_BoxWeapons ={	}
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
