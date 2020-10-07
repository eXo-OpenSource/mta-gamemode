-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicles/Extensions/HelicopterDrivebyManager.lua
-- *  PURPOSE:     provide ability to perform a drive by on a helicopter
-- *
-- ****************************************************************************

HelicopterDrivebyManager = inherit(Singleton)
HelicopterDrivebyManager.AvailableVehicles = {
	[487] = true,
	[488] = true,
	[497] = true,
	[447] = true,
	[469] = true
}
addRemoteEvents{"setHelicopterDrivebyCameraClip"}

function HelicopterDrivebyManager:constructor()
    addEventHandler("setHelicopterDrivebyCameraClip", root, bind(self.setCameraClip, self))
end

function HelicopterDrivebyManager:tryDriveby()
    if localPlayer.vehicle and HelicopterDrivebyManager.AvailableVehicles[localPlayer.vehicle:getModel()] and localPlayer:getTask("primary", 4) ~= "TASK_COMPLEX_ENTER_CAR_AS_PASSENGER" then
        triggerServerEvent("startHelicopterDriveby", localPlayer)
    else
        if localPlayer:getPublicSync("isDoingHelicopterDriveby") then
            triggerServerEvent("endHelicopterDriveby", localPlayer)
        else
            ErrorBox:new(_"Du sitzt nicht in einem Helikopter!")
        end
    end
end

function HelicopterDrivebyManager:setCameraClip()
    setCameraClip(true, true)
end