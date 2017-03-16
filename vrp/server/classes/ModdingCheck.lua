ModdingCheck = inherit( Singleton )
ModdingCheck.SKIN_MAX_DIFFER_X = 0.5
ModdingCheck.SKIN_MAX_DIFFER_Y = 0.5
ModdingCheck.SKIN_MAX_DIFFER_Z = 0.5

ModdingCheck.VEH_MAX_DIFFER_X = 0.1
ModdingCheck.VEH_MAX_DIFFER_Y = 0.1
ModdingCheck.VEH_MAX_DIFFER_Z = 0.1

function ModdingCheck:constructor()
	addEventHandler ( "onPlayerModInfo", getRootElement(), bind(self.handleOnPlayerModInfo, self))
	for _,plr in ipairs( getElementsByType("player") ) do
		resendPlayerModInfo( plr )
	end
end



function ModdingCheck:handleOnPlayerModInfo ( filename, modList )
	local tNames = {}
	local differenceX, differenceY, differenceZ
    for idx,item in ipairs(modList) do
		if item.id >= 0 and item.id <= 310 then -- Skins
			if item.sizeX then
				differenceX =  math.abs(item.originalSizeX - item.sizeX)
				differenceY = math.abs( item.originalSizeY - item.sizeY)
				differenceZ = math.abs( item.originalSizeZ - item.sizeZ)
				if differenceX >= ModdingCheck.SKIN_MAX_DIFFER_X or differenceY >= ModdingCheck.SKIN_MAX_DIFFER_Y or differenceZ >= ModdingCheck.SKIN_MAX_DIFFER_Z then
					tNames[#tNames+1] = item.id.." - "..item.name
				end
			end
        elseif item.id >= 400 and item.id <= 611 then
			if item.sizeX then
				differenceX =  math.abs(item.originalSizeX - item.sizeX)
				differenceY = math.abs( item.originalSizeY - item.sizeY)
				differenceZ = math.abs( item.originalSizeZ - item.sizeZ)
				if differenceX >= ModdingCheck.VEH_MAX_DIFFER_X or differenceY >= ModdingCheck.VEH_MAX_DIFFER_Y or differenceZ >= ModdingCheck.VEH_MAX_DIFFER_Z then
					tNames[#tNames+1] = item.id.." - "..item.name
				end
			end
		end
    end
	if #tNames > 0 then
		fadeCamera(source, false,0.5,255,255,255)
		triggerClientEvent("showModCheck", source, tNames)
	end
end
