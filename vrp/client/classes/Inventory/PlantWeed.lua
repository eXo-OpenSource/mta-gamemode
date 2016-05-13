-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/PlantWeed.lua
-- *  PURPOSE:     Weed-Seed class client
-- *
-- ****************************************************************************
local w,h = guiGetScreenSize()
PlantWeed = inherit( Object )
addEvent("PlantWeed:sendClientCheck", true)

function PlantWeed:constructor( )
	self.m_BindRemotFunc = bind( PlantWeed.onUse, self )
	addEventHandler("PlantWeed:sendClientCheck", localPlayer, self.m_BindRemotFunc )
end

function PlantWeed:onUse(  objID )
	local x,y,z = getElementPosition( localPlayer )
	local gz = getGroundPosition( x, y, z )
	local bProc, _, _, _, _, _, _, _, mat =  processLineOfSight ( x, y, gz, x, y, gz-1)
	outputChatBox( mat )
	triggerServerEvent("PlantWeed:getClientCheck", localPlayer, IsMatInMaterialType( mat ), gz)
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