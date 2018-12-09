-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Plane/PlaneAccident.lua
-- *  PURPOSE:     Plane Accident Class
-- *
-- ****************************************************************************

PlaneAccident = inherit(Plane)

function PlaneAccident:setAccidentPlane(flyingTime, colX, colY, colZ, colTime, standstillX, standstillY, standstillZ, standstillTime, fireX, fireY, fireWidth, fireHeight)
    if colX and colY and colZ and colTime then
        Timer(
            function()
                self.m_Object:move(colTime, colX, colY, colZ)
                self.m_Plane:setHealth(50)
                self.m_Plane:setEngineState(true)
            end
        , flyingTime, 1)

        if standstillX and standstillY and standstillZ and standstillTime then
            Timer(
                function()
                    self:explode()
                    self.m_Object:move(standstillTime, standstillX, standstillY, standstillZ, 0, 0, 0, "OutQuad")

                    Timer(
                        function()
                            self:explode()
                            self:createAccidentFire()
                            self:createRubble()
                        end
                    , standstillTime, 1)

                end
            , flyingTime + colTime, 1)
        end
        if DEBUG then
            getRandomPlayer():setPosition(standstillX, standstillY, standstillZ)
        end
    end
end

function PlaneAccident:createAccidentFire()
    local planePos = self.m_Plane:getPosition()
    local planeID = self.m_Plane:getModel()
    local zone = getZoneName(planePos.x, planePos.y, planePos.z)
    local city = getZoneName(planePos.x, planePos.y, planePos.z, true)
    FireManager:getSingleton().m_Fires[1000] = {
        ["name"] = ("Flugzeug Unfall: %s"):format(zone),
        ["message"] = ("Ein Flugzeugabsturz wurde in %s, %s gemeldet!"):format(zone, city),
        ["position"] = Vector3(planePos.x-PlaneSizeTable[planeID][1], planePos.y-PlaneSizeTable[planeID][2], planePos.z),
        ["positionTbl"] = {planePos.x-PlaneSizeTable[planeID][1], planePos.y-PlaneSizeTable[planeID][2], planePos.z},
        ["width"] = PlaneSizeTable[planeID][1] * 2,
        ["height"] = PlaneSizeTable[planeID][2] * 2,
        ["creator"] = "Flugzeug-Unfall",
        ["enabled"] = true,
    }
    FireManager:getSingleton():startFire(1000)
end

function PlaneAccident:createRubble()
    if isElement(self.m_Rubble) then
        self.m_Rubble:destroy()
    end
    for _, player in pairs(Element.getAllByType("player")) do
        player:triggerEvent("triggerClientPlaneDestroySmoke", self.m_Plane)
    end
    if #CompanyManager:getSingleton():getFromId(CompanyStaticId.MECHANIC):getOnlinePlayers() >= 1 then
        Timer(
            function()
                local planePos = self.m_Plane:getPosition()
                local planeRot = self.m_Plane:getRotation()
                self.m_Rubble = createObject(10985, planePos.x, planePos.y, planePos.z + PlaneRubbleOffsets[self.m_Plane:getModel()], planeRot.x, planeRot.y, planeRot.z + 45)
                self.m_IsRubbleBeingRemoved = false
                addEventHandler("onElementClicked", self.m_Rubble, bind(self.removeRubble, self))
                self.m_Plane:destroy()
                self.m_Object:destroy()
                self.m_Pilot:destroy()
            end
        , 10000, 1)
        self:createTrashTruck()
    else
        PlaneManager:getSingleton():endAccident()
    end
end

function PlaneAccident:removeRubble(button, state, player)
    if button == "left" and state == "down" then
        if source == self.m_Rubble then
            if player:getCompany():getId() == 2 and player:isCompanyDuty() then
                if self.m_IsRubbleBeingRemoved ~= true then
                    local playerPos = player:getPosition()
                    local rubblePos = source:getPosition()
                    local TruckPos = self.m_TrashTruck:getPosition()
                    if player:getContactElement() == self.m_Rubble then
                        if getDistanceBetweenPoints3D(playerPos.x, playerPos.y, playerPos.z, TruckPos.x, TruckPos.y, TruckPos.z) < 20 then
                            player:setAnimation("BOMBER", "BOM_Plant_Loop", -1, true, false, false)
                            toggleAllControls(player, false)
                            self.m_IsRubbleBeingRemoved = true
                            Timer(
                                function()
                                    local rubblePos = self.m_Rubble:getPosition()
                                    self.m_Rubble:setPosition(rubblePos.x, rubblePos.y, rubblePos.z-1)
                                end
                            , 5000, 3)

                            Timer(
                                function(player)
                                    self.m_Rubble:destroy()
                                    player:setAnimation()
                                    toggleAllControls(player, true)
                                    self.m_TrashTruck:setVariant(4, 2)
                                    self.m_TrashDeliveryMarker:setAlpha(255)
                                    self.m_TrashTruckLoaded = true
                                    player:sendInfo("Fahre nun die Überreste zurück zur Mech&Tow Base!")
                                    self.m_AccidentDeliveryBlip = Blip:new("Marker.png", 869.36, -1280.87, {company = 2}, 400, {255, 255, 255}, {175, 175, 175})
                                end
                            , 15100, 1, player)
                        else
                            player:sendError("Der Flatbed ist zu weit entfernt!")
                        end
                    else
                        player:sendError("Du musst auf den Wrackteilen stehen!")
                    end
                else
                    player:sendError("Die Wrackteile werden bereits verladen!")
                end
            else
                player:sendError("Du bist kein Mechaniker im Dienst!")
            end
        end
    end
end

function PlaneAccident:createTrashTruck()
    if isElement(self.m_TrashTruck) then
        self.m_TrashTruck:destroy()
    end
    self.m_TrashTruck = TemporaryVehicle.create(455, 869.36, -1280.87, 14.77, 0) -- <- Mech&Tow Flatbed
    self.m_TrashTruck:setData("TrashTruck", true, true)
    self.m_TrashTruck:toggleRespawn(false)
    self.m_TrashTruck:setVariant(4, 3)
    self.m_TrashTruck:setColor(90, 90, 90)
    self.m_TrashTruckLoaded = false

    addEventHandler("onVehicleStartEnter", self.m_TrashTruck, 
        function(player, seat)
            if player:getCompany() ~= CompanyManager:getSingleton():getFromId(CompanyStaticId.MECHANIC) then
                cancelEvent()
                player:sendError("Du darfst das Fahrzeug nicht benutzen!")
            end
        end
    )

    addEventHandler("onVehicleEnter", self.m_TrashTruck, 
        function(player)
            if self.m_TrashTruckLoaded == false then
                player:sendInfo("Fahre die Überreste des Flugzeugunfalls zurück hierher! Klicke auf die Überreste des Flugzeugs um sie auf den Flatbed aufzuladen!")
            end
        end
    )

    self.m_TrashDeliveryMarker = Marker(869.36, -1280.87, 13.3, "cylinder", 4.0, 255, 0, 0, 0)

    local planePos = self.m_Plane:getPosition()
    local zone = getZoneName(planePos.x, planePos.y, planePos.z)
    CompanyManager:getSingleton():getFromId(CompanyStaticId.MECHANIC):sendWarning("Ein Mechaniker wird mit dem Flatbed aus der Base am Unfallort benötigt! Position: %s", "Flugzeug-Wrack", true, planePos, zone)

    addEventHandler("onMarkerHit", self.m_TrashDeliveryMarker, 
        function(hitElement, matchingDim)
            if matchingDim then
                if hitElement == self.m_TrashTruck then
                    if self.m_TrashTruckLoaded == true then
                        if hitElement.controller then
                            CompanyManager:getSingleton():getFromId(CompanyStaticId.MECHANIC):transferMoney(hitElement.controller, 5000, "Flugzeug-Wrack Abgabe", "Company", "Plane accident removal", {silent = true})
                        end
                        self.m_TrashTruck:destroy()
                        self.m_TrashDeliveryMarker:destroy()
                        self.m_AccidentDeliveryBlip:delete()
                        PlaneManager:getSingleton():endAccident()
                    end
                end
            end
        end
    )
end

function PlaneAccident:explode()
    local planePos = self.m_Plane:getPosition()
    local forwardVector = self.m_Plane.matrix.forward
    local rightVector = self.m_Plane.matrix.right
    local vehicleID = self.m_Plane:getModel()

    createExplosion(planePos.x, planePos.y, planePos.z, 23)
    if PlaneExplosionSizes[vehicleID] == 2 then
        createExplosion(planePos.x + forwardVector.x*5, planePos.y + forwardVector.y*5, planePos.z + forwardVector.z*5, 23)
        createExplosion(planePos.x + forwardVector.x*-5, planePos.y + forwardVector.y*-5, planePos.z + forwardVector.z*-5, 23)
        createExplosion(planePos.x + rightVector.x*5, planePos.y + rightVector.y*5, planePos.z + rightVector.z*5, 23)
        createExplosion(planePos.x + rightVector.x*-5, planePos.y + rightVector.y*-5, planePos.z + rightVector.z*-5, 23)
    elseif PlaneExplosionSizes[vehicleID] == 3 then
        createExplosion(planePos.x + forwardVector.x*15, planePos.y + forwardVector.y*15, planePos.z + forwardVector.z*15, 23)
        createExplosion(planePos.x + forwardVector.x*-15, planePos.y + forwardVector.y*-15, planePos.z + forwardVector.z*-15, 23)
        createExplosion(planePos.x + rightVector.x*15, planePos.y + rightVector.y*15, planePos.z + rightVector.z*15, 23)
        createExplosion(planePos.x + rightVector.x*-15, planePos.y + rightVector.y*-15, planePos.z + rightVector.z*-15, 23)
    elseif PlaneExplosionSizes[vehicleID] == 4 then
        createExplosion(planePos.x + forwardVector.x*15, planePos.y + forwardVector.y*15, planePos.z + forwardVector.z*15, 23)
        createExplosion(planePos.x + forwardVector.x*-15, planePos.y + forwardVector.y*-15, planePos.z + forwardVector.z*-15, 23)
        createExplosion(planePos.x + rightVector.x*15, planePos.y + rightVector.y*15, planePos.z + rightVector.z*15, 23)
        createExplosion(planePos.x + rightVector.x*-15, planePos.y + rightVector.y*-15, planePos.z + rightVector.z*-15, 23)
        createExplosion(planePos.x + rightVector.x*25, planePos.y + rightVector.y*25, planePos.z + rightVector.z*25, 23)
        createExplosion(planePos.x + rightVector.x*-25, planePos.y + rightVector.y*-25, planePos.z + rightVector.z*-25, 23)
    end
end