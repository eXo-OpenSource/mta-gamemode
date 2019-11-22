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

	addEventHandler("RocketLauncher:syncRocketEffect", root, bind(self.onSyncRocketEffect, self))
end


function RocketLauncher:destructor() 

end

function RocketLauncher:update() 
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
			if self.m_BlurShader and isValidElement(self.m_BlurShader:getSource()) then
				self.m_BlurShader:setBlurOption(0.5, ease*.005)
			end
			if progress > 1 then 
				self.m_Fired = false 
				self.m_Tilt = 0
				if self.m_BlurShader then
					self.m_BlurShader:delete() 
					self.m_BlurShader = nil
				end
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
	if self.m_BlurShader then
		self.m_BlurShader:delete() 
		self.m_BlurShader = nil
	end

	if isValidElement(self.m_Object) then
		self.m_Object:destroy()
	end
end

function RocketLauncher:fire(weapon, ammo, ammoClip, hitX, hitY, hitZ, hitElement, startX, startY, startZ) 
	if isValidElement(self.m_Object) then
		if self.m_BlurShader then 
			self.m_BlurShader:delete()
		end
		self.m_BlurShader = ZoomBlurShader:new()
		if self.m_BlurShader and isValidElement(self.m_BlurShader:getSource()) then 
			self.m_BlurShader:setBlurOption(0.5, 0)
		end
		local start = self.m_Object:getPosition() + self.m_Object.matrix.right*.5 + self.m_Object.matrix.up*.1
		local stop = start + Vector3(Vector3(hitX, hitY, hitZ) - start):getNormalized()
		local back =  self.m_Object:getPosition() + self.m_Object.matrix.right * -.9
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
		for i = 1, 2 do
			Effect.addTyreBurst(back, stop)
			local effect = Effect(RocketLauncher.Effect, back)
			effect:setDensity(2)
			setTimer(function(effect) 
				if isValidElement(effect) then 
					effect:destroy() 
				end 
			end, 1000, 1, effect)
		end
		Sound3D("files/audio/weapon/rocket-effect.ogg", start):setMaxDistance(130)
		triggerServerEvent("Guns:onClientRocketLauncherFire", localPlayer, {x = start.x, y = start.y, z = start.z}, {x = stop.x,y = stop.y,z = stop.z}, {x = back.x, y = back.y, z = back.z})
	end
end

function RocketLauncher:onSyncRocketEffect(start, stop, back) 
	for i = 1, 2 do
		local effect = Effect(RocketLauncher.Effect, Vector3(start.x, start.y, start.z))
		Effect.addTyreBurst(Vector3(start.x, start.y, start.z), Vector3(stop.x, stop.y, stop.z))
		setTimer(function(effect) 
			if isValidElement(effect) then 
				effect:destroy() 
			end 
		end, 1000, 1, effect)
	end
	for i = 1, 2 do
		local effect = Effect(RocketLauncher.Effect, Vector3(back.x, back.y, back.z))
		Effect.addTyreBurst(Vector3(back.x, back.y, back.z), Vector3(stop.x, stop.y, stop.z))
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
	else 
		setPlayerHudComponentVisible("crosshair", true)
	end
	return isPedAiming(localPlayer) and localPlayer:getWeapon() == 35 and not self:check()
end


function RocketLauncher:check() 
	local player = localPlayer:getPosition()
	local camera = getCamera():getPosition() 
	return (player - camera):getLength() > 1
end