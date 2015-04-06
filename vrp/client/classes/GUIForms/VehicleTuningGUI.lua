-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleTuningGUI.lua
-- *  PURPOSE:     Vehicle tuning garage class
-- *
-- ****************************************************************************
VehicleTuningGUI = inherit(GUIForm)

function VehicleTuningGUI:constructor(vehicle)
    GUIForm.constructor(self, 10, 10, screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight/2)

    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Vehicle shop", false, true, self)
    self.m_PartsList = GUIGridList:new(0, self.m_Height*0.22, self.m_Width, self.m_Height*0.72, self.m_Window)
    self.m_PartsList:addColumn(_"Name", 1)
    GUIImage:new(0, 30, self.m_Width, self.m_Height/7, "files/images/TuningHeader.png", self.m_Window)
    GUILabel:new(0, self.m_Height-self.m_Height/14, self.m_Width, self.m_Height/14, "↕", self.m_Window):setAlignX("center")

    -- Part rect
    local width, height = 500, 80
    --self.m_UpgradeRect = GUIRectangle:new(screenWidth/2-width/2, screenHeight-20-height, width, height, Color.Grey)
    --self.m_UpgradeNameLabel = GUILabel:new(25, 15, 500-25*2, 80-15*2, "Fucking part name", self.m_UpgradeRect):setAlignX("center")
    self.m_UpgradeChanger = GUIChanger:new(screenWidth/2-width/2, screenHeight-20-height, width, height)
    self.m_UpgradeChanger:addItem("Fucking Dennis")

    self.m_Vehicle = vehicle
    self:initPartsList()
    self:moveCameraToSlot(7)

    self.m_Music = Sound.create("https://jusonex.net/public/saonline/Audio/GarageMusic.mp3", true)
end

function VehicleTuningGUI:destructor()
    setCameraTarget(localPlayer)

    GUIForm.destructor(self)
end

function VehicleTuningGUI:initPartsList()
    for slot = 0, 16 do
        local name = getVehicleUpgradeSlotName(slot)
        local item = self.m_PartsList:addItem(name)
        item.PartSlot = slot
        item.onLeftClick = bind(self.PartItem_Click, self)
    end
end

function VehicleTuningGUI:updateUpgradeList(slot)
    local upgrades = getVehicleCompatibleUpgrades(self.m_Vehicle, slot)

    -- TODO: Update upgrade list
end

function VehicleTuningGUI:moveCameraToSlot(slot)
    local targetPosition = self.CameraPositions[slot]
    local targetLookAtPosition = self.m_Vehicle:getPosition()
    if type(targetPosition) == "table" then
        targetPosition, targetLookAtPosition = unpack(targetPosition)
        targetLookAtPosition = self.m_Vehicle.matrix:transformPosition(targetLookAtPosition)
    end

    local oldX, oldY, oldZ, oldLookX, oldLookY, oldLookZ = getCameraMatrix()
    local progress = 0

    addEventHandler("onClientPreRender", root,
        function(deltaTime)
            local x, y, z = interpolateBetween(oldX, oldY, oldZ, self.m_Vehicle.matrix:transformPosition(targetPosition), progress, "InOutBack")
            local lx, ly, lz = interpolateBetween(oldLookX, oldLookY, oldLookZ, targetLookAtPosition, progress, "Linear")
            setCameraMatrix(x, y, z, lx, ly, lz)

            progress = progress + deltaTime * 0.0006
            if progress >= 1 then
                removeEventHandler("onClientPreRender", root, getThisFunction())
            end
        end
    )
end

function VehicleTuningGUI:PartItem_Click(item)
    self:moveCameraToSlot(item.PartSlot)
    if item.PartSlot then
        self:updateUpgradeList(item.PartSlot)
    end
end

VehicleTuningGUI.CameraPositions = {
    [0] = Vector3(0, 5.6, 1.5), -- Hood
    [1] = Vector3(0, 4.76, 0.35), -- Vent
    [2] = Vector3(1.8, -5, 1.6), -- Spoiler
    [3] = Vector3(5, 0, 0.5), -- Sideskirt
    [4] = Vector3(0, 5.8, 0.2), -- Front bullbars
    [5] = Vector3(0, -6, 0.2), -- Rear bullbars
    [6] = Vector3(0, 5.6, 1), -- Headlights
    [7] = Vector3(4.2, 2.1, 2.1), -- Roof
    [8] = Vector3(0.5, -4.9, 2.2), -- Nitro
    [9] =  {Vector3(3.2, -1.7, 0), Vector3(-96.7, -4.7, 0)}, -- Hydraulics
    [10] = Vector3(0, 0, 0), -- Stereo
    [11] = Vector3(4.2, 2.1, 2.1), -- Unkonwn
    [12] = {Vector3(3.2, -1.7, 0), Vector3(-96.7, -4.7, 0)}, -- Wheels
    [13] = Vector3(0, -4.1, 0), -- Exhaust
    [14] = Vector3(0, 5.8, 0.2), -- Front Bumper
    [15] = Vector3(0, -6, 0.2), -- Rear Bumper
    [16] = Vector3(4.2, 2.1, 2.1), -- Misc
}

-- A piece of debug code | TODO: Remove soon
if DEBUG then
    local tuningGUI = false

    addCommandHandler("setvehicle",
        function(cmd, id)
            id = tonumber(id)
            if not id or id < 1 or id > 3 then
                return
            end

            if tuningGUI then
                delete(tuningGUI)
            end
            tuningGUI = VehicleTuningGUI:new(getElementByID("TuningVehicle"..id))
        end
    )
end
