-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Guns/Guns.lua
-- *  PURPOSE:     Client Gun Class
-- *
-- ****************************************************************************

Guns = inherit(Singleton)

function Guns:constructor()

	self.m_Blood = false
	self.m_BloodImage = "files/images/Other/blood.png"
	self.m_BloodAlpha = 0
	self.m_BloodRender = bind(self.drawBloodScreen, self)


	engineImportTXD (engineLoadTXD ( "files/models/taser.txd" ), 347 )
	engineReplaceModel ( engineLoadDFF ( "files/models/taser.dff", 347 ), 347 )

	self.m_ClientDamageBind = bind(self.Event_onClientPlayerDamage, self)

	self.m_TaserImage = dxCreateTexture("files/images/Other/thunder.png")
	self.m_TaserRender = bind(self.Event_onTaserRender, self)
	addEventHandler("onClientPlayerDamage", root, self.m_ClientDamageBind)
	addEventHandler("onClientPlayerWeaponFire", root, bind(self.Event_onClientWeaponFire, self))
	addEventHandler("onClientPedDamage", root, bind(self.Event_onClientPedDamage))
	addEventHandler("onClientPlayerWasted", localPlayer, bind(self.Event_onClientPlayerWasted, self))
	addEventHandler("onClientPlayerStealthKill", root, cancelEvent)

	self:initalizeAntiCBug()

	addRemoteEvents{"clientBloodScreen"}

	addEventHandler("clientBloodScreen", root, bind(self.bloodScreen, self))
end

function Guns:destructor()

end

function Guns:Event_onClientPlayerDamage(attacker, weapon, bodypart, loss)
	if weapon == 9 then -- Chainsaw
		cancelEvent()
	elseif weapon == 23 then -- Taser
		local dist = getDistanceBetweenPoints3D(attacker:getPosition(),source:getPosition())
		if not attacker.vehicle and dist < 10 and dist > 1.5 then
			if attacker == localPlayer then
				triggerServerEvent("onTaser",attacker,source)
			end
		end
		cancelEvent()
	else
		if attacker and (attacker == localPlayer or instanceof(attacker, Actor)) then -- Todo: Sometimes Error: classlib.lua:139 - Cannot get the superclass of this element
			if weapon and bodypart and loss then
				if WEAPON_DAMAGE[weapon] then
					triggerServerEvent("onClientDamage",attacker, source, weapon, bodypart, loss)
				end
			end
		elseif localPlayer == source then
			self:bloodScreen()
			if attacker and weapon and bodypart and loss then
				if WEAPON_DAMAGE[weapon] then
					cancelEvent()
				end
			end
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

function Guns:bloodScreen()
	self.m_BloodAlpha = 255
	if self.m_Blood == false then
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

function Guns:Event_onClientPedDamage()
	if source:getData("NPC:Immortal") == true then
		cancelEvent()
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
	self.m_LastDeageShot = 0
	self.m_GotDeagle = false
	self.m_CrouchOn = true

	self.m_StopFastDeagleBind = bind(self.stopFastDeagle, self)
	self.m_StopCBugBind = bind(self.stopCbug, self)

	if getPedWeapon ( localPlayer ) == 24 then
		toggleControl ( "crouch", true )
		self.m_CrouchOn = true
		addEventHandler ( "onClientPlayerWeaponFire", localPlayer, self.m_StopFastDeagleBind )
		bindKey ( "crouch", "both", self.m_StopCBugBind )
		self.m_GotDeagle = true
	end

	addEventHandler ( "onClientPlayerWeaponSwitch", root, function ( previous, current )
	if getPedWeapon ( localPlayer, current ) == 24 then
		addEventHandler ( "onClientPlayerWeaponFire", localPlayer, self.m_StopFastDeagleBind )
		bindKey ( "crouch", "both", self.m_StopCBugBind )
		self.m_GotDeagle = true
	elseif self.m_GotDeagle then
		removeEventHandler ( "onClientPlayerWeaponFire", localPlayer, self.m_StopFastDeagleBind )
		unbindKey ( "crouch", "both", self.m_StopCBugBind )
		self.m_GotDeagle = false
	end
		toggleControl ( "crouch", true )
		self.m_CrouchOn = true
	end )

end

function Guns:stopCbug ( )
	if not self.m_CrouchOn then
		if self.m_LastDeageShot + 500 <= getTickCount() then
			toggleControl ( "crouch", true )
			self.m_CrouchOn = true
		end
	end
end

function Guns:stopFastDeagle ( )
	self.m_LastDeageShot = getTickCount()
	toggleControl ( "crouch", false )
	self.m_CrouchOn = false
end
