-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarManager.lua
-- *  PURPOSE:     Gangwar Class
-- *
-- ****************************************************************************

Gangwar = inherit(Singleton)


--// RESET VARIABLE //
GANGWAR_RESET_AREAS = false --// NUR IM FALLE VON GEBIET-RESET


--// Gangwar - Constants //--
GANGWAR_MATCH_TIME = 15
GANGWAR_CENTER_HOLD_RANGE = 20
GANGWAR_MIN_PLAYERS = 0
GANGWAR_ATTACK_PAUSE = 0 --// DAY
GANGWAR_CENTER_TIMEOUT = 20 --// SEKUNDEN NACH DEM DIE FLAGGE NICHT GEHALTEN IST
GANGWAR_DUMP_COLOR = setBytesInInt32(240,0,200,200)
GANGWAR_ATTACK_PICKUPMODEL =  1313
UNIX_TIMESTAMP_24HRS = 86400
--//

addRemoteEvents{"onLoadCharacter","onDeloadCharacter","Gangwar:onClientRequestAttack"}

function Gangwar:constructor( )
	if GANGWAR_RESET_AREAS then 
		self:RESET() 
	end
	self.m_Areas = {	}
	self.m_CurrentAttacks = {	}
	local sql_query = "SELECT * FROM ??_gangwar"
	local drow = sql:queryFetch(sql_query,sql:getPrefix())
	if drow then 
		for i, datarow in ipairs( drow ) do 
			self.m_Areas[#self.m_Areas+1] = Area:new( datarow )
		end
	end
	
	addCommandHandler("attack",bind(self.onAttackCMD,self))
	addEventHandler("onLoadCharacter",root,bind(self.onPlayerJoin,self))
	addEventHandler("onDeloadCharacter",root,bind(self.onPlayerQuit,self))
	addEventHandler("Gangwar:onClientRequestAttack",root,bind(self.attackReceiveCMD,self))
	addEventHandler("onPlayerWasted",root,bind(self.onPlayerWasted,self))
	
end	

function Gangwar:RESET() 
	local sql_query = "UPDATE ??_gangwar SET Besitzer='5'"
	sql:queryFetch(sql_query,sql:getPrefix())
	outputDebugString("Gangwar-areas were reseted!")
end

function Gangwar:destructor( )
	for index = 1,#self.m_Areas do 
		self.m_Areas[index]:delete()
	end
end

function Gangwar:onPlayerJoin()
	local factionObj = source.m_Faction
	if factionObj then 
		local factionID = factionObj.m_Id
		for index = 1,#self.m_CurrentAttacks do 
			local faction1,faction2 = self.m_CurrentAttacks[index]:getMatchFactions()
			if faction1 == factionID or faction2 == factionID then 
				--// gangwar join
				AttackSession:joinPlayer( source ) 
			end
		end
	end
end

function Gangwar:onPlayerQuit()
	local factionObj = source.m_Faction
	if factionObj then 
		local factionID = factionObj.m_Id
		for index = 1,#self.m_CurrentAttacks do 
			local faction1,faction2 = self.m_CurrentAttacks[index]:getMatchFactions()
			if faction1 == factionID or faction2 == factionID then 
				--// gangwar quit
				AttackSession:quitPlayer( source ) 
			end
		end
	end
end

function Gangwar:onPlayerWasted(  ... ) 
	local attackSession = source.m_RefAttackSession
	if attackSession then 
		attackSession:onPlayerWasted( source,... )
	end
end

function Gangwar:addAreaToAttacks( pArea ) 
	self.m_CurrentAttacks[#self.m_CurrentAttacks + 1] = pArea
end

function Gangwar:removeAreaFromAttacks( pArea ) 
	local area
	for index = 1,#self.m_CurrentAttacks do 
		area = self.m_CurrentAttacks[index]
		if area == pArea then
			table.remove( self.m_CurrentAttacks,index)
		end
	end
end

function Gangwar:getCurrentGangwars( ) 
	local area
	local objTable = {	}
	for index = 1,#self.m_CurrentAttacks do 
		area = self.m_CurrentAttacks[index]
		if area:isUnderAttack() then 
			objTable[#objTable + 1] = area 
		end
	end
	return objTable
end


function Gangwar:onAttackCMD( player )
	local mArea = player.m_InsideArea 
	if mArea then 
		player:triggerEvent("Gangwar:show_AttackGUI")
	end
end

function Gangwar:attackReceiveCMD( ) 
	if client then 
		if client == source then 
			self:attackArea( client )
		end
	end
end

function Gangwar:attackArea( player )
	local faction = player.m_Faction 
	if faction then 
		local id = player.m_Faction.m_Id 
		local mArea = player.m_InsideArea
		if mArea then 
			local bWithin = isElementWithinColShape(player,mArea.m_CenterSphere)
			if bWithin then 
				local areaOwner = mArea.m_Owner
				local faction2 = FactionManager:getSingleton():getFromId(areaOwner)
				if areaOwner ~= id then 
					local factionCount = #faction:getOnlinePlayers()
					local factionCount2 = #faction2:getOnlinePlayers()
					if factionCount >= GANGWAR_MIN_PLAYERS then 
						if factionCount2 >= GANGWAR_MIN_PLAYERS then 
							local activeGangwars = self:getCurrentGangwars( )
							local acGangwar,acFaction1,acFaction2
							for index = 1,#activeGangwars do 
								acGangwar = activeGangwars[index]
								if acGangwar.m_AttackSessions then 
									acFaction1,acFaction2 = acGangwar.m_AttackSessions:getFactions()
									if acFaction1 ~= faction and acFaction2 ~= faction then 
										if acFaction2 ~= faction2 and acFaction2 ~= faction2 then 
										else return player:sendError(_("Die gegnerische Fraktion ist bereits in einem Gangwar!", player))
										end
									else return player:sendError(_("Ihre Fraktion ist bereits in einem Gangwar!", player))
									end
								end
							end
							local lastAttack = mArea.m_LastAttack 
							local currentTimestamp = getRealTime().timestamp
							local nextAttack = lastAttack + ( GANGWAR_ATTACK_PAUSE*UNIX_TIMESTAMP_24HRS)
							if nextAttack <= currentTimestamp then 
								mArea:attack(faction,faction2)
							else player:sendError(_("Dieses Gebiet ist noch nicht attackierbar!", player))
							end 
						else player:sendError(_("Es müssen mind. "..GANGWAR_MIN_PLAYERS.." aus der Gegner-Fraktion online sein!", player))
						end
					else player:sendError(_("Es müssen mind. "..GANGWAR_MIN_PLAYERS.." aus Ihrer Fraktion online sein!", player))
					end
				else player:sendError(_("Sie können sich nicht selbst angreifen!", player))
				end
			else player:sendError(_("Sie sind an keinem Gebiet!", player))
			end
		else player:sendError(_("Sie sind an keinem Gebiet!", player))
		end
	else player:sendError(_("Sie sind in keiner Fraktion!", player))
	end
end