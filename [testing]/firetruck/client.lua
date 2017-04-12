-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/CustomModelManager.lua
-- *  PURPOSE:     Easy way to load custom models
-- *
-- ****************************************************************************
CustomModelManager = {}

function CustomModelManager.loadImportDFF(filePath, modelId)
	local dff = engineLoadDFF(filePath, 0)
	return engineReplaceModel(dff, modelId)
end

function CustomModelManager.loadImportTXD(filePath, modelId)
	local txd = engineLoadTXD(filePath)
	return engineImportTXD(txd, modelId), txd
end

function CustomModelManager.loadImportCOL(filePath, modelId)
	local col = engineLoadCOL(filePath)
	engineReplaceCOL(col, modelId)
end

CustomModelManager.loadImportTXD("files/models/fire_ledder.txd", 1931)
CustomModelManager.loadImportDFF("files/models/fire_ledder.dff", 1931)
CustomModelManager.loadImportCOL("files/models/fire_ledder.col", 1931)

CustomModelManager.loadImportTXD("files/models/fire_main.txd", 1932)
CustomModelManager.loadImportDFF("files/models/fire_main.dff", 1932)
CustomModelManager.loadImportCOL("files/models/fire_main.col", 1932)

addEventHandler("onClientElementStreamIn", root, function()
	if source:getType() == "vehicle" and source:getModel() == 544 then
		setVehicleComponentVisible(source, "misc_a", false)
		setVehicleComponentVisible(source, "misc_b", false)
		setVehicleComponentVisible(source, "misc_c", false)
	end
end)

addCommandHandler ( "gvc",
    function ( )
        local theVehicle = getPedOccupiedVehicle ( localPlayer )
        if ( theVehicle ) then
            for k in pairs ( getVehicleComponents ( theVehicle ) ) do
                outputChatBox ( k )
            end
        end
    end
)