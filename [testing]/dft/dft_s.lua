

VehicleTransportExtension = {}
VehicleTransportExtension.Presets = {
    [578] = {
        boundingBox = {-1.5, -5.6, 0, -1.5, 2.2, 1.5}
    }
}

VehicleRamps = {}

local open = false

DFT = createVehicle(578, 1529.57, -1695.12, 14.01, 359.91, 0.00, 181.19)




function createRamp(offsetX)
    VehicleRamps[1] = createObject(1337, 0, 0, 0)
    attachElements(VehicleRamps[1], DFT, offsetX, -5.6, -0.26, -90, 0, 0)
    --attachElements(VehicleRamps[1], DFT, offsetX, -5.6, -0.26, 15, 0, 0)
    
    VehicleRamps[2] = createObject(1337, 0, 0, 0)
    attachElements(VehicleRamps[2], VehicleRamps[1], 0, -2.02, 0, 180, 0, 0)
    --attachElements(VehicleRamps[2], VehicleRamps[1], 0, -2.02, 0, 0, 0, 0)

    VehicleRamps[3] = createObject(1337, 0, 0, 0)
    attachElements(VehicleRamps[3], DFT, -offsetX, -5.6, -0.26, -90, 0, 0)
    --attachElements(VehicleRamps[3], DFT, -offsetX, -5.6, -0.26, 15, 0, 0)
    
    VehicleRamps[4] = createObject(1337, 0, 0, 0)
    attachElements(VehicleRamps[4], VehicleRamps[3], 0, -2.02, 0, 180, 0, 0)
    --attachElements(VehicleRamps[4], VehicleRamps[3], 0, -2.02, 0, 0, 0, 0)
end

createRamp(0.9)

offsetOpen = {0, 15}
offsetClose = {180, -90}

addCommandHandler("move", function()
    if open then
        setVehicleHandling(DFT, "suspensionUpperLimit", nil, true)
		setVehicleHandling(DFT, "suspensionLowerLimit", nil, true)
    else
        setVehicleHandling(DFT, "suspensionUpperLimit", 0.6)
		setVehicleHandling(DFT, "suspensionLowerLimit", 0.1)
    end
    setElementVelocity(DFT, 0, 0, 0.01)
    triggerClientEvent("moveDFTLoading", DFT, VehicleRamps, offsetOpen, offsetClose, open)
    open = not open
end)