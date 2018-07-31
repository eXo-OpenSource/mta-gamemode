-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Guns/Guns.lua
-- *  PURPOSE:     Client Gun Class
-- *
-- ****************************************************************************

Guns = inherit(Singleton)
local w,h = guiGetScreenSize()
local tracer = dxCreateTexture("files/images/Textures/tracer.png")
local flyTime = 200
local NO_TRACERS = {
	[25] = true,
	[26] = true,
	[27] = true,
}

local TOGGLE_WEAPONS =
{
	[24] = true, -- [FROM] = TO
	[23] = true,
	[22] = true,
}

local WEAPON_RANGE_CHECK = 
{
	[22] = true,
	[23] = true,
	[22] = true,
	[24] = true, 
	[25] = true, 
	[26] = true, 
	[29] = true,
	[30] = true,
	[31] = true,
	[32] = true, 
	[33] = true, 
	[34] = true,
}

local WEAPON_CACHE_MELEE_DAMAGE = 
{
	[17] = true, 
	[18] = true,
	[37] = true,
	[53] = true,
	[41] = true,
}

function Guns:constructor()

	self.m_Blood = false
	self.m_BloodImage = "files/images/Other/blood.png"
	self.m_BloodAlpha = 0
	self.m_BloodRender = bind(self.drawBloodScreen, self)

	engineImportTXD (engineLoadTXD ( "files/models/taser.txd" ), 347 )
	engineReplaceModel ( engineLoadDFF ( "files/models/taser.dff", 347 ), 347 )

	self.m_ClientDamageBind = bind(self.Event_onClientPlayerDamage, self)
	localPlayer.m_LastSniperShot = getTickCount()
	self.m_TaserImage = dxCreateTexture("files/images/Other/thunder.png")
	self.m_TaserRender = bind(self.Event_onTaserRender, self)
	addEventHandler("onClientPlayerDamage", root, self.m_ClientDamageBind)
	addEventHandler("onClientPlayerWeaponFire", root, bind(self.Event_onClientWeaponFire, self))
	addEventHandler("onClientPedDamage", root, bind(self.Event_onClientPedDamage, self))
	addEventHandler("onClientPedWasted", root, bind(self.Event_onClientPedWasted, self))
	addEventHandler("onClientPlayerWasted", localPlayer, bind(self.Event_onClientPlayerWasted, self))
	addEventHandler("onClientPlayerStealthKill", root, cancelEvent)
	addEventHandler("onClientPlayerWeaponSwitch",localPlayer, bind(self.Event_onWeaponSwitch,self))
	self.m_NetworkInteruptFreeze = false
	self.HookDrawAttention = bind(self.drawNetworkInterupt, self)
	addEventHandler( "onClientPlayerNetworkStatus", root, bind(self.Event_NetworkInterupt, self))
	addEventHandler("onClientRender",root, bind(self.Event_checkFadeIn, self))
	self:initalizeAntiCBug()
	self.m_LastWeaponToggle = 0
	addRemoteEvents{"clientBloodScreen"}

	addEventHandler("clientBloodScreen", root, bind(self.bloodScreen, self))
	self.m_MeleeCache = {}
	setTimer(bind(self.checkMeleeCache, self), MELEE_CACHE_CHECK, 0)
	
	self.m_HitMarkRender = bind(self.Event_RenderHitMarker, self)
end

function Guns:destructor()

end

function Guns:toggleHitMark( bool )
	self.m_HitMark = bool
end

function Guns:Event_NetworkInterupt( status, ticks )
	if (status == 0) then
		if (not isElementFrozen(localPlayer)) then
			setElementFrozen(localPlayer, true) 
			self.m_NetworkInteruptFreeze = true
		end
		--addEventHandler( "onClientRender", root, self.HookDrawAttention)
		outputDebugString( "interruption began " .. ticks .. " ticks ago" )
	elseif (status == 1) then
		if (self.m_NetworkInteruptFreeze) then
			setElementFrozen(localPlayer, false) 
			self.m_NetworkInteruptFreeze = false
		end
		--removeEventHandler( "onClientRender", root, self.HookDrawAttention)
		outputDebugString( "interruption began " .. ticks .. " ticks ago and has just ended" )
	end
end

function Guns:drawNetworkInterupt() 
	if getTickCount() % 1000 <= 750 then
		dxDrawImage(w*0.3-w*0.035, h*0.01, w*0.035, w*0.035, "files/images/warning.png")
		dxDrawText("Netzwerkprobleme!", w*0.31, h*0.01+1, w, (h*0.01+w*0.035)+1, tocolor(0, 0, 0, 255), 2, "clear", "left", "center")
		dxDrawText("Netzwerkprobleme!", w*0.31, h*0.01, w, h*0.01+w*0.035, tocolor(200, 0, 0, 255), 2, "clear", "left", "center")
	end
end

function Guns:Event_onClientPedWasted( killer, weapon, bodypart, loss)
	if killer == localPlayer then
		triggerServerEvent("onDeathPedWasted", localPlayer, source, weapon)
	end
end

MELEE_CACHE_CHECK = 2000
function Guns:Event_onClientPlayerDamage(attacker, weapon, bodypart, loss)
	local bPlaySound = false
	local bRangeCheck = true
	if weapon == 9 then -- Chainsaw
		cancelEvent()
	elseif weapon == 42 then --Fire Extinguisher
		cancelEvent()
		setPedOnFire(source, false)
	elseif weapon == 23 then -- Taser
		local dist = getDistanceBetweenPoints3D(attacker:getPosition(),source:getPosition())
		if not attacker.vehicle and dist < 10 and dist > 1.5 then
			if attacker == localPlayer then
				bPlaySound = true
				triggerServerEvent("onTaser",attacker,source)
			end
		end
		cancelEvent()
	else
		if attacker and (attacker == localPlayer or instanceof(attacker, Actor)) and not self.m_NetworkInteruptFreeze then -- Todo: Sometimes Error: classlib.lua:139 - Cannot get the superclass of this element
			if weapon and bodypart and loss then
				if WEAPON_DAMAGE[weapon] then
					if WEAPON_RANGE_CHECK[weapon] and self:isInRange(source, bodypart, weapon)  then
						bPlaySound = true
						triggerServerEvent("onClientDamage", attacker, source, weapon, bodypart, loss, self:isInMeleeRange( source))
					elseif not WEAPON_RANGE_CHECK[weapon] then
						bPlaySound = true
						triggerServerEvent("onClientDamage", attacker, source, weapon, bodypart, loss)
					end
				else
					if weapon ~= 17 or ( not WearableHelmet:getSingleton().m_GasMask ) then
						bPlaySound = false
						self:addMeleeDamage( source, weapon, bodypart, loss)
					else 
						cancelEvent()
					end
				end
			end
		elseif localPlayer == source then
			if attacker and weapon and bodypart and loss then
				if WEAPON_DAMAGE[weapon] then
					cancelEvent()
				end
			end
		elseif attacker and (attacker == localPlayer or instanceof(attacker, Actor)) and self.m_NetworkInteruptFreeze then
			cancelEvent()
			outputDebugString("Canceling Damage")
		end
	end
	if core:get("Other", "HitSoundBell", true) and bPlaySound and getElementType(attacker) ~= "ped" then
		playSound("files/audio/hitsound.wav")
	end
	if bPlaySound and core:get("HUD", "Hitmark", true)  then 
		self.m_HitAccuracy = getWeaponProperty ( getPedWeapon(localPlayer), "pro", "accuracy")
		self.m_HitMarkEnd = 100
		removeEventHandler("onClientRender", root, self.m_HitMarkRender)
		addEventHandler("onClientRender", root, self.m_HitMarkRender)
	end
end

function Guns:isInRange( target, bodypart, weapon) 
	if target and isElement(target) and isElementStreamedIn(target) then
		local targetPosition = Vector3(target:getPosition(targetPosition))
		local position = Vector3(localPlayer:getPosition())
		local weaponRange = getWeaponProperty( weapon, "std", "weapon_range")
		return ((math.floor((targetPosition - position):getLength())) <= weaponRange), weaponRange
	end
	return false
end	

function Guns:isInMeleeRange( target ) 
	if target and isElement(target) and isElementStreamedIn(target) then
		local targetPosition = Vector3(target:getPosition(targetPosition))
		local position = Vector3(localPlayer:getPosition())
		return (targetPosition - position):getLength() <= 1
	end
	return false
end	

function Guns:addMeleeDamage( player, weapon , bodypart, loss ) 
	if self.m_MeleeCache then 
		if WEAPON_CACHE_MELEE_DAMAGE[weapon] then
			if self.m_MeleeCache["Weapon"] and self.m_MeleeCache["Weapon"] == weapon and self.m_MeleeCache["Target"] and self.m_MeleeCache["Target"] == player then 
				self.m_MeleeCache["Loss"] = self.m_MeleeCache["Loss"] + loss
			else 
				self.m_MeleeCache["Weapon"] = weapon 
				self.m_MeleeCache["Target"] = player 
				self.m_MeleeCache["Tick"] = getTickCount() 
				self.m_MeleeCache["Bodypart"] = bodypart
				self.m_MeleeCache["Loss"] = 0
				if core:get("Other", "HitSoundBell", true) and getElementType(player) ~= "ped" then
					playSound("files/audio/hitsound.wav")
				end
			end
		else 
			triggerServerEvent("gunsLogMeleeDamage", localPlayer, player, weapon, bodypart, loss)
			if core:get("Other", "HitSoundBell", true) and getElementType(player) ~= "ped" then
				playSound("files/audio/hitsound.wav")
			end
		end
	end
end

function Guns:sendMeleeDamage() 
	if self.m_MeleeCache then 
		triggerServerEvent("gunsLogMeleeDamage", localPlayer, self.m_MeleeCache["Target"], self.m_MeleeCache["Weapon"], self.m_MeleeCache["Bodypart"], self.m_MeleeCache["Loss"])
		self.m_MeleeCache = {}
	end
end

function Guns:checkMeleeCache() 
	if self.m_MeleeCache then 
		if self.m_MeleeCache["Tick"] then
			if getTickCount() > self.m_MeleeCache["Tick"] + MELEE_CACHE_CHECK then 
				self:sendMeleeDamage()
			end
		end
	end
end

function Guns:Event_onWeaponSwitch(pw, cw)
	if source == localPlayer then
		local prevWeapon = getPedWeapon(localPlayer,pw)
		local cWeapon = getPedWeapon(localPlayer, cw)
		if cWeapon ~= 34 then
			toggleControl("fire",true)
			if localPlayer.m_FireToggleOff then
				if localPlayer.m_LastSniperShot+6000 <= getTickCount() then
					localPlayer.m_FireToggleOff = false
				end
			end
			self.m_HasSniper = false
		else
			if localPlayer.m_FireToggleOff then
				if localPlayer.m_LastSniperShot+6000 >= getTickCount() then
					toggleControl("fire",false)
				else
					localPlayer.m_FireToggleOff = false
					toggleControl("fire",true)
				end
			else
				if not NoDm:getSingleton().m_NoDm then
					toggleControl("fire",true)
					localPlayer.m_FireToggleOff = false
				end
			end
			self.m_HasSniper = true
		end
	end
end

function Guns:Event_onClientPlayerWasted( killer, weapon, bodypart)
	if source == localPlayer then
		triggerServerEvent("onClientWasted", localPlayer, killer, weapon, bodypart)
	end
end

function Guns:Event_onClientWeaponFire(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if weapon == 23 then -- Taser
		if source.vehicle then return end

		self.m_TaserAttacker = source
		self.m_HitPos = Vector3(hitX, hitY, hitZ)
		if getDistanceBetweenPoints3D(source:getPosition(),self.m_HitPos) < 10 then
			if hitElement and getElementType(hitElement) == "player" and not hitElement:getOccupiedVehicle() then
				self.m_TaserTarget = hitElement
				removeEventHandler("onClientRender",root,self.m_TaserRender)
				addEventHandler("onClientRender",root,self.m_TaserRender)
			else
				self.m_TaserTarget = nil
				removeEventHandler("onClientRender",root,self.m_TaserRender)
				addEventHandler("onClientRender",root,self.m_TaserRender)
			end

			if isTimer(self.m_ResetTimerNoTarget) then killTimer(self.m_ResetTimerNoTarget) end
			if isTimer(self.m_ResetTimer) then killTimer(self.m_ResetTimer) end
			self.m_ResetTimer = setTimer(function() removeEventHandler("onClientRender", root, self.m_TaserRender) end, 15000, 1)
		end
	end

	if source == localPlayer then
		if weapon == 34 then
			if not localPlayer.m_FireToggleOff then
				localPlayer.m_LastSniperShot = getTickCount()
				localPlayer.m_FireToggleOff = true
				toggleControl("fire",false)
				setTimer(function()
					localPlayer.m_FireToggleOff = false
					toggleControl("fire",true)
				end, 6000,1)
			end
		end
	end

	if weapon == 43 then -- Camera
		HUDRadar:getSingleton():hide()
		HUDUI:getSingleton():hide()
		HelpBar:getSingleton().m_Icon:setVisible(false)
		showChat(false)

		for k, v in pairs(MessageBoxManager.Map) do
			v:hide()
		end

		--dxDrawText("Powered by #Pew#ff8000P#fffffforn.com", 10, 10, screenWidth, screenHeight, Color.White, 1, "clear", "left", "top", false, false, false, true)
		dxDrawImage(0, screenHeight - 68, 142/1920*screenWidth, 68/1080*screenHeight, "files/images/Logo.png", 0, 0, 0, tocolor(255, 255, 255, 50))

		nextframe(
			function()
				HUDRadar:getSingleton():show()
				HUDUI:getSingleton():show()
				showChat(true)

				if core:get("HUD", "showHelpBar", true) then
					HelpBar:getSingleton().m_Icon:setVisible(true)
				end

				for k, v in pairs(MessageBoxManager.Map) do
					v:show()
				end
			end
		)
	end
end

function Guns:Event_checkFadeIn()
	local hasSniper = getPedWeapon(localPlayer) == 34
	if hasSniper then

		local bAiming = isPedAiming(localPlayer)
		if bAiming then
			if not self.m_SniperShader then
				if localPlayer:getData("inWare") then return end
				self.m_SniperShader = SniperShader:new(3000)
				playSound("files/audio/sniper.ogg")
				self.m_SniperTimer = setTimer(function()
					self:removeSniperShader()
				end, 3100,1)
			end
		else
			if self.m_SniperShader then
				delete(self.m_SniperShader)
			end
			self.m_SniperShader = false
			if self.m_SniperTimer then
				if isTimer(self.m_SniperTimer) then
					killTimer(self.m_SniperTimer)
				end
			end
		end
	else
		if self.m_SniperShader then
			delete(self.m_SniperShader)
		end
		self.m_SniperShader = false
		if self.m_SniperTimer then
			if isTimer(self.m_SniperTimer) then
				killTimer(self.m_SniperTimer)
			end
		end
	end
end

function Guns:removeSniperShader()
	if self.m_SniperShader then
		delete(self.m_SniperShader)
	end
end

function Guns:Event_onTaserRender()
	if self.m_TaserAttacker and (self.m_HitPos or self.m_TaserTarget) then
		if self.m_TaserTarget and self.m_TaserAttacker:getTarget() == self.m_TaserTarget then
			self.m_HitPos = self.m_TaserTarget:getPosition()
			self.m_HitPos.z = self.m_HitPos.z-1
		else
			if not isTimer(self.m_ResetTimerNoTarget) then
				self.m_ResetTimerNoTarget = setTimer(
					function()
						if isTimer(self.m_ResetTimer) then killTimer(self.m_ResetTimer) end
						removeEventHandler("onClientRender", root, self.m_TaserRender)
					end, 1000, 1)
			end
		end

		local muzzlePos = Vector3(getPedWeaponMuzzlePosition(self.m_TaserAttacker))
		local effect = math.random(0,10)/10
		if math.random(0,1) == 1 then self.m_HitPos.z = self.m_HitPos.z+effect/20 else self.m_HitPos.z = self.m_HitPos.z-effect/20 end

		dxDrawMaterialLine3D (muzzlePos,self.m_HitPos,self.m_TaserImage, 0.8+effect)
	else
		removeEventHandler("onClientRender",root,self.m_TaserRender)
	end
end

function Guns:Event_RenderHitMarker()
	if getPedControlState ( localPlayer, 'aim_weapon' ) then
		self.m_HitMarkEnd = self.m_HitMarkEnd - 5;
		local hitX,hitY,hitZ = getPedTargetEnd ( localPlayer )
		if not self.m_HitAccuracy then self.m_HitAccuracy = 1 end
		local scale = 1 / self.m_HitAccuracy
		local screenX1, screenY1 = getScreenFromWorldPosition ( hitX,hitY,hitZ )
		dxDrawImage(screenX1-(16*scale/2), screenY1-(16*scale/2), 16*scale, 16*scale, 'files/images/hit.png')	
	else 
		removeEventHandler("onClientRender", root, self.m_HitMarkRender)
	end	
	if self.m_HitMarkEnd <= 0 then
		removeEventHandler("onClientRender", root, self.m_HitMarkRender)
	end
end

function Guns:bloodScreen()
	self.m_BloodAlpha = 255
	if self.m_Blood == false then
		removeEventHandler("onClientRender", root, self.m_BloodRender)
		addEventHandler("onClientRender", root, self.m_BloodRender)
	end
end

function Guns:drawBloodScreen()
	self.m_Blood = true
	if self.m_BloodAlpha > 0 then
	  self.m_BloodAlpha = self.m_BloodAlpha - 5;
	end
	dxDrawImage(0, 0, screenWidth, screenHeight, self.m_BloodImage, 0, 0, 0, tocolor(225, 255, 255, self.m_BloodAlpha))
	if self.m_BloodAlpha <= 0 then
	  removeEventHandler("onClientRender", root, self.m_BloodRender)
	  self.m_Blood = false
	end
end

function Guns:Event_onClientPedDamage(attacker)
	if source:getData("NPC:Immortal") == true or getElementData( source, "NPC:Immortal_serverside") then
		cancelEvent()
	else
		if attacker == localPlayer then
			if core:get("Other", "HitSoundBell", true) then
				playSound("files/audio/hitsound.wav")
			end
			if self.m_HitMark then 
				self.m_HitAccuracy = getWeaponProperty ( getPedWeapon(localPlayer), "pro", "accuracy")
				self.m_HitMarkEnd = 100
				removeEventHandler("onClientRender", root, self.m_HitMarkRender)
				addEventHandler("onClientRender", root, self.m_HitMarkRender)
			end
		end
	end
end

function Guns:disableDamage(state)
	if state then
		removeEventHandler("onClientPlayerDamage", root, self.m_ClientDamageBind)
	else
		addEventHandler("onClientPlayerDamage", root, self.m_ClientDamageBind)
	end
end

function Guns:initalizeAntiCBug()
	self.m_AntiFastShotEnabled = true
	self.m_LastShot = 0
	self.m_LastCrouchTimers = {}

	self.m_StopFastDeagleBind = bind(self.stopFastDeagle, self)
	self.m_CrounchBind = bind(self.crounch, self)

	addEventHandler("onClientPlayerWeaponFire", localPlayer, self.m_StopFastDeagleBind, true, "high")
	bindKey("crouch", "both", self.m_CrounchBind)
end

function Guns:crounch(btn, state)
	if state == "down" then
		if not isPedDucked ( localPlayer ) and ( getTickCount () - self.m_LastShot <= 700 ) then
			setPedControlState ( "crouch", true )
			toggleControl ( "crouch", false )
			if isTimer ( self.m_LastCrouchTimers[1] ) then
				killTimer ( self.m_LastCrouchTimers[1] )
			end
			self.m_LastCrouchTimers[1] = setTimer ( setPedControlState, 100, 1, "crouch", false )
		end
	else
		if getTickCount() - self.m_LastShot <= 700 then
			setPedControlState ( "crouch", false )
			toggleControl ( "crouch", false )
			if isTimer ( self.m_LastCrouchTimers[1] ) then
				killTimer ( self.m_LastCrouchTimers[1] )
			end
			if isTimer ( self.m_LastCrouchTimers[2] ) then
				killTimer ( self.m_LastCrouchTimers[2] )
			end
			self.m_LastCrouchTimers[2] = setTimer ( toggleControl, 100, 1, "crouch", true )
		else
			toggleControl ( "crouch", true )
		end
	end
end

function Guns:stopFastDeagle(weapon)
	if weapon == 24 then
		self.m_LastShot = getTickCount()
		setPedControlState ( "crouch", false )
		if isPedDucked ( localPlayer ) then
			toggleControl ( "crouch", false )
			self.m_LastCrouchTimers[1] = setTimer ( toggleControl, 500, 1, "crouch", true )
		end
	end
end

function Guns:toggleFastShot(bool)
	self.m_AntiFastShotEnabled = not bool
	if not self.m_AntiFastShotEnabled then
		removeEventHandler ( "onClientPlayerWeaponFire", localPlayer, shoot )
		unbindKey ( "crouch", "both", crouch )
	end
end
