-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     AttackSession Client
-- *
-- ****************************************************************************
AttackClient = inherit(Object)
addRemoteEvents{"onGangwarDamage", "onGangwarKill", "GangwarPick:synchronizePick", "GangwarPick:close"}

local REPORT_LAST_KILL = false
local pseudoSingleton, clearTimer
function AttackClient:constructor( faction1 , faction2 , pParticipants, pDisqualified, pInitTime, pPos, pAreaID, bIsNoRush, areaName, pCanModifyPick, pPickParticipants, pShowPickGUI, pNoPickGUI)
	REPORT_LAST_KILL = false
	self.m_Faction = faction1
	self.m_Faction2 = faction2
	self.m_Participants = pParticipants
	self.m_Disqualified = pDisqualified
	self.m_PickParticipants = pPickParticipants
	localPlayer.attackSession = self
	self.m_GangwarDamage = 0
	self.m_GangwarKill = 0
	self.m_NoRush = bIsNoRush
	self.m_AreaID = pAreaID
	if isTimer(clearTimer) then
		killTimer(clearTimer)
	end
	self.m_Display = GangwarDisplay:new( faction1, faction2, self, pInitTime, pPos )
	if not pNoPickGUI then
		self.m_GangwarPick = GangwarPickGUI:new( areaName, pCanModifyPick, pShowPickGUI )
	end
	if self.m_GangwarPick then
		self.m_GangwarPick:setVisible(false)
	end
	self.m_GangwarPick:synchronize( pPickParticipants, pDisqualified)
	self.m_Blips = {}
	self.m_DamageFunc = bind( AttackClient.addDamage, self)
	addEventHandler("onGangwarDamage", localPlayer, self.m_DamageFunc)
	self.m_KillFunc = bind( AttackClient.addKill, self)
	addEventHandler("onGangwarKill", localPlayer, self.m_KillFunc)
	self.m_bindWeaponBoxFunc = bind( AttackClient.showWeaponBox, self )
	addEventHandler( "Gangwar:showWeaponBox", localPlayer, self.m_bindWeaponBoxFunc)
	self.m_bindWeaponBoxRefreshFunc = bind( AttackClient.onRefreshItems, self )
	addEventHandler( "ClientBox:refreshItems", localPlayer, self.m_bindWeaponBoxRefreshFunc)
	self.m_bindWeaponBoxCloseFunc = bind( AttackClient.forceClose, self )
	addEventHandler( "ClientBox:forceClose", localPlayer, self.m_bindWeaponBoxCloseFunc)
	--self.m_BindNoRushFunc = bind( AttackClient.onDamage, self )
	--addEventHandler("onClientPlayerDamage",root, self.m_BindNoRushFunc)
	self.m_bindPickClose = bind(AttackClient.closeGangwarPick, self)
	addEventHandler("GangwarPick:close", localPlayer, self.m_bindPickClose)
	self.m_TeamBlipCreateBind = bind(AttackClient.createTeamBlips, self)
	addEventHandler("Gangwar:createTeamBlips", localPlayer, self.m_TeamBlipCreateBind)
	self.m_TeamBlipDestroyBind = bind(AttackClient.destroyTeamBlips, self)
	addEventHandler("Gangwar:destroyTeamBlips", localPlayer, self.m_TeamBlipDestroyBind)
end

function AttackClient:onDamage( attacker )
	if self.m_NoRush then
		--cancelEvent()
	end
end

function AttackClient:addDamage( target, weapon, bodypart, loss )
	if target ~= localPlayer then
		local facSource = source:getFactionId()
		local facTarget = target:getFactionId()
		if facSource ~= facTarget then
			if facSource == self.m_Faction.m_Id or facSource == self.m_Faction2.m_Id then
				if facTarget == self.m_Faction.m_Id or facTarget == self.m_Faction2.m_Id then
					if source == localPlayer then
						if not self.m_GangwarDamage then
							self.m_GangwarDamage = 0
						end
						self.m_GangwarDamage = math.ceil( self.m_GangwarDamage + loss )
					end
				end
			end
		end
	end
end

function AttackClient:addKill( target, weapon, bodypart, loss)
	if target ~= localPlayer then
		local facSource = source:getFactionId()
		local facTarget = target:getFactionId()
		if facTarget ~= facSource then
			if facSource == self.m_Faction.m_Id or facSource == self.m_Faction2.m_Id then
				if facTarget == self.m_Faction.m_Id or facTarget == self.m_Faction2.m_Id then
					if source == localPlayer then
						self.m_GangwarKill = math.floor( self.m_GangwarKill + 1 )
						if not self.m_GangwarDamage then
							self.m_GangwarDamage = 0
						end
						self.m_GangwarDamage = math.ceil( self.m_GangwarDamage + loss )
					end
				end
			end
		end
	end
end

function AttackClient:destructor()
	if self.m_Display then
		local func = function() self.m_Display:delete() end
		clearTimer = setTimer( func, 5000, 1)
	end
	if self.m_GangwarPick then
		self.m_GangwarPick:delete()
	end
	destroyQuestionBox()
end

function AttackClient:closeGangwarPick()
	if self.m_GangwarPick then
		self.m_GangwarPick:delete()
	end
end

function AttackClient:synchronizeLists( pParticipants, pDisqualified, pPickList, pUpdater, pTick, pPickParticipants )
	self.m_Participants = pParticipants
	self.m_Disqualified = pDisqualified
	if self.m_GangwarPick then
		self:synchronizeGangwarPick( pPickParticipants, pDisqualified )
		self.m_GangwarPick:updateMessage(pPickList, pUpdater, pTick, true)
	end
end

function AttackClient:synchronizeTime( time )
	if self.m_Display then
		if self.m_Display.m_TimeLeft then
			if (self.m_Display.m_TimeLeft - time) > 2 then
				outputDebugString("Synchronized Time by "..self.m_Display.m_TimeLeft-time.." seconds!", 0, 200, 200, 0)
			end
			self.m_Display.m_TimeLeft = time
		end
	end
end

function AttackClient:getFactionParticipants( pFac )
	local table_ = { }
	for k, v in ipairs( self.m_Participants ) do
		if v:getFactionId() == pFac.m_Id then
			table_[#table_+1] = v
		end
	end
	return table_
end

function AttackClient:getFactionsMembers( pFac )
	local tAll = getElementsByType("player")
	local table_ = { }
	for k, v in ipairs( tAll ) do
		if v:getFactionId() == pFac.m_Id then
			table_[#table_+1] = v
		end
	end
	return table_
end

function AttackClient:synchronizeGangwarPick( participants, disuqlified )
	if participants and disuqlified then
		self.m_GangwarPick:synchronize( participants, disuqlified )
	end
end

addEvent("AttackClient:synchronizeLists",true)
function AttackClient.remoteSynchronize( pParticipants, pDisqualified, pList, pUpdater, pTick, pPickParticipants )
	if pseudoSingleton then
		pseudoSingleton:synchronizeLists( pParticipants , pDisqualified, pList, pUpdater, pTick, pPickParticipants )
	end
end
addEventHandler("AttackClient:synchronizeLists", root,AttackClient.remoteSynchronize)

addEvent("AttackClient:synchronizeTime",true)
function AttackClient.remoteSynchronizeTime( pTime )
	if pseudoSingleton then
		pseudoSingleton:synchronizeTime( pTime )
	end
end
addEventHandler("AttackClient:synchronizeTime", root,AttackClient.remoteSynchronizeTime)

addEvent("AttackClient:launchClient",true)
function AttackClient.newClient( faction1, faction2, pParticipants, pDisqualified, pTime, pPos, pAreaID, bNoRush, pAreaName, pAttacker, pPickParticipants, pShowPickGUI, pNoPick)
	if pseudoSingleton then
		pseudoSingleton:delete()
	end
	pseudoSingleton = AttackClient:new( faction1, faction2, pParticipants, pDisqualified, pTime, pPos, pAreaID, bNoRush, pAreaName, pAttacker, pPickParticipants, pShowPickGUI, pNoPick)
end
addEventHandler("AttackClient:launchClient",localPlayer,AttackClient.newClient)

addEvent("AttackClient:stopClient",true)
function AttackClient.stopClient()
	if pseudoSingleton then
		pseudoSingleton:delete()
	end
end
addEventHandler("AttackClient:stopClient",localPlayer,AttackClient.stopClient)

addEvent("AttackClient:sendBreakMsg", true)
function AttackClient.onBreakCMD( bState )
	if pseudoSingleton then
		if bState then
			pseudoSingleton.m_State = "Gebraked"
		else
			pseudoSingleton.m_State = "Entbraked"
		end
		if not pseudoSingleton.m_RenderFunc then
			pseudoSingleton.m_RenderFunc = bind( AttackClient.m_BreakRender, pseudoSingleton)
		end
		pseudoSingleton.m_StartTick = getTickCount()
		removeEventHandler("onClientRender", root, pseudoSingleton.m_RenderFunc)
		addEventHandler("onClientRender", root, pseudoSingleton.m_RenderFunc)
	end
end
addEventHandler("AttackClient:sendBreakMsg", localPlayer, AttackClient.onBreakCMD)

function AttackClient.m_BreakRender( )
	local now = getTickCount()
	if now - pseudoSingleton.m_StartTick < 5000 then
		dxDrawRectangle(screenWidth*0.3,screenHeight*0.6,screenWidth*0.4,screenHeight*0.05,tocolor(0,0,0,200))
		dxDrawText("#FFFFFF[Sie haben dieses Fahrzeug #00FFFF"..pseudoSingleton.m_State.." #FFFFFF!]",screenWidth*0.3,screenHeight*0.6,screenWidth*0.7,screenHeight*0.6+screenHeight*0.05,tocolor(255,255,255,255),1,"sans","center","center",false,false,false,true)
	else removeEventHandler("onClientRender", root, pseudoSingleton.m_RenderFunc)
	end
end

addEvent("Gangwar:showWeaponBox", true )
function AttackClient:showWeaponBox( pList )
	if not self.m_isBoxActive then
		self.m_WeaponBoxUI = WeaponBoxGUI:new( self , pList )
	end
end

addEvent("ClientBox:refreshItems",true)
function AttackClient:onRefreshItems( pList )
	if self.m_WeaponBoxUI then
		self.m_WeaponBoxUI:refreshItems( pList )
	end
end

addEvent("ClientBox:forceClose",true)
function AttackClient:forceClose( )
	if self.m_WeaponBoxUI then
		self.m_WeaponBoxUI:delete()
	end
end

addEvent("Gangwar:createTeamBlips",true)
function AttackClient:createTeamBlips(playertable)
	for key, player in ipairs(playertable) do
		if player ~= localPlayer then
			self.m_Blips[player] = Blip:new("Marker.png", player:getPosition().x, player:getPosition().y, 700, {235, 125, 15}, {235, 125, 15})
			self.m_Blips[player]:attach(player)
			self.m_Blips[player]:setDisplayText(player:getName(), "Anderes")
		end
	end
end

addEvent("Gangwar:destroyTeamBlips",true)
function AttackClient:destroyTeamBlips()
	for player, blip in ipairs(self.m_Blips) do
		delete(self.m_Blips[player])
	end
end