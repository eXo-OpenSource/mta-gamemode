DrivingSchool = inherit(Company)
DrivingSchool.LicenseCosts = {["car"] = 1500, ["bike"] = 750, ["truck"] = 4000, ["heli"] = 15000, ["plane"] = 20000 }
DrivingSchool.TypeNames = {["car"] = "Autoführerschein", ["bike"] = "Motorradschein", ["truck"] = "LKW-Schein", ["heli"] = "Helikopterschein", ["plane"] = "Flugschein"}
DrivingSchool.m_LessonVehicles = {}
DrivingSchool.testRoute =
{
	--{1355.07, -1621.64, 13.22, 90} .. start
	{1378.94, -1648.58, 13.03},
	{1421.00, -1648.88, 13.03},
	{1427.45, -1719.98, 13.04},
	{1327.79, -1730.02, 13.04},
	{1310.11, -1575.86, 13.04},
	{1349.55, -1399.87, 12.97},
	{1106.99, -1392.60, 13.12},
	{804.73, -1393.98, 13.14},
	{650.62, -1397.89, 13.04},
	{625.97, -1534.58, 14.72},
	{651.80, -1674.67, 14.15},
	{796.70, -1676.98, 13.01},
	{819.15, -1641.51, 13.04},
	{1019.96, -1574.58, 13.04},
	{1048.16, -1516.02, 13.04},
	{1065.41, -1419.91, 13.08},
	{1060.16, -1276.25, 13.40},
	{1060.41, -1161.71, 23.36},
	{1323.85, -1148.96, 23.3},
	{1444.42, -1163.26, 23.31},
	{1451.98, -1285.99, 13.04},
	{1700.87, -1305.06, 13.10},
	{1712.74, -1427.98, 13.04},
	{1468.86, -1438.64, 13.04},
	{1427.40, -1577.95, 13.02},
	{1515.72, -1595.33, 13.03},
	{1527.44, -1718.88, 13.04},
	{1439.76, -1729.61, 13.04},
	{1431.99, -1659.23, 13.04},
	{1372.90, -1648.60, 13.04},
}

addRemoteEvents{"drivingSchoolCallInstructor", "drivingSchoolStartTheory", "drivingSchoolPassTheory", "drivingSchoolStartAutomaticTest", "drivingSchoolHitRouteMarker",	"drivingSchoolStartLessionQuestion", "drivingSchoolEndLession", "drivingSchoolReceiveTurnCommand", "drivingSchoolReduceSTVO"}

function DrivingSchool:constructor()
    InteriorEnterExit:new(Vector3(1364.14, -1669.10, 13.55), Vector3(-2026.93, -103.89, 1035.17), 90, 180, 3, 0, false)

	Gate:new(968, Vector3(1413.59, -1653.09, 13.30), Vector3(0, 90, 90), Vector3(1413.59, -1653.09, 13.30), Vector3(0, 5, 90), false).onGateHit = bind(self.onBarrierHit, self)

    self.m_OnQuit = bind(self.Event_onQuit,self)
	self.m_StartLession = bind(self.startLession, self)
	self.m_DiscardLession = bind(self.discardLession, self)
	self.m_BankAccountServer = BankServer.get("company.driving_school")

    local safe = createObject(2332, -2032.70, -113.70, 1036.20)
    safe:setInterior(3)
	self:setSafe(safe)

	local id = self:getId()
	local blip = Blip:new("DrivingSchool.png", 1364.14, -1669.10, root, 400, {companyColors[id].r, companyColors[id].g, companyColors[id].b})
	blip:setDisplayText(self:getName(), BLIP_CATEGORY.Company)

	self.m_CurrentLessions = {}

	addEventHandler("drivingSchoolCallInstructor", root, bind(DrivingSchool.Event_callInstructor, self))
	addEventHandler("drivingSchoolStartTheory", root, bind(DrivingSchool.Event_startTheory, self))
	addEventHandler("drivingSchoolPassTheory", root, bind(DrivingSchool.Event_passTheory, self))

	addEventHandler("drivingSchoolStartAutomaticTest", root, bind(DrivingSchool.Event_startAutomaticTest, self))
	addEventHandler("drivingSchoolHitRouteMarker", root, bind(DrivingSchool.onHitRouteMarker, self))
	addEventHandler("drivingSchoolStartLessionQuestion", root, bind(DrivingSchool.Event_startLessionQuestion, self))

    addEventHandler("drivingSchoolEndLession", root, bind(DrivingSchool.Event_endLession, self))
    addEventHandler("drivingSchoolReceiveTurnCommand", root, bind(DrivingSchool.Event_receiveTurnCommand, self))
	addEventHandler("drivingSchoolReduceSTVO", root, bind(DrivingSchool.Event_reduceSTVO, self))
end

function DrivingSchool:destructor()
end

function DrivingSchool:onVehicleEnter(vehicle, player, seat)
	if seat == 0 then return end
	if not self.m_CurrentLessions[player] then return end

	if self.m_CurrentLessions[player].vehicle ~= vehicle then
		self.m_CurrentLessions[player].vehicle = vehicle
		self.m_CurrentLessions[player].startMileage = vehicle:getMileage()
		player:setPrivateSync("instructorData", {vehicle = vehicle, startMileage = vehicle:getMileage()})
	end
end

function DrivingSchool:onBarrierHit(player)
	if player.vehicle and player.vehicle.m_IsAutoLesson then
		return true
	end

	if player:getCompany() ~= self then
		return false
	end

	return true
end

function DrivingSchool:Event_callInstructor()
	client:sendInfo(_("Die Fahrschule wurde kontaktiert. Ein Fahrlehrer wird sich bald bei dir melden!",client))
	self:sendShortMessage(_("Der Spieler %s sucht einen Fahrlehrer! Bitte melden!", client, client.name))
end

function DrivingSchool:Event_startTheory()
	if client.m_HasTheory then
		client:sendWarning(_("Du hast die Theorieprüfung bereits bestanden!", client))
		return
	end

	QuestionBox:new(client, client, _("Möchtest du die Theorie-Prüfung starten? Kosten: 300$", client),
		function(player)
			if not player:transferMoney(self.m_BankAccountServer, 300, "Fahrschule Theorie", "Company", "License") then
				player:sendError(_("Du hast nicht genug Geld dabei!", player))
				return
			end

			player:triggerEvent("showDrivingSchoolTest")
		end,
		function() end,
		client
	)
end

function DrivingSchool:Event_passTheory(pass)
	if pass then
		client.m_HasTheory = true
		client:sendInfo(_("Du kannst nun die praktische Prüfung machen!", client))
	else
		client:sendInfo(_("Du hast abgebrochen oder nicht bestanden! Versuche die Prüfung erneut!", client))
	end
end

function DrivingSchool:Event_startAutomaticTest(type)
	if not client.m_HasTheory then
		client:sendWarning(_("Du hast die Theorieprüfung noch nicht bestanden!", client))
		return
	end

	if #self:getOnlinePlayers() >= 3 then
		client:sendWarning(_("Es sind genügend Fahrlehrer online!", client))
		return
	end

	local valid = {["car"]= true, ["bike"] = true }
	if not valid[type] then return end

	if type == "car" and client.m_HasDrivingLicense then
		client:sendWarning(_("Du hast bereits den Autoführerschein", client))
		return
	end

	if type == "bike" and client.m_HasBikeLicense then
		client:sendWarning(_("Du hast bereits den Motorradführerschein", client))
		return
	end

	QuestionBox:new(client, client, _("Möchtest du die automatische Fahrprüfung starten? Kosten: %s$", client, DrivingSchool.LicenseCosts[type]),
		function(player, type)
			if player:getMoney() <  DrivingSchool.LicenseCosts[type] then
				player:sendError(_("Du hast nicht genug Geld dabei!", player))
				return
			end
			player:transferMoney(self.m_BankAccountServer, DrivingSchool.LicenseCosts[type], ("%s-Prüfung"):format(DrivingSchool.TypeNames[type]), "Company", "License")

			player.m_AutoTestMode = type
			self:startAutomaticTest(player, type)
		end,
		function() end,
		client, type
	)
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

function DrivingSchool:setPlayerLicense(player, type, bool)
	if type == "car" then
		player.m_HasDrivingLicense = bool
	elseif type == "bike" then
		player.m_HasBikeLicense = bool
	elseif type == "truck" then
		player.m_HasTruckLicense = bool
	elseif type == "heli" then
		player.m_HasPilotsLicense = bool
	elseif type == "plane" then
		player.m_HasPilotsLicense = bool
	end
end

function DrivingSchool:getLessionFromStudent(player)
	for index, key in pairs(self.m_CurrentLessions) do
		if key["target"] == player then return key end
	end
	return false
end

function DrivingSchool:startAutomaticTest(player, type)
	if DrivingSchool.m_LessonVehicles[player] then
		player:triggerEvent("DrivingLesson:endLesson")
		if DrivingSchool.m_LessonVehicles[player].m_NPC then
			if isElement(DrivingSchool.m_LessonVehicles[player].m_NPC ) then
				destroyElement(DrivingSchool.m_LessonVehicles[player].m_NPC)
			end
		end
		destroyElement(DrivingSchool.m_LessonVehicles[player])
	end

	local veh  = TemporaryVehicle.create(type == "car" and 410 or 586, 1355.07, -1621.64, 14.22, 90)
	veh:setColor(255, 255, 255)
	veh.m_Driver = player
	veh.m_CurrentNode = 1
	veh.m_IsAutoLesson = true
	veh.m_TestMode = type

	player:setPosition(Vector3(1348.97, -1620.68, 13.60))
	player:setInterior(0)
	player:setCameraTarget(player)

	local randomName =	{"Nero Soliven", "Kempes Waldemar", "Avram Vachnadze", "Klaus Schweiger", "Luca Pasqualini", "Peter Schmidt", "Mohammed Vegas", "Isaha Rosenberg"}
	local name = randomName[math.random(1, #randomName)]
	veh.m_NPC = createPed(295,1355.07, -1621.64, 13.22)
	veh.m_NPC:setData("NPC:Immortal", true, true)
	veh.m_NPC:setData("isBuckeled", true, true)
	veh.m_NPC:setData("Ped:fakeNameTag", name, true)
	veh.m_NPC:setData("isDrivingCoach", true)
	veh.m_NPC:warpIntoVehicle(veh, 1)

	player:sendInfo("Steige in das Fahrzeug vor dir.")

	addEventHandler("onVehicleStartEnter", veh,
		function(player, seat)
			if source.m_Driver == player then
				if seat == 0 then
					outputChatBox(_("Fahre die vorgesehene Strecke ab und achte darauf, dass dein Fahrzeug nicht beschädigt wird!", player), player, 200, 200, 0)
					outputChatBox(_("%s sagt: Mit 'X' schaltest du den Motor an.", player, name), player, 200, 200, 200)

					setTimer(outputChatBox, 2000, 1, _("%s sagt: Anschließend mit 'L' die Lichter.", player, name) , player, 200, 200, 200)
					setTimer(outputChatBox, 8000, 1, _("%s sagt: Und abgeht es! Vergiss nicht den Limiter mit der Taste 'K' anzuschalten.", player, name) , player, 200, 200, 200)

					if player.m_AutoTestMode == "car" then
						setTimer(outputChatBox, 4000, 1, _("%s sagt: Nun Anschnallen mit 'M'", player, name) , player, 200, 200, 200)
					else
						setTimer(outputChatBox, 4000, 1, _("%s sagt: Ziehe deinen Helm an.", player, name) , player, 200, 200, 200)
					end
				end
			else
				cancelEvent()
			end
		end
	)

	addEventHandler("onVehicleExit", veh,
		function(player, seat)
			if seat ~= 0 then return end
			if not source.m_IsFinished then
				outputChatBox("Du hast das Fahrzeug verlassen und die Prüfung beendet!", player, 200,0,0)
			end
			if DrivingSchool.m_LessonVehicles[player] == source then
				DrivingSchool.m_LessonVehicles[player] = nil
				if source.m_NPC then
					destroyElement(source.m_NPC)
				end
				destroyElement(source)
			end
			player:triggerEvent("DrivingLesson:endLesson")
			fadeCamera(player,false,0.5)
			setTimer(setElementPosition,1000,1,player,1348.97, -1620.68, 13.60)
			setTimer(fadeCamera,1500,1, player,true,0.5)
		end
	)

	addEventHandler("onVehicleExplode",veh,
		function()
			local player = getVehicleOccupant(source)
			if DrivingSchool.m_LessonVehicles[player] == source then
			local alreadyFinished = source.m_IsFinished
				DrivingSchool.m_LessonVehicles[player] = nil
				if source.m_NPC then
					destroyElement(source.m_NPC)
				end
				destroyElement(source)
			end
			player:triggerEvent("DrivingLesson:endLesson")
			fadeCamera(player,false,0.5)
			setTimer(setElementPosition,1000,1,player,1348.97, -1620.68, 13.60)
			setTimer(fadeCamera,1500,1, player,true,0.5)
			if not alreadyFinished then
				outputChatBox("Du hast das Fahrzeug zerstört!", player, 200,0,0)
			end
		end
	)

	addEventHandler("onElementDestroy", veh,
		function()
			local player = getVehicleOccupant(source)
			if player then
				if DrivingSchool.m_LessonVehicles[player] == source then
					DrivingSchool.m_LessonVehicles[player] = nil
					if not source.m_IsFinished then
						outputChatBox("Du hast das Fahrzeug verlassen und die Prüfung beendet!", player, 200,0,0)
					end
					if source.m_NPC then
						if isElement(source.m_NPC) then
							destroyElement(source.m_NPC)
						end
					end
				end
				player:triggerEvent("DrivingLesson:endLesson")
				fadeCamera(player,false,0.5)
				setTimer(setElementPosition,1000,1,player,1348.97, -1620.68, 13.60)
				setTimer(fadeCamera,1500,1, player,true,0.5)
			end
		end, false
	)

	player:triggerEvent("DrivingLesson:setMarker", DrivingSchool.testRoute[veh.m_CurrentNode], veh)
	DrivingSchool.m_LessonVehicles[player] = veh
end

function DrivingSchool:onHitRouteMarker()
	if DrivingSchool.m_LessonVehicles[client] then
		local veh = DrivingSchool.m_LessonVehicles[client]
		veh.m_CurrentNode = veh.m_CurrentNode + 1
		if veh.m_CurrentNode <= #DrivingSchool.testRoute then
			client:triggerEvent("DrivingLesson:setMarker",DrivingSchool.testRoute[veh.m_CurrentNode], veh)
		else
			veh.m_IsFinished = true
			if getElementHealth(veh) >= 500 then
				if veh.m_TestMode == "car" then
					client.m_HasDrivingLicense = true
				else
					client.m_HasBikeLicense = true
				end
				outputChatBox("Du hast die Prüfung bestanden und dein Fahrzeug ist in einem ausreichenden Zustand!", client, 0, 200, 0)
				if veh.m_NPC then
					destroyElement(veh.m_NPC)
				end
				destroyElement(veh)
				DrivingSchool.m_LessonVehicles[client] = nil
				client:triggerEvent("DrivingLesson:endLesson")
			else
				client.m_HasDrivingLicense = false
				outputChatBox("Da dein Fahrzeug zu beschädigt war hast du nicht bestanden!", client, 200, 0, 0)
				if veh.m_NPC then
					destroyElement(veh.m_NPC)
				end
				destroyElement(veh)
				DrivingSchool.m_LessonVehicles[client] = nil
				client:triggerEvent("DrivingLesson:endLesson")
			end
		end
	end
end

function DrivingSchool:Event_startLessionQuestion(target, type)
    local costs = DrivingSchool.LicenseCosts[type]
    if costs and target then
        if not self:checkPlayerLicense(target, type) then
			if target.m_HasTheory then
				if target:getMoney() >= costs then
					if not target:getPublicSync("inDrivingLession") then
						if not self.m_CurrentLessions[client] then
							QuestionBox:new(client, target, _("Der Fahrlehrer %s möchte mit dir die %s Prüfung starten!\nDiese kostet %d$! Möchtest du die Prüfung starten?", target, client.name, DrivingSchool.TypeNames[type], costs), self.m_StartLession, self.m_DiscardLession, client, target, type)
						else
							client:sendError(_("Du bist bereits in einer Fahrprüfung!", client))
						end
					else
						client:sendError(_("Der Spieler %s ist bereits in einer Prüfung!", client, target.name))
					end
				else
					client:sendError(_("Der Spieler %s hat nicht genug Geld dabei! (%d$)", client, target.name, costs))
				end
			else
                client:sendError(_("Der Spieler %s muss erst die theoretische Fahrprüfung bestehen!", client, target.name))
			end
		else
			client:sendError(_("Der Spieler %s hat den %s bereits!", client, target.name, DrivingSchool.TypeNames[type]))
		end
    else
        client:sendError(_("Interner Fehler: Argumente falsch @DrivingSchool:Event_startLessionQuestion!", client))
    end
end

function DrivingSchool:discardLession(instructor, target, type)
    instructor:sendError(_("Der Spieler %s hat die %s Prüfung abgelehnt!", instructor, target.name, DrivingSchool.TypeNames[type]))
    target:sendError(_("Du hast die %s Prüfung mit %s abgelehnt!", target, DrivingSchool.TypeNames[type], instructor.name))
end

function DrivingSchool:startLession(instructor, target, type)
    local costs = DrivingSchool.LicenseCosts[type]
    if costs and target then
        if self:checkPlayerLicense(target, type) == false then
            if target:getMoney() >= costs then
                if not target:getPublicSync("inDrivingLession") == true then
                    if not self.m_CurrentLessions[instructor] then
                        self.m_CurrentLessions[instructor] = {
                            ["target"] = target,
							["type"] = type,
							["instructor"] = instructor,
							["vehicle"] = false,
							["startMileage"] = false,
						}

						target:transferMoney(self.m_BankAccountServer, costs, ("%s-Prüfung"):format(DrivingSchool.TypeNames[type]), "Company", "License")
						self.m_BankAccountServer:transferMoney({self, nil, true}, costs*0.85, ("%s-Prüfung"):format(DrivingSchool.TypeNames[type]), "Company", "License")
						self.m_BankAccountServer:transferMoney(instructor, costs*0.15, ("%s-Prüfung"):format(DrivingSchool.TypeNames[type]), "Company", "License")

                        target:setPublicSync("inDrivingLession",true)
                        instructor:sendInfo(_("Du hast die %s Prüfung mit %s gestartet!", instructor, DrivingSchool.TypeNames[type], target.name))
                        target:sendInfo(_("Fahrlehrer %s hat die %s Prüfung mit dir gestartet, Folge seinen Anweisungen!", target, instructor.name, DrivingSchool.TypeNames[type]))
                        target:triggerEvent("showDrivingSchoolStudentGUI", DrivingSchool.TypeNames[type])
                        instructor:triggerEvent("showDrivingSchoolInstructorGUI", DrivingSchool.TypeNames[type], target)
						self:addLog(instructor, "Fahrschule", ("hat eine %s Prüfung mit %s gestartet!"):format(DrivingSchool.TypeNames[type], target:getName()))
                        addEventHandler("onPlayerQuit", instructor, self.m_OnQuit)
                        addEventHandler("onPlayerQuit", target, self.m_OnQuit)
                    else
                        instructor:sendError(_("Du bist bereits in einer Fahrprüfung!", instructor))
                    end
                else
                    instructor:sendError(_("Der Spieler %s ist bereits in einer Prüfung!", instructor, target.name))
                    target:sendError(_("Du bist bereits in einer Prüfung!", target))
                end
            else
                instructor:sendError(_("Der Spieler %s hat nicht genug Geld dabei! (%d$)", instructor, target.name, costs))
                target:sendError(_("Du hast nicht genug Geld dabei! (%d$)", target, costs))
            end
        else
            instructor:sendError(_("Der Spieler %s hat den %s bereits!", instructor, target.name, DrivingSchool.TypeNames[type]))
            target:sendError(_("Du hast den %s bereits!", target, DrivingSchool.TypeNames[type]))
        end
    else
        instructor:sendError(_("Interner Fehler: Argumente falsch @DrivingSchool:Event_startLession!", instructor))
    end
end

function DrivingSchool:Event_onQuit()
    if self.m_CurrentLessions[source] then
        local lession = self.m_CurrentLessions[source]
		self:Event_endLession(lession["target"], false, source)
        lession["target"]:sendError(_("Der Fahrlehrer %s ist offline gegangen!",lession["target"], source.name))
    elseif self:getLessionFromStudent(source) then
        local lession = self:getLessionFromStudent(source)
        self:Event_endLession(source, false, lession["instructor"])
        lession["instructor"]:sendError(_("Der Fahrschüler %s ist offline gegangen!",lession["instructor"], source.name))
    end
end

function DrivingSchool:Event_endLession(target, success, clientServer)
    if not client and clientServer then client = clientServer end
    local type = self.m_CurrentLessions[client]["type"]
    if success == true then
		local vehicle = self.m_CurrentLessions[client].vehicle
		if not vehicle then return end

		local startMileage = self.m_CurrentLessions[client].startMileage
		local mileageDiff = math.round((vehicle:getMileage()-startMileage)/1000, 1)

		if mileageDiff < 2 then
			client:sendWarning("Du musst mindestens 2km mit dem Fahrschüler fahren!")
			return
		end

        self:setPlayerLicense(target, type, true)
        target:sendInfo(_("Du hast die %s Prüfung erfolgreich bestanden und den Schein erhalten!",target, DrivingSchool.TypeNames[type]))
        client:sendInfo(_("Du hast die %s Prüfung mit %s erfolgreich beendet!",client, DrivingSchool.TypeNames[type], target.name))
    	self:addLog(client, "Fahrschule", ("hat die %s Prüfung mit %s erfolgreich beendet (%s km)!"):format(DrivingSchool.TypeNames[type], target:getName(), mileageDiff))
	else
        target:sendError(_("Du hast die %s Prüfung nicht geschaft! Viel Glück beim nächsten Mal!",target, DrivingSchool.TypeNames[type]))
        client:sendInfo(_("Du hast die %s Prüfung mit %s abgebrochen!",client, DrivingSchool.TypeNames[type], target.name))
		self:addLog(client, "Fahrschule", ("hat die %s Prüfung mit %s abgebrochen!"):format(DrivingSchool.TypeNames[type], target:getName()))
    end

	target:removeFromVehicle()
    target:triggerEvent("hideDrivingSchoolStudentGUI")
    client:triggerEvent("hideDrivingSchoolInstructorGUI")
    removeEventHandler("onPlayerQuit", client, self.m_OnQuit)
    removeEventHandler("onPlayerQuit", target, self.m_OnQuit)
    target:setPublicSync("inDrivingLession", false)
    self.m_CurrentLessions[client] = nil
end

function DrivingSchool:Event_receiveTurnCommand(turnCommand, arg)
    local target = self.m_CurrentLessions[client]["target"]
    if target then
        target:triggerEvent("drivingSchoolChangeDirection", turnCommand, arg)
    end
end

function DrivingSchool:Event_reduceSTVO(category, amount)
	if tonumber(client:getSTVO(category)) < tonumber(amount) then
		client:sendError(_("Du hast nicht so viele STVO-Punkte!", client))
		return false
	end

	local stvoPricing = 250 * amount

	if not client:transferMoney(self.m_BankAccountServer, stvoPricing, "STVO-Punkte abbauen", "Driving School", "ReduceSTVO") then
		client:sendError(_("Du hast nicht genügend Geld! ("..tostring(stvoPricing).."$)", client))
		return false
	end

	client:setSTVO(category, client:getSTVO(category) - amount)
	self.m_BankAccountServer:transferMoney({self, nil, true}, stvoPricing*0.85, "STVO-Punkte abbauen", "Driving School", "ReduceSTVO")
	triggerClientEvent(client, "hideDrivingSchoolReduceSTVO", resourceRoot)
end
