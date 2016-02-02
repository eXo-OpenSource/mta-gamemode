-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Guns/Guns.lua
-- *  PURPOSE:     Client Gun Class
-- *
-- ****************************************************************************

Guns = inherit(Singleton)

function Guns:constructor()
	
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
	if attacker:getPublicSync("Faction:Duty") and weapon == 23 then -- Taser
		if getDistanceBetweenPoints3D(attacker:getPosition(),source:getPosition()) < 10 then
			if attacker == localPlayer then
				triggerServerEvent("onTaser",attacker,source)
			end
		end
		cancelEvent()
	end
end

function Guns:Event_onClientWeaponFire(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if source:getPublicSync("Faction:Duty") and weapon == 23 then -- Taser
		self.m_MuzzlePos = Vector3(getPedWeaponMuzzlePosition(source))
		self.m_TaserAttacker = source
		if hitElement and getElementType(hitElement) == "player" then
			self.m_TaserTarget = hitElement
			removeEventHandler("onClientRender",root,self.m_TaserRender)
			addEventHandler("onClientRender",root,self.m_TaserRender)
		else
			self.m_HitPos = Vector3(hitX, hitY, hitZ)
			removeEventHandler("onClientRender",root,self.m_TaserRender)
			addEventHandler("onClientRender",root,self.m_TaserRender)
		end
	end
end

function Guns:Event_onTaserRender()
	if self.m_MuzzlePos and (self.m_HitPos or self.m_TaserTarget) then
		if self.m_TaserTarget then
			if getPedTarget(self.m_TaserAttacker) then
				self.m_HitPos = self.m_TaserTarget:getPosition()
				self.m_HitPos.z = self.m_HitPos.z-1
			else
				removeEventHandler("onClientRender",root,self.m_TaserRender)
			end
		end
		
		local effect = math.random(0,10)/10
		if math.random(0,1) == 1 then self.m_HitPos.z = self.m_HitPos.z+effect/20 else self.m_HitPos.z = self.m_HitPos.z-effect/20 end
		
		dxDrawMaterialLine3D (self.m_MuzzlePos,self.m_HitPos,self.m_TaserImage, 0.8+effect)
	else
		removeEventHandler("onClientRender",root,self.m_TaserRender)
	end 
end