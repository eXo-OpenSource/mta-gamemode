-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleInfrared.lua
-- *  PURPOSE:     Vehicle infrared class
-- *
-- ****************************************************************************

VehicleInfrared = inherit(Singleton)
VehicleInfrared.Textures = 
{
	"*grill*"
}

VehicleInfrared.AntiTextures = 
{
	"maverick92texpage128",
	"vehiclegeneric256",
}


VehicleInfrared.Keys = 
{
	w = "y+", 
	arrow_u = "y+",
	s = "y-", 
	arrow_d = "y-",
	a = "x-", 
	arrow_l = "x-", 
	d = "x+", 
	arrow_r = "x+",
	lshift = "s+",
	lctrl = "s-",
	lalt = "v+", 
	mouse1 = "l",
}

VehicleInfrared.Sensitivity = 2

VehicleInfrared.MaxZoom = 500

function VehicleInfrared:constructor(vehicle) 
	self.m_State = false
	self.m_Coronas = {}
	self.m_Yaw = 0
	self.m_Pitch = 0
	self.m_X = 0 
	self.m_Y = 0 
	self.m_Z = 0
	self.m_Zoom = 0
	self.m_ExtendX = 5
	self.m_ExtendY = 0
	self.m_Sensitivity = VehicleInfrared.Sensitivity
	self.m_SensitivitySlow = self.m_Sensitivity * .15
	self.m_Modificator = false
	self.m_ControlLocked = false
	self.m_Retarget = true
	self.m_Update = bind(self.update, self)
	self.m_Render = bind(self.render, self)
	self.m_Key = bind(self.onKey, self)
	self:start(vehicle)
end

function VehicleInfrared:destructor() 
	self:restore()
end

function VehicleInfrared:resume() 
	if localPlayer.m_PreviousInfrared and localPlayer.m_PreviousInfrared.vehicle == self.m_Vehicle then
		self.m_Yaw = localPlayer.m_PreviousInfrared.yaw 
		self.m_Pitch = localPlayer.m_PreviousInfrared.pitch
		self.m_Zoom = localPlayer.m_PreviousInfrared.zoom 
	end
end

function VehicleInfrared:start(vehicle) 
	toggleAllControls(false)
	self.m_Shader = MonochromeShader:new(true)
	self.m_ThermalShaderVehicle = DxShader("files/shader/thermal.fx", 9999, 0, true)
	self.m_ThermalShaderPed = DxShader("files/shader/thermal-ped.fx", 9999, 0, false, "ped")
	self.m_ThermalAntiShader = DxShader("files/shader/thermal-anti.fx", 9999, 0, true)
	setNearClipDistance(.1)
	self.m_Vehicle = vehicle or localPlayer.vehicle
	self.m_Yaw = self.m_Vehicle.rotation.z
	self.m_Pitch = 90 + 45
	self:resume() 
	self.m_X, self.m_Y, self.m_Z = self.m_Vehicle.position.x, self.m_Vehicle.position.y, self.m_Vehicle.position.z-20
	
	removeEventHandler("onClientPreRender", root, self.m_Update)
	removeEventHandler("onClientKey", root, self.m_Key)
	--removeEventHandler("onClientRender", root, self.m_Render)

	addEventHandler("onClientKey", root, self.m_Key)
	addEventHandler("onClientPreRender", root, self.m_Update)
	--addEventHandler("onClientRender", root, self.m_Render)

	if self.m_ThermalShaderVehicle then
		for index, textures in pairs(VehicleInfrared.Textures) do
			engineApplyShaderToWorldTexture ( self.m_ThermalShaderVehicle, textures)
		end
	end
	if self.m_ThermalAntiShader then
		for index, textures in pairs(VehicleInfrared.AntiTextures) do
			engineApplyShaderToWorldTexture ( self.m_ThermalAntiShader, textures )
		end
	end
	if self.m_ThermalShaderPed then 
		engineApplyShaderToWorldTexture ( self.m_ThermalShaderPed, "*")
	end
end

function VehicleInfrared:stop() 
	self:restore()
	delete(self)
end

function VehicleInfrared:restore() 	
	removeEventHandler("onClientPreRender", root, self.m_Update)
	removeEventHandler("onClientKey", root, self.m_Key)
	--removeEventHandler("onClientRender", root, self.m_Render, true, "low+999")

	toggleAllControls(true)
	setCameraTarget(localPlayer)
	if isValidElement(self.m_Vehicle, "vehicle") then 
		self.m_Vehicle:setAlpha(255)
		for k, occupant in pairs(self.m_Vehicle:getOccupants()) do
			occupant:setAlpha(255)
		end
		localPlayer.m_PreviousInfrared = 
		{
			yaw = self.m_Yaw,
			pitch = self.m_Pitch, 
			zoom = self.m_Zoom,
			vehicle = self.m_Vehicle,
		}
	end
	if self.m_ThermalShaderVehicle then
		for index, textures in pairs(VehicleInfrared.Textures) do
			engineRemoveShaderFromWorldTexture ( self.m_ThermalShaderVehicle, textures )
		end
	end
	if self.m_ThermalAntiShader then
		for index, textures in pairs(VehicleInfrared.AntiTextures) do
			engineRemoveShaderFromWorldTexture ( self.m_ThermalAntiShader, textures )
		end
	end
	if self.m_ThermalShaderPed then 
		engineRemoveShaderFromWorldTexture ( self.m_ThermalShaderPed, "*" )
	end
	self.m_Shader:delete()
	if self.m_White then 
		self.m_White:destroy()
	end
	if self.m_ThermalAntiShader then 
		self.m_ThermalAntiShader:destroy()
	end
	if self.m_ThermalShaderPed then 
		self.m_ThermalShaderPed:destroy() 
	end
	if self.m_ThermalShaderVehicle then 
		self.m_ThermalShaderVehicle:destroy()
	end
	for p, corona in pairs(self.m_Coronas) do 
		corona:destroy()
	end
	setNearClipDistance(.3)
end

function VehicleInfrared:key(button) 
	if VehicleInfrared.Keys[button] then 
		local direction =  VehicleInfrared.Keys[button]
		if getKeyState(button) then
			if direction == "y+" then 
				self.m_Pitch = (self.m_Pitch + (self.m_Modificator and self.m_SensitivitySlow or self.m_Sensitivity)) % 360
			elseif direction == "y-" then 
				self.m_Pitch = (self.m_Pitch - (self.m_Modificator and self.m_SensitivitySlow or self.m_Sensitivity)) % 360
			elseif direction == "x+" then 
				self.m_Yaw = (self.m_Yaw - (self.m_Modificator and self.m_SensitivitySlow or self.m_Sensitivity)) % 360
				self.m_Retarget = true
			elseif direction == "x-" then 
				self.m_Yaw = (self.m_Yaw + (self.m_Modificator and self.m_SensitivitySlow or self.m_Sensitivity)) % 360
				self.m_Retarget = true
			elseif direction == "s+" then 
				self.m_Zoom = self.m_Zoom + 1
			elseif direction == "s-" then
				self.m_Zoom = self.m_Zoom - 1
			end
		end
	end
end

function VehicleInfrared:onKey(button, state)
	if not state then 
		if VehicleInfrared.Keys[button] then 
			if VehicleInfrared.Keys[button] == "v+" then 
				self.m_Modificator = not self.m_Modificator
			elseif VehicleInfrared.Keys[button] == "l" then 
				self.m_ControlLocked = not self.m_ControlLocked 
				toggleAllControls(self.m_ControlLocked)
			end
		end
	end
end

function VehicleInfrared:yaw() 
	self.m_X, self.m_Y = getPointFromDistanceRotation(self.m_Start.x, self.m_Start.y, self.m_ExtendX, self.m_Yaw*-1)
end

function VehicleInfrared:pitch() 
	if self.m_Pitch < 100 then self.m_Pitch = 100 end 
	if self.m_Pitch > 170 then self.m_Pitch = 170 end 
	local sin = math.sin(math.rad(self.m_Pitch))
	local cos = math.cos(math.rad(self.m_Pitch)) 
	self.m_ExtendX = 5 * cos + 0 * sin 
	self.m_ExtendY = -5 * sin + 0 * cos
	self.m_Z = self.m_Vehicle.position.z + self.m_ExtendY
end

function VehicleInfrared:zoom() 
	if self.m_Zoom < 0 then 
		self.m_Zoom = 0
	end
	if self.m_Zoom > VehicleInfrared.MaxZoom then 
		self.m_Zoom = VehicleInfrared.MaxZoom
	end

	self.m_Sensitivity = VehicleInfrared.Sensitivity *  (1 - (self.m_Zoom / VehicleInfrared.MaxZoom))
	self.m_SensitivitySlow = self.m_Sensitivity * .15
	
	self:intersect()
end

function VehicleInfrared:round() 
	self.m_Zoom = math.floor(self.m_Zoom*100) / 100
	self.m_Sensitivity = math.floor(self.m_Sensitivity*100)/100
	self.m_SensitivitySlow = self.m_Sensitivity * .15
	self.m_X = math.floor(self.m_X*100) / 100
	self.m_Y = math.floor(self.m_Y*100) / 100
	self.m_Z = math.floor(self.m_Z*100) / 100
	if self.m_Origin then
		self.m_Origin = Vector3(math.floor(self.m_Origin.x*100) / 100, math.floor(self.m_Origin.y*100) / 100,  math.floor(self.m_Origin.z*100) / 100)
	end
	self.m_Pitch = math.floor(self.m_Pitch*100) / 100
	self.m_Yaw = math.floor(self.m_Yaw*100) / 100
end

function VehicleInfrared:intersect() 
	local ahead = self.m_Start + (Vector3(self.m_Origin - self.m_Start):getNormalized())*(self.m_Zoom+1)
	local hit, hitX, hitY, hitZ = processLineOfSight(self.m_Start.x, self.m_Start.y, self.m_Start.z, ahead.x, ahead.y, ahead.z, true, true, true, true, true, false, false, true, self.m_Vehicle)
	if hit then 
		self.m_Zoom = Vector3(self.m_Start - Vector3(hitX, hitY, hitZ)):getLength()-1
		self.m_Blur = getTickCount() + 100
	end
end

function VehicleInfrared:update()

	
	if isValidElement(self.m_Vehicle, "vehicle") then 
		self.m_Vehicle:setAlpha(0) 
		for k, occupant in pairs(self.m_Vehicle:getOccupants()) do 
			occupant:setAlpha(0)
		end
	else 
		self:stop()
	end


	self.m_Start = self.m_Vehicle.position + self.m_Vehicle.matrix.up*-0.5
	self:yaw()
	self.m_Spot = Vector3(self.m_X, self.m_Y, self.m_Z)
	self.m_Origin = self.m_Start + (Vector3(self.m_Spot - self.m_Start):getNormalized()*self.m_Zoom)
	self:round()
	self:intersect()

	
	setCameraMatrix(self.m_Origin, self.m_Origin + (self.m_Spot - self.m_Start):getNormalized()*2000, 0, 70)

	if not self.m_ControlLocked then
		for button, i in pairs(VehicleInfrared.Keys) do 
			self:key(button)
		end
	end
	self:round()

	self:pitch()

	self:zoom()


	self.m_Shader:update()
	self:render() 
end

function VehicleInfrared:render() 
	if self.m_Shader then
		local scale = self.m_Zoom/500
		if scale > 1 then scale = 1 end
		dxDrawImage(-screenWidth*scale, -screenHeight*scale, screenWidth + ((screenWidth*scale)*2), screenHeight +  ((screenHeight*scale)*2), self.m_Shader:getSource())
		if self.m_Blur and getTickCount() < self.m_Blur then 
			if not self.m_BlurUp then 
				self.m_BlurUp = 0
			end
			if self.m_BlurUp + .05 < .5 then 
				self.m_BlurUp = self.m_BlurUp + .05
			end
			self.m_Shader:getSource():setValue("BlurAmount", self.m_BlurUp)
			dxDrawImage(0, 0, screenWidth, screenHeight, "files/images/static.png", 0, 0, 0, tocolor(255, 255, 255, 100*(self.m_BlurUp/.5)))
		else 
			self.m_Blur = nil 
			self.m_BlurUp = nil
			self.m_Shader:getSource():setValue("BlurAmount", 0)
		end
	end	
	dxDrawLine(screenWidth*.48, screenHeight*.5, screenWidth*.52, screenHeight*.5, tocolor(250, 250, 250, 100), 10)
	dxDrawLine(screenWidth*.5, screenHeight*.5-screenWidth*.02, screenWidth*.5, screenHeight*.5+screenWidth*.02, tocolor(250, 250, 250, 100), 10)

	--self:debug()
end

function VehicleInfrared:debug() 
	dxDrawText(self.m_Yaw, 200, 200)
	dxDrawText(self.m_Pitch, 200, 250)
	dxDrawText(self.m_ExtendX, 200, 300)
	dxDrawText(self.m_ExtendY, 200, 340)
	dxDrawText(self.m_Zoom, 200, 400)
	dxDrawText(("%s %s %s"):format(self.m_Origin.x, self.m_Origin.y, self.m_Origin.z), 200, 450)
	dxDrawText(("%s %s %s"):format(self.m_X, self.m_Y, self.m_Z), 200, 500)
end