ModdingCheck = inherit( Singleton )

--[[
ModdingCheck.SKIN_MAX_DIFFER_X = 0.5
ModdingCheck.SKIN_MAX_DIFFER_Y = 0.5
ModdingCheck.SKIN_MAX_DIFFER_Z = 0.5

ModdingCheck.VEH_MAX_DIFFER_X = 0.8
ModdingCheck.VEH_MAX_DIFFER_Y = 0.8
ModdingCheck.VEH_MAX_DIFFER_Z = 0.8

ModdingCheck.OTHER_MAX_DIFFER_X = 0.2
ModdingCheck.OTHER_MAX_DIFFER_Y = 0.2
ModdingCheck.OTHER_MAX_DIFFER_Z = 0.2

--]]

ModdingCheck.SKIN_MAX_DIF = 0.2 --// 20% Difference
ModdingCheck.VEHICLE_MAX_DIF = 0.2
ModdingCheck.OTHER_MAX_DIF = 0.2
function ModdingCheck:constructor()
	addEventHandler ( "onPlayerModInfo", getRootElement(), bind(self.handleOnPlayerModInfo, self))
	for _,plr in ipairs( getElementsByType("player") ) do
		resendPlayerModInfo( plr )
	end
end



function ModdingCheck:handleOnPlayerModInfo ( filename, modList )
	local tNames = {}
	local sumOriginal, sumMod --// will store the product of all axis multiplied
	local divResult --// sumOriginal / sumMod
	local difCondition --// bool that will state if the modded skin is differing too much from the original one
    for idx,item in ipairs(modList) do
		if item.sizeX then
			sumOriginal = item.originalSizeX + item.originalSizeY + item.originalSizeZ
			sumMod = item.sizeX + item.sizeY + item.sizeZ
			divResult = sumOriginal / sumMod
			if divResult then
				if item.id >= 0 and item.id <= 310 then -- Skins
					difCondition = divResult <= 1 and divResult < (1-ModdingCheck.SKIN_MAX_DIF)  or divResult > (1+ModdingCheck.SKIN_MAX_DIF)
					if difCondition then
						tNames[#tNames+1] = item.id.." - "..item.name
					end
				elseif item.id >= 400 and item.id <= 611 then -- Vehicles
					difCondition = divResult <= 1 and divResult < (1-ModdingCheck.VEHICLE_MAX_DIF)  or divResult > (1+ModdingCheck.VEHICLE_MAX_DIF)
					outputChatBox(divResult.."-vehicle")
					if difCondition then
						tNames[#tNames+1] = item.id.." - "..item.name
					end
				elseif item.id >= 321 and item.id <= 372 then -- Weapons
					--Allow Weapon Mods
				else	
					difCondition = divResult <= 1 and divResult < (1-ModdingCheck.OTHER_MAX_DIF)  or divResult > (1+ModdingCheck.OTHER_MAX_DIF)
					if difCondition then
						tNames[#tNames+1] = item.id.." - "..item.name
					end
				end
			end
		end
    end
	if #tNames > 0 then
		fadeCamera(source, false,0.5,255,255,255)
		triggerClientEvent("showModCheck", source, tNames)
	end
end
