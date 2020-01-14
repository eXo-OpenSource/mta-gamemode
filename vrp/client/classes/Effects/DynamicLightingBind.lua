-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/DynamicLightingBind.lua
-- *  PURPOSE:     DynamicLightingBind class
-- *
-- ****************************************************************************
DynamicLightingBind = inherit(Singleton)
DynamicLightingBind.Map = {}


function DynamicLightingBind:constructor() 
	DynamicLightingBind:new()
	Light = DynamicLightingBind:getSingleton()
end

function DynamicLightingBind:getExport() 
	return exports.dynamic_lighting
end

function DynamicLightingBind:createPointLight(posX, posY, posZ, colorR, colorG, colorB, colorA, attenuation,...)
	if not core:get("Shaders", "DynamicLighting") then return end
	local light = self:getExport():createPointLight(posX, posY, posZ, colorR, colorG, colorB, colorA, attenuation, unpack(arg))
	if light then
		self:register(light)
	end
	return light
end

function DynamicLightingBind:createSpotLight(posX,posY,posZ,colorR,colorG,colorB,colorA,dirX,dirY,dirZ,isEuler,falloff,theta,phi,attenuation,...)
	if not core:get("Shaders", "DynamicLighting") then return end
	local light = self:getExport():createSpotLight(posX, posY, posZ, colorR, colorG, colorB, colorA, dirX, dirY, dirZ, isEuler, falloff, theta, phi, attenuation, unpack(arg))
	if light then
		self:register(light)
	end
	return light
end

function DynamicLightingBind:destroyLight(element)
	if element then 
		self:unregister(element)
		self:getExport():destroyLight(element)
	end
end

function DynamicLightingBind:setDimension(element, dim)
	if element then 
		self:getExport():setLightDimension(element, dim)
	end
end

function DynamicLightingBind:getDimension(element)
	if element then 
		return self:getExport():getLightDimension(element)
	end
end

function DynamicLightingBind:setInterior(element, int)
	if element then 
		self:getExport():setLightInterior(element, int)
	end
end

function DynamicLightingBind:getInterior(element)
	if element then 
		return self:getExport():getLightInterior(element)
	end
end

function DynamicLightingBind:setDirection(element, dirX, dirY, dirZ, ...)
	if element then 
		self:getExport():setLightDirection(element, dirX, dirY, dirZ, unpack(arg))
	end
end

function DynamicLightingBind:getDirection(element)
	if element then 
		return self:getExport():getLightInterior(element)
	end
end

function DynamicLightingBind:setPosition(element, posX, posY, posZ)
	if element then 
		self:getExport():setLightPosition(element, posX, posY, posZ)
	end
end

function DynamicLightingBind:getPosition(element)
	if element then 
		return self:getExport():getLightPosition(element)
	end
end

function DynamicLightingBind:setColor(element, colorR, colorG, colorB, colorA)
	if element then 
		self:getExport():setLightColor(element, colorR, colorG, colorB, colorA)
	end
end

function DynamicLightingBind:getColor(element)
	if element then 
		return self:getExport():getLightColor(element)
	end
end

function DynamicLightingBind:setAttenuation(element, attenuation)
	if element then 
		self:getExport():setLightAttenuation(element, attenuation)
	end
end

function DynamicLightingBind:getAttenuation(element)
	if element then 
		return self:getExport():getLightAttenuation(element)
	end
end

function DynamicLightingBind:setNormalShading(element, isNormalShading)
	if element then 
		self:getExport():setLightNormalShading(element, isNormalShading)
	end
end

function DynamicLightingBind:getNormalShading(element)
	if element then 
		return self:getExport():getLightNormalShading(element)
	end
end

function DynamicLightingBind:setFalloff(element, falloff)
	if element then 
		self:getExport():setLightFalloff(element, falloff)
	end
end

function DynamicLightingBind:getFalloff(element)
	if element then 
		return self:getExport():getLightFalloff(element)
	end
end

function DynamicLightingBind:setTheta(element, theta)
	if element then 
		self:getExport():setLightTheta(element, theta)
	end
end

function DynamicLightingBind:getTheta(element)
	if element then 
		return self:getExport():getLightTheta(element)
	end
end

function DynamicLightingBind:setPhi(element, phi)
	if element then 
		self:getExport():setLightPhi(element, theta)
	end
end

function DynamicLightingBind:getPhi(element)
	if element then 
		return self:getExport():getLightPhi(element)
	end
end

function DynamicLightingBind:setMaxLights(count)
	self:getExport():setMaxLights(count)
end

function DynamicLightingBind:setVertexLights(count)
	self:getExport():setVertexLights(count)
end

function DynamicLightingBind:setWorldNormalShading(bool)
	self:getExport():setWorldNormalShading(bool)
end

function DynamicLightingBind:setNormalShading(isWrd, isVeh, isPed)
	self:getExport():setNormalShading(isWrd, isVeh, isPed)
end

function DynamicLightingBind:setForceVertexLightings(isWrd, isVeh, isPed)
	self:getExport():setForceVertexLightings(isWrd, isVeh, isPed)
end

function DynamicLightingBind:setShadersLayered(isWrd, isVeh, isPed)
	self:getExport():setShadersLayered(isWrd, isVeh, isPed)
end

function DynamicLightingBind:setGenerateBumpNormals(isGenerated, ...)
	self:getExport():setGenerateBumpNormals(isGenerated, unpack(arg))
end

function DynamicLightingBind:setTextureBrightness(value)
	self:getExport():setTextureBrightness(value)
end

function DynamicLightingBind:setLightsDistFade(dist, dist2)
	self:getExport():setLightsDistFade(dist, dist2)
end

function DynamicLightingBind:setLightsEffectRange(range)
	self:getExport():setLightsEffectRange(range)
end

function DynamicLightingBind:setShaderForcedOn(bool)
	self:getExport():setShaderForcedOn(bool)
end

function DynamicLightingBind:setShaderTimeout(value)
	self:getExport():setShaderTimeout(bool)
end

function DynamicLightingBind:setShaderNightMod(value)
	self:getExport():setShaderNightMod(value)
end

function DynamicLightingBind:setShaderPedDiffuse(value)
	self:getExport():setShaderPedDiffuse(value)
end

function DynamicLightingBind:setShaderDayTime(value)
	self:getExport():setShaderDayTime(value)
end

function DynamicLightingBind:setDirLightEnable(value)
	self:getExport():setDirLightEnable(value)
end

function DynamicLightingBind:setDirLightColor(colorR,colorG,colorB,colorA)
	self:getExport():setDirLightColor(colorR,colorG,colorB,colorA)
end

function DynamicLightingBind:setDirLightDirection(dirX, dirY, dirZ, ...)
	self:getExport():setDirLightDirection(dirX, dirY, dirZ, unpack(arg))
end

function DynamicLightingBind:setDirLightRange(value)
	self:getExport():setDirLightRange(value)
end

function DynamicLightingBind:setDiffLightEnable(value)
	self:getExport():setDiffLightEnable(value)
end

function DynamicLightingBind:setDiffLightColor(colorR,colorG,colorB,colorA)
	self:getExport():setDiffLightColor(colorR, colorG, colorB, colorA)
end

function DynamicLightingBind:setDiffLightRange(value)
	self:getExport():setDiffLightColor(value)
end

function DynamicLightingBind:setNightSpotEnable(value)
	self:getExport():setNightSpotEnable(value)
end

function DynamicLightingBind:setNightSpotRadius(value)
	self:getExport():setNightSpotRadius(value)
end

function DynamicLightingBind:setNightSpotPosition(posX, posY, posZ)
	self:getExport():setNightSpotPosition(posX, posY, posZ)
end

function DynamicLightingBind:refreshAll() 
	self:getExport():forceRefresh()
end

function DynamicLightingBind:register(element)
	if not DynamicLightingBind.Map[element] then 
		DynamicLightingBind.Map[element] = getTickCount()
	end
end

function DynamicLightingBind:unregister(element)
	if DynamicLightingBind.Map[element] then 
		DynamicLightingBind.Map[element] = nil
	end
end

function DynamicLightingBind:purge() 
	for element, _ in pairs(DynamicLightingBind.Map) do 
		self:destroyLight(element)
	end
end

function DynamicLightingBind:destructor() 
	self:purge()
end


addEvent("switchDynamicLighting")
addEventHandler("switchDynamicLighting", root, 
	function()
		if core:get("Shaders", "DynamicLighting") then
			DynamicLightingBind:getSingleton():purge()
		end
	end)