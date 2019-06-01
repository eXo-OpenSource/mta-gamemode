-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/Wearables/WearableHelmet.lua
-- *  PURPOSE:     Wearable Helmets Client
-- *
-- ****************************************************************************
WearableHelmet = inherit( Singleton )
addRemoteEvents{"onClientToggleHelmet"}

function WearableHelmet:constructor()
	addEventHandler("onClientToggleHelmet", localPlayer, bind( self.Event_toggleHelmet, self))
	addEventHandler("onClientRender", root, bind(self.Event_draw, self), true, "high+999")
	self.m_Helmets = {}
	self.m_StopBind = bind(self.onEffectStop, self)
	self.m_ShaderValue = 0.1
end

function WearableHelmet:destructor()
end

function WearableHelmet:onTearNade()
	if not self.m_ZoomBlur then
		self.m_ZoomBlur = ZoomBlurShader:new()
	end
	self.m_ZoomBlur:setValue(self.m_ShaderValue)
	if self.m_StopEffectTimer and isTimer(self.m_StopEffectTimer) then
		self.m_StopEffectTimer:destroy()
	end
	if localPlayer:getWalkingStyle() == 0 or localPlayer:getWalkingStyle() == 54 then
		triggerServerEvent("onPlayerEnterTearGas", localPlayer)
	end
	self.m_StopEffectTimer = setTimer(self.m_StopBind, 1500, 1)
	setControlState(localPlayer, "walk", true)
	toggleControl("sprint", false)
	toggleControl("fire", false)
	toggleControl("aim_weapon", false)
	toggleControl("jump", false)
	self.m_ShaderValue = self.m_ShaderValue + 0.025
	if self.m_ShaderValue > 0.5 then
		self.m_ShaderValue = 0.5
	end
end

function WearableHelmet:onEffectStop()
	if self.m_ZoomBlur then
		self.m_ZoomBlur:delete()
		self.m_ZoomBlur = nil
	end
	setControlState(localPlayer, "walk", false)
	toggleControl("sprint", true)
	toggleControl("jump", true)
	toggleControl("fire", true)
	toggleControl("aim_weapon", true)
	triggerServerEvent("onPlayerLeaveTearGas", localPlayer)
	self.m_ShaderValue = 0.1
end

function WearableHelmet:Event_toggleHelmet( state, item )
	if state then
		if item == "Gasmaske" then
			self.m_GasMask = true
			self.m_StartTick = getTickCount()
			self.m_EndTick = self.m_StartTick + 3000
			self.m_MaskSound = playSound("files/audio/gasmask.ogg", true)
			self.m_MaskSound:setVolume(0.4)
		else
			if self.m_MaskSound then
				stopSound(self.m_MaskSound)
			end
			self.m_GasMask = false
		end
	else
		self.m_GasMask = false
		if self.m_MaskSound then
			stopSound(self.m_MaskSound)
		end
	end
end

function WearableHelmet:Event_draw()
	if self.m_GasMask then
		local vx, vy, vz = getElementVelocity(localPlayer)
		local speed = 1 + ((vx^2 + vy^2 + vz^2)^(0.5))
		local now = getTickCount()
		local elap = now - self.m_StartTick
		local dur = self.m_EndTick - self.m_StartTick
		local prog = (elap / dur) * speed
		local sway_x, sway_y, rot = interpolateBetween(-screenWidth*0.005, -screenHeight*0.03, -3, screenWidth*0.005, screenHeight*0.03, 3, prog, "SineCurve")
		if prog >= 1 then
			self.m_StartTick = getTickCount()
			self.m_EndTick = self.m_StartTick + 3000
		end
		dxDrawImage(-screenWidth*0.05, -screenHeight*0.05+sway_y, screenWidth*1.1, screenHeight*1.1, "files/images/Other/gasmask.png", 0, 0, 0)
	end
end
