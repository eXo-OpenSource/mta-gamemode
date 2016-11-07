--
-- c_bloom.lua
--

local scx, scy = guiGetScreenSize()
local enabled = false
-----------------------------------------------------------------------------------
-- Le settings
-----------------------------------------------------------------------------------
Settings = {}
Settings.var = {}
Settings.var.cutoff = 0.08
Settings.var.power = 1.88
Settings.var.bloom = 2.0
Settings.var.blendR = 204
Settings.var.blendG = 153
Settings.var.blendB = 130
Settings.var.blendA = 140


----------------------------------------------------------------
-- onClientResourceStart
----------------------------------------------------------------
function setShaderEnabled ( x )
	if x and not enabled then
		myScreenSource = dxCreateScreenSource( scx/2, scy/2 )
        blurHShader,tecName = dxCreateShader( "blurH.fx" )
        blurVShader,tecName = dxCreateShader( "blurV.fx" )
        brightPassShader,tecName = dxCreateShader( "brightPass.fx" )
        addBlendShader,tecName = dxCreateShader( "addBlend.fx" )
		bAllValid = myScreenSource and blurHShader and blurVShader and brightPassShader and addBlendShader
		addEventHandler ( "onClientHUDRender", root, onClientHudRender )
		enabled = true
	elseif not x and enabled then
		destroyElement ( blurHShader )
		destroyElement ( blurVShader )
		destroyElement ( brightPassShader )
		destroyElement ( addBlendShader )
		removeEventHandler ( "onClientHUDRender", root, onClientHudRender )
		bAllValid = false
		enabled = false
	end
end

-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
function onClientHudRender ()
	if not Settings.var then return end
	if bAllValid then
		RTPool.frameStart()
		dxUpdateScreenSource( myScreenSource )
		local current = myScreenSource
		current = applyBrightPass( current, Settings.var.cutoff, Settings.var.power )
		current = applyDownsample( current )
		current = applyDownsample( current )
		current = applyGBlurH( current, Settings.var.bloom )
		current = applyGBlurV( current, Settings.var.bloom )
		dxSetRenderTarget()
		if current then
			dxSetShaderValue( addBlendShader, "TEX0", current )
			local col = tocolor(Settings.var.blendR, Settings.var.blendG, Settings.var.blendB, Settings.var.blendA)
			dxDrawImage( 0, 0, scx, scy, addBlendShader, 0,0,0, col )
		end
	end
end


-----------------------------------------------------------------------------------
-- Apply the different stages
-----------------------------------------------------------------------------------
function applyDownsample( Src, amount )
	if not Src then return nil end
	amount = amount or 2
	local mx,my = dxGetMaterialSize( Src )
	mx = mx / amount
	my = my / amount
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0, 0, mx, my, Src )
	return newRT
end

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

function applyBrightPass( Src, cutoff, power )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( brightPassShader, "TEX0", Src )
	dxSetShaderValue( brightPassShader, "CUTOFF", cutoff )
	dxSetShaderValue( brightPassShader, "POWER", power )
	dxDrawImage( 0, 0, mx,my, brightPassShader )
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

function switchBloom( sbOn )
	setShaderEnabled(sbOn)
end
addEvent( "switchBloom", true )
addEventHandler( "switchBloom", resourceRoot, switchBloom )
