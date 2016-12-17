--
-- c_main.lua
--

Settings = {}
Settings.var = {}
local scx,scy = guiGetScreenSize ()

function setcpRLffectVehicle()
    local v = Settings.var
	v.renderDistance = 60 -- max render distance of the shader effect
	v.scXY = {800,600} -- reflection screensource resolution
	v.normalXY = 0.2 -- deformation strength (0-1.0) 1.0 = the highest (X and Y of vector)
	v.normalZ = 0.2 -- deformation strength (0-1.0) 1.0 = the highest (Z of vector)
	v.bumpSize = 0.7 -- for car paint
	v.envIntensity = {0.25, 0.5} -- intensity of the reflection effect
	v.brightnessMul = {1.0, 1.0} -- multiply after brightpass
	v.brightpassPower = {2.5, 2.0} -- 1-5
	v.brightnessAdd = {0.1, 0.1} -- before bright pass
	v.uvMul = {2.0,0.5} -- uv multiply
	v.uvMov = {0,-2.8} -- uv move
end

--a table of additional texture names:
			
	local texturegrun = {
			"predator92body128", "monsterb92body256a", "monstera92body256a", "andromeda92wing","fcr90092body128",
			"hotknifebody128b", "hotknifebody128a", "rcbaron92texpage64", "rcgoblin92texpage128", "rcraider92texpage128", 
			"rctiger92body128","rhino92texpage256", "petrotr92interior128","artict1logos","rumpo92adverts256","dash92interior128",
			"coach92interior128","combinetexpage128","hotdog92body256",
			"raindance92body128", "cargobob92body256", "andromeda92body", "at400_92_256", "nevada92body256",
			"polmavbody128a" , "sparrow92body128" , "hunterbody8bit256a" , "seasparrow92floats64" , 
			"dodo92body8bit256" , "cropdustbody256", "beagle256", "hydrabody256", "rustler92body256", 
			"shamalbody256", "skimmer92body128", "stunt256", "maverick92body128", "leviathnbody8bit256" }



function startCarPaintReflect()
		if cprEffectEnabled then return end
		local v = Settings.var
		setcpRLffectVehicle()
		-- Create shader
		paintShader = dxCreateShader ( "fx/car_paint.fx",1 ,v.renderDistance ,false, "vehicle" )
		glassShader = dxCreateShader ( "fx/car_glass.fx",1 ,v.renderDistance ,false, "vehicle" )
		--shatterShader = dxCreateShader ( "fx/car_glass.fx",1 ,v.renderDistance ,false, "vehicle" )		
		if paintShader then
			myScreenSource = dxCreateScreenSource( v.scXY[1], v.scXY[2] )
			addEventHandler ( "onClientPreRender", getRootElement (), updateScreen )
			-- Set textures
			textureVol = dxCreateTexture ( "images/smallnoise3d.dds" )
			
			dxSetShaderValue ( paintShader, "sRandomTexture", textureVol )
			dxSetShaderValue ( paintShader, "sReflectionTexture", myScreenSource )

			dxSetShaderValue ( paintShader, "sNorFacXY", v.normalXY)
			dxSetShaderValue ( paintShader, "sNorFacZ", v.normalZ)
			dxSetShaderValue ( paintShader, "uvMul", v.uvMul[1],v.uvMul[2])
			dxSetShaderValue ( paintShader, "uvMov", v.uvMov[1],v.uvMov[2])
			dxSetShaderValue ( paintShader, "bumpSize", v.bumpSize )
			dxSetShaderValue ( paintShader, "envIntensity", v.envIntensity[1])

			dxSetShaderValue ( paintShader, "sPower", v.brightpassPower[1])			
			dxSetShaderValue ( paintShader, "sAdd", v.brightnessAdd[1])
			dxSetShaderValue ( paintShader, "sMul", v.brightnessMul[1])
			
			dxSetShaderValue ( glassShader, "sRandomTexture", textureVol )
			dxSetShaderValue ( glassShader, "sReflectionTexture", myScreenSource )

			dxSetShaderValue ( glassShader, "sNorFacXY", v.normalXY)
			dxSetShaderValue ( glassShader, "sNorFacZ", v.normalZ)
			dxSetShaderValue ( glassShader, "uvMul", v.uvMul[1],v.uvMul[2])
			dxSetShaderValue ( glassShader, "uvMov", v.uvMov[1],v.uvMov[2])
			dxSetShaderValue ( glassShader, "bumpSize", v.bumpSize )
			dxSetShaderValue ( glassShader, "envIntensity", v.envIntensity[2])

			dxSetShaderValue ( glassShader, "sPower", v.brightpassPower[2])			
			dxSetShaderValue ( glassShader, "sAdd", v.brightnessAdd[2])
			dxSetShaderValue ( glassShader, "sMul", v.brightnessMul[2])
--[[
			dxSetShaderValue ( shatterShader, "sRandomTexture", textureVol )
			dxSetShaderValue ( shatterShader, "sReflectionTexture", myScreenSource )
			dxSetShaderValue ( shatterShader, "isShatter", true)
			
			dxSetShaderValue ( shatterShader, "sNorFacXY", v.normalXY)
			dxSetShaderValue ( shatterShader, "sNorFacZ", v.normalZ)
			dxSetShaderValue ( shatterShader, "uvMul", v.uvMul[1],v.uvMul[2])
			dxSetShaderValue ( shatterShader, "uvMov", v.uvMov[1],v.uvMov[2])
			dxSetShaderValue ( shatterShader, "bumpSize", v.bumpSize )
			dxSetShaderValue ( shatterShader, "envIntensity", v.envIntensity[2])

			dxSetShaderValue ( shatterShader, "sPower", v.brightpassPower[2])			
			dxSetShaderValue ( shatterShader, "sAdd", v.brightnessAdd[2])
			dxSetShaderValue ( shatterShader, "sMul", v.brightnessMul[2])
]]--
			-- Apply to world texture
			engineApplyShaderToWorldTexture ( paintShader, "vehiclegrunge256" )
			engineApplyShaderToWorldTexture ( paintShader, "?emap*" )
			
			engineApplyShaderToWorldTexture ( glassShader, "vehiclegeneric256" )
			
			--engineApplyShaderToWorldTexture ( shatterShader, "vehicleshatter128" )
			
			for _,addList in ipairs(texturegrun) do
			engineApplyShaderToWorldTexture (paintShader, addList )
		    end
			cprEffectEnabled = true
		else	
			outputChatBox( "Car Paint Reflect: Could not create shaders.",255,0,0 ) return		
		end
end

function stopCarPaintReflect()
	if not cprEffectEnabled then return end
	removeEventHandler ( "onClientPreRender", getRootElement (), updateScreen )
	engineRemoveShaderFromWorldTexture ( paintShader,"*" )
	destroyElement( paintShader )
	paintShader = nil
	engineRemoveShaderFromWorldTexture ( glassShader,"*" )
	destroyElement( glassShader )
	glassShader = nil
	--engineRemoveShaderFromWorldTexture ( shatterShader,"*" )
	--destroyElement( shatterShader )
	--shatterShader = nil
	destroyElement( textureVol )
	textureVol = nil
	destroyElement( myScreenSource )
	myScreenSource = nil
	cprEffectEnabled = false
end

function updateScreen()
	if myScreenSource then
		dxUpdateScreenSource( myScreenSource)
	end
end
