-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/Plant.lua
-- *  PURPOSE:     Plant-Seed class client
-- *
-- ****************************************************************************

ItemPlant = inherit( Object )

addRemoteEvents{"Plant:sendClientCheck", "Plant:syncPlantMap", "Plant:onWaterPlant"}

function ItemPlant.initalize()
	ItemPlant.Shader = dxCreateShader ( "files/shader/shell_layer.fx",0,20,true, "object" )
	ItemPlant.Shader2 = dxCreateShader ( "files/shader/shell_layer.fx",0,20,true, "object" )
	ItemPlant.WaterDrop =  "files/images/Inventory/waterdrop.png"
end

function ItemPlant:constructor( )
	self.m_BindRemoteFunc = bind( ItemPlant.onUse, self )
	self.m_BindRemoteFunc2 = bind( ItemPlant.onSync, self )
	self.m_BindRemoteFunc3 = bind( ItemPlant.Render, self )
	self.m_BindRemoteFunc4 = bind( ItemPlant.onWaterPlant, self )
	self.m_EntityTable = {	}
	addEventHandler("Plant:sendClientCheck", localPlayer, self.m_BindRemoteFunc )
	addEventHandler("Plant:syncPlantMap", localPlayer, self.m_BindRemoteFunc2 )
	addEventHandler("onClientRender", root, self.m_BindRemoteFunc3 )
	addEventHandler("Plant:onWaterPlant", localPlayer, self.m_BindRemoteFunc4 )
end

function ItemPlant:isUnderWater()
	local pos = localPlayer:getPosition()
	local waterLevel = getWaterLevel(pos.x, pos.y, pos.z)
	if waterLevel and pos.z-waterLevel < 0 then
		return true
	end
	return false
end

function ItemPlant:onUse(plant)
	local pos = localPlayer:getPosition()
	local gz = getGroundPosition(pos)
	local surfaceClear = true
	local surfaceRightType = true
	if math.abs(pos.z - gz) < 2 then
		local base, __, __, __, __, __, __, __, surface = processLineOfSight(pos.x, pos.y, pos.z, pos.x, pos.y, gz-0.5, true, false, false)
		if base then
			local edges = {
				top = {processLineOfSight(pos.x + 1, pos.y, pos.z, pos.x + 1, pos.y, gz-0.5, true, false, false)},
				left = {processLineOfSight(pos.x, pos.y + 1, pos.z, pos.x, pos.y + 1, gz-0.5, true, false, false)},
				bottom = {processLineOfSight(pos.x - 1, pos.y, pos.z, pos.x - 1, pos.y, gz-0.5, true, false, false)},
				right = {processLineOfSight(pos.x, pos.y - 1, pos.z, pos.x, pos.y - 1, gz-0.5, true, false, false)},
			}
			for i,v in pairs(edges) do
				if v[1] then
					if not IsMatInMaterialType(v[9]) then
						surfaceRightType = false
						break
					end
				else
					surfaceClear = false
					break
				end
			end
			if not IsMatInMaterialType(surface) then
				surfaceRightType = false
			end
		else
			surfaceClear = false
		end
	else
		surfaceClear = false
	end
	triggerServerEvent("plant:getClientCheck", localPlayer, plant, surfaceClear and surfaceRightType, gz, self:isUnderWater())
end

function ItemPlant:Render()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/PlantUI") end
	if ItemPlant.Shader and ItemPlant.Shader2 then
		if #self.m_EntityTable ~= 0 then
			local timeElapsed = getTickCount() - self.m_RendTick
			local f = timeElapsed / 500
			f = math.min( f, 1 )
			local size = math.lerp ( 1, 1.2, f )
			local alpha = math.lerp ( 1.0, 0.0, f )
			dxSetShaderValue( ItemPlant.Shader, "sMorphSize", size, size, size )
			dxSetShaderValue( ItemPlant.Shader, "sMorphColor", 0, 1, 0, alpha )
			dxSetShaderValue( ItemPlant.Shader2, "sMorphSize", size, size, size )
			dxSetShaderValue( ItemPlant.Shader2, "sMorphColor", 1, 0, 0, alpha )
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
			dxDrawImage(sx,sy,screenWidth*0.03,screenWidth*0.05, ItemPlant.WaterDrop, 0,0,0, color)
		else
			self.m_HydPlant = nil
		end
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/PlantUI", 1, 1) end
end

function ItemPlant:destructor( )

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

function ItemPlant:onSync( tbl )
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
			obj.m_Shader = ItemPlant.Shader
		else
			obj.m_Shader = ItemPlant.Shader2
		end
		engineApplyShaderToWorldTexture ( obj.m_Shader, "*", obj)
		setElementAlpha( obj, 254 )
	end
end

function ItemPlant:onWaterPlant( plant )
	self.m_HydPlant = plant
	self.m_HydDrawTick = getTickCount()
end

function math.lerp(from,to,alpha)
    return from + (to-from) * alpha
end
