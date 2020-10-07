-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/HelicopterDrivebyManager.lua
-- *  PURPOSE:     provide ability to perform a drive by on a helicopter
-- *
-- ****************************************************************************

HelicopterDrivebyManager = inherit(Singleton)
HelicopterDrivebyManager.SeatOffsets = {
    {1.2, 1.5, 0},
    {-1.2, 0, 0},
    {1.2, 0, 0}
}
addRemoteEvents{"startHelicopterDriveby", "endHelicopterDriveby"}

function HelicopterDrivebyManager:constructor()
    self.m_StartBind = bind(self.startDriveby, self)
    self.m_EndBind = bind(self.endDriveby, self)

    addEventHandler("startHelicopterDriveby", root, self.m_StartBind)
    addEventHandler("endHelicopterDriveby", root, self.m_EndBind)
end

function HelicopterDrivebyManager:startDriveby()
    if client.vehicle and client.vehicleSeat > 0 then
        client.m_HelicopterDrivebyVehicle = client.vehicle
        client.m_HelicopterDrivebySeat = client.vehicleSeat

        client:removeFromVehicle()
        client:attach(client.m_HelicopterDrivebyVehicle, unpack(HelicopterDrivebyManager.SeatOffsets[client.m_HelicopterDrivebySeat]))
        client:triggerEvent("setHelicopterDrivebyCameraClip")

        client:setPublicSync("isDoingHelicopterDriveby", true)
    end
end

function HelicopterDrivebyManager:endDriveby()
    if client:getPublicSync("isDoingHelicopterDriveby") then
        if not isElement(client.m_HelicopterDrivebyVehicle) then
            client.m_HelicopterDrivebyVehicle = nil
            client.m_HelicopterDrivebySeat = nil
            client:setPublicSync("isDoingHelicopterDriveby", false)
            return
        end

        if client.m_HelicopterDrivebyVehicle:getOccupant(client.m_HelicopterDrivebySeat) then
            local newSeat = false
            for i = 1, 3 do
                if not client.m_HelicopterDrivebyVehicle:getOccupant(i) then
                    client.m_HelicopterDrivebySeat = i
                    newSeat = true
                end
            end
            if not newSeat then
                client:sendError(_("Der Helikopter ist voll!", client))
                return
            end
        end

        client:detach()
        client:warpIntoVehicle(client.m_HelicopterDrivebyVehicle, client.m_HelicopterDrivebySeat)
        client:triggerEvent("setHelicopterDrivebyCameraClip")

        client.m_HelicopterDrivebyVehicle = nil
        client.m_HelicopterDrivebySeat = nil
        client:setPublicSync("isDoingHelicopterDriveby", false)
    end
end