-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Guns/Guns.lua
-- *  PURPOSE:     Client Gun Class
-- *
-- ****************************************************************************
RocketLauncher = inherit(Singleton) 
RocketLauncher.Effect = "coke_puff"

function RocketLauncher:constructor() 
	addRemoteEvents{"RocketLauncher:syncRocketEffect"}
	self.m_Shader = DxShader("files/shader/loginShader.fx")

	addEventHandler("onClientPreRender", root, bind(self.onUpdate, self))
	addEventHandler("onClientPlayerWeaponFire", root, bind(self.onFire, self))
	addEventHandler("RocketLauncher:syncRocketEffect", root, bind(self.onSyncRocketEffect, self))
end


function RocketLauncher:destructor() 

end

function RocketLauncher:onUpdate() 
	if self:isAiming() then
		if not self.m_Aiming then 
			self:onUse()
		end
		self.m_Aiming = true
		self.m_Object:setPosition(getCamera():getPosition() + getCamera().matrix.forward*.2 + getCamera().matrix.up * -.3 + getCamera().matrix.right*.15)
		local rot = getCamera():getRotation()
		rot:setZ(rot:getZ() - 268)
		rot:setY(rot:getX()*-1+self.m_Tilt)
		rot:setX(0)

		if self.m_Fired then 
			local progress = (getTickCount() - self.m_Fired) / 300
			local ease = getEasingValue(progress, "SineCurve")
			self.m_Tilt = ease * -30 
			if progress > 1 then 
				self.m_Fired = false 
				self.m_Tilt = 0
			end
		end
		self.m_Object:setRotation(rot)
	else 
		if self.m_Aiming then 
			self.m_Aiming = false
			self.m_Tilt = 0 
			self.m_Fired = false
			self:onStop()
		end
	end
end

function RocketLauncher:onUse()
	if isValidElement(self.m_Object) then 
		self.m_Object:destroy()
	end
	self.m_Tilt = 0 
	self.m_Fired = false
	self.m_Object = createObject(359, localPlayer:getPosition())
end

function RocketLauncher:onStop() 
	if isValidElement(self.m_Object) then
		self.m_Object:destroy()
	end
end

function RocketLauncher:onFire(weapon, ammo, ammoClip, hitX, hitY, hitZ, hitElement, startX, startY, startZ) 
	if weapon == 35 then
		if isValidElement(self.m_Object) then
			local start = self.m_Object:getPosition() + self.m_Object.matrix.right*.5 + self.m_Object.matrix.up*.1
			local stop = start + Vector3(Vector3(hitX, hitY, hitZ) - start):getNormalized()
			self.m_Fired = getTickCount()
			for i = 1, 2 do
				Effect.addTyreBurst(start, stop)
				local effect = Effect(RocketLauncher.Effect, start)
				effect:setDensity(2)
				setTimer(function(effect) 
					if isValidElement(effect) then 
						effect:destroy() 
					end 
				end, 1000, 1, effect)
			end
			self.m_Locked = getTickCount() + 5000
			self.m_LockDone = false
			Sound3D("files/audio/weapon/rocket-effect.ogg", start):setMaxDistance(130)
			triggerServerEvent("Guns:onClientRocketLauncherFire", localPlayer, {x = start.x, y = start.y, z = start.z}, {x = stop.x,y = stop.y,z = stop.z})
		end
	end
end

function RocketLauncher:onSyncRocketEffect(start, stop) 
	for i = 1, 2 do
		local effect = Effect(RocketLauncher.Effect, Vector3(start.x, start.y, start.z))
		Effect.addTyreBurst(Vector3(start.x, start.y, start.z), Vector3(stop.x, stop.y, stop.z))
		setTimer(function(effect) 
			if isValidElement(effect) then 
				effect:destroy() 
			end 
		end, 1000, 1, effect)
	end
	Sound3D("files/audio/weapon/rocket-effect.ogg", Vector3(start.x, start.y, start.z)):setMaxDistance(130)
end

function RocketLauncher:isAiming() 
	if localPlayer:getWeapon() == 35 then 
		setPlayerHudComponentVisible("crosshair", false)
		if self.m_Locked and self.m_Locked > getTickCount() then
			toggleControl("fire", false)
			if not self.m_LockDone then 
				
				self.m_LockDone = true
			end
		else 
			if self.m_LockDone then 
				self.m_LockDone = false 
				self.m_Locked = false
				toggleControl("fire", true)
			end
		end
	else 
		toggleControl("fire", true)
		setPlayerHudComponentVisible("crosshair", true)
	end
	return isPedAiming(localPlayer) and localPlayer:getWeapon() == 35 and not self:check()
end


function RocketLauncher:check() 
	local player = localPlayer:getPosition()
	local camera = getCamera():getPosition() 
	return (player - camera):getLength() > 1
end