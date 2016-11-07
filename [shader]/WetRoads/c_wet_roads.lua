-- reflective bump test 2_5
-- Original By ren712
-- Modified ccw

local scx, scy = guiGetScreenSize()
local enabled = false
-----------------------------------------------------------------------------------
-- Le settings
-----------------------------------------------------------------------------------
Settings = {}
Settings.var = {}

Settings.var.bloom = 1.176

function setShaderEnabled ( x )
	if x and not enabled then
        myScreenSource = dxCreateScreenSource( scx/2, scy/2 )
        blurHShader = dxCreateShader( "blurH.fx" )
        blurVShader = dxCreateShader( "blurV.fx" )
		wetRoadsShader = dxCreateShader ( "shader_wet_roads.fx", 1, 400, false, "world,object" )
		if not wetRoadsShader then return end
		wetAmountTexture = dxCreateTexture ( "images/wet_amount.png" );
		dxSetShaderValue ( wetRoadsShader, "sWetAmountTexture", wetAmountTexture );
		engineApplyShaderToWorldTexture ( wetRoadsShader, "*freew*" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "*road*" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "tar_*" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "hiway*" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "snpedtest*" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "*junction*" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "cos_hiwaymid_256" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "cos_hiwayout_256" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "gm_lacarpark1" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "des_1line256" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "des_1linetar" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "crossing_law" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "concroadslab_256" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "custom_roadsign_text" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "roadsback01_la" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "hiwaygravel1_256" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "laroad_offroad1" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "ws_freeway2" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "desertgravelgrassroad" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "tar_1line256hvtodirt" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "sw_farmroad*" )
		bAllValid = myScreenSource and blurHShader and blurVShader and wetRoadsShader
		addEventHandler ( "onClientPreRender", root, onPreRender )
		enabled = true
	elseif not x and enabled then
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "*freew*" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "*road*" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "tar_*" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "hiway*" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "snpedtest*" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "*junction*" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "cos_hiwaymid_256" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "cos_hiwayout_256" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "gm_lacarpark1" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "des_1line256" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "des_1linetar" )
		engineRemoveShaderFromWorldTexture ( wetRoadsShader, "crossing_law" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "concroadslab_256" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "custom_roadsign_text" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "roadsback01_la" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "hiwaygravel1_256" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "laroad_offroad1" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "ws_freeway2" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "desertgravelgrassroad" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "tar_1line256hvtodirt" )
		engineApplyShaderToWorldTexture ( wetRoadsShader, "sw_farmroad*" )
		removeEventHandler ( "onClientPreRender", root, onPreRender )
		
		destroyElement ( wetAmountTexture )
		destroyElement ( wetRoadsShader )
		destroyElement ( blurHShader )
		destroyElement ( blurVShader )
		destroyElement ( myScreenSource )
		
		blurHShader=nil
		blurVShader=nil
		wetRoadsShader=nil
		enabled = false
	end
end


function onPreRender()
	if not Settings.var then return end
	if bAllValid then
		RTPool.frameStart()
		dxUpdateScreenSource( myScreenSource, false )
		current = myScreenSource
		current = applyGBlurH( current, Settings.var.bloom )
		current = applyGBlurV( current, Settings.var.bloom )
		dxSetRenderTarget()
		dxSetShaderValue( wetRoadsShader, "sReflectionTexture", current );
		local Anisotropy = math.pow( 2, dxGetStatus().SettingAnisotropicFiltering )
		dxSetShaderValue( wetRoadsShader, "sMaxAnisotropy", Anisotropy )
	end
end


-----------------------------------------------------------------------------------
-- Apply the different stages
-----------------------------------------------------------------------------------

function applyGBlurH( Src, bloom )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurHShader, "TEX0", Src )
	dxSetShaderValue( blurHShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurHShader, "BLOOM", bloom )
	dxDrawImage( 0, 0, mx, my, blurHShader )
	return newRT
end

function applyGBlurV( Src, bloom )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurVShader, "TEX0", Src )
	dxSetShaderValue( blurVShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurVShader, "BLOOM", bloom )
	dxDrawImage( 0, 0, mx,my, blurVShader )
	return newRT
end

-----------------------------------------------------------------------------------
-- Pool of render targets
-----------------------------------------------------------------------------------
RTPool = {}
RTPool.list = {}

function RTPool.frameStart()
	for rt,info in pairs(RTPool.list) do
		info.bInUse = false
	end
end

function RTPool.GetUnused( mx, my )
	-- Find unused existing
	for rt,info in pairs(RTPool.list) do
		if not info.bInUse and info.mx == mx and info.my == my then
			info.bInUse = true
			return rt
		end
	end
	-- Add new
	local rt = dxCreateRenderTarget( mx, my )
	if rt then
		RTPool.list[rt] = { bInUse = true, mx = mx, my = my }
	end
	return rt
end


function switchWetRoads( sbOn )
	setShaderEnabled(sbOn)
end
addEvent( "switchCarPaint", true )
addEventHandler( "switchWetRoads", resourceRoot, switchWetRoads )
