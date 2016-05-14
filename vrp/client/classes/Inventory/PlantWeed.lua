-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/PlantWeed.lua
-- *  PURPOSE:     Weed-Seed class client
-- *
-- ****************************************************************************
local w,h = guiGetScreenSize()
local shader = dxCreateShader ( "files/shader/shell_layer.fx",0,0,true, "object" )
PlantWeed = inherit( Object )
addEvent("PlantWeed:sendClientCheck", true)
addEvent("PlantWeed:syncPlantMap", true)

function PlantWeed:constructor( )
	self.m_BindRemoteFunc = bind( PlantWeed.onUse, self )
	self.m_BindRemoteFunc2 = bind( PlantWeed.onSync, self )
	self.m_BindRemoteFunc3 = bind( PlantWeed.Render, self )
	self.m_EntityTable = {	}
	addEventHandler("PlantWeed:sendClientCheck", localPlayer, self.m_BindRemoteFunc )
	addEventHandler("PlantWeed:syncPlantMap", localPlayer, self.m_BindRemoteFunc2 )
	addEventHandler("onClientRender", root, self.m_BindRemoteFunc3 )
end

function PlantWeed:onUse(  objID )
	local x,y,z = getElementPosition( localPlayer )
	local gz = getGroundPosition( x, y, z )
	local bProc, _, _, _, _, _, _, _, mat =  processLineOfSight ( x, y, gz, x, y, gz-1)
	triggerServerEvent("PlantWeed:getClientCheck", localPlayer, IsMatInMaterialType( mat ), gz)
end

function PlantWeed:Render( )
	if shader then
		if #self.m_EntityTable ~= 0 then
			local timeElapsed = getTickCount() - self.m_RendTick
			local f = timeElapsed / 500
			f = math.min( f, 1 )
			local size = math.lerp ( 1, 1.2, f )
			local alpha = math.lerp ( 1.0, 0.0, f )
			dxSetShaderValue( shader, "sMorphSize", size, size, size )
			dxSetShaderValue( shader, "sMorphColor", 0, 1, 0, alpha )
		end
	end
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
	for i = 1,#self.m_EntityTable do 
		engineRemoveShaderFromWorldTexture ( shader, "*" ,self.m_EntityTable[i])
		setElementAlpha( self.m_EntityTable[i], 255 )
	end
	self.m_EntityTable = tbl
	self.m_RendTick = getTickCount()
	for i = 1,#self.m_EntityTable do 
		engineApplyShaderToWorldTexture ( shader, "*", self.m_EntityTable[i])
		setElementAlpha( self.m_EntityTable[i], 254 )
	end
end

function math.lerp(from,to,alpha)
    return from + (to-from) * alpha
end