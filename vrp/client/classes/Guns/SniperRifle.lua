-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Guns/Guns.lua
-- *  PURPOSE:     Client Gun Class
-- *
-- ****************************************************************************
SniperRifle = inherit(Singleton)

function SniperRifle:constructor()

end

function SniperRifle:destructor()

end

function SniperRifle:update()
	if self:isAiming() then
		if not self.m_Aiming then
			self:onUse()
		end
		self.m_Aiming = true
	else
		if self.m_Aiming then
			Nametag:getSingleton():setDisabled(false)
		end
		self.m_Aiming = false
		self.m_Use = nil
		if self.m_Shader then
			self.m_Shader:delete()
			self.m_Shader = nil
		end
	end
end

function SniperRifle:render()
	if self.m_Use then
		Nametag:getSingleton():setDisabled(true)

		local progress = (getTickCount() - self.m_Use) / WEAPON_READY_TIME[34]
		local ease = getEasingValue(progress, "SineCurve")


		if not self.m_Shader then
			self.m_Shader = ZoomBlurShader:new()
			self.m_Shader:setBlurOption(.5, 0)
		end

		if self.m_Shader and isValidElement(self.m_Shader:getSource()) then
			self.m_Shader:setBlurOption(.5, ease)
		else
			dxDrawRectangle(0, 0, screenWidth, screenHeight, Color.Black) -- fallback
		end

		setPlayerHudComponentVisible("crosshair", false)

		if progress > 1 then
			self.m_Use = nil
			setPlayerHudComponentVisible("crosshair", true)
			Nametag:getSingleton():setDisabled(false)
			if self.m_Shader then
				self.m_Shader:delete()
				self.m_Shader = nil
			end
		end
	end
end

function SniperRifle:onUse()
	self.m_Use = getTickCount()
	WeaponManager.Weapon[34] = {ready = getTickCount() + WEAPON_READY_TIME[34]}
end

function SniperRifle:onStop()
	setPlayerHudComponentVisible("crosshair", true)
	Nametag:getSingleton():setDisabled(true)
end

function SniperRifle:fire(weapon, ammo, ammoClip, hitX, hitY, hitZ, hitElement, startX, startY, startZ)

end

function SniperRifle:isAiming()
	return isPedAiming(localPlayer) and localPlayer:getWeapon() == 34
end

function SniperRifle:inUse()
	return self.m_Use
end
