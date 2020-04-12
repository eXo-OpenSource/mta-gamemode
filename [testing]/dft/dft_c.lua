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


addEventHandler("onClientResourceStart", resourceRoot, function()
    CustomModelManager.loadImportTXD("ramp.txd", 1337)
    CustomModelManager.loadImportDFF("ramp.dff", 1337)
    CustomModelManager.loadImportCOL("ramp.col", 1337)
end)


local progress
local startTime
local r, sp, ep
function animateRamps()
	local prog = (getTickCount()-startTime)/5000
	for i,v in pairs(r) do
		local p = interpolateBetween(sp[i % 2 + 1], 0, 0, ep[i % 2 + 1], 0, 0, prog, "InOutQuad")
		local x, y, z, rx, ry, rz = getElementAttachedOffsets(v)
		setElementAttachedOffsets(v, x, y, z, p, ry, rz)
	end
	if prog >= 1 then
		for i,v in pairs(r) do
			local x, y, z = getElementPosition(v)
			local rx, ry, rz = getElementRotation(v)
			detachElements(v)
			setElementPosition(v, x, y, z)
			setElementRotation(v, rx, ry, rz)
		end
		removeEventHandler("onClientRender", root, animateRamps)
	end
end


addEvent("moveDFTLoading", true)
addEventHandler("moveDFTLoading", root, function(VehicleRamps, offsetOpen, offsetClose, open)
	if open then
        setVehicleHandling(source, "suspensionUpperLimit", nil, true)
		setVehicleHandling(source, "suspensionLowerLimit", nil, true)
		r, sp, ep = VehicleRamps, offsetOpen, offsetClose
		addEventHandler("onClientRender", root, animateRamps)
    else
        setVehicleHandling(source, "suspensionUpperLimit", 0.6)
		setVehicleHandling(source, "suspensionLowerLimit", 0.1)
		r, sp, ep = VehicleRamps, offsetClose, offsetOpen
		addEventHandler("onClientRender", root, animateRamps)
	end
	progress = 0
	startTime = getTickCount()
end)