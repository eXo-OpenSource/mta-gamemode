Export = {}

function Export.FUNC_getShaders()
	local shaderStatus = {}
	for name, key in pairs(SHADERS) do
        setting = core:get("Shaders", name) or false
		shaderStatus[name] = setting == false and "Nein" or "Ja"
    end

	return shaderStatus
end

function Export.FUNC_getTextureMode()
	return core:get("Other", "TextureMode", 1)
end

function Export.FUNC_getTextureStatus()
	return #TextureReplace.Cache
end

function Export.FUNC_getHUDStatus()
	return core:get("HUD", "UIStyle", UIStyle.vRoleplay)
end

function Export.FUNC_getRadarStatus()
	return core:get("HUD", "RadarDesign", RadarDesign.GTA)
end

function exportWrapper(func, ...)
	if func == "shaderStatus" then
		return Export.FUNC_getShaders(...)
	elseif func == "textureMode" then
		return Export.FUNC_getTextureMode(...)
	elseif func == "textureStatus" then
		return Export.FUNC_getTextureStatus(...)
	elseif func == "hudStatus" then
		return Export.FUNC_getHUDStatus(...)
	elseif func == "radarStatus" then
		return Export.FUNC_getRadarStatus(...)
	else
		return {result = false, status = "wrapper method not found!"}
	end
end
