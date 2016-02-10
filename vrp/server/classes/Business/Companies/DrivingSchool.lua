DrivingSchool = inherit(Company)
DrivingSchool.LicenseCosts = {["car"] = 1500, ["bike"] = 750, ["truck"] = 4000, ["heli"] = 15000, ["plane"] = 20000 }

function DrivingSchool:constructor()
    outputDebug(("[%s] Extra-class successfully loaded! (Id: %d)"):format(self:getName(), self:getId()))
    self:createDrivingSchoolMarker(Vector3(1362.04, -1663.74, 13.57))

    self.m_CurrentLicenseTypes = {}

    VehicleBarrier:new(Vector3(1413.59, -1653.09, 13.30), Vector3(0, 90, 88)).onBarrierHit = bind(self.onBarrierHit, self)
    VehicleBarrier:new(Vector3(1345.19, -1722.80, 13.39), Vector3(0, 90, 0)).onBarrierHit = bind(self.onBarrierHit, self)
    VehicleBarrier:new(Vector3(1354.80, -1591.00, 13.39), Vector3(0, 90, 161), 0).onBarrierHit = bind(self.onBarrierHit, self)

    addRemoteEvents{"drivingSchoolMenu", "drivingSchoolStartLession", "drivingSchoolEndLession"}
    addEventHandler("drivingSchoolMenu", root, bind(self.Event_drivingSchoolMenu, self))
    addEventHandler("drivingSchoolStartLession", root, bind(self.Event_startLession, self))
    addEventHandler("drivingSchoolEndLession", root, bind(self.Event_endLession, self))
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
            outputChatBox(("%s %s"):format(player.name, player:getPublicSync("Company:Duty") and _("%s(Im Dienst)", client, "#357c01") or _("%s(Nicht im Dienst)", client, "#870000")), client, 255, 125, 0, true)
        end
    end
end

function DrivingSchool:checkPlayerLicense(player, type)
    if type == "car" then
        return player.m_HasDrivingLicense
    elseif type == "bike" then
        return player.m_HasBikeLicense
    elseif type == "truck" then
        return player.m_HasTruckLicense
    elseif type == "heli" then
        return player.m_HasPilotsLicense
    elseif type == "plane" then
        return player.m_HasPilotsLicense
    end
end

function DrivingSchool:givePlayerLicense(player, type)
    if type == "car" then
        player.m_HasDrivingLicense = true
    elseif type == "bike" then
        player.m_HasBikeLicense = true
    elseif type == "truck" then
        player.m_HasTruckLicense = true
    elseif type == "heli" then
        player.m_HasPilotsLicense = true
    elseif type == "plane" then
        player.m_HasPilotsLicense = true
    end
end

function DrivingSchool:Event_startLession(target, type)
    local costs = DrivingSchool.LicenseCosts[type]
    if costs then
        if target then
            if self:checkPlayerLicense(target, type) == false then
                if target:getMoney() >= costs then
                    if not target:getPublicSync("inDrivingLession") == true then
                        target:takeMoney(costs)
                        self:setMoney(self:getMoney() + math.floor(costs/5))
                        self.m_CurrentLicenseTypes[target] = type
                        target:setPublicSync("inDrivingLession",true)
                        client:sendInfo(_("Du hast die Prüfung mit %s gestartet!", client, target.name))
                        target:sendInfo(_("Fahrlehrer %s hat die Prüfung mit dir gestartet, Folge seinen Anweisungen!", target, client.name))
                    else
                        client:sendError(_("Der Spieler %s ist bereits in einer Fahrprüfung!", client, target.name))
                        target:sendError(_("Du bist bereits in einer Fahrprüfung!", target))
                    end
                else
                    client:sendError(_("Der Spieler %s hat nicht genug Geld dabei! (%d$)", client, target.name, costs))
                    target:sendError(_("Du hast nicht genug Geld dabei! (%d$)", target, costs))
                end
            else
                client:sendError(_("Der Spieler %s hat diesen Schein bereits!", client, target.name))
                target:sendError(_("Du hast diesen Schein bereits!", target))
            end
        else
            client:sendError(_("Interner Fehler: Der Spieler wurde nicht gefunden!", client, target))
        end
    else
        client:sendError(_("Interner Fehler: Falscher Führerschein-Typ!", client))
    end
end

function DrivingSchool:Event_endLession(target, success)
    if success == true then
        local type = self.m_CurrentLicenseTypes[target]
        self:givePlayerLicense(target, type)
        target:sendInfo(_("Du hast die Fahrprüfung erfolgreich bestanden und den Schein erhalten!",target))
        client:sendInfo(_("Du hast die Fahrprüfung mit %s erfolgreich beendet!",client, target.name))
        target:setPublicSync("inDrivingLession",false)
        self.m_CurrentLicenseTypes[target] = nil
    else
        target:sendError(_("Du hast die Fahrprüfung nicht geschaft! Viel Glück beim nächsten Mal!",target))
        client:sendInfo(_("Du hast die Fahrprüfung mit %s abgebrochen!",client, target.name))
        target:setPublicSync("inDrivingLession",false)
        self.m_CurrentLicenseTypes[target] = nil
    end
end
