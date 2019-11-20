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
	mouse_wheel_up = "s+",
	mouse_wheel_down = "s-",
	lalt = "v+", 
	mouse1 = "l",
	h = "light",
	m = "mode",
}

VehicleInfrared.KeyState = {}

VehicleInfrared.Sensitivity = 2

VehicleInfrared.MaxZoom = 500

VehicleInfrared.FontHeight = dxGetFontHeight(2, "clear")

VehicleInfrared.SpotLight = {}

VehicleInfrared.DefaultColor = tocolor(250, 250, 250, 100)
VehicleInfrared.DefaultColorSecondary = tocolor(0, 0, 0, 255)

VehicleInfrared.InvertColor = tocolor(0, 0, 0, 255)
VehicleInfrared.InvertColorSecondary = tocolor(255, 255, 255, 255)

function VehicleInfrared:constructor(vehicle) 
	VehicleInfrared.Sensitivity = core:get("Vehicles", "InfraredSensitivity", 2)
	self.m_State = false
	self.m_Yaw = 0
	self.m_Pitch = 0
	self.m_MouseX = 0
	self.m_MouseY = 0
	self.m_X = 0 
	self.m_Mode = 0
	self.m_Color = VehicleInfrared.DefaultColor 
	self.m_ColorSecondary = VehicleInfrared.DefaultColorSecondary
	self.m_Y = 0 
	self.m_Z = 0
	self.m_Zoom = 0
	self.m_ExtendX = 5
	self.m_ExtendY = 0
	self.m_Sensitivity = VehicleInfrared.Sensitivity
	self.m_SensitivitySlow = self.m_Sensitivity * .15
	self.m_Modificator = false
	self.m_Light = false
	self.m_ControlLocked = false
	self.m_Update = bind(self.update, self)
	self.m_Render = bind(self.render, self)
	self.m_Cursor = bind(self.cursor, self)
	self.m_Key = bind(self.onKey, self)
	self:sound()
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
		self.m_Mode = localPlayer.m_PreviousInfrared.mode
	end
	self:mode()
end

function VehicleInfrared:updateSensitivity() 
	VehicleInfrared.Sensitivity = core:get("Vehicles", "InfraredSensitivity", 2)
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
	self:mode()
	self.m_X, self.m_Y, self.m_Z = self.m_Vehicle.position.x, self.m_Vehicle.position.y, self.m_Vehicle.position.z-20
	
	removeEventHandler("onClientPreRender", root, self.m_Update)
	removeEventHandler("onClientKey", root, self.m_Key)
	removeEventHandler("onClientRender", root, self.m_Render)
	removeEventHandler( "onClientCursorMove", root, self.m_Cursor)

	addEventHandler("onClientKey", root, self.m_Key)
	addEventHandler("onClientPreRender", root, self.m_Update)
	addEventHandler("onClientRender", root, self.m_Render, true, "high+9999")
	addEventHandler( "onClientCursorMove", root, self.m_Cursor) 

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
	delete(self)
end

function VehicleInfrared:restore() 	
	removeEventHandler("onClientPreRender", root, self.m_Update)
	removeEventHandler("onClientKey", root, self.m_Key)
	removeEventHandler("onClientRender", root, self.m_Render, true, "low+999")
	removeEventHandler( "onClientCursorMove", root, self.m_Cursor)

	toggleAllControls(true)
	setCameraTarget(localPlayer)
	if isValidElement(self.m_Vehicle, "vehicle") then 
		localPlayer.m_PreviousInfrared = 
		{
			yaw = self.m_Yaw,
			pitch = self.m_Pitch, 
			zoom = self.m_Zoom,
			vehicle = self.m_Vehicle,
			mode = self.m_Mode,
		}
		if self.m_Light then 
			VehicleInfrared.stopLight(self.m_Vehicle)
			triggerLatentServerEvent("VehicleInfrared:onStopLight", 5000, false, localPlayer, self.m_Vehicle)
		end
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
	self.m_Sound:delete()

	resetSkyGradient()
	setNearClipDistance(.3)
end

function VehicleInfrared:sound() 
	self.m_Sound = Sound:new("files/audio/Ambient/helicopter_internal.ogg", true)
	self.m_Sound:fadeIn(1)
end

function VehicleInfrared:key(button) 
	if VehicleInfrared.Keys[button] then 
		local direction =  VehicleInfrared.Keys[button]
		local previousKeyState = VehicleInfrared.KeyState[button]
		VehicleInfrared.KeyState[button] = getKeyState(button) 
		if VehicleInfrared.KeyState[button] then
			if direction == "s+" then 
				self.m_Zoom = self.m_Zoom + 1
			elseif direction == "s-" then
				self.m_Zoom = self.m_Zoom - 1
			end
			self:zoom()
		end
	end
end

function VehicleInfrared:cursor(x, y, aX, aY) 
	if not self.m_ControlLocked then
		if not isCursorShowing() then
			aX = aX - screenWidth / 2
			aY = aY - screenHeight / 2

			self.m_Yaw = self.m_Yaw - aX * self.m_Sensitivity * 0.01745
			self.m_Pitch = self.m_Pitch - aY * self.m_Sensitivity * 0.01745
			
			self.m_MouseLastMovement = getTickCount()+100
			self.m_MouseMoveEvent = true
		end
	end
end

function VehicleInfrared:onKey(button, state)
	if state then 
		if VehicleInfrared.Keys[button] then
			if VehicleInfrared.Keys[button] == "v+" then 
				self.m_Modificator = not self.m_Modificator
			elseif VehicleInfrared.Keys[button] == "l" then 
				self.m_ControlLocked = not self.m_ControlLocked 
				toggleAllControls(self.m_ControlLocked)
			elseif VehicleInfrared.Keys[button] == "light" then 
				if not self.m_ControlLocked then 
					self:light()
				end
			elseif VehicleInfrared.Keys[button] == "mode" then 
				if self.m_Shader and self.m_Shader:getSource() then 
					self.m_Mode = (self.m_Mode + 1) % 2
				end
				self:mode()
			elseif VehicleInfrared.Keys[button] == "s+" then 
				self.m_Zoom = self.m_Zoom + 1
				self:zoom()
			elseif VehicleInfrared.Keys[button] == "s-" then 
				self.m_Zoom = self.m_Zoom - 1
				self:zoom()
			end
		end
	end
end


function VehicleInfrared:yaw() 
	self.m_X, self.m_Y = getPointFromDistanceRotation(self.m_Start.x, self.m_Start.y, self.m_ExtendX, self.m_Yaw*-1)
end

function VehicleInfrared:pitch() 
	if self.m_Pitch < 90.1 then self.m_Pitch = 90.1 end 
	if self.m_Pitch > 180-20 then self.m_Pitch = 180-20 end 
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

	local scale = (1 - (self.m_Zoom / VehicleInfrared.MaxZoom))
	if scale < .1 then scale = .1 end 

	self.m_Sensitivity = VehicleInfrared.Sensitivity * scale
	self.m_SensitivitySlow = self.m_Sensitivity * .15
	
	self:intersect()
end

function VehicleInfrared:intersect() 
	if self.m_Start and self.m_Origin then
		local ahead = self.m_Start + (Vector3(self.m_Origin - self.m_Start):getNormalized())*(self.m_Zoom+1)
		local hit, hitX, hitY, hitZ = processLineOfSight(self.m_Start.x, self.m_Start.y, self.m_Start.z, ahead.x, ahead.y, ahead.z, true, true, true, true, true, false, false, true, self.m_Vehicle)
		if hit then 
			self.m_Zoom = Vector3(self.m_Start - Vector3(hitX, hitY, hitZ)):getLength()-1
			self.m_Blur = getTickCount() + 100
		end
	end
end

function VehicleInfrared:update()	
	if isValidElement(self.m_Vehicle, "vehicle") then 
	else 
		self:stop()
	end

	self.m_Start = self.m_Vehicle.position + self.m_Vehicle.matrix.up*-0.8
	self:yaw()
	self:zoom()
	self:pitch()
	
	self.m_Spot = Vector3(self.m_X, self.m_Y, self.m_Z)
	self.m_Origin = self.m_Start + (Vector3(self.m_Spot - self.m_Start):getNormalized()*self.m_Zoom)

	self:intersect()

	setCameraMatrix(self.m_Origin, self.m_Origin + (self.m_Spot - self.m_Start):getNormalized()*2000, 0, 70)

	if not self.m_ControlLocked then
		for button, i in pairs(VehicleInfrared.Keys) do 
			self:key(button)
		end
	end

	if self.m_MouseLastMovement and self.m_MouseLastMovement < getTickCount() then
		if self.m_MouseMoveEvent then 
			self:onSpotMove()
			self.m_MouseMoveEvent = false
		end
	end 

	self:laser()
	
	self.m_Shader:update()

	self:updateLight()
end

function VehicleInfrared:onSpotMove() 
	if self.m_Light then 
		self:syncLight()
	end
end

function VehicleInfrared:syncLight() 
	local light = VehicleInfrared.get(self.m_Vehicle) 
	if light then  
		triggerLatentServerEvent("VehicleInfrared:onSyncLight", 5000, false, localPlayer, self.m_Vehicle, 
		{
			{
				x = light:getStartPosition().x, 
				y = light:getStartPosition().y,
				z = light:getStartPosition().z,  	
			},
			{
				x = light:getEndPosition().x, 
				y = light:getEndPosition().y,
				z = light:getEndPosition().z,  		
			}
		})
	end
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
			dxDrawImage(0, 0, screenWidth, screenHeight, "files/images/HUD/infrared/static.png", 0, 0, 0, tocolor(255, 255, 255, 100*(self.m_BlurUp/.5)))
		else 
			self.m_Blur = nil 
			self.m_BlurUp = nil
			self.m_Shader:getSource():setValue("BlurAmount", 0)
		end
	end	
	self:hud()
	--self:debug()
end

function VehicleInfrared:laser() 
	local laser = self.m_Start + (self.m_Spot - self.m_Start):getNormalized()*3000
	local hit, hitX, hitY, hitZ = processLineOfSight(self.m_Start.x, self.m_Start.y, self.m_Start.z, laser.x, laser.y, laser.z, 
	true, true, true, true, true, false, false, true, self.m_Vehicle)
	if hit then 
		self.m_LaserDistance = Vector3(Vector3(hitX, hitY, hitZ) - self.m_Start):getLength() 
	else 
		self.m_LaserDistance = nil
	end
end

function VehicleInfrared:hud() 
	dxDrawLine(screenWidth*.48, screenHeight*.5, screenWidth*.49, screenHeight*.5, self.m_ColorSecondary, 5)
	dxDrawLine(screenWidth*.48, screenHeight*.5, screenWidth*.49, screenHeight*.5, self.m_Color, 3)

	dxDrawLine(screenWidth*.51, screenHeight*.5, screenWidth*.52, screenHeight*.5, self.m_ColorSecondary, 5)
	dxDrawLine(screenWidth*.51, screenHeight*.5, screenWidth*.52, screenHeight*.5, self.m_Color, 3)

	dxDrawLine(screenWidth*.5, screenHeight*.5-screenWidth*.02, screenWidth*.5, screenHeight*.5-screenWidth*.01, self.m_ColorSecondary, 5)
	dxDrawLine(screenWidth*.5, screenHeight*.5-screenWidth*.02, screenWidth*.5, screenHeight*.5-screenWidth*.01, self.m_Color, 3)

	dxDrawLine(screenWidth*.5, screenHeight*.5+screenWidth*.01, screenWidth*.5, screenHeight*.5+screenWidth*.02, self.m_ColorSecondary, 5)
	dxDrawLine(screenWidth*.5, screenHeight*.5+screenWidth*.01, screenWidth*.5, screenHeight*.5+screenWidth*.02, self.m_Color, 3)

	if self.m_LaserDistance then
		dxDrawText(("%.2fKM"):format(self.m_LaserDistance/1000), screenWidth*.7, screenHeight-VehicleInfrared.FontHeight*3, nil, screenHeight-VehicleInfrared.FontHeight*2, self.m_Color, 2, "clear")
	else 
		dxDrawText(("--.--KM"), screenWidth*.7, screenHeight-VehicleInfrared.FontHeight*3, nil, screenHeight-VehicleInfrared.FontHeight*2, self.m_Color, 2, "clear")
	end
	if self.m_Yaw then 
		dxDrawText(("↔ %.2f°"):format((self.m_Yaw-180)%360), screenWidth*.7, VehicleInfrared.FontHeight*1, nil, nil, self.m_Color, 2, "clear")
	end
	if self.m_Pitch then 
		dxDrawText(("↕  %.2f°"):format(self.m_Pitch*-1 + 180), screenWidth*.7, VehicleInfrared.FontHeight*2.5, nil, nil, self.m_Color, 2, "clear")
	end
	if self.m_Zoom then 
		dxDrawText(("× %.2f"):format(1 + (self.m_Zoom / VehicleInfrared.MaxZoom)), screenWidth*.85, screenHeight-VehicleInfrared.FontHeight*3, nil, nil, self.m_Color, 2, "clear")
	end
	if self.m_ControlLocked then 
		dxDrawImage(screenWidth*.5-16, screenHeight-VehicleInfrared.FontHeight*3, 32, 32, "files/images/HUD/infrared/lock.png", 0, 0, 0, self.m_Color)
	end

	if self.m_Light then 
		dxDrawImage(screenWidth*.4-16, screenHeight - VehicleInfrared.FontHeight*3, 32, 32, "files/images/HUD/infrared/light.png", 0, 0, 0, self.m_Color)
	end
	dxDrawImage(screenWidth*.5-16, VehicleInfrared.FontHeight*1, 32, 16, "files/images/HUD/infrared/infrared.png", 0, 0, 0, self.m_Color)
end

function VehicleInfrared:light() 
	self.m_Light = not self.m_Light 
	if self.m_Light then 
		local length = self.m_LaserDistance or 400
		local start =  (self.m_Vehicle.position + self.m_Vehicle.matrix.right*-.5) + self.m_Vehicle.matrix.up*-.5
		VehicleInfrared.createLight(self.m_Vehicle, start, self.m_Start + (self.m_Spot - self.m_Start):getNormalized()*length)
		local light = VehicleInfrared.get(self.m_Vehicle)
		if light then
			triggerLatentServerEvent("VehicleInfrared:onCreateLight", 5000, false, localPlayer, self.m_Vehicle, 
			{
				{
					x = light:getStartPosition().x, 
					y = light:getStartPosition().y,
					z = light:getStartPosition().z,  	
				},
				{
					x = light:getEndPosition().x, 
					y = light:getEndPosition().y,
					z = light:getEndPosition().z,  		
				}
			})
		end
	else 
		VehicleInfrared.stopLight(self.m_Vehicle)
		triggerLatentServerEvent("VehicleInfrared:onStopLight", 5000, false, localPlayer, self.m_Vehicle)
	end
end

function VehicleInfrared:mode() 
	if self.m_Shader:getSource() then
		if self.m_Mode == 0 then 
			self.m_Shader:getSource():setValue("luminanceFloat", 2)
			self.m_Shader:getSource():setValue("negative", 0)
			self.m_Color = VehicleInfrared.DefaultColor 
			self.m_ColorSecondary = VehicleInfrared.DefaultColorSecondary
		elseif self.m_Mode == 1 then 
			self.m_Shader:getSource():setValue("negative", 1)
			self.m_Color = VehicleInfrared.InvertColor 
			self.m_ColorSecondary = VehicleInfrared.InvertColorSecondary
		end
	end
end

function VehicleInfrared:updateLight() 
	if self.m_Light then
		local length = self.m_LaserDistance or 400 
		local start =  (self.m_Vehicle.position + self.m_Vehicle.matrix.right*-.5) + self.m_Vehicle.matrix.up*-.5
		VehicleInfrared.moveLight(self.m_Vehicle, start, self.m_Start + (self.m_Spot - self.m_Start):getNormalized()*length)
	end
end

function VehicleInfrared:debug() 
	dxDrawText(("%.2f"):format(self.m_Yaw), 200, 300)
	dxDrawText(("%.2f"):format(self.m_Pitch), 200, 300)
	dxDrawText(("%.2f"):format(self.m_ExtendX), 200, 300)
	dxDrawText(("%.2f"):format(self.m_ExtendY), 200, 350)
	dxDrawText(("%.2f"):format(self.m_Zoom), 200, 400)
	dxDrawText(("%.2f %.2f %.2f"):format(self.m_Origin.x, self.m_Origin.y, self.m_Origin.z), 200, 450)
	dxDrawText(("%.2f %.2f %.2f"):format(self.m_X, self.m_Y, self.m_Z), 200, 500)
end

addEvent("VehicleInfrared:createLight", true)
addEventHandler("VehicleInfrared:createLight", root, function(vehicle, start, stop) 
	if not VehicleInfrared:isInstantiated() then 
		VehicleInfrared.createLight(vehicle, start, stop)
	else 
		if VehicleInfrared:getSingleton().m_Vehicle ~= vehicle then 
			VehicleInfrared.createLight(vehicle, start, stop)
		end	
	end
end)

addEvent("VehicleInfrared:stopLight", true)
addEventHandler("VehicleInfrared:stopLight", root, function(vehicle) 
	if not VehicleInfrared:isInstantiated() then 
		VehicleInfrared.stopLight(vehicle)
	else 
		if VehicleInfrared:getSingleton().m_Vehicle ~= vehicle then 
			VehicleInfrared.stopLight(vehicle)
		end	
	end
end)

addEvent("VehicleInfrared:updateLight", true)
addEventHandler("VehicleInfrared:updateLight", root, function(vehicle, start, stop) 
	if not VehicleInfrared:isInstantiated() then 
		VehicleInfrared.moveLight(vehicle, start, stop)
	else 
		if VehicleInfrared:getSingleton().m_Vehicle ~= vehicle then 
			VehicleInfrared.moveLight(vehicle, start, stop)
		end	
	end
end)

addEvent("VehicleInfrared:onWasted", true)
addEventHandler("VehicleInfrared:onWasted", root, function() 
	if VehicleInfrared:isInstantiated() then 
		delete(VehicleInfrared:getSingleton())
		localPlayer.m_PreviousInfrared = nil
	end
end)

addEvent("VehicleInfrared:start", true)
addEventHandler("VehicleInfrared:start", root, function(vehicle) 
	if localPlayer:getData("inInfraredVehicle") and vehicle:getData("isInfraredVehicle") then 
		VehicleInfrared:new(vehicle)
	end
end)

addEvent("VehicleInfrared:stop", true)
addEventHandler("VehicleInfrared:stop", root, function() 
	if VehicleInfrared:isInstantiated() then 
		delete(VehicleInfrared:getSingleton())
	end
end)



addEventHandler("onClientPreRender", root, function()
	local currentVehicle = nil 
	if VehicleInfrared:isInstantiated() then 
		currentVehicle = VehicleInfrared:getSingleton().m_Vehicle
	end
	for vehicle, spotlight in pairs(VehicleInfrared.SpotLight) do
		if VehicleInfrared.SpotLight[vehicle] then
			if isValidElement(vehicle) and isValidElement(spotlight) then
				if not currentVehicle or currentVehicle ~= vehicle then
					local start =  (vehicle.position + vehicle.matrix.right*-.5) + vehicle.matrix.up*-.5 
					spotlight:setStartPosition(start)
				end
			else 
				VehicleInfrared.SpotLight[vehicle] = nil
			end
		end
	end
end)
function VehicleInfrared.createLight(vehicle, start, stop)
	VehicleInfrared.stopLight(vehicle)
	VehicleInfrared.SpotLight[vehicle] = SearchLight(Vector3(start.x, start.y, start.z), Vector3(stop.x, stop.y, stop.z), .2, 4, true)
	VehicleInfrared.SpotLight[vehicle]:attach(vehicle, -.5, 0, -.5)
end

function VehicleInfrared.stopLight(vehicle)
	if VehicleInfrared.SpotLight[vehicle] and isElement(VehicleInfrared.SpotLight[vehicle]) then 
		VehicleInfrared.SpotLight[vehicle]:destroy()
	end
end

function VehicleInfrared.moveLight(vehicle, start, stop)
	if VehicleInfrared.SpotLight[vehicle] and isElement(VehicleInfrared.SpotLight[vehicle]) then 
		VehicleInfrared.SpotLight[vehicle]:setStartPosition(Vector3(start.x, start.y, start.z))
		VehicleInfrared.SpotLight[vehicle]:setEndPosition(Vector3(stop.x, stop.y, stop.z))
	end
end

function VehicleInfrared.get(vehicle) 
	if VehicleInfrared.SpotLight[vehicle] and isElement(VehicleInfrared.SpotLight[vehicle]) then
		return VehicleInfrared.SpotLight[vehicle]
	else 
		VehicleInfrared.SpotLight[vehicle] = nil
	end
end