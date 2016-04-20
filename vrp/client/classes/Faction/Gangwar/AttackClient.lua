-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     AttackSession Client
-- *
-- ****************************************************************************
local w,h = guiGetScreenSize()
AttackClient = inherit(Object)
local pseudoSingleton

function AttackClient:constructor( faction1 , faction2 , pParticipants, pDisqualified, pInitTime, pPos, bIsNoRush) 
	self.m_Faction = faction1 
	self.m_Faction2 = faction2
	self.m_Participants = pParticipants 
	self.m_Disqualified = pDisqualified
	localPlayer.attackSession = self 
	self.m_GangwarDamage = 0
	self.m_GangwarKill = 0
	self.m_NoRush = bIsNoRush
	self.m_Display = GangwarDisplay:new( faction1, faction2, self, pInitTime, pPos )
	self.m_DamageFunc = bind( self.addDamage, self)
	addEventHandler("onClientPlayerDamage",root, self.m_DamageFunc)
	self.m_KillFunc = bind( self.addKill, self)
	addEventHandler("onClientPlayerWasted",root, self.m_KillFunc)
	self.m_bindWeaponBoxFunc = bind( AttackClient.showWeaponBox, self )
	addEventHandler( "Gangwar:showWeaponBox", localPlayer, self.m_bindWeaponBoxFunc)
	self.m_bindWeaponBoxRefreshFunc = bind( AttackClient.onRefreshItems, self )
	addEventHandler( "ClientBox:refreshItems", localPlayer, self.m_bindWeaponBoxRefreshFunc)
	self.m_bindWeaponBoxCloseFunc = bind( AttackClient.forceClose, self )
	addEventHandler( "ClientBox:forceClose", localPlayer, self.m_bindWeaponBoxCloseFunc)
	self.m_BindNoRushFunc = bind( AttackClient.onDamage, self )
	addEventHandler("onClientPlayerDamage",root, self.m_BindNoRushFunc)
end

function AttackClient:onDamage( attacker )
	if self.m_NoRush then 
	
	end
end

function AttackClient:addDamage( attacker, weapon, bodypart, loss )
	if source ~= localPlayer then 
		local facSource = source:getFaction()
		local facAttacker = attacker:getFaction()
		if facSource ~= facAttacker then 
			if facSource == self.m_Faction or facSource == self.m_Faction2 then 
				if facAttacker == self.m_Faction or facAttacker == self.m_Faction2 then 
					if attacker == localPlayer then 
						localPlayer.m_GangwarDamage = localPlayer.m_GangwarDamage + loss
					end
				end
			end
		end
	end
end

function AttackClient:addKill( attacker, weapon, bodypart)
	if source ~= localPlayer then 
		local facSource = source:getFaction()
		local facAttacker = attacker:getFaction()
		if facSource ~= facAttacker then 
			if facSource == self.m_Faction or facSource == self.m_Faction2 then 
				if facAttacker == self.m_Faction or facAttacker == self.m_Faction2 then 
					if attacker == localPlayer then 
						localPlayer.m_GangwarKill = localPlayer.m_GangwarKill + 1
					end
				end
			end
		end
	end
end

function AttackClient:destructor() 
	if self.m_Display then 
		self.m_Display:destructor()
	end
end 

function AttackClient:synchronizeLists( pParticipants, pDisqualified )
	self.m_Participants = pParticipants 
	self.m_Disqualified = pDisqualified
end

function AttackClient:synchronizeTime( ) 

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

addEvent("AttackClient:synchronizeLists",true)
function AttackClient.remoteSynchronize( pParticipants, pDisqualified )
	pseudoSingleton:synchronizeLists( pParticipants , pDisqualified )
end
addEventHandler("AttackClient:synchronizeLists",root,AttackClient.remoteSynchronize)

addEvent("AttackClient:launchClient",true)
function AttackClient.newClient( faction1, faction2, pParticipants, pDisqualified, pTime, pPos )
	if pseudoSingleton then 
		pseudoSingleton:delete()
	end
	pseudoSingleton = AttackClient:new( faction1, faction2, pParticipants, pDisqualified, pTime, pPos)
end
addEventHandler("AttackClient:launchClient",localPlayer,AttackClient.newClient)

addEvent("AttackClient:stopClient",true)
function AttackClient.stopClient(   )
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
		dxDrawRectangle(w*0.3,h*0.6,w*0.4,h*0.05,tocolor(0,0,0,200))
		dxDrawText("#FFFFFF[Sie haben diese Fahrzeug #00FFFF"..pseudoSingleton.m_State.." #FFFFFF!]",w*0.3,h*0.6,w*0.7,h*0.6+h*0.05,tocolor(255,255,255,255),1,"sans","center","center",false,false,false,true)
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
		self.m_WeaponBoxUI:destructor()
	end
end


