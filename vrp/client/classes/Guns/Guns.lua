-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Guns/Guns.lua
-- *  PURPOSE:     Client Gun Class
-- *
-- ****************************************************************************
Guns = inherit(Singleton)
local w, h = screenWidth, screenHeight
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
	self.m_TracerTable = {}
	self.m_NetworkInteruptFreeze = false
	self.HookDrawAttention = bind(self.drawNetworkInterupt, self)
	addEventHandler( "onClientPlayerNetworkStatus", root, bind(self.Event_NetworkInterupt, self))
	--addEventHandler("onClientRender",root, bind(self.Event_checkFadeIn, self))
	self.m_LastWeaponToggle = 0
	addRemoteEvents{"clientBloodScreen", "clientMonochromeFlash", "prepareGrenadeThrow", "throwProjectile"}
	addEventHandler("clientBloodScreen", root, bind(self.bloodScreen, self))
	addEventHandler("clientMonochromeFlash", root, bind(self.monochromeFlash, self))
	addEventHandler("prepareGrenadeThrow", root, bind(self.prepareGrenadeThrow, self))
	addEventHandler("throwProjectile", root, bind(self.throwProjectile, self))
	self.m_GrenadeThrowBind = bind(self.renderThrowPreparation, self)
	self.m_GrenadeHandleBind = bind(self.handleThrowBind, self)
	self.m_MeleeCache = {}
	setTimer(bind(self.checkMeleeCache, self), MELEE_CACHE_CHECK, 0)

	self.m_HitMarkRender = bind(self.Event_RenderHitMarker, self)
	self.m_HitMark = false
	self.m_TracerEnabled = false
	self.m_hitpath = fileExists("_custom/files/audio/hitsound.wav") and "_custom/files/audio/hitsound.wav" or "files/audio/hitsound.wav"

	WeaponManager:new()

end

function Guns:destructor()

end

function Guns:toggleMonochromeShader(bool)
	if bool then
		self.m_ChromeShader = MonochromeShader:new()
		self.m_ChromeShader:setAlpha(0)
		self.m_ChromeShader.m_Active = false
	else
		if self.m_ChromeShader then
			self.m_ChromeShader = MonochromeShader:delete()
		end
	end
end

function Guns:toggleTracer( bool )
	if bool then
		self.m_TracerTable = {}
		removeEventHandler("onClientRender", root, bind(self.Event_renderTracer, self))
		addEventHandler("onClientRender", root, bind(self.Event_renderTracer, self))
	else
		self.m_TracerTable = {}
		removeEventHandler("onClientRender", root, bind(self.Event_renderTracer, self))
	end
	self.m_TracerEnabled = bool
end

function Guns:toggleHitMark( bool )
	self.m_HitMark = bool
end

function Guns:Event_NetworkInterupt( status, ticks )
	if (status == 0) then
		if (not isElementFrozen(localPlayer)) then
			setElementFrozen(localPlayer, true)
			toggleControl("fire", false)
			toggleControl("aim_weapon", false)
			self.m_NetworkInteruptFreeze = true
		end
		--addEventHandler( "onClientRender", root, self.HookDrawAttention)
		outputDebugString( "interruption began " .. ticks .. " ticks ago" )
	elseif (status == 1) then
		if (self.m_NetworkInteruptFreeze) then
			setElementFrozen(localPlayer, false)
			toggleControl("fire", true)
			toggleControl("aim_weapon", true)
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
		if not source.m_isClientSided then
			triggerServerEvent("onDeathPedWasted", localPlayer, source, weapon)
		end
	end
end

MELEE_CACHE_CHECK = 2000
function Guns:Event_onClientPlayerDamage(attacker, weapon, bodypart, loss)
	local bPlaySound = false
	local bRangeCheck = true
	local isThrowingHit = false
	if isValidElement(attacker, "object") then
		if self:onHitByThrowObject(attacker, source, weapon, bodypart, loss) then -- check if the object that damaged the player is a throwable
			return cancelEvent()
		end
	end
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
		if localPlayer == source then
			if InjuryTreatmentGUI:isInstantiated() then
				triggerServerEvent("Damage:onCancelTreat", localPlayer)
			end
		end
		cancelEvent()
	elseif weapon == 17 then
		if source.getPublicSync and source:getPublicSync("HelmetItem") == "Gasmaske" then
		else
			if source == localPlayer then
				WearableHelmet:getSingleton():onTearNade()
			end
		end
		cancelEvent()
	else
		if attacker and weapon and source == localPlayer and attacker:getPublicSync("supportMode") and weapon == 0 then
			-- source:setAnimation("fight_c", "hitc_3", -1, false, true, true, true, 250, true)
			localPlayer:setVelocity(0, 0, 0.2)
			setTimer(function(forward)
				localPlayer:setVelocity(forward * Vector3(0.2, 0.2, 0))
			end, 200, 1, attacker.matrix:getForward())
		end

		if attacker and (attacker == localPlayer or instanceof(attacker, Actor)) and not self.m_NetworkInteruptFreeze and not NetworkMonitor:getSingleton():getPingDisabled() and not NetworkMonitor:getSingleton():getLossDisabled() then -- Todo: Sometimes Error: classlib.lua:139 - Cannot get the superclass of this element
			if weapon and bodypart and loss then
				if WEAPON_DAMAGE[weapon] or EXPLOSIVE_DAMAGE_MULTIPLIER[weapon] then
					if WEAPON_RANGE_CHECK[weapon] and self:isInRange(source, bodypart, weapon)  then
						bPlaySound = true
						triggerServerEvent("onClientDamage", attacker, source, weapon, bodypart, loss, self:isInMeleeRange( source))
					elseif not WEAPON_RANGE_CHECK[weapon] then
						bPlaySound = true
						triggerServerEvent("onClientDamage", attacker, source, weapon, bodypart, loss)
					end
					if EXPLOSIVE_DAMAGE_MULTIPLIER[weapon] then cancelEvent() end
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
				if InjuryTreatmentGUI:isInstantiated() then
					triggerServerEvent("Damage:onCancelTreat", localPlayer)
				end
				if WEAPON_DAMAGE[weapon] then
					cancelEvent()
				end
			end
		elseif attacker and (attacker == localPlayer or instanceof(attacker, Actor)) and self.m_NetworkInteruptFreeze then
			cancelEvent()
			outputDebugString("Canceling Damage")
		end
	end
	if core:get("Sounds", "HitBell", true) and bPlaySound and getElementType(attacker) ~= "ped" and source ~= attacker then
		playSound(self.m_hitpath or "files/audio/hitsound.wav")
	end
	if bPlaySound and self.m_HitMark and attacker == localPlayer then
		self.m_HitAccuracy = getWeaponProperty ( getPedWeapon(localPlayer), "pro", "accuracy") or 1
		self.m_HitMarkRed = getElementHealth(source) == 0
		self.m_HitMarkEnd = self.m_HitMarkRed and 200 or 100
		removeEventHandler("onClientRender", root, self.m_HitMarkRender)
		addEventHandler("onClientRender", root, self.m_HitMarkRender)
	end
end

function Guns:onHitByThrowObject(attacker, target, weapon, bodypart, loss)
	local throwingPlayer =  attacker:getData("Throw:responsiblePlayer")
	if throwingPlayer then
		if throwingPlayer == localPlayer then
			if not attacker:getData("Throw:entityDamageDisabled") then
				triggerServerEvent("Throw:reportDamage", localPlayer, target, attacker, bodypart)
			end
			self.m_HitMark = true
			self.m_HitAccuracy = 1.3
			self.m_HitMarkRed = true
			self.m_HitMarkEnd = self.m_HitMarkRed and 200 or 100
			removeEventHandler("onClientRender", root, self.m_HitMarkRender)
			addEventHandler("onClientRender", root, self.m_HitMarkRender)
			if core:get("Sounds", "HitBell", true) then
				playSound(self.m_hitpath or "files/audio/hitsound.wav")
			end
		end
		return true
	end
end

function Guns:onPedHitByThrowObject(attacker, ped, weapon, bodypart)
	local throwingPlayer =  attacker:getData("Throw:responsiblePlayer")
	if throwingPlayer then
		if throwingPlayer == localPlayer then
			if not attacker:getData("Throw:entityDamageDisabled") then
				triggerServerEvent("Throw:reportDamage", localPlayer, ped, attacker, bodypart)
			end
			self.m_HitMark = true
			self.m_HitAccuracy = 1.3
			self.m_HitMarkRed = true
			self.m_HitMarkEnd = self.m_HitMarkRed and 200 or 100
			removeEventHandler("onClientRender", root, self.m_HitMarkRender)
			addEventHandler("onClientRender", root, self.m_HitMarkRender)
			if core:get("Sounds", "HitBell", true) then
				playSound(self.m_hitpath or "files/audio/hitsound.wav")
			end
		end
		return true
	end
end

function Guns:isInRange( target, bodypart, weapon)
	if target and isElement(target) and isElementStreamedIn(target) then
		local tx, ty, tz = getElementPosition(target)
		local px, py, pz = getElementPosition(localPlayer)
		local weaponRange = getWeaponProperty( weapon, "std", "weapon_range")
		return (math.floor(getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz)) <= weaponRange), weaponRange
	end
	return false
end

function Guns:isInMeleeRange( target )
	if target and isElement(target) and isElementStreamedIn(target) then
		local tx, ty, tz = getElementPosition(target)
		local px, py, pz = getElementPosition(localPlayer)
		return getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz) <= 1
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
				if core:get("Sounds", "HitBell", true) and getElementType(player) ~= "ped" and player ~= localPlayer then
					playSound(self.m_hitpath or "files/audio/hitsound.wav")
				end
			end
		else
			triggerServerEvent("gunsLogMeleeDamage", localPlayer, player, weapon, bodypart, loss)
			if core:get("Sounds", "HitBell", true) and getElementType(player) ~= "ped" and player ~= localPlayer then
				playSound(self.m_hitpath or "files/audio/hitsound.wav")
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
			toggleControl("action",true)
			if localPlayer.m_FireToggleOff then
				if localPlayer.m_LastSniperShot+4000 <= getTickCount() then
					localPlayer.m_FireToggleOff = false
				end
			end
			self.m_HasSniper = false
		else
			if localPlayer.m_FireToggleOff then
				if localPlayer.m_LastSniperShot+4000 >= getTickCount() then
					toggleControl("fire",false)
					toggleControl("action",false)
				else
					localPlayer.m_FireToggleOff = false
					toggleControl("fire",true)
					toggleControl("action",true)
				end
			else
				if not NoDm:getSingleton().m_NoDm then
					toggleControl("fire",true)
					toggleControl("action",true)
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
		if self.m_TracerEnabled then
			if not THROWABLE_WEAPONS[weapon] then
				local wx, wy, wz = getPedWeaponMuzzlePosition(localPlayer)
				local x, y, z = normalize(hitX-wx, hitY-wy, hitZ-wz)
				local x, y, z = x*10, y*10, z*10
				if (x^2+y^2+z^2)^0.5 > getDistanceBetweenPoints3D(wx, wy, wz, hitX, hitY, hitZ) then
					x, y, z = hitX-wx, hitY-wy, hitZ-wz
				end
				local length = getDistanceBetweenPoints3D(hitX, hitY, hitZ, wx, wy, wz)
				local steps = length / (x^2+y^2+z^2)^0.5
				self.m_TracerTable[getTickCount()] = {wx-x, wy-y, wz-z, hitX, hitY, hitZ, steps, x, y, z, 0}
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

--[[
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
]]

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

		local muzzlePosX, muzzlePosY, muzzlePosZ = getPedWeaponMuzzlePosition(self.m_TaserAttacker)
		local effect = math.random(0,10)/10
		if math.random(0,1) == 1 then self.m_HitPos.z = self.m_HitPos.z+effect/20 else self.m_HitPos.z = self.m_HitPos.z-effect/20 end

		dxDrawMaterialLine3D (muzzlePosX, muzzlePosY, muzzlePosZ,self.m_HitPos,self.m_TaserImage, 0.8+effect)
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
		local color =  not self.m_HitMarkRed and tocolor(255, 255, 255, 255) or tocolor(200, 0, 0, 255)
		dxDrawImage(screenX1-(16*scale/2), screenY1-(16*scale/2), 16*scale, 16*scale, 'files/images/hit.png', 0, 0, 0, color)
	else
		removeEventHandler("onClientRender", root, self.m_HitMarkRender)
	end
	if self.m_HitMarkEnd <= 0 then
		removeEventHandler("onClientRender", root, self.m_HitMarkRender)
	end
end

function Guns:Event_renderTracer()
	local now = getTickCount()
	local interp, prog, startPos, vecFlight, bulletVec, length, startX, startY, startZ, updateVec, steps
	for time, obj in pairs(self.m_TracerTable) do
		if time and obj then
			startPosX, startPosY, startPosZ, endPosX, endPosY, endPosZ, maxSteps, flightX, flightY, flightZ, steps = obj[1], obj[2], obj[3], obj[4], obj[5], obj[6], obj[7], obj[8], obj[9], obj[10], obj[11]
			--startPos, endPos, maxSteps, flightVec, steps = obj[1], obj[2], obj[3], obj[4], obj[5]
			steps = steps + 1
			startX = startPosX+flightX
			startY = startPosY+flightY
			startZ = startPosZ+flightZ
			if startPosX and endPosX then
				dxDrawLine3D(startX, startY, startZ, startX+flightX, startY+flightY, startZ+flightZ, tocolor(255, 255, 255, 80), 2 )
			end
			self.m_TracerTable[time] = {startX, startY, startZ, obj[4], obj[5], obj[6], maxSteps, obj[8], obj[9], obj[10], steps}
			if steps > maxSteps then
				self.m_TracerTable[time] = nil
			end
		end
	end
end

function Guns:monochromeFlash()
	if self.m_ChromeShader then
		self.m_ChromeShader:flash()
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

function Guns:Event_onClientPedDamage(attacker, weapon, bodypart)
	if isValidElement(attacker, "object") then
		self:onPedHitByThrowObject(attacker, source, weapon, bodypart) -- check if the object that damaged the ped is a throwable
	end
	if source:getData("NPC:Immortal") == true or getElementData( source, "NPC:Immortal_serverside") then
		cancelEvent()
	else
		if attacker == localPlayer then
			if core:get("Sounds", "HitBell", true) then
				playSound(self.m_hitpath or "files/audio/hitsound.wav")
			end
			if self.m_HitMark then
				self.m_HitAccuracy = getWeaponProperty ( getPedWeapon(localPlayer), "pro", "accuracy")
				self.m_HitMarkRed = getElementHealth(source) == 0
				self.m_HitMarkEnd = self.m_HitMarkRed and 200 or 100
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

function Guns:throwProjectile(projectile, force, leftHanded)
	local bx, by, bz = getPedBonePosition(localPlayer, leftHanded and 35 or 25)
	local x, y, z, x2, y2, z2 = getCameraMatrix()
	local x, y, z = normalize(x2-x, y2-y, z2-z)
	createProjectile(localPlayer, projectile, bx, by, bz, 1, false, 0, 0, 0, x*force, y*force, z*force)
	localPlayer.m_HasThrownGrenade = false
end

function Guns:renderThrowPreparation()
	localPlayer.m_GrenadeThrowProgress = localPlayer.m_GrenadeThrowProgress - 0.001
	setPedAnimationProgress(localPlayer, "WEAPON_throw", localPlayer.m_GrenadeThrowProgress)
	localPlayer.m_GrenadeThrowForce = localPlayer.m_GrenadeThrowForce + 0.02

	if localPlayer.m_GrenadeThrowProgress < 0.12 then
		removeEventHandler("onClientRender", root, self.m_GrenadeThrowBind)
	end
end

function Guns:handleThrowBind(key, keystate)
	if localPlayer.m_HasThrownGrenade == false then
		if keystate == "down" then
			localPlayer.m_GrenadeThrowProgress = 0.15
			localPlayer.m_GrenadeThrowForce = 0.2
			triggerServerEvent("disableGrenadeAimLeave", localPlayer)
			if not isEventHandlerAdded("onClientRender", root, self.m_GrenadeThrowBind) then
				addEventHandler("onClientRender", root, self.m_GrenadeThrowBind)
			end
		elseif keystate == "up" then
			if isEventHandlerAdded("onClientRender", root, self.m_GrenadeThrowBind) then
				removeEventHandler("onClientRender", root, self.m_GrenadeThrowBind)
			end
			triggerServerEvent("startGrenadeThrow", localPlayer, localPlayer.m_GrenadeThrowForce)
			localPlayer.m_HasThrownGrenade = true
		end
	end
end

function Guns:prepareGrenadeThrow(state)
	if state == true then
		bindKey("fire", "both", self.m_GrenadeHandleBind)
		localPlayer.m_HasThrownGrenade = false
	else
		unbindKey("fire", "both", self.m_GrenadeHandleBind)
		if isEventHandlerAdded("onClientRender", root, self.m_GrenadeThrowBind) then
			removeEventHandler("onClientRender", root, self.m_GrenadeThrowBind)
		end
	end
end
