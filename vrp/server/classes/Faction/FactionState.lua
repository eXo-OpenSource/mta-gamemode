-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionState.lua
-- *  PURPOSE:     Faction State Class
-- *
-- ****************************************************************************
FactionState = inherit(Singleton)

local radarRange = 20
  -- implement by children

function FactionState:constructor()
	self:createArrestZone(1564.92, -1693.55, 5.89, 0, 5) -- PD garare
	self:createArrestZone(1578.50, -1682.24, 15.0)-- PD cells
	self:createArrestZone(1564.38, -1702.57, 28.40) --PD roof
	self:createArrestZone(163.05, 1904.10, 18.67) -- Area
	self:createArrestZone(-1589.91, 715.65, -5.24) -- SF
	self:createArrestZone(2281.71, 2431.59, 3.27) --lv

	--self.m_GaragePorter = VehicleTeleporter:new(Vector3(1587.61, -1654.99, 13.43), Vector3(1597.39, -1671.34, 7.89), 180, 0, 4, 5, "cylinder" , 5, Vector3(0,0,3)) -- pd exit vehicle
	--self.m_GaragePorter:addEnterEvent(function( player) player:triggerEvent("setOcclusion", false) end)
	--self.m_GaragePorter:addExitEvent(function( player) player:triggerEvent("setOcclusion", true) end)

	self.m_InstantTeleportCol = createColCuboid(1523.19, -1722.73, 0, 89, 89, 10)
	InstantTeleportArea:new( self.m_InstantTeleportCol, 0, 5)

	self.m_InteriorGarageEntrance = InteriorEnterExit:new(Vector3(246.17, 88, 1003.64), Vector3(1568.64, -1690.16, 5.89), 180, 180, 0, 5, 6) -- pd exit
	self.m_InteriorGarageEntrance:addEnterEvent(function( player) player:triggerEvent("setOcclusion", false) end)
	self.m_InteriorGarageEntrance:addExitEvent(function( player) player:triggerEvent("setOcclusion", true) end)

	InteriorEnterExit:new(Vector3(1583.42, -1660.01, 13.39), Vector3(1591.63, -1667.39, 5.89), 180, 0, 4, 5) -- pd exit

	self.ms_IllegalItems = {"Kokain", "Weed", "Heroin", "Shrooms", "Diebesgut"}

	self.m_ArmySpecialVehicleBorder = {
		x = -179.915,
		y = 1614.156,
		sizeX = 616.486,
		sizeY = 610.996
	}

	self.m_ArmySepcialVehicleCol = createColRectangle(self.m_ArmySpecialVehicleBorder.x, self.m_ArmySpecialVehicleBorder.y, self.m_ArmySpecialVehicleBorder.sizeX, self.m_ArmySpecialVehicleBorder.sizeY)
	self.m_BankAccountServer = BankServer.get("faction.state")

	addEventHandler("onColShapeLeave", self.m_ArmySepcialVehicleCol, function(element)
		if element and isElement(element) and element:getType() == "player" and element.vehicle then
			if element.vehicle:getModel() == 432 or element.vehicle:getModel() == 520 or element.vehicle:getModel() == 425 then
				if element:getFaction().m_Id ~= 3 or element:getFaction():getPlayerRank(element) == 0 then
					local veh = element.vehicle
					element:removeFromVehicle()
					veh:respawn(true)
					FactionManager:getSingleton().Map[3]:addLog(element, "Spezial-Fahrzeuge", "hat das Fahrzeug " .. veh:getName() .. " entwendet!")
					for _, v in pairs(FactionManager:getSingleton().Map[3]:getOnlinePlayers()) do
						if FactionManager:getSingleton().Map[3]:getPlayerRank(v) ~= 0 then
							v:sendMessage(element:getName() .. " hat das Fahrzeug " .. veh:getName() .. " entwendet!", 193, 44, 44)
						end
					end
				end
			end
		end
	end)

	self.m_Bugs = {}

	for i = 1, FACTION_FBI_BUGS do
		self.m_Bugs[i] = {}
	end

	self.m_SelfBailMarker = {}
	self:createSelfArrestMarker(  Vector3(249.51, 67.46, 1003.64), 6, 0 )
	self:createEvidencePickup( 255.29, 90.78, 1002.45, 6, 0)
	self:createEvidencePickup( 1579.43, -1691.53, 5.92, 0, 5)


	self.m_EvidenceEquipmentBox = {}
	self:createEquipmentEvidence(Vector3(1581.7, -1689.27, 5.2), 0, 5)
	self:createEquipmentEvidence(Vector3(1581.7, -1689.27, 5.2), 0, 5)
	self.m_Items = {
		["Barrikade"] = 0,
		["Nagel-Band"] = 0,
		["Blitzer"] = 0,
		["Warnkegel"] = 0,
	}

	nextframe(
		function ()
			self:loadLSPD(1)
			self:loadFBI(2)
			self:loadArmy(3)
		end
	)

	addRemoteEvents{
	"factionStateArrestPlayer", "factionStateGiveWanteds", "factionStateClearWanteds", "factionStateLoadJailPlayers", "factionStateFreePlayer", "playerSelfArrestConfirm",
	"factionStateRearm","factionStateToggleDuty", "factionStateStorageWeapons",
	"factionStateGrabPlayer", "factionStateFriskPlayer", "stateFactionSuccessCuff", "factionStateAcceptTicket", "factionStateStartAlcoholTest",
	"factionStateShowLicenses", "factionStateAcceptShowLicense", "factionStateDeclineShowLicense",
	"factionStateTakeDrugs", "factionStateTakeWeapons", "factionStateGivePANote", "factionStatePutItemInVehicle", "factionStateTakeItemFromVehicle",
	"factionStateLoadBugs", "factionStateAttachBug", "factionStateBugAction", "factionStateCheckBug",
	"factionStateGiveSTVO", "factionStateSetSTVO", "SpeedCam:onStartClick","State:startEvidenceTruck"
	}

	addCommandHandler("suspect",bind(self.Command_suspect, self))
	addCommandHandler("su",bind(self.Command_suspect, self))
	addCommandHandler("tie",bind(self.Command_tie, self))
	addCommandHandler("needhelp",bind(self.Command_needhelp, self))
	addCommandHandler("bail",bind(self.Command_bail, self))
	addCommandHandler("cuff",bind(self.Command_cuff, self))
	addCommandHandler("uncuff",bind(self.Command_uncuff, self))
	addCommandHandler("ticket",bind(self.Command_ticket, self))
	addCommandHandler("stvo",bind(self.Command_stvo, self))

	addEventHandler("factionStateArrestPlayer", root, bind(self.Event_JailPlayer, self))
	addEventHandler("factionStateRearm", root, bind(self.Event_FactionRearm, self))
	addEventHandler("factionStateToggleDuty", root, bind(self.Event_toggleDuty, self))
	addEventHandler("factionStateStorageWeapons", root, bind(self.Event_storageWeapons, self))
	addEventHandler("factionStateGiveWanteds", root, bind(self.Event_giveWanteds, self))
	addEventHandler("factionStateClearWanteds", root, bind(self.Event_clearWanteds, self))
	addEventHandler("factionStateGrabPlayer", root, bind(self.Event_grabPlayer, self))
	addEventHandler("factionStateFriskPlayer", root, bind(self.Event_friskPlayer, self))
	addEventHandler("factionStateStartAlcoholTest", root, bind(self.Event_alcoholTest, self))
	addEventHandler("factionStateShowLicenses", root, bind(self.Event_showLicenses, self))
	addEventHandler("factionStateTakeDrugs", root, bind(self.Event_takeDrugs, self))
	addEventHandler("factionStateTakeWeapons", root, bind(self.Event_takeWeapons, self))
	addEventHandler("factionStateAcceptShowLicense", root, bind(self.Event_acceptShowLicense, self))
	addEventHandler("factionStateDeclineShowLicense", root, bind(self.Event_declineShowLicense, self))
	addEventHandler("factionStateGivePANote", root, bind(self.Event_givePANote, self))
	addEventHandler("factionStatePutItemInVehicle", root, bind(self.Event_putItemInVehicle, self))
	addEventHandler("factionStateTakeItemFromVehicle", root, bind(self.Event_takeItemFromVehicle, self))
	addEventHandler("factionStateLoadJailPlayers", root, bind(self.Event_loadJailPlayers, self))
	addEventHandler("factionStateFreePlayer", root, bind(self.Event_freePlayer, self))
	addEventHandler("factionStateLoadBugs", root, bind(self.Event_loadBugs, self))
	addEventHandler("factionStateAttachBug", root, bind(self.Event_attachBug, self))
	addEventHandler("factionStateBugAction", root, bind(self.Event_bugAction, self))
	addEventHandler("factionStateCheckBug", root, bind(self.Event_checkBug, self))
	addEventHandler("factionStateGiveSTVO", root, bind(self.Event_giveSTVO, self))
	addEventHandler("factionStateSetSTVO", root, bind(self.Event_setSTVO, self))
	addEventHandler("onPlayerVehicleExit",root, bind(self.Event_onPlayerExitVehicle, self))
	addEventHandler("stateFactionSuccessCuff", root, bind(self.Event_CuffSuccess, self))
	addEventHandler("factionStateAcceptTicket", root, bind(self.Event_OnTicketAccept, self))
	addEventHandler("playerSelfArrestConfirm", root, bind(self.Event_OnConfirmSelfArrest, self))
	addEventHandler("SpeedCam:onStartClick", root, bind(self.Event_speedRadar,self))
	addEventHandler("State:startEvidenceTruck", root, bind(self.Event_startEvidenceTruck,self))

	self.onTiedExitBind = bind(self.onTiedExit, self)
	self.m_onSpeedColHit = bind(self.Event_OnSpeedColShapeHit, self)

	local row = sql:queryFetch("SELECT * FROM ??_StateEvidence", sql:getPrefix())
	self.m_EvidenceRoomItems = {}
	if row then
		for i, v in ipairs(row) do

			self.m_EvidenceRoomItems[#self.m_EvidenceRoomItems+1] = {v.Type, v.Var1, v.Var2, v.Var3, v.Cop, v.Date}
		end
	end
end


function FactionState:destructor()
end

function FactionState:createSelfArrestMarker( pos, int, dim )
	self.m_Ped = NPC:new(280, 251.59, 67.10, 1003.64)
	self.m_Ped:setRotation(Vector3(0, 0, 90))
	self.m_Ped:setImmortal(true)
	self.m_Ped:setFrozen(true)
	local marker = createPickup(pos, 3, 1247, 10)
	if int then
		self.m_Ped:setInterior(int)
		marker:setInterior(int)
	end
	if dim then
		self.m_Ped:setDimension(dim)
		marker:setDimension(dim)
	end
	self.m_SelfBailMarker[#self.m_SelfBailMarker+1] = marker
	addEventHandler("onPickupHit",marker, function(hE, bDim)
		if getElementDimension(hE) == getElementDimension(source) then
			if getElementType(hE) == "player" then
				if hE:getWanteds() > 0 and not (hE:getFaction() and hE:getFaction():isStateFaction() and hE:isFactionDuty()) then
					hE:triggerEvent("playerSelfArrest")
				end
			end
		end
	end)
end

function FactionState:createEquipmentEvidence( pos, int, dim )
	local box = createObject(964, pos)
	box:setInterior(int)
	box:setDimension(dim)
	box:setData("clickable",true,true)
	addEventHandler("onElementClicked", box, bind(self.Event_OnEvidenceEquipmentClick, self))
	self.m_EvidenceEquipmentBox[#self.m_EvidenceEquipmentBox+1] = box
end

function FactionState:Event_OnEvidenceEquipmentClick(button, state, player)
	if button == "left" and state == "down" then
		if player:getFaction() and player:getFaction():isStateFaction() then
			local box = player:getPlayerAttachedObject()
			if box and isElement(box) and box.m_Content then 
				self:putEvidenceInDepot(player, box)
			else 
				player:sendError(_("Du trägst keine Schwarzmarktware mit dir!", player))
			end
		else
			player:sendError(_("Dieses Depot gehört nicht deiner Fraktion!", player))
		end
	end
end

function FactionState:putEvidenceInDepot(player, box)
	local content = box.m_Content 
	local type, product, amount, price, id = unpack(box.m_Content)
	local depot = player:getFaction():getDepot()
	if type == "Waffe" then
		if id then
			player:getFaction():sendShortMessage(("%s hat %s Waffe/n [ %s ] (%s $) konfesziert!"):format(player:getName(), amount, product, price))
			self:addWeaponToEvidence(player, id, amount, 0, true)
		end
	elseif type == "Munition" then
		if id then
			player:getFaction():sendShortMessage(("%s hat %s Munition [ %s ] (%s $) konfesziert!"):format(player:getName(), amount, product, price))
			self:addWeaponToEvidence(player, id, amount, 0, true)
		end
	else 
		player:getFaction():sendShortMessage(("%s hat %s Stück %s (%s $) konfesziert!"):format(player:getName(), amount, product, price))
		self.m_BankAccountServer:transferMoney(player:getFaction(), price , "Schwarzmarktware", "Faction", "Schwarzmarktware")
	end
	box.m_Package:delete()
end

function FactionState:Event_OnConfirmSelfArrest()
	local bailcosts = 0
	local wantedLevel = client:getWanteds()
	local jailTime = wantedLevel * JAIL_TIME_PER_WANTED_BAIL
	local factionBonus = JAIL_COSTS[wantedLevel]
	bailcosts = BAIL_PRICES[wantedLevel]
	client:setJailTime(jailTime)
	client:setWanteds(0)
	client:moveToJail(CUTSCENE)
	self:uncuffPlayer(client)
	client:clearCrimes()
	bailcosts = BAIL_PRICES[wantedLevel]
	client:setJailBail(bailcosts)
	StatisticsLogger:getSingleton():addArrestLog(client, wantedLevel, jailTime, client, bailcosts)
	self:sendMessage("Der Spieler "..client:getName().." hat sich gestellt!", 0, 0,200)
end

function FactionState:loadLSPD(factionId)
	self:createDutyPickup(252.6, 69.4, 1003.64, 6) -- PD Interior
	self:createDutyPickup(1530.21, -1671.66, 6.22, 0, 5) -- PD Garage

	self:createTakeItemsPickup(Vector3(1543.96, -1707.26, 5.59), 0, 5)

	local blip = Blip:new("Police.png", 1552.278, -1675.725, root, 400, {factionColors[factionId].r, factionColors[factionId].g, factionColors[factionId].b})
		blip:setDisplayText(FactionManager:getSingleton():getFromId(factionId):getName(), BLIP_CATEGORY.Faction)

	--VehicleBarrier:new(Vector3(1544.70, -1630.90, 13.10), Vector3(0, 90, 90)).onBarrierHit = bind(self.onBarrierGateHit, self) -- PD Barrier
	local barrier = Gate:new(968, Vector3(1544.70, -1630.90, 13.1), Vector3(0, 90, 90), Vector3(1544.70, -1630.90, 13.1), Vector3(0, 5, 90), false)
	barrier.onGateHit = bind(self.onBarrierGateHit, self)  -- PD Barrier

	local gate = Gate:new(3055, Vector3(1588.5042, -1637.8517, 14.58093), Vector3(0, 0, 0), Vector3(1588.5039, -1639.1016, 16.52393), Vector3(80, 0, 0))
	gate.onGateHit = bind(self.onBarrierGateHit, self) -- PD Garage Gate
	gate:setGateScale(1.01)
	gate:addGate(3055, Vector3(1588.5042, -1637.8517, 14.58093), Vector3(0, 0, 0), Vector3(1588.5039, -1639.1016, 16.52393), Vector3(80, 0, 0), false, 0, 5, 1.01)

	--[[local gate2 = Gate:new(3055, Vector3(1597.288, -1665.1272, 7.0712), Vector3(0, 0, 0), Vector3(1597.288, -1665.1272, 9.0712), Vector3(80, 0, 0), true, 0, 5)
	gate2.onGateHit = bind(self.onBarrierGateHit, self) -- PD Garage Gate
	gate2:setGateScale(1.0285093)
	gate2:addGate(3055, Vector3(1597.288, -1665.1272, 7.0712), Vector3(0, 0, 0), Vector3(1597.288, -1665.1272, 9.0712), Vector3(80, 0, 0), false, 0, 0, 1.0285093)
	]]
	createColCuboid( 1582.064, -1665.5, 5.080, 21.7, 27.6, 13):setData("NonCollidingSphere", "ignoreDimension", true) -- nc area inside garage to prevent cars from spawning inside each other

	local door = Door:new(2949, Vector3(1584.09, -1638.09, 12.30), Vector3(0, 0, 270))
	door.onDoorHit = bind(self.onBarrierGateHit, self) -- PD Garage Gate
	door:setDoorScale(1.1)
	door:addDoor( 2949, Vector3(1584.09, -1638.09, 12.30), Vector3(0, 0, 270),  false, 0, 5, 1.1)
	--InteriorEnterExit:new(Vector3(1525.16, -1678.17, 5.89), Vector3(259.22, 73.73, 1003.64), 0, 0, 6, 0) -- LSPD Garage
	--InteriorEnterExit:new(Vector3(1564.84, -1666.84, 28.40), Vector3(226.65, 75.95, 1005.04), 0, 0, 6, 0) -- LSPD Roof

	local elevator = Elevator:new()
	elevator:addStation("Dach - Heliports", Vector3(1564.84, -1666.84, 28.40), 90, 0, 0)
	elevator:addStation("Erdgeschoss", Vector3(259.22, 73.73, 1003.64), 84, 6, 0, 5)
	elevator:addStation("UG Garage", Vector3(1525.16, -1678.17, 5.89), 270, 0, 5)



	local safe = createObject(2332, 1559.90, -1647.80, 17, 0, 0, 90)
	FactionManager:getSingleton():getFromId(factionId):setSafe(safe)
end

function FactionState:loadFBI(factionId)
	self:createDutyPickup(275.85, -40.26, 1032.20, 10) -- FBI Interior
	self:createDutyPickup(1214.813, -1813.902, 16.594) -- FBI backyard

	local blip = Blip:new("Police.png", 1209.32, -1748.02, {factionType = "State"}, 400, {factionColors[factionId].r, factionColors[factionId].g, factionColors[factionId].b})
		blip:setDisplayText(FactionManager:getSingleton():getFromId(factionId):getName(), BLIP_CATEGORY.Faction)

	local safe = createObject(2332, 294.43, -22.6, 1031.7)
	safe:setInterior(10)
	FactionManager:getSingleton():getFromId(1):setSafe(safe)

	local elevator = Elevator:new()
	elevator:addStation("Heliport", Vector3(1242, -1777.0996, 33.7), 270)
	elevator:addStation("Erdgeschoss", Vector3(296.49, -36.23, 1032.20), 90, 10)

	self:createTakeItemsPickup(Vector3(1215.7, -1822.8, 13))

	local gateLeft = Gate:new(988, Vector3(1211, -1841.9004, 13.4), Vector3(0, 0, 0), Vector3(1206, -1841.9004, 13.4))
	gateLeft.onGateHit = bind(self.onBarrierGateHit, self)
	gateLeft:addGate(988, Vector3(1216.5, -1841.9004, 13.4), Vector3(0, 0, 0), Vector3(1221.9004, -1841.9004, 13.4))

	local gateRight = Gate:new(988, Vector3(1267.4, -1841.9004, 13.4), Vector3(0, 0, 0), Vector3(1262, -1841.9004, 13.4))
	gateRight.onGateHit = bind(self.onBarrierGateHit, self)
	gateRight:addGate(988, Vector3(1272.9004, -1841.9004, 13.4), Vector3(0, 0, 0), Vector3(1277.9004, -1841.9004, 13.4))

	for i,v in pairs(gateLeft:getGateObjects()) do
		VehicleTexture:new(v, "files/images/Textures/Faction/State/FBI_Logo.png", "ws_airsecurity", true)
	end
	for i,v in pairs(gateRight:getGateObjects()) do
		VehicleTexture:new(v, "files/images/Textures/Faction/State/FBI_Logo.png", "ws_airsecurity", true)
	end

	InteriorEnterExit:new(Vector3(1211.5996, -1750.0996, 13.6), Vector3(267.03, -23.87, 1032.20), 220, 0, 10) -- main entrance
	InteriorEnterExit:new(Vector3(1219.20, -1812.25, 16.59), Vector3(259.91, -74.91, 1037.35), 0, 180, 10) -- back entrance / parking lot
end

function FactionState:loadArmy(factionId)
	self:createDutyPickup(2743.75, -2453.81, 13.86) -- Army-LS
	self:createDutyPickup(247.05, 1859.38, 14.08) -- Army Area

	self:createTakeItemsPickup(Vector3(134.356, 1850.466, 17.692))

	local blip = Blip:new("Police.png", 134.53, 1929.06, {factionType = "State"}, 400, {factionColors[factionId].r, factionColors[factionId].g, factionColors[factionId].b})
		blip:setDisplayText(FactionManager:getSingleton():getFromId(factionId):getName(), BLIP_CATEGORY.Faction)

	local safe = createObject(2332, 242.38, 1862.32, 14.08, 0, 0, 0 )
	FactionManager:getSingleton():getFromId(1):setSafe(safe)

	local areaGate = Gate:new(974, Vector3(135.10, 1941.30, 21.60), Vector3(0, 0, 0), Vector3(122.30, 1941.30, 21.60))
	--areaGate:addGate(971, Vector3(139.2, 1934.8, 19.1), Vector3(0, 0, 180), Vector3(139.3, 1934.8, 13.7))
	areaGate.m_Gates[1]:setDoubleSided(true)
	areaGate.onGateHit = bind(self.onBarrierGateHit, self)


	local areaGateBack = Gate:new(974, Vector3(286.5, 1821.5, 19.90), Vector3(0, 0, 90), Vector3(286.5, 1834, 19.90))
	areaGateBack.m_Gates[1]:setDoubleSided(true)
	areaGateBack.onGateHit = bind(self.onBarrierGateHit, self)

	local areaGarage = Gate:new(2929, Vector3(211.9, 1875.35, 13.94), Vector3(0, 0, 0), Vector3(207.9, 1875.35, 13.94))
	areaGarage:addGate(2927, Vector3(215.9, 1875.35, 13.94), Vector3(0, 0, 0), Vector3(219.9, 1875.35, 13.94))
		areaGarage.onGateHit = bind(self.onBarrierGateHit, self)
end

function FactionState:createTakeItemsPickup(pos, int, dim)
	local pickup = createPickup(pos, 3, 1238, 0)
	pickup:setInterior(int or 0 )
	pickup:setDimension(dim or 0)
	addEventHandler("onPickupHit", pickup, function(hitElement)
		if hitElement:getType() == "player" then
			if hitElement.vehicle then
				if hitElement:isFactionDuty() and hitElement:getFaction() and hitElement:getFaction():isStateFaction() == true then
					local veh = hitElement.vehicle
					if instanceof(veh, FactionVehicle) and veh:getFaction():isStateFaction() then
						hitElement:triggerEvent("showStateItemGUI")
						triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, 0, self.m_Items)
					else
						hitElement:sendError(_("Ungültiges Fahrzeug!", hitElement))
					end
				else
					hitElement:sendError(_("Du bist nicht im Dienst!", hitElement))
				end
			else
				hitElement:sendError(_("Du brauchst ein Fahrzeug zum einladen!", hitElement))
			end
		end
	end)
end


function FactionState:countPlayers(afkCheck, dutyCheck)
	local count = #self:getOnlinePlayers(afkCheck, dutyCheck)
	return count
end

function FactionState:Command_ticket(source, cmd, target)
	if target then
		if type(target) == "string" then
			local targetPlayer = PlayerManager:getSingleton():getPlayerFromPartOfName(target, source)
			if targetPlayer then
				local faction = source:getFaction()
				if not faction then return end
				if not faction:isStateFaction() then return end
				if source:isFactionDuty() then
					if getDistanceBetweenPoints3D(source:getPosition(), targetPlayer:getPosition()) <= 5 then
						if source ~= targetPlayer then
							if targetPlayer:getWanteds() <= 3 then
								if targetPlayer:getMoney() >= TICKET_PRICE*targetPlayer:getWanteds() + 500 then
									source.m_CurrentTicket = targetPlayer
									targetPlayer:triggerEvent("stateFactionOfferTicket", source)
									source:sendSuccess(_("Du hast %s ein Ticket für %d$ angeboten!", source,  targetPlayer:getName(), TICKET_PRICE*targetPlayer:getWanteds()+500 ))
								else
									source:sendError(_("%s hat nicht genug Geld dabei! (%d$)", source, targetPlayer:getName(),  TICKET_PRICE*targetPlayer:getWanteds()+500 ))
								end
							else
								source:sendError("Der Spieler hat kein oder ein zu hohes Fahndungslevel!")
							end
						else
							source:sendError("Du kannst dir kein Ticket anbieten!")
						end
					else
						source:sendError("Du bist zu weit weg!")
					end
				else
					source:sendError("Du bist nicht im Dienst!")
				end
			else
				source:sendError("Ziel nicht gefunden!")
			end
		end
	else outputChatBox("Syntax: Für Staatsbeamte -> /ticket [ziel]", source, 200, 0,0)
	end
end

function FactionState:Event_OnTicketAccept(cop)
	if client then
		if client:getMoney() >=  TICKET_PRICE*client:getWanteds()+500  then
			if client:getWanteds() <= 3 then
				if cop and isElement(cop) then
					cop:sendSuccess(_("%s hat dein Ticket angenommen und bezahlt!", cop, client:getName()))
					self.m_BankAccountServer:transferMoney(cop:getFaction(),  TICKET_PRICE*client:getWanteds()+500 , "Ticket", "Faction", "Ticket")
				end
				client:sendSuccess(_("Du hast das Ticket angenommen! Dir wurde(n) %s Wanted(s) erlassen!", client, client:getWanteds()))
				client:transferMoney(self.m_BankAccountServer,  TICKET_PRICE*client:getWanteds()+500 , "[SAPD] Kautionsticket", "Faction", "Ticket")
				client:setWanteds(0)
			end
		end
	end
end

function FactionState:Command_cuff( source, cmd, target )
	if target then
		if type(target) == "string" then
			local targetPlayer = PlayerManager:getSingleton():getPlayerFromPartOfName(target, source)
			if targetPlayer then
				if getDistanceBetweenPoints3D(source:getPosition(), targetPlayer:getPosition()) <= 5 then
					local faction = source:getFaction()
					if faction then
						if faction:isStateFaction() then
							if source ~= targetPlayer then
								if source:isFactionDuty() then
									if not targetPlayer.vehicle then
										if not targetPlayer:isStateCuffed() then
											source.m_CurrentCuff = targetPlayer
											source:triggerEvent("factionStateStartCuff", targetPlayer)
											targetPlayer:triggerEvent("CountdownStop",  10, "Gefesselt in")
											targetPlayer:triggerEvent("Countdown", 10, "Gefesselt in")
											source:triggerEvent("CountdownStop", 10, "Gefesselt in")
											source:triggerEvent("Countdown", 10, "Gefesselt in")
										else
											source:sendError("Der Spieler ist bereits gefesselt!")
										end
									else
										source:sendError("Du kommst nicht an den Spieler heran!")
									end
								else
									source:sendError("Du bist nicht im Dienst!")
								end
							else
								source:sendError("Du kannst dich nicht selbst fesseln!")
							end
						else
							source:sendError("Du hast keine Handschellen dabei!")
						end
					end
				else
					source:sendError("Du bist zu weit weg!")
				end
			else
				source:sendError("Ziel nicht gefunden!")
			end
		end
	else outputChatBox("Syntax: /cuff [ziel]", source, 200, 0,0)
	end
end

function FactionState:Command_uncuff( source, cmd, target )
	if target then
		if type(target) == "string" then
			local targetPlayer = PlayerManager:getSingleton():getPlayerFromPartOfName(target, source)
			if targetPlayer then
				if getDistanceBetweenPoints3D(source:getPosition(), targetPlayer:getPosition()) <= 5 then
					local faction = source:getFaction()
					if faction then
						if source ~= targetPlayer then
							if faction:isStateFaction() then
								if source:isFactionDuty() then
									if targetPlayer:isStateCuffed() then
										self:uncuffPlayer(targetPlayer)
										source:meChat(true,"nimmt die Handschellen von "..targetPlayer:getName().." ab!")
										targetPlayer:triggerEvent("updateCuffImage", false)
									else
										source:sendError("Der Spieler ist nicht gefesselt!")
									end
								else
									source:sendError("Du hast keine Handschellen dabei!")
								end
							else
								source:sendError("Du hast keine Handschellen dabei!")
							end
						end
					else
						source:sendError("Du kannst dich nicht selbst entfesseln!")
					end
				else
					source:sendError("Du bist zu weit weg!")
				end
			else
				source:sendError("Ziel nicht gefunden!")
			end
		end
	else outputChatBox("Syntax: /uncuff [ziel]", source, 200, 0,0)
	end
end

function FactionState:uncuffPlayer( player)
	toggleControl(player, "sprint", true)
	toggleControl(player, "jump", true)
	toggleControl(player, "fire", true)
	toggleControl(player, "aim_weapon", true)
	player:triggerEvent("updateCuffImage", false)
	player:setStateCuffed(false)
	setPedWalkingStyle(player, 0)
end

function FactionState:Event_CuffSuccess( target )
	if client then
		if client.m_CurrentCuff == target then
			if getDistanceBetweenPoints3D(target:getPosition() , client:getPosition()) <= 5 then
				if not target.vehicle then
					toggleControl(target, "sprint", false)
					toggleControl(target, "jump", false)
					toggleControl(target, "fire", false)
					toggleControl(target, "aim_weapon", false)
					target:setStateCuffed(true)
					setPedWalkingStyle(target, 123)
					source:meChat(true,"legt "..target:getName().." Handschellen an!")
					source:triggerEvent("CountdownStop", "Gefesselt in", 10)
					target:triggerEvent("CountdownStop", "Gefesselt in", 10)
					target:triggerEvent("updateCuffImage", true)
				end
			end
		end
	end
end

function FactionState:addLog(player, category, text)
	FactionManager:getSingleton().Map[1]:addLog(player, category, text)
	FactionManager:getSingleton().Map[2]:addLog(player, category, text)
	FactionManager:getSingleton().Map[3]:addLog(player, category, text)
end

function FactionState:getOnlinePlayers(afkCheck, dutyCheck)
	local factions = self:getFactions()
	local players = {}
	for index,faction in pairs(factions) do
		for index, value in pairs(faction:getOnlinePlayers(afkCheck, dutyCheck)) do
			table.insert(players, value)
		end
	end
	return players
end

function FactionState:giveKarmaToOnlineMembers(karma, reason)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:giveKarma(karma)
		player:sendShortMessage(_("%s\nDu hast %d Karma erhalten!", player, reason, karma), "Karma")
	end
end

function FactionState:getFactions()
	local factions = FactionManager:getSingleton():getAllFactions()
	local returnFactions = {}
	for i, faction in pairs(factions) do
		if faction:isStateFaction() then
			table.insert(returnFactions, faction)
		end
	end
	return returnFactions
end

function FactionState:onBarrierGateHit(player)
    if player:getFaction() and player:getFaction():isStateFaction() then
		return true
	else
		return false
	end
end

function FactionState:createDutyPickup(x,y,z,int, dim)
	self.m_DutyPickup = createPickup(x,y,z, 3, 1275) --PD
	setElementInterior(self.m_DutyPickup, int or 0)
	setElementDimension ( self.m_DutyPickup, dim or 0)
	addEventHandler("onPickupHit", self.m_DutyPickup,
		function(hitElement)
			if getElementType(hitElement) == "player" and not hitElement.vehicle then
				local faction = hitElement:getFaction()
				if faction then
					if faction:isStateFaction() == true then
						hitElement.m_CurrentDutyPickup = source
						hitElement:getFaction():updateDutyGUI(hitElement)
					end
				end
			end
			cancelEvent()
		end
	)
end

function FactionState:createArrestZone(x, y, z, int, dim)
	local pickup = createPickup(x,y,z, 3, 2680)
	local col = createColSphere(x,y,z, 4)
	if int then
		pickup:setInterior(int)
		col:setInterior(int)
	end

	if dim then
		pickup:setDimension(dim)
		col:setDimension(dim)
	end
	addEventHandler("onPickupHit", pickup,
	function(hitElement)
		if getElementType(hitElement) == "player" then
			local faction = hitElement:getFaction()
			if faction then
				if faction:isStateFaction() == true then
					if hitElement:isFactionDuty() then
						hitElement:triggerEvent("showStateFactionArrestGUI", col)
					end
				end
			end
		end
		cancelEvent()
	end
	)
end

function FactionState:createEvidencePickup( x,y,z, int, dim )
	local pickup = createPickup(x,y,z,3, 2061, 10)
	setElementInterior(pickup, int)
	setElementDimension(pickup, dim)
	self.m_EvidenePickup = pickup
	addEventHandler("onPickupUse", pickup, function( hitElement )
		local dim = source:getDimension() == hitElement:getDimension()
		if hitElement:getType() == "player" and dim then
			if hitElement:getFaction() and hitElement:getFaction():isStateFaction() and hitElement:isFactionDuty() then
				hitElement.evidencePickup = source
				self:showEvidenceStorage( hitElement )
			else
				hitElement:sendError(_("Nur für Staatsfraktionisten im Dienst!", hitElement))
			end
		end
	end)
end

function FactionState:getFullCategoryFromShurtcut(category)
	local bMatch = false

	if string.lower(category) == "auto" or string.lower(category) == "pkw" then
		category = "Driving"
		bMatch = true
	elseif string.lower(category) == "motorrad" or string.lower(category) == "mt" then
		category = "Bike"
		bMatch = true
	elseif string.lower(category) == "lastkraftwagen" or string.lower(category) == "lkw" then
		category = "Truck"
		bMatch = true
	elseif string.lower(category) == "pilot" or string.lower(category) == "flug" then
		category = "Pilot"
		bMatch = true
	end

	if bMatch then
		return category
	end
end

function FactionState:getFullReasonFromShortcut(reason)
	local amount = false
	if string.lower(reason) == "bs" or string.lower(reason) == "wn" then
        reason = "Beschuss/Waffennutzung"
        amount = 3
    elseif string.lower(reason) == "db" then
        reason = "Drogenbesitz (>= 10 Gramm)"
        amount = 1
    elseif string.lower(reason) == "db2" then
        reason = "Drogenbesitz (>= 50 Gramm)"
        amount = 2
    elseif string.lower(reason) == "db3" then
        reason = "Drogenbesitz (>= 150 Gramm)"
        amount = 3
    elseif string.lower(reason) == "br" then
        reason = "Banküberfall"
        amount = 6
	 elseif string.lower(reason) == "mord" then
        reason = "Mord"
        amount = 4
    elseif string.lower(reason) == "wt" then
        reason = "Waffen-Truck"
        amount = 5
	elseif string.lower(reason) == "gt" then
        reason = "Geldtransport-Überfall"
        amount = 5
    elseif string.lower(reason) == "dt" then
        reason = "Drogen-Truck"
        amount = 5
    elseif string.lower(reason) == "swt" then
        reason = "Staatswaffentruck-Überfall"
        amount = 6
    elseif string.lower(reason) == "illad" then
        reason = "Illegale Werbung"
        amount = 1
    elseif string.lower(reason) == "kpv" then
        reason = "Körperverletzung"
        amount = 2
    elseif string.lower(reason) == "garage" or string.lower(reason) == "pdgarage" then
        reason = "Einbruch-in-die-PD-Garage"
        amount = 3
    elseif string.lower(reason) == "wd" then
        reason = "Waffen-Drohung"
        amount = 2
    elseif string.lower(reason) == "bh" then
        reason = "Beihilfe einer Straftat"
        amount = false
    elseif string.lower(reason) == "vw" then
        reason = "Verweigerung-zur-Durchsuchung"
        amount = 2
    elseif string.lower(reason) == "bb" or string.lower(reason) == "beleidigung" then
        reason = "Beamtenbeleidigung"
        amount = 1
    elseif string.lower(reason) == "flucht" or string.lower(reason) == "fvvk" or string.lower(reason) == "vk" then
        reason = "Flucht aus Kontrolle"
        amount = 2
    elseif string.lower(reason) == "bv" then
        reason = "Befehlsverweigerung"
        amount = 1
    elseif string.lower(reason) == "sb" then
        reason = "Sachbeschädigung"
        amount = 1
    elseif string.lower(reason) == "rts" then
        reason = "Shop-Überfall"
        amount = 3
    elseif string.lower(reason) == "haus" then
        reason = "Hauseinbruch"
        amount = 3
    elseif string.lower(reason) == "eöä" then
        reason = "Erregung öffentlichen Ärgernisses"
        amount = 1
    elseif string.lower(reason) == "vd" then
        reason = "versuchter Diebstahl"
        amount = 1
    elseif string.lower(reason) == "fof" then
        reason = "Fahren ohne Führerschein"
        amount = 1
    elseif string.lower(reason) == "gn" then
        reason = "Geiselnahme"
        amount = 6
    elseif string.lower(reason) == "stellen" then
        reason = "Stellenflucht"
        amount = 12
	end
	return reason, amount
end

function FactionState:sendShortMessage(text, ...)
	for k, player in pairs(self:getOnlinePlayers()) do
		if player:isFactionDuty() then
			player:sendShortMessage(_(text, player), "Staat", {11, 102, 8}, ...)
		end
	end
end

function FactionState:sendWarning(text, header, withOffDuty, pos, ...)
	for k, player in pairs(self:getOnlinePlayers(false, not withOffDuty)) do
		player:sendWarning(_(text, player, ...), 30000, header)
	end
	if pos and pos.x then pos = {pos.x, pos.y, pos.z} end -- serialiseVector conversion
	if pos and pos[1] and pos[2] then
		local blip = Blip:new("Alarm.png", pos[1], pos[2], {factionType = "State", duty = (withOffDuty and nil or true)}, 4000, BLIP_COLOR_CONSTANTS.Orange)
			blip:setDisplayText(header)
		if pos[3] then
			blip:setZ(pos[3])
		end
		setTimer(function()
			blip:delete()
		end, 30000, 1)
	end
end

function FactionState:sendMessage(text, r, g, b, ...)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function FactionState:sendStateChatMessage(sourcePlayer, message)
	local faction = sourcePlayer:getFaction()
	if faction and faction:isStateFaction() == true then
		local playerId = sourcePlayer:getId()
		local rank = faction:getPlayerRank(playerId)
		local rankName = faction:getRankName(rank)
		local r,g,b = 200, 100, 100
		local receivedPlayers = {}
		local text = ("%s %s: %s"):format(rankName,getPlayerName(sourcePlayer), message)
		for k, player in pairs(self:getOnlinePlayers()) do
			player:sendMessage(text, r, g, b)
			if player ~= sourcePlayer then
				receivedPlayers[#receivedPlayers+1] = player
			end
		end
		StatisticsLogger:getSingleton():addChatLog(sourcePlayer, "state", message, receivedPlayers)
	end
end

function FactionState:outputMegaphone(player, ...)
	local faction = player:getFaction()
	if faction and faction:isStateFaction() == true then
		if player:isFactionDuty() then
			if player:getOccupiedVehicle() and player:getOccupiedVehicle():getFaction() and player:getOccupiedVehicle():isStateVehicle() then
				local playerId = player:getId()
				local playersToSend = player:getPlayersInChatRange(3)
				local receivedPlayers = {}
				local text = ("[[ %s %s: %s ]]"):format(faction:getShortName(), player:getName(), table.concat({...}, " "))
				for index = 1,#playersToSend do
					playersToSend[index]:sendMessage(text, 255, 255, 0)
					if playersToSend[index] ~= player then
						receivedPlayers[#receivedPlayers+1] = playersToSend[index]
					end
				end

				StatisticsLogger:getSingleton():addChatLog(player, "chat", text, receivedPlayers)
				FactionState:getSingleton():addBugLog(player, "(Megafon)", text)
				return true
			else
				player:sendError(_("Du sitzt in keinem Fraktions-Fahrzeug!", player))
			end
		else
			player:sendError(_("Du bist nicht im Dienst!", player))
		end
	end
	return false
end

function FactionState:Command_suspect(player,cmd,target,amount,...)
	if player:isFactionDuty() and player:getFaction() and player:getFaction():isStateFaction() == true then
		local reason, wAmount = self:getFullReasonFromShortcut(table.concat({...}, " "))
		local reason2, wAmount2
		if amount then
			if not tonumber(amount) then
				reason2, wAmount2 = self:getFullReasonFromShortcut(amount)
				if reason2 and wAmount2 then
					reason = reason2
					amount = wAmount2
				end
			end
		end
		amount = tonumber(amount)
		if amount and amount >= 1 and amount <= MAX_WANTED_LEVEL  then
			local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
			if isElement(target) then
				if not isPedDead(target) then
					if string.len(reason) > 2 and string.len(reason) < 50 then
						target:giveWanteds(amount)
						outputChatBox(("Verbrechen begangen: %s, %s Wanted/s, Gemeldet von: %s"):format(reason,amount,player:getName()), target, 255, 255, 0 )
						local msg = ("%s hat %s %d Wanted/s wegen %s gegeben!"):format(player:getName(),target:getName(),amount, reason)
						player:getFaction():addLog(player, "Wanteds", "hat "..target:getName().." "..amount.." Wanteds wegen "..reason.." gegeben!")
						self:sendMessage(msg, 255,0,0)
					else
						player:sendError(_("Der Grund ist ungültig!", player))
					end
				else
					player:sendError(_("Der Spieler ist tot!", player))
				end
			end
		else
			player:sendError(_("Die Anzahl muss zwischen 1 und %s liegen!", player, MAX_WANTED_LEVEL))
		end
	else
		player:sendError(_("Du bist nicht im Dienst!", player))
	end
end

function FactionState:Command_stvo(player, cmd, target, category, amount,...)
	if player:isFactionDuty() and player:getFaction() and player:getFaction():isStateFaction() == true then
		local amount = tonumber(amount)
		if amount and amount >= 1 and amount <= 6 then
			local reason = table.concat({...}, " ")
			local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
			if isElement(target) then
				if string.len(reason) > 2 and string.len(reason) < 50 then
					category = self:getFullCategoryFromShurtcut(category)
					if category then
						local newSTVO = target:getSTVO(category) + amount
						target:setSTVO(category, newSTVO)
						outputChatBox(("Du hast %d STVO-Punkt/e von %s erhalten! Gesamt: %d"):format(amount, player:getName(), newSTVO), target, 255, 255, 0 )
						outputChatBox(("Grund: %s"):format(reason), target, 255, 255, 0 )

						local msg = ("%s hat %s %d STVO-Punkt/e wegen %s gegeben!"):format(player:getName(),target:getName(),amount, reason)
						player:getFaction():addLog(player, "STVO", "hat "..target:getName().." "..amount.." STVO-Punkte wegen "..reason.." gegeben!")
						self:sendMessage(msg, 255,0,0)
					else
						player:sendError(_("Die Kategorie ist ungültig!", player))
					end
				else
					player:sendError(_("Der Grund ist ungültig!", player))
				end
			end
		else
			player:sendError(_("Die Anzahl muss zwischen 1 und 6 liegen!", player))
		end
	else
		player:sendError(_("Du bist nicht im Dienst!", player))
	end
end

function FactionState:Event_giveSTVO(target, category, amount, reason)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			local newSTVO = target:getSTVO(category) + amount
			target:setSTVO(category, newSTVO)
			outputChatBox(("Du hast %d STVO-Punkt/e von %s erhalten! Gesamt: %d"):format(amount, client:getName(), newSTVO), target, 255, 255, 0)
			outputChatBox(("Grund: %s"):format(reason), target, 255, 255, 0 )
			local msg = ("%s hat %s %d STVO-Punkt/e wegen %s gegeben!"):format(client:getName(),target:getName(),amount, reason)
			client:getFaction():addLog(client, "STVO", "hat "..target:getName().." "..amount.." STVO-Punkte wegen "..reason.." gegeben!")
			self:sendMessage(msg, 255,0,0)
		end
	end
end

function FactionState:Event_setSTVO(target, category, amount, reason)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			local newSTVO = tonumber(amount)
			target:setSTVO(category, newSTVO)
			outputChatBox(("%s hat deine STVO-Punkt/e auf %d gesetzt!"):format(client:getName(), newSTVO), target, 255, 255, 0 )
			outputChatBox(("Grund: %s"):format(reason), target, 255, 255, 0 )
			local msg = ("%s hat die STVO-Punkte von %s auf %d gesetzt! Grund: %s"):format(client:getName(),target:getName(),amount, reason)
			client:getFaction():addLog(client, "STVO", "die STVO-Punkte von "..target:getName().." auf "..amount.." gesetzt! Grund: "..reason.."!")
			self:sendMessage(msg, 255,0,0)
		end
	end
end

function FactionState:getGrabbedPlayersInVehicle(vehicle)
	local temp = {}
	for k, player in pairs(vehicle:getOccupants()) do
		if player.isGrabbedInVehicle then
			table.insert(temp, player)
		end
	end
	return temp
end

function FactionState:Command_tie(player, cmd, tname, bool, force)
	local faction = player:getFaction()
	if faction and faction:isStateFaction() then
		if player:isFactionDuty() then
			local vehicle = player:getOccupiedVehicle()
			if force == true or (player:getOccupiedVehicle() and vehicle and isElement(vehicle) and vehicle.getFaction and vehicle:getFaction() and vehicle:isStateVehicle()) then
				if tname then
					local target = PlayerManager:getSingleton():getPlayerFromPartOfName(tname, player)
					if isElement(target) then
						if target == player then
							player:sendError(_("Du kannst dich nicht selbst fesseln!", player))
							return
						end
						if force == true or (target:getOccupiedVehicle() and target:getOccupiedVehicle() == vehicle) then
							if not target.isGrabbedInVehicle or (force and bool) then
								target.isGrabbedInVehicle = true
								target:setData("isTied", true, true)
								toggleControl(target, "fire", false) -- this is not working sometimes >_>

								if not vehicle.eventStartExit then
									vehicle.eventStartExit = true
									addEventHandler("onVehicleStartExit", vehicle, self.onTiedExitBind)
								end

								if not force then
									player:sendInfo(_("Du hast %s gefesselt", player, target:getName()))
									target:sendInfo(_("Du wurdest von %s gefesselt", target, player:getName()))
								end
							else
								target.isGrabbedInVehicle = false
								target:setData("isTied", false, true)
								toggleControl(target, "fire", true)

								-- only remove, when no grabbed players are in the vehicle
								if #self:getGrabbedPlayersInVehicle(vehicle) == 0 then
									removeEventHandler("onVehicleStartExit", vehicle, self.onTiedExitBind)
									vehicle.eventStartExit = false
								end

								if not force then
									player:sendInfo(_("Du hast %s entfesselt", player, target:getName()))
									target:sendInfo(_("Du wurdest von %s entfesselt", target, player:getName()))
								end
							end
						else
							player:sendError(_("Der Spieler ist nicht in deinem Fahrzeug!", player))
						end
					end
				else
					player:sendError(_("Kein Ziel angegeben! Befehl: /tie [NAME]!", player))
				end
			else
				player:sendError(_("Du sitzt in keinem Fraktions-Fahrzeug!", player))
			end
		else
			player:sendError(_("Du bist nicht im Dienst!", player))
		end
	end
end

function FactionState:onTiedExit(exitingPlayer, seat, jacked, door)
	if exitingPlayer.isGrabbedInVehicle then
		cancelEvent()
	end
end

function FactionState:Command_needhelp(player)
	local faction = player:getFaction()
	local player = player
	if faction and faction:isStateFaction() then
		if player:isFactionDuty() then
			if player:getInterior() == 0 and player:getDimension() == 0 then
				if player.m_ActiveNeedHelp then return false end
				player.m_ActiveNeedHelp = true
				local rankName = faction:getRankName(faction:getPlayerRank(player))
				local color = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
				local blip = Blip:new("Marker.png", player.position.x, player.position.y, {factionType = "State", duty = true}, 9999, color)
					blip:setDisplayText(player.name)
					blip:attach(player)

				for k, onlinePlayer in pairs(self:getOnlinePlayers(true, true)) do
					onlinePlayer:sendShortMessage(_("%s %s benötigt Unterstützung!", onlinePlayer, rankName, player:getName()), "Unterstützungseinheit erforderlich", color, 20000)
				end

				setTimer(function()
					blip:delete()
					if isElement(player) then
						player.m_ActiveNeedHelp = false
					end
				end, 20000, 1)
			else
				player:sendError(_("Du kannst hier keine Hilfe anfordern!", player))
			end
		else
			player:sendError(_("Du bist nicht im Dienst!", player))
		end
	else
		player:sendError(_("Du bist in keiner Staatsfraktion!", player))
	end
end

function FactionState:Event_JailPlayer(player, bail, CUTSCENE, police, force, pFactionBonus, offline, isoCell)
	if player:getWanteds() == 0 then return end
	local policeman = police or client
	if not force then
		if policeman:getFaction() and policeman:getFaction():isStateFaction() then
			if policeman:isFactionDuty() then
				if player:getWanteds() > 0 then
					local bailcosts = 0
					local wantedLevel = player:getWanteds()
					local jailTime = wantedLevel * JAIL_TIME_PER_WANTED_ARREST
					local factionBonus = JAIL_COSTS[wantedLevel]

					if player:getFaction() and player:getFaction():isEvilFaction() then
						factionBonus = JAIL_COSTS[wantedLevel]/2
					end

					if bail then
						bailcosts = BAIL_PRICES[wantedLevel]
						player:setJailBail(bailcosts)
						jailTime = wantedLevel * JAIL_TIME_PER_WANTED_BAIL
					end
					if offline then
						jailTime = wantedLevel * JAIL_TIME_PER_WANTED_OFFLINE
					end


					if policeman.vehicle and player.vehicle then
						self:Command_tie(policeman, "tie", player:getName(), false, true)
					end
					local mon = player:getMoney()
					if mon < factionBonus then
						local bankM = player:getBankMoney()
						local remainMoney = factionBonus - mon
						player:transferMoney(self.m_BankAccountServer, mon, "Knaststrafe (Bar)", "Faction", "Arrest")
						if remainMoney > bankM then
							player:transferMoney(self.m_BankAccountServer, bankM, "Knaststrafe (Bank)", "Faction", "Arrest")
						else
							player:transferMoney(self.m_BankAccountServer, remainMoney, "Knaststrafe (Bank)", "Faction", "Arrest")
						end
					else
						player:transferMoney(self.m_BankAccountServer, factionBonus, "Knaststrafe (Bar)", "Faction", "Arrest")
					end

					player:takeKarma(wantedLevel)
					player:setJailTime(jailTime)
					player:setWanteds(0)
					player:moveToJail(CUTSCENE, isoCell)
					self:uncuffPlayer(player)
					player:clearCrimes()

					local DrugItems = self.ms_IllegalItems
					local inv = player:getInventory()
					for index, item in pairs(DrugItems) do
						if inv:getItemAmount(item) > 0 then
							inv:removeAllItem(item)
						end
					end

					-- Pay some money to faction and karma, xp to the policeman
					self.m_BankAccountServer:transferMoney(policeman:getFaction(), factionBonus, "Arrest", "Faction", "Arrest")
					policeman:giveKarma(wantedLevel)
					policeman:givePoints(wantedLevel)
					PlayerManager:getSingleton():sendShortMessage(_("%s wurde soeben von %s für %d Minuten eingesperrt! Strafe: %d$", player, player:getName(), policeman:getName(), jailTime, factionBonus), "Staat")
					StatisticsLogger:getSingleton():addArrestLog(player, wantedLevel, jailTime, policeman, bailcosts)
					policeman:getFaction():addLog(policeman, "Knast", "hat "..player:getName().." für "..jailTime.."min. eingesperrt!")
					-- Give Achievements
					if wantedLevel > 4 then
						policeman:giveAchievement(48)
					else
						policeman:giveAchievement(47)
					end

					setTimer(function (player) -- (delayed)
						if isElement(player) then player:giveAchievement(31) end
					end, 14000, 1, player)

				else
					policeman:sendError(_("Der Spieler wird nicht gesucht!", player))
				end
			else
				policeman:sendError(_("Du bist nicht im Dienst!", player))
			end
		end
	else
		local bailcosts = 0
		local wantedLevel = player:getWanteds()
		local jailTime = wantedLevel * JAIL_TIME_PER_WANTED_ARREST
		local factionBonus = JAIL_COSTS[wantedLevel]
		if player:getFaction() and player:getFaction():isEvilFaction() then
			factionBonus = JAIL_COSTS[wantedLevel]/2
		end
		if bail then
			bailcosts = BAIL_PRICES[wantedLevel]
			player:setJailBail(bailcosts)
			jailTime = wantedLevel * JAIL_TIME_PER_WANTED_BAIL
		end
		if policeman then
			if policeman.vehicle and player.vehicle then
				self:Command_tie(policeman, "tie", player:getName(), false, true)
			end
		end
		local mon = player:getMoney()
		if mon < factionBonus then
			local bankM = player:getBankMoney()
			local remainMoney = factionBonus - mon
			player:transferMoney(self.m_BankAccountServer, mon, "Knast Strafe (Bar)", "Faction", "Arrest")
			if remainMoney > bankM then
				player:transferBankMoney(self.m_BankAccountServer, bankM, "Knast Strafe (Bank)", "Faction", "Arrest")
			else
				player:transferBankMoney(self.m_BankAccountServer, remainMoney, "Knast Strafe (Bank)", "Faction", "Arrest")
			end
		else
			player:transferMoney(self.m_BankAccountServer, factionBonus, "Knast Strafe (Bar)", "Faction", "Arrest")
		end
		player:takeKarma(wantedLevel)
		player:setJailTime(jailTime)
		player:setWanteds(0)
		player:moveToJail(CUTSCENE, isoCell)
		self:uncuffPlayer(player)
		player:clearCrimes()
		setTimer(function (player) -- (delayed)
			if isElement(player) then player:giveAchievement(31) end
		end, 14000, 1, player)
		player.m_DeathInJail = nil
	end
end

function FactionState:Command_bail(player)
	if player.m_JailTimer then
		if player.m_Bail and player.m_JailTime then
			if player.m_Bail > 0 then
				local money = player:getBankMoney()
				if money >= player.m_Bail then

					player:transferBankMoney({FactionManager:getSingleton():getFromId(1), nil, true}, player.m_Bail, "Kaution", "Faction", "Bail")

					player:sendInfo(_("Sie haben sich mit der Kaution von %s$ freigekauft!", player, player.m_Bail))
					player.m_Bail = 0
					self:freePlayer(player)
				else
					player:sendError("Sie haben nicht genügend Geld!")
				end
			end
		end
	end
end

function FactionState:Event_onPlayerExitVehicle(vehicle, seat)
	if instanceof(vehicle, FactionVehicle) and vehicle:getFaction():isStateFaction() then
		if source.m_SpeedCol then
			if isElement(source.m_SpeedCol) then
				delete(source.m_SpeedCol)
				setElementData(source, "speedCamEnabled", false)
			end
			if isElement(source.m_SpeedCol) then
				destroyElement(source.m_SpeedCol)
				setElementData(source, "speedCamEnabled", false)
			end
			source.m_SpeedCol = false
		end
	end
end

function FactionState:Event_OnSpeedColShapeHit(hE, bDim)
	if bDim then
		local bType = getElementType(hE) == "vehicle"
		if bType then
			local bOcc = getVehicleOccupant(hE)
			if bOcc then
				local cop = source.m_Owner
				if cop then
					local copVehicle = getPedOccupiedVehicle(cop)
					if copVehicle then
						if copVehicle ~= hE then
							if instanceof(copVehicle, FactionVehicle) and copVehicle:getFaction():isStateFaction() then
								if hE.m_LastSpeedTrap then
									if hE.m_LastSpeedTrap + 7000 > getTickCount() then
										return
									end
								end
								local actualspeed = hE.getSpeed and hE:getSpeed() or 0
								local maxSpeed = source.m_SpeedLimit or 80
								if actualspeed > maxSpeed then
									local secondOccupant = getVehicleOccupant(copVehicle,1)
									cop:triggerEvent("SpeedCam:showSpeeder", actualspeed, hE)
									if secondOccupant and secondOccupant:getFaction() and secondOccupant:getFaction():isStateFaction() then
										secondOccupant:triggerEvent("SpeedCam:showSpeeder", actualspeed, hE)
										secondOccupant.m_LastVehicle = hE
									end
								end
								hE.m_LastSpeedTrap = getTickCount()
							else
								destroyElement(source)
							end
						end
					else
						destroyElement(source)
					end
				else
					destroyElement(source)
				end
			end
		end
	end
end

function FactionState:Event_speedRadar()
	if (client.m_Faction:isStateFaction() == true and client:getFaction() and client:getFaction():isStateFaction() == true) then
		local stateVehicle = client.vehicle
		if stateVehicle then
			if instanceof(stateVehicle, FactionVehicle) and stateVehicle:getFaction():isStateFaction() then
				if client.vehicleSeat == 0 then
					if not client.m_SpeedCol then
						local x, y, z = getElementPosition(stateVehicle)
						client.m_SpeedCol = createColSphere(x, y, z, radarRange)
						attachElements(client.m_SpeedCol, stateVehicle,0,22)
						client.m_SpeedCol.m_Owner = client
						addEventHandler("onColShapeHit",client.m_SpeedCol, self.m_onSpeedColHit)
						playSoundFrontEnd(client, 101)
						client:sendInfo("Radarfalle ist angeschaltet!")
						setElementData(stateVehicle, "speedCamEnabled", true)
					else
						playSoundFrontEnd(client, 101)
						if isElement(client.m_SpeedCol) then
							delete(client.m_SpeedCol)
						end
						if isElement(client.m_SpeedCol) then
							destroyElement(client.m_SpeedCol)
						end
						client.m_SpeedCol = false
						client:sendInfo("Radarfalle ist ausgeschaltet!")
						setElementData(stateVehicle, "speedCamEnabled", false)
					end
				end
			end
		end
	end
end

function FactionState:freePlayer(player, prisonBreak)
	if prisonBreak then
		player:sendShortMessage("Du bist aus dem Gefängnis ausgebrochen!")
		self:sendShortMessage(player:getName().." ist aus dem Gefängnis ausgebrochen!")
	else
		setElementDimension(player,0)
		setElementInterior(player,0)
		player:setPosition(267.40, 77.75, 1001.04)
		player:setInterior(6)
		player:setRotation(0, 0, 180)
		player:setWanteds(0)
	end

	player:setData("inJail",false, true)
	player:toggleControl("fire", true)
	player:toggleControl("jump", true)
	player:toggleControl("aim_weapon ", true)
	player:toggleControl("enter_exit ", true)
	if isTimer(player.m_JailTimer) then
		killTimer( player.m_JailTimer )
	end
	player.m_JailTimer = nil
	player.m_JailStart = nil
	player:setJailTime(0)
	player.m_Bail = 0
	player:setCorrectSkin()
	player:triggerEvent("playerLeftJail")
	player:triggerEvent("checkNoDm")
end

function FactionState:Event_FactionRearm()
	if not self:isPlayerInDutyPickup(client) then return client:sendError(_("Du bist zu weit entfernt!", client)) end
	if client:isFactionDuty() then
		client.m_WeaponStoragePosition = client.position
		client:triggerEvent("showFactionWeaponShopGUI")
		client:setHealth(100)
		client:setArmor(100)
		local wStorage, aStorage
		for i = 1,12 do
			wStorage, aStorage = Guns:getSingleton():getWeaponInStorage( client, i)
			if wStorage then
				Guns:getSingleton():setWeaponInStorage(client, wStorage, false)
			end
		end
		local inv = client:getInventory()
		if inv then
			inv:removeAllItem("Einsatzhelm")
			inv:giveItem("Einsatzhelm",1)
		end
	end
end

function FactionState:isPlayerInDutyPickup(player)
	if not player.m_CurrentDutyPickup then return false end
	return getDistanceBetweenPoints3D(player.position, player.m_CurrentDutyPickup.position) <= 10
end

function FactionState:Event_toggleDuty(wasted, preferredSkin)
	if wasted then client:removeFromVehicle() end

	if getPedOccupiedVehicle(client) then
		return client:sendError("Steige erst aus dem Fahrzeug aus!")
	end
	local faction = client:getFaction()
	if faction:isStateFaction() then
		if self:isPlayerInDutyPickup(client) or wasted then
			if client:isFactionDuty() then
				if wasted then
					--client:takeAllWeapons()
					takeAllWeapons(client) -- due to attached weapons
				else
					self:Event_storageWeapons(client)
					takeAllWeapons(client) -- due to attached weapons
				end
				client:setCorrectSkin()
				client:setFactionDuty(false)
				client:sendInfo(_("Du bist nicht mehr im Dienst!", client))
				client:getInventory():removeAllItem("Taser")
				client:getInventory():removeAllItem("Warnkegel")
				client:getInventory():removeAllItem("Barrikade")
				client:getInventory():removeAllItem("Nagel-Band")
				client:getInventory():removeAllItem("Blitzer")
				client:getInventory():removeAllItem("Einsatzhelm")
				if not wasted then faction:updateDutyGUI(client) end
				Guns:getSingleton():setWeaponInStorage(client, false, false)
			else
				if client:getPublicSync("Company:Duty") and client:getCompany() then
					client:sendWarning(_("Bitte beende zuerst deinen Dienst im Unternehmen!", client))
					return false
				end
				client:setFactionDuty(true)
				faction:changeSkin(client, preferredSkin)
				client:setHealth(100)
				client:setArmor(100)
				takeAllWeapons(client)
				Guns:getSingleton():setWeaponInStorage(client, false, false)
				client:sendInfo(_("Du bist nun im Dienst!", client))
				client:getInventory():removeAllItem("Warnkegel")
				client:getInventory():giveItem("Warnkegel", 5)
				client:getInventory():removeAllItem("Einsatzhelm")
				client:getInventory():giveItem("Einsatzhelm", 1)
				client:getInventory():removeAllItem("Taser")
				client:getInventory():giveItem("Taser", 1)
				if not wasted then faction:updateDutyGUI(client) end
			end
		else
			client:sendError(_("Du bist zu weit entfernt!", client))
		end
	else
		client:sendError(_("Du bist in keiner Staatsfraktion!", client))
		return false
	end
end

function FactionState:Event_storageWeapons(player, ignoreDutyCheck) -- ignoreDutyCheck if for when the player gets revived by medics
	local client = client
	if player then
		client = player
	end
	if not self:isPlayerInDutyPickup(client) then return client:sendError(_("Du bist zu weit entfernt!", client)) end
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() or ignoreDutyCheck then

			--switch tazer if it is being used
			local weapon = getPedWeapon(client, 2)
			if weapon == 23 then
				ItemManager.Map["Taser"]:use(client)
			end
			--storage weapons
			local depot = faction:getDepot()
			local logData = {}
			for i= 1, 12 do
				if client:getWeapon(i) > 0 then
					local weaponId = client:getWeapon(i)
					local clipAmmo = getWeaponProperty(weaponId, "pro", "maximum_clip_ammo") or 0
					if WEAPON_CLIPS[weaponId] then
						clipAmmo = WEAPON_CLIPS[weaponId]
					end

					local magazines = clipAmmo > 0 and math.floor(client:getTotalAmmo(i)/clipAmmo) or 0

					local depotWeapons, depotMagazines = faction:getDepot():getWeapon(weaponId)
					local depotMaxWeapons, depotMaxMagazines = faction.m_WeaponDepotInfo[weaponId]["Waffe"], faction.m_WeaponDepotInfo[weaponId]["Magazine"]
					if depotWeapons+1 <= depotMaxWeapons then
						if magazines > 0 and depotMagazines + magazines <= depotMaxMagazines then
							depot:addWeaponD(weaponId, 1)
							depot:addMagazineD(weaponId, magazines)
							takeWeapon(client, weaponId)
							logData[WEAPON_NAMES[weaponId]] = magazines
						elseif magazines > 0 then
							local magsToMax = depotMaxMagazines - depotMagazines
							depot:addMagazineD(weaponId, magsToMax)
							setWeaponAmmo(client, weaponId, getPedTotalAmmo(client, i) - magsToMax*clipAmmo)
							logData[WEAPON_NAMES[weaponId]] = magsToMax
							client:sendError(_("Im Depot ist nicht Platz für %s %s Magazin/e! Es wurden nur %s Magazine eingelagert.", client, magazines, WEAPON_NAMES[weaponId], magsToMax))
						end

					else
						client:sendError(_("Im Depot ist nicht Platz für eine/n %s!", client, WEAPON_NAMES[weaponId]))
					end
				end
			end
			local textForPlayer = "Du hast folgende Waffen in das Lager gelegt:"
			local wepaponsPut = false
			for i,v in pairs(logData) do
				wepaponsPut = true
				textForPlayer = textForPlayer.."\n"..i
				if v > 0 then
					textForPlayer = textForPlayer.. " mit ".. v .. " Magazin(en)"
					faction:addLog(client, "Waffenlager", ("hat ein/e(n) %s mit %s Magazin(en) in das Lager gelegt!"):format(i, v))
				else
					faction:addLog(client, "Waffenlager", ("hat ein/e(n) %s in das Lager gelegt!"):format(i))
				end
			end
			if wepaponsPut then client:sendInfo(textForPlayer) end
		end
	end
end

-- Area 51
function FactionState:createDefendActors(Actors)
	for i, v in pairs(Actors or {}) do
		local actor = DefendActor:new(v[1], v[3], v[4], v[5])
		actor:setRotation(v[2])
		actor:setFrozen(true)
		actor.onAttackRangeHit = function (actor, ele)
			if ele then
				local ele = ele
				if ele:getType() == "vehicle" or ele:getType() == "player" then
					if ele:getType() == "vehicle" then
						ele = ele:getOccupant()
						if not ele then -- Do not attack emtpy vehicles
							return true
						end
					end
					if ele:getType() == "player" then
						if ele:getFaction() and ele:getFaction():isStateFaction() then
							return true
						end
					end
				else
					return true -- Only attack Vehicles and Players
				end
			end

			return false
		end
	end
end

function FactionState:checkLogout(player)
	local pos = player:getPosition()
	local col = createColSphere(pos, 20)
	local colPlayers = getElementsWithinColShape(col, "player")
	col:destroy()
	for index, cop in pairs(colPlayers) do
		if cop:getFaction() and cop:getFaction():isStateFaction() and cop:isFactionDuty() and not cop:isDead() then
			if player:getInterior() == cop:getInterior() and player:getDimension() == cop:getDimension() then
				self:Event_JailPlayer(player, false, false, cop, false, false, true)
				player:addOfflineMessage( "Sie wurden offline eingesperrt! Die Knast ist dadurch länger!", 1)
				return
			end
		end
	end

end

function FactionState:Event_giveWanteds(target, amount, reason)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			target:giveWanteds(amount)
			outputChatBox(("Verbrechen begangen: %s, %s Wanted/s, Gemeldet von: %s"):format(reason, amount, client:getName()), target, 255, 255, 0 )
			local msg = ("%s hat %s %d Wanted/s wegen %s gegeben!"):format(client:getName(), target:getName(), amount, reason)
			faction:addLog(client, "Wanteds", "hat "..target:getName().." "..amount.." Wanted/s gegeben! Grund: "..reason)
			self:sendMessage(msg, 255,0,0)
		end
	end
end

function FactionState:Event_clearWanteds(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			target:takeWanteds(MAX_WANTED_LEVEL)
			outputChatBox(("Dir wurden alle Wanteds von %s erlassen"):format(client:getName()), target, 255, 255, 0 )
			local msg = ("%s hat %s alle Wanteds erlassen!"):format(client:getName(), target:getName())
			faction:addLog(client, "Wanteds", "hat "..target:getName().." alle Wanteds erlassen!")
			self:sendMessage(msg, 255,0,0)
		end
	end
end

function FactionState:Event_grabPlayer(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			local vehicle = client:getOccupiedVehicle()
			if client:getOccupiedVehicle() and vehicle and isElement(vehicle) and vehicle.getFaction and vehicle:isStateVehicle() then
				if target.isTasered == true and not target:isDead() then
					for seat = 1, getVehicleMaxPassengers(vehicle) do
						if not vehicle:getOccupant(seat) then
							warpPedIntoVehicle(target, vehicle, seat)
							client:sendInfo(_("%s wurde in dein Fahrzeug gezogen!", client, target:getName()))
							target:sendInfo(_("Du wurdest von %s in das Fahrzeug gezogen!", target, client:getName()))
							self:Command_tie(client, "tie", target:getName(), true, true)
							return
						end
					end
					client:sendError(_("Du hast keinen Platz in deinem Fahrzeug!", client))
				else
					client:sendError(_("Der Spieler ist nicht getazert oder Tod!", client))
				end
			else
				client:sendError(_("Du sitzt in keinem Fraktions-Fahrzeug!", client))
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_friskPlayer(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			if (target.vehicle or client.vehicle) and client.vehicle ~= target.vehicle then
				client:sendError(_("So kannst du den Spieler nicht durchsuchen!", target))
				return
			end

			target:sendInfo(_("Der Staatsbeamte %s durchsucht dich!", target, client:getName()))

			local DrugItems = self.ms_IllegalItems
			local inv = target:getInventory()
			local targetDrugs = {}
			for index, item in pairs(DrugItems) do
				if inv:getItemAmount(item) > 0 then
					targetDrugs[item] = inv:getItemAmount(item)
				end
			end

			local targetWeapons = {}
			for i = 0, 12 do
				if getPedWeapon(target, i) > 0 then
					targetWeapons[getPedWeapon(target, i)] = getPedTotalAmmo(target, i)
				end
			end

			client:triggerEvent("showFriskGUI", target, targetWeapons, targetDrugs)
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_alcoholTest(target)
local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			if (target.vehicle or client.vehicle) and client.vehicle ~= target.vehicle then
				client:sendError(_("Du kannst den Spieler nicht in einem Fahrzeug auf Alkohol testen!", target))
				return
			end
			client:meChat(true, ("führt einen Alkoholtest an %s durch!"):format(target:getName()))
			target:meChat(true, "pustet in das Röhrchen des Alkohol-Schnelltesters...")
			setTimer(function(player, target)
				player:sendInfo(_("Du hast einen Alkoholtest an %s durchgeführt!\nErgebnis: %s Promille", player, target:getName(), target.m_AlcoholLevel))
				target:sendInfo(_("%s hat einen Alkoholtest an dir durchgeführt!\nErgebnis: %s Promille", target, player:getName(), target.m_AlcoholLevel))
			end, 2000, 1, client, target)
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_showLicenses(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			QuestionBox:new(client, target, _("Staatsbeamter %s fordert dich auf deinen Führerschein zu zeigen! Zeigst du ihm deinen Führerschein?", client, getPlayerName(client)), "factionStateAcceptShowLicense", "factionStateDeclineShowLicense", client, target)
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_acceptShowLicense(player, target)
	player:triggerEvent("showIDCard", target)
	target:meChat(true, _("nickt.", target))
	player:meChat(true, _("sieht sich den Führerschein von %s an.", player, target:getName()))
end

function FactionState:Event_declineShowLicense(player, target)
	target:meChat(true, _("schüttelt den Kopf.", target))
end

function FactionState:Event_givePANote(target, note)
	local faction = client:getFaction()
	if faction and faction:getId() == 3 then
		if client:isFactionDuty() then
			if faction:getPlayerRank(client) < FactionRank.Manager then
				client:sendError(_("Du bist nicht berechtig GWD-Noten auszuteilen!", client))
				return
			end
			if client == target then
				client:sendError(_("Du darfst dir nicht selber eine GWD-Noten setzen!", client))
				return
			end
			if note > 0 and note <= 100 then
				target:sendInfo(_("%s hat dir eine GWD-Note von %d gegeben!", target, client:getName(), note))
				client:sendInfo(_("Du hast %s eine GWD-Note von %d gegeben!", client, target:getName(), note))
				target:setPaNote(note)
				client:getFaction():addLog(player, "GWD", ("%s hat %s eine GWD-Note von %d gegeben!"):format(client:getName(), target:getName(), note))
			else
				client:sendError(_("Ungültige GWD-Note!", client))
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	else
		client:sendError(_("Du bist nicht im MBT!", client))
	end
end

function FactionState:Event_takeDrugs(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			local DrugItems = self.ms_IllegalItems
			client:sendMessage(_("Du hast %s folgende illegale Items abgenommen:", client, target:getName()), 255, 255, 0)
			target:sendMessage(_("%s hat dir folgende illegale Items abgenommen:", target, client:getName()), 255, 255, 0)
			local drugsTaken = false
			local amount = 0
			local inv = target:getInventory()
			for index, item in pairs(DrugItems) do
				if inv:getItemAmount(item) > 0 then
					amount = inv:getItemAmount(item)
					drugsTaken = true
					client:sendMessage(_("%d %s", client, amount, item), 255, 125, 0)
					target:sendMessage(_("%d %s", target, amount, item), 255, 125, 0)
					inv:removeAllItem(item)
				end
			end
			if not drugsTaken then
				client:sendMessage(_("Keine", client), 255, 125, 0)
				target:sendMessage(_("Keine", target), 255, 125, 0)
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_takeWeapons(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			client:sendMessage(_("Du hast %s entwaffnet!", client, target:getName()), 255, 255, 0)
			target:sendMessage(_("%s hat dich entwaffnet!", target, client:getName()), 255, 255, 0)
			takeAllWeapons(target)
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_putItemInVehicle(itemName, amount, inventory)
	if client.vehicle or inventory then
		if client:isFactionDuty() and client:getFaction() and client:getFaction():isStateFaction() == true then
			local veh = inventory and source or client.vehicle
			if veh:getFaction() and veh:getFaction():isStateFaction() then
				veh:loadFactionItem(client, itemName, amount, inventory)
			else
				client:sendError(_("Ungültiges Fahrzeug!", client))
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	else
		client:sendError(_("Du brauchst ein Fahrzeug zum einladen!", client))
	end
end

function FactionState:Event_takeItemFromVehicle(itemName)
	if client:isFactionDuty() and client:getFaction() and client:getFaction():isStateFaction() == true then
		local veh = source
		if veh:getFaction() and veh:getFaction():isStateFaction() then
			veh:takeFactionItem(client, itemName)
		else
			client:sendError(_("Ungültiges Fahrzeug!", client))
		end
	else
		client:sendError(_("Du bist nicht im Dienst!", client))
	end
end

function FactionState:Event_loadJailPlayers()
	local players = {}
	for index, playeritem in pairs(getElementsByType("player")) do
		if playeritem.m_JailTime and playeritem.m_JailTimer and playeritem.m_JailTime > 0 then
			local timeLeft = playeritem.m_JailTimer:getDetails()/1000/60
			players[playeritem] = ("%.1f / %smin"):format(timeLeft, playeritem.m_JailTime)
		end
	end
	client:triggerEvent("receiveJailPlayers", players)
end

function FactionState:Event_freePlayer(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() and faction:getPlayerRank(client) >= FactionRank.Rank3 then
			if target and isElement(target) then
				outputChatBox(("Du wurdest von %s aus dem Knast entlassen!"):format(client:getName()), target, 255, 255, 0 )
				local msg = ("%s hat %s aus dem Knast entlassen!"):format(client:getName(), target:getName())
				self:sendMessage(msg, 255,0,0)
				faction:addLog(client, "Knast", "hat "..target:getName().." aus dem Knast entlassen!")
				self:freePlayer(target)
			else
				client:sendError(_("Spieler nicht gefunden!", client))
			end
		else
			client:sendError(_("Du bist nicht berechtigt! Ab Rang %d!", client, FactionRank.Rank3))
		end
	end
end

function FactionState:addBugLog(player, func, msg)
	self:refreshBugs()
	if not self:isBugActive() then return end
	local range = CHAT_TALK_RANGE

	if func == "flüstert" then
		range = CHAT_WHISPER_RANGE
	elseif func == "schreit" then
		range = CHAT_SCREAM_RANGE
	end

	for id, bugData in pairs(self.m_Bugs) do
		if bugData["element"] and isElement(bugData["element"]) then
			if (player:getPosition() - bugData["element"]:getPosition()).length < range then
				if getTickCount() - self.m_Bugs[id]["lastMessage"] >= 300000 then
					self:sendShortMessage("Wanze "..id.." hat etwas empfangen!\n(Drücke F4)")
				end

				local logId = #self.m_Bugs[id]["log"]+1
				self.m_Bugs[id]["log"][logId] = player:getName().." "..func..": "..msg
				self.m_Bugs[id]["lastMessage"] = getTickCount()
			end
		end
	end

end

function FactionState:Event_loadBugs()
	self:refreshBugs()
	client:triggerEvent("receiveBugs", self.m_Bugs)
end

function FactionState:refreshBugs()
	for id, bugData in pairs(self.m_Bugs) do
		if bugData["element"] and isElement(bugData["element"]) then
			bugData["active"] = true
		else
			self.m_Bugs[id] = {}
		end
	end
end

function FactionState:getFreeBug()
	for id, bugData in ipairs(self.m_Bugs) do
		if not bugData["active"] or bugData["active"] == false then
			return id
		end
	end
	return false
end

function FactionState:isBugActive()
	for id, bugData in pairs(self.m_Bugs) do
		if bugData["active"] and bugData["active"] == true then
			return true
		end
	end
	return false
end

function FactionState:Event_attachBug()
	self:refreshBugs()
	local id = self:getFreeBug()
	if id then
		local typeName = source:getType() == "vehicle" and "Fahrzeug" or "Spieler"

		self.m_Bugs[id] = {
			["element"] = source,
			["log"] = {},
			["active"] = true,
			["lastMessage"] = 0,
		}
		source.BugId = id
		source:setData("Wanze", true, true)
		client:triggerEvent("receiveBugs", self.m_Bugs)
		self:sendShortMessage(client:getName().." hat Wanze "..id.." an ein/en "..typeName.." angebracht!")
	else
		client:sendError(_("Alle verfügbaren Wanzen sind aktiv!", client))
	end
end

function FactionState:addWeaponToEvidence( cop, weaponID, weaponAmmo, factionID, noMessage)
	if self.m_EvidenceRoomItems then
		if #self.m_EvidenceRoomItems < STATEFACTION_EVIDENCE_MAXITEMS  then
			local type_ = "Waffe"
			local copName = "Unbekannt"
			local timeStamp =  getRealTime().timestamp
			if isElement(cop) then
				copName = getPlayerName(cop)
			end
			sql:queryExec("INSERT INTO ??_StateEvidence (Type, Var1, Var2, Var3, Cop, Date) VALUES(?, ?, ?, ?, ?, ?)",
				sql:getPrefix(), type_, weaponID, weaponAmmo, factionID or 0, copName, timeStamp)
			if not noMessage then self:sendShortMessage(copName.." hat eine Waffe mit "..weaponAmmo.." Schuss konfesziert!") end
			self.m_EvidenceRoomItems[#self.m_EvidenceRoomItems+1] = {type_, weaponID, weaponAmmo, factionID or "keine", copName, timeStamp}
		else
			self:sendShortMessage("Die Asservatenkammer ist voll, die Waffe konnte nicht mehr eingelagert werden!")
		end
	end
end

function FactionState:showEvidenceStorage(player)
	if player then
		if player:isFactionDuty() and player:getFaction() and player:getFaction():isStateFaction() then
			player:triggerEvent("State:sendEvidenceItems", self.m_EvidenceRoomItems)
		end
	end
end

function FactionState:Event_startEvidenceTruck()
	if client:isFactionDuty() and client:getFaction() and client:getFaction():isStateFaction() then
		if ActionsCheck:getSingleton():isActionAllowed(client) then
			local evObj, weapon, weaponAmmo, weaponMoney, ammoMoney
			local totalMoney = 0
			for i = 1, #self.m_EvidenceRoomItems do
				evObj = self.m_EvidenceRoomItems[i]
				if evObj and evObj[1] and evObj[1] == "Waffe" then
					weapon = evObj[2]
					weaponAmmo = evObj[3]
					if weapon then
						weapon = tonumber(weapon)
						if AmmuNationInfo[weapon] then
							weaponMoney  = AmmuNationInfo[weapon].Weapon
							ammoMoney  = math.floor((AmmuNationInfo[weapon].Magazine.price*weaponAmmo) / AmmuNationInfo[weapon].Magazine.amount)
						else
							weaponMoney = 500
							ammoMoney = 0
						end
						if weaponMoney and ammoMoney then
							totalMoney = totalMoney + (weaponMoney + ammoMoney)
						end
					end
				end
			end
			if totalMoney > 0 then
				ActionsCheck:getSingleton():setAction("Geldtransport")
				FactionState:getSingleton():sendMoveRequest(TSConnect.Channel.STATE)
				StateEvidenceTruck:new(client, totalMoney)
				PlayerManager:getSingleton():breakingNews("Ein Geld-Transporter ist unterwegs! Bitte bleiben Sie vom Transport fern!")
				Discord:getSingleton():outputBreakingNews("Ein Geld-Transporter ist unterwegs! Bitte bleiben Sie vom Transport fern!")
				self:sendShortMessage(client:getName().." hat einen Geldtransport gestartet!",10000)
				sql:queryExec("TRUNCATE TABLE ??_StateEvidence",sql:getPrefix())
				self.m_EvidenceRoomItems = {}
				triggerClientEvent(root,"State:clearEvidenceItems", root)
			else
				client:sendError(_("In der Asservatenkammer befindet sich zuwenig Material!", client))
			end
		end
	end
end

function FactionState:Event_bugAction(action, id)
	if self.m_Bugs[id] then
		if action == "disable" then
			self.m_Bugs[id]["element"].BugId = nil
			self.m_Bugs[id]["element"]:setData("Wanze", false, true)

			self.m_Bugs[id] = {}
			self:sendShortMessage(client:getName().." hat Wanze "..id.." deaktiviert!")
		elseif action == "clearLog" then
			self.m_Bugs[id]["log"] = {}
			client:sendSuccess(_("Du hast den Log der Wanze %d gelöscht!", client, id))
		end
		client:triggerEvent("receiveBugs", self.m_Bugs)
	else
		client:sendError(_("Wanze nicht verfügbar!", client))
	end
end

function FactionState:Event_checkBug(element)
	local checkElement = client
	local text = _("deinem Körper", client)
	local price = 25
	if element then
		checkElement = element
		text = _("deinem Fahrzeug", client)
		price = 50
	end
	if client:getMoney() >= price then
		client:transferMoney(CompanyManager:getSingleton():getFromId(CompanyStaticId.MECHANIC), price, "Wanzen-Check", "Company", "BugCheck")
		if checkElement:getData("Wanze") == true and checkElement.BugId then
			local id = checkElement.BugId
			self.m_Bugs[id]["element"].BugId = nil
			self.m_Bugs[id]["element"]:setData("Wanze", false, true)
			self.m_Bugs[id] = {}
			self:sendShortMessage("Wanze "..id.." wurde entdeckt und entfernt!")
			client:sendShortMessage(_("Oha! Ich habe eine Wanze von %s entfernt!", client, text))
		else
			client:sendShortMessage(_("Ich habe keine Wanze an %s gefunden!", client, text))
		end
	else
		client:sendError(_("Du hast nicht genug Geld dabei! (%d$)", client, price))
	end
end

function FactionState:sendMoveRequest(targetChannel, text)
	for k, faction in pairs(self:getFactions()) do
		faction:sendMoveRequest(targetChannel, text)
	end
end
