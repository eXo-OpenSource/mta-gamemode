	function doTheShaderStuff( )
		if getVersion ().sortable < "1.1.0" then
			return
		end
		myShader, tec = dxCreateShader ( "car_paint.fx" )
		if myShader then
			textureVol = dxCreateTexture ( "images/smallnoise3d.dds" );
			textureCube = dxCreateTexture ( "images/cube_env256.dds" );
			dxSetShaderValue ( myShader, "sRandomTexture", textureVol );
			dxSetShaderValue ( myShader, "sReflectionTexture", textureCube );
			engineApplyShaderToWorldTexture ( myShader, "vehiclegrunge256" )
			engineApplyShaderToWorldTexture ( myShader, "?emap*" )
		end
	end


local enabled = true
function setShaderEnabled ( b )
	if not b and enabled then
		enabled = false
		if textureVol and textureCube and myShader then
			engineRemoveShaderFromWorldTexture ( myShader, "vehiclegrunge256" )
			engineRemoveShaderFromWorldTexture ( myShader, "?emap" )
			destroyElement ( myShader )
			destroyElement ( textureVol )
			destroyElement ( textureCube )
		end
	else
		doTheShaderStuff ( )
		enabled = true
	end
end

function switchCarPaint( sbOn )
	setShaderEnabled(sbOn)
end
addEvent( "switchCarPaint", true )
addEventHandler( "switchCarPaint", resourceRoot, switchCarPaint )
