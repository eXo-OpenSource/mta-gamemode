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

	self.m_TaserImage = dxCreateTexture("files/images/Other/thunder.png")
	self.m_TaserRender = bind(self.Event_onTaserRender, self)
	addEventHandler("onClientPlayerDamage", root, bind(self.Event_onClientPlayerDamage, self))
	addEventHandler("onClientPlayerWeaponFire", root, bind(self.Event_onClientWeaponFire, self))
end

function Guns:destructor()

end

function Guns:Event_onClientPlayerDamage(attacker, weapon, bodypart, loss)
	if weapon == 23 then -- Taser
		if getDistanceBetweenPoints3D(attacker:getPosition(),source:getPosition()) < 10 then
			if attacker == localPlayer then
				triggerServerEvent("onTaser",attacker,source)
			end
		end
		cancelEvent()
	else
		if attacker and attacker == localPlayer then
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

function Guns:Event_onClientWeaponFire(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if weapon == 23 then -- Taser
		self.m_TaserAttacker = source
		self.m_HitPos = Vector3(hitX, hitY, hitZ)
		if getDistanceBetweenPoints3D(source:getPosition(),self.m_HitPos) < 10 then
			if hitElement and getElementType(hitElement) == "player" and not hitElement:getOccupiedVehicle() then
				self.m_TaserTarget = hitElement
				removeEventHandler("onClientRender",root,self.m_TaserRender)
				addEventHandler("onClientRender",root,self.m_TaserRender)
			else
				removeEventHandler("onClientRender",root,self.m_TaserRender)
				addEventHandler("onClientRender",root,self.m_TaserRender)
			end
		end
	end
end

function Guns:Event_onTaserRender()
	if self.m_TaserAttacker and (self.m_HitPos or self.m_TaserTarget) then
		if getPedTarget(self.m_TaserAttacker) then
			if self.m_TaserTarget then
				self.m_HitPos = self.m_TaserTarget:getPosition()
				self.m_HitPos.z = self.m_HitPos.z-1
			end
		else
			setTimer(function()
				removeEventHandler("onClientRender",root,self.m_TaserRender)
			end,1000,1)
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
