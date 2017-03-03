SkinModdingCheck = inherit( Singleton )
SkinModdingCheck.MAX_DIFFER_X = 0.2
SkinModdingCheck.MAX_DIFFER_Y = 0.2
SkinModdingCheck.MAX_DIFFER_Z = 0.1

function SkinModdingCheck:constructor() 
	addEventHandler ( "onPlayerModInfo", getRootElement(), bind(self.handleOnPlayerModInfo, self))
	for _,plr in ipairs( getElementsByType("player") ) do
		resendPlayerModInfo( plr )
	end
end



function SkinModdingCheck:handleOnPlayerModInfo ( filename, modList )
	local tNames = {}
	local differenceX, differenceY, differenceZ
    for idx,item in ipairs(modList) do
		if item.id >= 0 and item.id <= 310 then
			if item.sizeX then
				differenceX =  math.abs(item.originalSizeX - item.sizeX)
				differenceY = math.abs( item.originalSizeY - item.sizeY)
				differenceZ = math.abs( item.originalSizeZ - item.sizeZ)			
				if differenceX >= SkinModdingCheck.MAX_DIFFER_X or differenceY >= SkinModdingCheck.MAX_DIFFER_Y or differenceZ >= SkinModdingCheck.MAX_DIFFER_Z then 
					tNames[#tNames+1] = item.id.." - "..item.name
				end
			end
        end
    end
	if #tNames > 0 then 
		fadeCamera(source, false,0.5,255,255,255)
		triggerClientEvent("showSkinModCheck", source, tNames)
	end
end


