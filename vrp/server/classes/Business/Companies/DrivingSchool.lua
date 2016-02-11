DrivingSchool = inherit(Company)
DrivingSchool.LicenseCosts = {["car"] = 1500, ["bike"] = 750, ["truck"] = 4000, ["heli"] = 15000, ["plane"] = 20000 }
DrivingSchool.TypeNames = {["car"] = "Autoführerschein", ["bike"] = "Motorradschein", ["truck"] = "LKW-Schein", ["heli"] = "Helikopterschein", ["plane"] = "Flugschein" }

function DrivingSchool:constructor()
    outputDebug(("[%s] Extra-class successfully loaded! (Id: %d)"):format(self:getName(), self:getId()))
    self:createDrivingSchoolMarker(Vector3(1362.04, -1663.74, 13.57))

    self.m_CurrentLessions = {}

    VehicleBarrier:new(Vector3(1413.59, -1653.09, 13.30), Vector3(0, 90, 88)).onBarrierHit = bind(self.onBarrierHit, self)
    VehicleBarrier:new(Vector3(1345.19, -1722.80, 13.39), Vector3(0, 90, 0)).onBarrierHit = bind(self.onBarrierHit, self)
    VehicleBarrier:new(Vector3(1354.80, -1591.00, 13.39), Vector3(0, 90, 161), 0).onBarrierHit = bind(self.onBarrierHit, self)

    addRemoteEvents{"drivingSchoolMenu", "drivingSchoolstartLessionQuestion", "drivingSchoolDiscardLession", "drivingSchoolStartLession", "drivingSchoolEndLession", "drivingSchoolReceiveTurnCommand"}
    addEventHandler("drivingSchoolMenu", root, bind(self.Event_drivingSchoolMenu, self))
    addEventHandler("drivingSchoolDiscardLession", root, bind(self.Event_discardLession, self))
    addEventHandler("drivingSchoolstartLessionQuestion", root, bind(self.Event_startLessionQuestion, self))
    addEventHandler("drivingSchoolStartLession", root, bind(self.Event_startLession, self))
    addEventHandler("drivingSchoolEndLession", root, bind(self.Event_endLession, self))
    addEventHandler("drivingSchoolReceiveTurnCommand", root, bind(self.Event_receiveTurnCommand, self))
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

function DrivingSchool:Event_startLessionQuestion(target, type)
    target:triggerEvent("questionBox", _("Der Fahrlehrer %s möchte mit dir die %s Prüfung starten!\nDiese kostet %d$! Möchtest du die Prüfung starten?", target, client.name, DrivingSchool.TypeNames[type], DrivingSchool.LicenseCosts[type]), "drivingSchoolStartLession", "drivingSchoolDiscardLession", target, type)
end

function DrivingSchool:Event_discardLession(target, type)
    client:sendError(_("Der Spieler %s hat die %s Prüfung abgelehnt!", client, target.name, DrivingSchool.TypeNames[type]))
    target:sendError(_("Du hast die %s Prüfung mit %s abgelehnt!", target, DrivingSchool.TypeNames[type], client.name))
end

function DrivingSchool:Event_startLession(target, type)
    local costs = DrivingSchool.LicenseCosts[type]
    if costs then
        if target then
            if self:checkPlayerLicense(target, type) == false then
                if target:getMoney() >= costs then
                    if not target:getPublicSync("inDrivingLession") == true then
                        if not self.m_CurrentLessions[client] then
                            self.m_CurrentLessions[client] = {
                                ["target"] = target, ["type"] = type, ["instructor"] = client
                            }
                            target:takeMoney(costs)
                            self:setMoney(self:getMoney() + math.floor(costs/5))
                            target:setPublicSync("inDrivingLession",true)
                            client:sendInfo(_("Du hast die %s Prüfung mit %s gestartet!", client, DrivingSchool.TypeNames[type], target.name))
                            target:sendInfo(_("Fahrlehrer %s hat die %s Prüfung mit dir gestartet, Folge seinen Anweisungen!", target, client.name, DrivingSchool.TypeNames[type]))
                            target:triggerEvent("showDrivingSchoolStudentGUI", DrivingSchool.TypeNames[type])
                            client:triggerEvent("showDrivingSchoolInstructorGUI", DrivingSchool.TypeNames[type], target)
                        else
                            client:sendError(_("Du bist bereits in einer Fahrprüfung!", client))
                        end
                    else
                        client:sendError(_("Der Spieler %s ist bereits in einer Prüfung!", client, target.name))
                        target:sendError(_("Du bist bereits in einer Prüfung!", target))
                    end
                else
                    client:sendError(_("Der Spieler %s hat nicht genug Geld dabei! (%d$)", client, target.name, costs))
                    target:sendError(_("Du hast nicht genug Geld dabei! (%d$)", target, costs))
                end
            else
                client:sendError(_("Der Spieler %s hat den %s bereits!", client, target.name, DrivingSchool.TypeNames[type]))
                target:sendError(_("Du hast den %s bereits!", target, DrivingSchool.TypeNames[type]))
            end
        else
            client:sendError(_("Interner Fehler: Der Spieler wurde nicht gefunden!", client, target))
        end
    else
        client:sendError(_("Interner Fehler: Falscher Führerschein-Typ!", client))
    end
end

function DrivingSchool:Event_endLession(target, success)
    local type = self.m_CurrentLessions[client]["type"]
    if success == true then
        self:givePlayerLicense(target, type)
        target:sendInfo(_("Du hast die %s Prüfung erfolgreich bestanden und den Schein erhalten!",target, DrivingSchool.TypeNames[type]))
        client:sendInfo(_("Du hast die %s Prüfung mit %s erfolgreich beendet!",client, DrivingSchool.TypeNames[type], target.name))
    else
        target:sendError(_("Du hast die %s Prüfung nicht geschaft! Viel Glück beim nächsten Mal!",target, DrivingSchool.TypeNames[type]))
        client:sendInfo(_("Du hast die %s Prüfung mit %s abgebrochen!",client, DrivingSchool.TypeNames[type], target.name))
    end

    target:triggerEvent("hideDrivingSchoolStudentGUI")
    client:triggerEvent("hideDrivingSchoolInstructorGUI")
    target:setPublicSync("inDrivingLession",false)
    self.m_CurrentLessions[client] = nil
end

function DrivingSchool:Event_receiveTurnCommand(turnCommand)
    local target = self.m_CurrentLessions[client]["target"]
    if target then
        target:triggerEvent("drivingSchoolChangeDirection", turnCommand)
    end
end
