DrivingSchool = inherit(Company)
DrivingSchool.LicenseCosts = {["car"] = 1500, ["bike"] = 750, ["truck"] = 4000, ["heli"] = 15000, ["plane"] = 20000 }
DrivingSchool.TypeNames = {["car"] = "Autoführerschein", ["bike"] = "Motorradschein", ["truck"] = "LKW-Schein", ["heli"] = "Helikopterschein", ["plane"] = "Flugschein" }
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

local randomName = 
{
	"Nero Soliven",
	"Kempes Waldemar",
	"Avram Vachnadze",
	"Klaus Schweiger",
	"Luca Pasqualini",
	"Peter Schmidt",
	"Muhammad Vegas",
	"Isaha Rosenberg",
}
function DrivingSchool:constructor()
    self:createDrivingSchoolMarker(Vector3(1362.04, -1663.74, 13.57))
	self:createSchoolPed(Vector3( -2035.32, -117.65, 1035.17))
	self:createAutomaticTestPed(Vector3(1364.44, -1666, 13.55), Vector3(1364.62, -1674.70, 13.56))
    InteriorEnterExit:new(Vector3(1364.14, -1669.10, 13.55), Vector3(-2026.93, -103.89, 1035.17), 90, 180, 3, 0, false)

    VehicleBarrier:new(Vector3(1413.59, -1653.09, 13.30), Vector3(0, 90, 88)).onBarrierHit = bind(self.onBarrierHit, self)
    --VehicleBarrier:new(Vector3(1345.19, -1722.80, 13.39), Vector3(0, 90, 0)).onBarrierHit = bind(self.onBarrierHit, self)
    --VehicleBarrier:new(Vector3(1354.80, -1591.00, 13.39), Vector3(0, 90, 161), 0).onBarrierHit = bind(self.onBarrierHit, self)

    self.m_OnQuit = bind(self.Event_onQuit,self)
	
    local safe = createObject(2332, -2032.70, -113.70, 1036.20)
    safe:setInterior(3)
	self:setSafe(safe)
	self.m_CurrentLessions = {}
    addRemoteEvents{"drivingSchoolMenu", "drivingSchoolstartLessionQuestion", "drivingSchoolDiscardLession", "drivingSchoolStartLession", "drivingSchoolEndLession", "drivingSchoolReceiveTurnCommand","drivingSchoolPassTheory", "drivingSchoolStartTheory","drivingSchoolRequestSpeechBubble", "drivingSchoolStartAutomaticTest", "drivingSchoolHitRouteMarker", "requestAutomaticTestPedBubble"}
    addEventHandler("drivingSchoolMenu", root, bind(self.Event_drivingSchoolMenu, self))
    addEventHandler("drivingSchoolDiscardLession", root, bind(self.Event_discardLession, self))
    addEventHandler("drivingSchoolstartLessionQuestion", root, bind(self.Event_startLessionQuestion, self))
    addEventHandler("drivingSchoolStartLession", root, bind(self.Event_startLession, self))
    addEventHandler("drivingSchoolEndLession", root, bind(self.Event_endLession, self))
    addEventHandler("drivingSchoolReceiveTurnCommand", root, bind(self.Event_receiveTurnCommand, self))
	addEventHandler("drivingSchoolPassTheory", root, bind(self.Event_passTheory, self))
    addEventHandler("drivingSchoolStartTheory", root, bind(self.Event_startTheory, self))
	addEventHandler("drivingSchoolRequestSpeechBubble", root, bind(self.requestSpeechBubble, self))
	addEventHandler("drivingSchoolStartAutomaticTest", root, bind(self.onDrivingTestNPCStart, self))
	addEventHandler("drivingSchoolHitRouteMarker", root, bind(self.onHitRouteMarker, self))
	addEventHandler("requestAutomaticTestPedBubble", root, bind(self.requestAutomaticTestPedBubble, self))
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
    if player:getCompany() ~= self or not player:getPublicSync("inDrivingLession") == true then
        player:sendError(_("Du darfst dieses Fahrzeug nicht fahren!", player))
        return false
    end
    return true
end

function DrivingSchool:onBarrierHit(player)
	local veh = player.vehicle
	if veh then 
		if player.vehicle.m_IsAutoLesson then 
		return true
		end
	end
    if player:getCompany() ~= self then
        return false
    end
    return true
end

function DrivingSchool:createDrivingSchoolMarker(pos)
    self.m_DrivingSchoolPickup = createPickup(pos, 3, 1239)
    addEventHandler("onPickupHit", self.m_DrivingSchoolPickup,
        function(hitElement)
            if getElementType(hitElement) == "player" then
                local instructorTable = {}
				for k, player in pairs(self:getOnlinePlayers()) do
					instructorTable[player.name] = player:getPublicSync("Company:Duty") and "Ja" or "Nein"
				end

				hitElement:triggerEvent("showDrivingSchoolMenu",#self:getOnlinePlayers(), instructorTable)
            end
            cancelEvent()
        end
    )
end

function DrivingSchool:onDrivingTestNPCStart( ) 
	if DrivingSchool.m_LessonVehicles[source] then 
		source:triggerEvent("DrivingLesson:endLesson")
		if DrivingSchool.m_LessonVehicles[source].m_NPC then 
			if isElement(DrivingSchool.m_LessonVehicles[source].m_NPC ) then
				destroyElement(DrivingSchool.m_LessonVehicles[source].m_NPC)
			end
		end
		destroyElement(DrivingSchool.m_LessonVehicles[source])
	end
	if source:getMoney() < DrivingSchool.LicenseCosts["car"] then  
		source:sendError(_("Du hast zu wenig Geld dabei ( mind. "..DrivingSchool.LicenseCosts["car"].."$ )!", source)) 
		return 
	end
	local veh  = TemporaryVehicle.create(410,1355.07, -1621.64, 14.22,90)
	if source.m_AutoTestMode == "bike" then setElementModel(veh,586) end
	setVehicleHandling(veh,"maxVelocity",60)
	setElementPosition(source,1348.97, -1620.68, 13.60)
	setCameraTarget(source, source)
	
	veh.m_NPC = createPed(295,1355.07, -1621.64, 13.22)
	veh.m_NPC:setData("NPC:Immortal", true, true)
	setElementData(veh.m_NPC,"isBuckeled", true)
	local name =  randomName[math.random(1, #randomName)]
	setElementData(veh.m_NPC, "Ped:fakeNameTag",name)
	warpPedIntoVehicle(veh.m_NPC,veh,1)
	setVehicleColor(veh,255,255,255)
	veh.m_Driver = source
	veh.m_CurrentNode = 1
	veh.m_IsAutoLesson = true
	veh.m_TestMode = source.m_AutoTestMode
	veh.m_NPC:setData("isDrivingCoach",true)
	if source.m_AutoTestMode == "car" then
		source:takeMoney(DrivingSchool.LicenseCosts["car"], "Fahrprüfung")
		self:giveMoney(DrivingSchool.LicenseCosts["car"], ("%s-Prüfung"):format(DrivingSchool.TypeNames["car"]))
	else 
		source:takeMoney(DrivingSchool.LicenseCosts["bike"], "Fahrprüfung")
		self:giveMoney(DrivingSchool.LicenseCosts["bike"], ("%s-Prüfung"):format(DrivingSchool.TypeNames["bike"]))
	end
	outputChatBox("Steige in das Fahrzeug vor dir ein!", source, 200,200,0)
	addEventHandler("onVehicleStartEnter",veh,function(player, seat) 
		if source.m_Driver == player then 
			if seat == 0 then 
				local name2 = name
				outputChatBox("Fahre die vorgesehene Strecke ab und achte darauf, dass dein Fahrzeug nicht beschädigt wird!", player, 200,200,0)
				outputChatBox(name.." sagt: Mit 'X' schaltest du den Motor an.", player, 200, 200, 200)
				setTimer(outputChatBox,1000,1,name2.." sagt: Anschließend mit 'L' die Lichter.", player, 200, 200, 200)
				if player.m_AutoTestMode == "car" then
					setTimer(outputChatBox,3000,1,name2.." sagt: Nun Anschnallen mit 'M'. Falls du die Handbremse ziehen willst benutze 'G'.", player, 200, 200, 200)
				else 
					setTimer(outputChatBox,3000,1,name2.." sagt: Ziehe deinen Helm an. Falls du die Handbremse ziehen willst benutze 'G'.", player, 200, 200, 200)
				end
				setTimer(outputChatBox,5000,1,name2.." sagt: Und abgeht es! Vergess nicht den Limiter mit der Taste 'K' anzuschalten.", player, 200, 200, 200)
			end
		else 
			cancelEvent()
		end
	end)
	addEventHandler("onVehicleExit",veh,function(player, seat) 
		if seat ~= 0 then return end
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
			outputChatBox("Du hast das Fahrzeug verlassen und die Prüfung beendet!", player, 200,0,0)
		end
	end)
	addEventHandler("onVehicleExplode",veh,function()
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
	end)
	addEventHandler("onElementDestroy",veh,function()
		local player = getVehicleOccupant(source)
		if player then
			if DrivingSchool.m_LessonVehicles[player] == source then
				DrivingSchool.m_LessonVehicles[player] = nil
				if source.m_NPC then 
					if isElement(source.m_NPC) then
						destroyElement(source.m_NPC)
					end
				end
				destroyElement(source)
			end
			player:triggerEvent("DrivingLesson:endLesson")
			fadeCamera(player,false,0.5)
			setTimer(setElementPosition,1000,1,player,1348.97, -1620.68, 13.60)
			setTimer(fadeCamera,1500,1, player,true,0.5)
			outputChatBox("Du hast das Fahrzeug verlassen und die Prüfung beendet!", player, 200,0,0)
		end
	end)
	source:triggerEvent("DrivingLesson:setMarker",DrivingSchool.testRoute[veh.m_CurrentNode], veh)
	DrivingSchool.m_LessonVehicles[source] = veh
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
				if veh.m_AutoTestMode == "car" then
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

function DrivingSchool:requestSpeechBubble( )
	client:triggerEvent("addDrivingSchoolSpeechBubble", self.m_DrivingSchoolPed)
end

function DrivingSchool:createSchoolPed( pos )
	self.m_DrivingSchoolPed = NPC:new(295, pos.x, pos.y, pos.z, -90)
    self.m_DrivingSchoolPed:setData("clickable", true, true)
	self.m_DrivingSchoolPed:setImmortal(true)
	setElementInterior(self.m_DrivingSchoolPed, 3, pos)
    addEventHandler("onElementClicked", self.m_DrivingSchoolPed,
        function(button ,state ,player )
			if button == "left" and state == "up" then
				if source == self.m_DrivingSchoolPed then
					if not player.m_HasTheory then
                        if not player.isInTheory then
                            QuestionBox:new(player, player, _("Möchtest du die Theorie-Prüfung starten? Kosten: 300$", player), "drivingSchoolStartTheory")
                        end
                    else
                        player:sendInfo("Du hast bereits die Theorieprüfung bestanden!")
					end
				end
			end
        end
    )
end

function DrivingSchool:createAutomaticTestPed( pos, pos2 )
	self.m_DrivingSchoolAutoPed = NPC:new(295, pos.x, pos.y, pos.z, 270)
    self.m_DrivingSchoolAutoPed:setData("clickable", true, true)
	self.m_DrivingSchoolAutoPed:setImmortal(true)
	self.m_DrivingSchoolAutoPed:setFrozen(true)
    addEventHandler("onElementClicked", self.m_DrivingSchoolAutoPed,
        function(button ,state ,player )
			if button == "left" and state == "up" then
				if source == self.m_DrivingSchoolAutoPed then
					if player.m_HasTheory then
						if #self:getOnlinePlayers() < 3 then
							if not player.m_HasDrivingLicense  then
								if getPlayerMoney(player) >= DrivingSchool.LicenseCosts["car"] then
									player.m_AutoTestMode = "car"
									QuestionBox:new(player, player, _("Möchtest du die automatische Fahrprüfung starten (Auto-Schein)? Kosten: "..DrivingSchool.LicenseCosts["car"].."$",  player), "drivingSchoolStartAutomaticTest")
								else 
									player:sendError("Du musst mind. "..DrivingSchool.LicenseCosts["car"].."$ dabei haben!")
								end
							else 
								player:sendError("Du hast bereits den Führerschein für ein Auto!")
							end
						else 
							player:sendError("Es sind zurzeit genügend Fahrlehrer online!")
						end
                    else
                        player:sendError("Du hast noch nicht die Theorieprüfung bestanden!")
					end
				end
			end
        end
    )
	self.m_DrivingSchoolAutoPed2 = NPC:new(295, pos2.x, pos2.y, pos2.z, 270)
    self.m_DrivingSchoolAutoPed2:setData("clickable", true, true)
	self.m_DrivingSchoolAutoPed2:setImmortal(true)
	self.m_DrivingSchoolAutoPed2:setFrozen(true)
    addEventHandler("onElementClicked", self.m_DrivingSchoolAutoPed2,
        function(button ,state ,player )
			if button == "left" and state == "up" then
				if source == self.m_DrivingSchoolAutoPed2 then
					if player.m_HasTheory then
						if #self:getOnlinePlayers() < 3 then
							if not player.m_HasBikeLicense  then
								if getPlayerMoney(player) >= DrivingSchool.LicenseCosts["bike"] then
									player.m_AutoTestMode = "bike"
									QuestionBox:new(player, player, _("Möchtest du die automatische Fahrprüfung starten (Motorrad-Schein)? Kosten: "..DrivingSchool.LicenseCosts["bike"].."$",  player), "drivingSchoolStartAutomaticTest")
								else 
									player:sendError("Du musst mind. "..DrivingSchool.LicenseCosts["bike"].."$ dabei haben!")
								end
							else 
								player:sendError("Du hast bereits den Führerschein für ein Motorrad!")
							end
						else 
							player:sendError("Es sind zurzeit genügend Fahrlehrer online!")
						end
                    else
                        player:sendError("Du hast noch nicht die Theorieprüfung bestanden!")
					end
				end
			end
        end
    )
end

function DrivingSchool:requestAutomaticTestPedBubble()
	client:triggerEvent("addDrivingSchoolAutoTestSpeechBubble", self.m_DrivingSchoolAutoPed, self.m_DrivingSchoolAutoPed2)
end
function DrivingSchool:Event_startTheory()
    if source:getMoney() >= 300 then
        source:triggerEvent("showDrivingSchoolTest", self.m_DrivingSchoolPed)
        source:takeMoney(300, "Fahrschule")
        source.isInTheory = true
    else
        source:sendError(_("Du hast nicht genug Geld ( Kosten: 300)!", client))
    end
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

function DrivingSchool:Event_startLessionQuestion(target, type)
    local costs = DrivingSchool.LicenseCosts[type]
    if costs and target then
        if self:checkPlayerLicense(target, type) == false then
			if target.m_HasTheory then
				if target:getMoney() >= costs then
					if not target:getPublicSync("inDrivingLession") == true then
						if not self.m_CurrentLessions[client] then
							QuestionBox:new(client, target, _("Der Fahrlehrer %s möchte mit dir die %s Prüfung starten!\nDiese kostet %d$! Möchtest du die Prüfung starten?", target, client.name, DrivingSchool.TypeNames[type], DrivingSchool.LicenseCosts[type]), "drivingSchoolStartLession", "drivingSchoolDiscardLession", client, target, type)
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

function DrivingSchool:Event_discardLession(instructor, target, type)
    instructor:sendError(_("Der Spieler %s hat die %s Prüfung abgelehnt!", instructor, target.name, DrivingSchool.TypeNames[type]))
    target:sendError(_("Du hast die %s Prüfung mit %s abgelehnt!", target, DrivingSchool.TypeNames[type], instructor.name))
end

function DrivingSchool:Event_startLession(instructor, target, type)
    local costs = DrivingSchool.LicenseCosts[type]
    if costs and target then
        if self:checkPlayerLicense(target, type) == false then
            if target:getMoney() >= costs then
                if not target:getPublicSync("inDrivingLession") == true then
                    if not self.m_CurrentLessions[instructor] then
                        self.m_CurrentLessions[instructor] = {
                            ["target"] = target, ["type"] = type, ["instructor"] = instructor
                        }
                        target:takeMoney(costs, "Fahrschule")
                        self:giveMoney(math.floor(costs*0.5), ("%s-Prüfung"):format(DrivingSchool.TypeNames[type]))
						instructor:giveMoney(math.floor(costs*0.15), ("%s-Prüfung"):format(DrivingSchool.TypeNames[type]))
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

function DrivingSchool:getLessionFromStudent(player)
    for index, key in pairs(self.m_CurrentLessions) do
        if key["target"] == player then return key end
    end
    return false
end

function DrivingSchool:Event_onQuit()
    if self.m_CurrentLessions[source] then
        self:Event_endLession(self.m_CurrentLessions[source]["target"], false, source)
        lession["target"]:sendError(_("Der Fahrlehrer %s ist offline gegangen!",lession["target"], source.name))
    elseif self:getLessionFromStudent(source) then
        local lession = self:getLessionFromStudent(source)
        self:Event_endLession(source, false, lession["instructor"])
        lession["instructor"]:sendError(_("Der Fahrschüler %s ist offline gegangen!",lession["instructor"], source.name))
    else
    end
end

function DrivingSchool:Event_endLession(target, success, clientServer)
    if not client and clientServer then client = clientServer end
    local type = self.m_CurrentLessions[client]["type"]
    if success == true then
        self:setPlayerLicense(target, type, true)
        target:sendInfo(_("Du hast die %s Prüfung erfolgreich bestanden und den Schein erhalten!",target, DrivingSchool.TypeNames[type]))
        client:sendInfo(_("Du hast die %s Prüfung mit %s erfolgreich beendet!",client, DrivingSchool.TypeNames[type], target.name))
    else
        target:sendError(_("Du hast die %s Prüfung nicht geschaft! Viel Glück beim nächsten Mal!",target, DrivingSchool.TypeNames[type]))
        client:sendInfo(_("Du hast die %s Prüfung mit %s abgebrochen!",client, DrivingSchool.TypeNames[type], target.name))
    end

    target:triggerEvent("hideDrivingSchoolStudentGUI")
    client:triggerEvent("hideDrivingSchoolInstructorGUI")
    removeEventHandler("onPlayerQuit", client, self.m_OnQuit)
    removeEventHandler("onPlayerQuit", target, self.m_OnQuit)
    target:setPublicSync("inDrivingLession",false)
    self.m_CurrentLessions[client] = nil
end

function DrivingSchool:Event_receiveTurnCommand(turnCommand)
    local target = self.m_CurrentLessions[client]["target"]
    if target then
        target:triggerEvent("drivingSchoolChangeDirection", turnCommand)
    end
end

function DrivingSchool:Event_passTheory(pass)
    client.isInTheory = false
    if pass == true then
        client.m_HasTheory = true
        client:sendInfo(_("Gehe nun zur praktischen Prüfung!", client))
    else
        client:sendInfo(_("Du hast abgebrochen oder nicht bestanden! Versuche die Prüfung erneut!", client))
    end
end
