-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/PlantWeed.lua
-- *  PURPOSE:     Weed-Seed class client
-- *
-- ****************************************************************************

PlantWeed = inherit( Object )

addRemoteEvents{"PlantWeed:sendClientCheck", "PlantWeed:syncPlantMap", "PlantWeed:onWaterPlant"}

function PlantWeed.initalize()
	PlantWeed.Shader = dxCreateShader ( "files/shader/shell_layer.fx",0,20,true, "object" )
	PlantWeed.Shader2 = dxCreateShader ( "files/shader/shell_layer.fx",0,20,true, "object" )
	PlantWeed.WaterDrop =  "files/images/Inventory/waterdrop.png"
end

function PlantWeed:constructor( )
	self.m_BindRemoteFunc = bind( PlantWeed.onUse, self )
	self.m_BindRemoteFunc2 = bind( PlantWeed.onSync, self )
	self.m_BindRemoteFunc3 = bind( PlantWeed.Render, self )
	self.m_BindRemoteFunc4 = bind( PlantWeed.onWaterWeedPlant, self )
	self.m_EntityTable = {	}
	addEventHandler("PlantWeed:sendClientCheck", localPlayer, self.m_BindRemoteFunc )
	addEventHandler("PlantWeed:syncPlantMap", localPlayer, self.m_BindRemoteFunc2 )
	addEventHandler("onClientRender", root, self.m_BindRemoteFunc3 )
	addEventHandler("PlantWeed:onWaterPlant", localPlayer, self.m_BindRemoteFunc4 )
end

function PlantWeed:onUse()
	local pos = localPlayer:getPosition()
	local gz = getGroundPosition(pos)
	local hit, _, _, _, _, _, _, _, surface = processLineOfSight(pos.x, pos.y, gz, pos.x, pos.y, gz-0.5, true, false, false)
	triggerServerEvent("PlantWeed:getClientCheck", localPlayer, IsMatInMaterialType(surface), gz)
end

function PlantWeed:Render()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/WeedUI") end
	if PlantWeed.Shader and PlantWeed.Shader2 then
		if #self.m_EntityTable ~= 0 then
			local timeElapsed = getTickCount() - self.m_RendTick
			local f = timeElapsed / 500
			f = math.min( f, 1 )
			local size = math.lerp ( 1, 1.2, f )
			local alpha = math.lerp ( 1.0, 0.0, f )
			dxSetShaderValue( PlantWeed.Shader, "sMorphSize", size, size, size )
			dxSetShaderValue( PlantWeed.Shader, "sMorphColor", 0, 1, 0, alpha )
			dxSetShaderValue( PlantWeed.Shader2, "sMorphSize", size, size, size )
			dxSetShaderValue( PlantWeed.Shader2, "sMorphColor", 1, 0, 0, alpha )
		end
	end
	if self.m_HydPlant  and isElementStreamedIn(self.m_HydPlant) then
		local now = getTickCount()
		if self.m_HydDrawTick+1000 >= now then
			local prog = ( now - self.m_HydDrawTick) / 1000
			local offsetZ = 0.5 * prog
			local x,y,z = getElementPosition( self.m_HydPlant )
			local sx, sy = getScreenFromWorldPosition( x,y,(z+1)- offsetZ)
			local alpha = 255 * prog
			local color = tocolor( 255, 255, 255, alpha)
			dxDrawImage(sx,sy,screenWidth*0.03,screenWidth*0.05, PlantWeed.WaterDrop, 0,0,0, color)
		else
			self.m_HydPlant = nil
		end
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/WeedUI", 1, 1) end
end

function PlantWeed:destructor( )

end

function IsMatInMaterialType( mat )
	local bCheck
	for i = 1,#MATERIAL_TYPES do
		for i2 = 1,#MATERIAL_TYPES[i] do
			bCheck = mat == MATERIAL_TYPES[i][i2]
			if bCheck then
				return true
			end
		end
	end
	return false
end

function PlantWeed:onSync( tbl )
	local iHyd,obj
	for i = 1,#self.m_EntityTable do
		obj = self.m_EntityTable[i]
		engineRemoveShaderFromWorldTexture ( obj.m_Shader, "*" ,self.m_EntityTable[i])
		setElementAlpha( obj, 255 )
	end
	self.m_EntityTable = tbl
	self.m_RendTick = getTickCount()
	for i = 1,#self.m_EntityTable do
		obj = self.m_EntityTable[i]
		if getElementData(obj, "Plant:Hydration") then
			obj.m_Shader = PlantWeed.Shader
		else
			obj.m_Shader = PlantWeed.Shader2
		end
		engineApplyShaderToWorldTexture ( obj.m_Shader, "*", obj)
		setElementAlpha( obj, 254 )
	end
end

function PlantWeed:onWaterWeedPlant( plant )
	self.m_HydPlant = plant
	self.m_HydDrawTick = getTickCount()
end

function math.lerp(from,to,alpha)
    return from + (to-from) * alpha
end
