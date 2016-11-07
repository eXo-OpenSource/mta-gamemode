--
-- c_water_ref.lua
--

---------------------------------
-- Version check
---------------------------------
function isMTAUpToDate()
	local mtaVer = getVersion().sortable
	--outputDebugString("MTA Version: "..tostring(mtaVer))
	if getVersion ().sortable < "1.3.4-9.05899" then
		return false
	else
		return true
	end
end

---------------------------------
-- DepthBuffer access
---------------------------------
function isDepthBufferAccessible()
	local info = dxGetStatus()
	local depthStatus = false
		for k,v in pairs(info) do
			if string.find(k, "DepthBufferFormat") then
				--outputDebugString("DepthBufferFormat: "..tostring(v))
				depthStatus=true
				if tostring(v)=='unknown' then depthStatus = false end
			end
		end
	return depthStatus
end

----------------------------------
--dxGetStatus for debuging
----------------------------------
addCommandHandler( "dxGetStatus",
function()
	local info=dxGetStatus()
	local ver = getVersion ().sortable
	local outStr = 'MTAVersion:'..ver..'dxGetStatus: '
	for k,v in pairs(info) do
		outStr = outStr..' '..k..': '..tostring(v)..'  ,'
	end
	--outputDebugString(outStr)
	setClipboard(outStr)
	outputChatBox('---dxGetStatus copied to clipboard---' )
end
)


function startWaterRefract()
	if wrEffectEnabled then return end
		-- Create shader
		myShader, tec = dxCreateShader ( "fx/water_ref.fx" )
		if not myShader  then return end
		--outputDebugString('Shader WatRef 2.1 using techinque: '..tec)
			-- Set textures
			textureVol = dxCreateTexture ( "images/wavemap.png" )
			if not isDepthBufferAccessible() then 
				textureCube = dxCreateTexture ( "images/cube_env.dds" )
				dxSetShaderValue ( myShader, "sReflectionTexture", textureCube )
			end
			dxSetShaderValue ( myShader, "sRandomTexture", textureVol )
			dxSetShaderValue ( myShader, "normalMult", 0.24 )
			dxSetShaderValue ( myShader, "gBuffAlpha", 0.30)
			dxSetShaderValue ( myShader, "gDepthFactor", 0.03)

			-- Apply to global txd 13
			engineApplyShaderToWorldTexture ( myShader, "waterclear256" )
			
			-- Update water color incase it gets changed by persons unknown
			watTimer = setTimer(function()
							if myShader then
								local r,g,b,a = getWaterColor()
								dxSetShaderValue ( myShader, "sWaterColor", r/255, g/255, b/255, a/255 );
								local rSkyTop,gSkyTop,bSkyTop,rSkyBott,gSkyBott,bSkyBott = getSkyGradient ()
								dxSetShaderValue ( myShader, "sSkyColorTop", rSkyTop/255, gSkyTop/255, bSkyTop/255)
								dxSetShaderValue ( myShader, "sSkyColorBott", rSkyBott/255, gSkyBott/255, bSkyBott/255)
							end
						end
						,100,0 )
	wrEffectEnabled = true
end


function stopWaterRefract()
	if not wrEffectEnabled then return end
	if myShader then
		killTimer(watTimer)
		engineRemoveShaderFromWorldTexture ( myShader, "waterclear256" )
		destroyElement(myShader)
		myShader = nil
		destroyElement(textureVol)
		textureVol = nil
		if textureCube then 
			destroyElement(textureCube)
			textureCube = nil
		end
	end
		wrEffectEnabled = false
end