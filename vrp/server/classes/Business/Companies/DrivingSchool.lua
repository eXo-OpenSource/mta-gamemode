DrivingSchool = inherit(Company)

function DrivingSchool:constructor()
    outputDebug(("[%s] Extra-class successfully loaded! (Id: %d)"):format(self:getName(), self:getId()))
    self:createDrivingSchoolMarker(Vector3(1362.04, -1663.74, 13.57))

    VehicleBarrier:new(Vector3(1413.59, -1653.09, 13.30), Vector3(0, 90, 88)).onBarrierHit = bind(self.onBarrierHit, self)
    VehicleBarrier:new(Vector3(1345.19, -1722.80, 13.39), Vector3(0, 90, 0)).onBarrierHit = bind(self.onBarrierHit, self)
    VehicleBarrier:new(Vector3(1354.80, -1591.00, 13.39), Vector3(0, 90, 161), 0).onBarrierHit = bind(self.onBarrierHit, self)

    addRemoteEvents{"drivingSchoolMenu"}
    addEventHandler("drivingSchoolMenu", root, bind(self.Event_drivingSchoolMenu, self))

end

function DrivingSchool:destructor()
end

function DrivingSchool:onVehicleSpawn(veh)
    -- Adjust Color and Owner Text
    veh:setData("OwnerName", self:getName(), true)
    veh:setColor(255, 255, 255)

    -- Adjust variant
    if veh:getModel() == 521 then
        veh:setVariant(4, 4)
    end
end

function DrivingSchool:onVehiceEnter(player)
    if player:getCompany() ~= self then
        player:sendError(_("Du darfst dieses Fahrzeug nicht fahren!", player))
        return false
    end
    return true
end

function DrivingSchool:onBarrierHit(player)
    if player:getCompany() ~= self then
        player:sendError(_("Zufahrt Verboten!", player))
        return false
    end
    return true
end

function DrivingSchool:createDrivingSchoolMarker(pos)
    self.m_DrivingSchoolPickup = createPickup(pos, 3, 1239)
    addEventHandler("onPickupHit", self.m_DrivingSchoolPickup,
        function(hitElement)
            if getElementType(hitElement) == "player" then
                hitElement:triggerEvent("showDrivingSchoolMenu")
            end
            cancelEvent()
        end
    )
end

function DrivingSchool:Event_drivingSchoolMenu(func)

    if func == "callInstructor" then
        client:sendInfo(_("Alle Fahrlehrer werden gerufen!",client))
        self:sendMessage(_("Der Spieler %s sucht einen Fahrlehrer! Bitte melden!",client, client.name), 255, 125, 0)

    elseif func == "showInstructor" then
        outputChatBox(_("Folgende Fahrlehrer sind online:",client), client, 255, 255, 255)
        for k, player in pairs(self:getOnlinePlayers()) do
            outputChatBox(player.name,client,255,125,0)
        end
    end
end
